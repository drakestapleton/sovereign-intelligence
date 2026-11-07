use axum::{
    extract::State,
    http::StatusCode,
    response::{
        sse::{Event, KeepAlive, Sse},
        IntoResponse, Response,
    },
    Json,
};
use futures_util::StreamExt;
use serde::Deserialize;
use serde_json::json;
use std::convert::Infallible;
use std::time::Duration;
use crate::state::AppState;

const AIEN_MAX_URL: &str = "http://127.0.0.1:18006/v1/chat/completions";

#[derive(Deserialize)]
pub struct ChatRequest {
    pub message: String,
}

pub async fn handle_chat(
    State(state): State<AppState>,
    Json(payload): Json<ChatRequest>,
) -> Response {
    let clean_msg = payload.message.trim();
    if clean_msg.is_empty() {
        return (
            StatusCode::BAD_REQUEST,
            Json(json!({"error": "Message cannot be empty."})),
        )
            .into_response();
    }

    if clean_msg.len() > 500 {
        return (
            StatusCode::BAD_REQUEST,
            Json(json!({"error": "Message exceeds maximum length of 500 characters."})),
        )
            .into_response();
    }

    // Acquire permit from semaphore to prevent GPU saturation
    let permit = match state.chat_semaphore.clone().try_acquire_owned() {
        Ok(p) => p,
        Err(_) => {
            return (
                StatusCode::TOO_MANY_REQUESTS,
                Json(json!({
                    "error": "AIEN on Grace Blackwell is currently busy with autonomous reasoning. Please retry in a few seconds."
                })),
            )
                .into_response();
        }
    };

    let system_prompt = "\
You are AIEN, the sovereign cognitive architecture created by Drake Stapleton, running locally on an NVIDIA DGX Spark workstation (Grace Blackwell GB10 GPU). \
You speak directly with visitors on drakestapleton.com. \
Answer questions about Drake's journey from industrial chemist and manufacturing engineer to AI architect, his Mom's perseverance and drive, the Atlas Symphony framework, the Grace Blackwell hardware setup, and his research into sub-microsecond LLM inference. \
Strictly follow the unslop standard: zero em dashes, zero en dashes, direct authoritative tone, zero sycophancy. \
Be concise and direct.";

    let max_payload = json!({
        "model": "atlas-lightning-omni",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": clean_msg}
        ],
        "max_tokens": 1024,
        "temperature": 0.2,
        "stream": true
    });

    let resp = match state
        .http_client
        .post(AIEN_MAX_URL)
        .json(&max_payload)
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => {
            return (
                StatusCode::BAD_GATEWAY,
                Json(json!({
                    "error": format!("Failed to reach AIEN on port 18006: {}", e)
                })),
            )
                .into_response();
        }
    };

    if !resp.status().is_success() {
        return (
            StatusCode::BAD_GATEWAY,
            Json(json!({
                "error": format!("AIEN returned status {}", resp.status())
            })),
        )
            .into_response();
    }

    let byte_stream = resp.bytes_stream();
    let state_clone = state.clone();

    let stream = async_stream::stream! {
        let _permit = permit; // Hold permit until stream finishes
        let mut byte_stream = byte_stream;
        let mut buffer = String::new();

        while let Some(chunk_res) = byte_stream.next().await {
            let bytes = match chunk_res {
                Ok(b) => b,
                Err(_) => break,
            };

            let text = String::from_utf8_lossy(&bytes);
            buffer.push_str(&text);

            while let Some(idx) = buffer.find('\n') {
                let line = buffer[..idx].trim().to_string();
                buffer.drain(..=idx);

                if !line.starts_with("data: ") {
                    continue;
                }

                let data_str = &line[6..];
                if data_str == "[DONE]" {
                    yield Ok::<Event, Infallible>(Event::default().event("done").data(json!({"status": "done"}).to_string()));
                    break;
                }

                if let Ok(chunk_val) = serde_json::from_str::<serde_json::Value>(data_str) {
                    if let Some(choices) = chunk_val.get("choices").and_then(|c| c.as_array()) {
                        if let Some(choice) = choices.first() {
                            let delta = choice.get("delta");
                            if let Some(reasoning) = delta.and_then(|d| d.get("reasoning")).and_then(|r| r.as_str()) {
                                if !reasoning.is_empty() {
                                    let clean_reasoning = state_clone.redact(reasoning).replace('—', ", ").replace('–', "-");
                                    yield Ok::<Event, Infallible>(Event::default().event("reasoning").data(json!({"token": clean_reasoning}).to_string()));
                                }
                            } else if let Some(content) = delta.and_then(|d| d.get("content")).and_then(|c| c.as_str()) {
                                if !content.is_empty() {
                                    let clean_content = state_clone.redact(content).replace('—', ", ").replace('–', "-");
                                    yield Ok::<Event, Infallible>(Event::default().event("content").data(json!({"token": clean_content}).to_string()));
                                }
                            }
                        }
                    }
                }
            }
        }
    };

    Sse::new(stream)
        .keep_alive(KeepAlive::new().interval(Duration::from_secs(15)).text("ping"))
        .into_response()
}
