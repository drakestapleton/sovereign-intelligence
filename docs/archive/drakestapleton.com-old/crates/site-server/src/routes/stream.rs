use axum::{
    extract::State,
    response::{
        sse::{Event, KeepAlive, Sse},
        Json,
    },
};
use futures_util::stream::Stream;
use std::convert::Infallible;
use std::time::Duration;
use crate::state::AppState;
use crate::telemetry::TelemetryPacket;

pub async fn get_telemetry(State(state): State<AppState>) -> Json<TelemetryPacket> {
    let current = state.latest_telemetry.read().await.clone();
    Json(current)
}

pub async fn stream_telemetry(
    State(state): State<AppState>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let mut rx = state.telemetry_tx.subscribe();
    let stream = async_stream::stream! {
        while let Ok(packet) = rx.recv().await {
            let json_str = serde_json::to_string(&packet).unwrap_or_default();
            yield Ok(Event::default().event("telemetry").data(json_str));
        }
    };

    Sse::new(stream).keep_alive(KeepAlive::new().interval(Duration::from_secs(15)).text("ping"))
}
