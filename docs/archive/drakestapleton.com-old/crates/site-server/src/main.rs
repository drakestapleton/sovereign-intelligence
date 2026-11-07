mod agent_status;
mod routes;
mod state;
mod telemetry;

use axum::{routing::{get, post}, Router};
use std::net::SocketAddr;
use std::path::Path;
use std::time::Duration;
use tower_http::compression::CompressionLayer;
use tower_http::cors::{Any, CorsLayer};
use tower_http::services::ServeDir;

use crate::state::AppState;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let port = std::env::var("PORT")
        .ok()
        .and_then(|p| p.parse::<u16>().ok())
        .unwrap_or(18090);

    let dist_dir_str = std::env::var("DIST_DIR").unwrap_or_else(|_| "dist".to_string());
    let dist_dir = Path::new(&dist_dir_str);

    println!("============================================================");
    println!("  Drake Stapleton Sovereign Full-Stack Rust Server          ");
    println!("  Host: NVIDIA DGX Spark (Grace Blackwell GB10)             ");
    println!("  Target Port: {}                                           ", port);
    println!("  Cache Directory: {}                                       ", dist_dir.display());
    println!("============================================================");

    let state = match AppState::new(dist_dir) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("[FATAL] Failed to initialize AppState: {}", e);
            std::process::exit(1);
        }
    };

    println!("[INIT] Cached {} static routes in Spark RAM.", state.routes.len());

    let telemetry_state = state.clone();
    tokio::spawn(async move {
        let mut interval = tokio::time::interval(Duration::from_secs(2));
        loop {
            interval.tick().await;
            let (active_goal, latest_milestone) = agent_status::get_active_goal_and_milestone();
            let packet = telemetry::sample_telemetry(
                telemetry_state.start_time,
                &active_goal,
                &latest_milestone,
            );

            {
                let mut lock = telemetry_state.latest_telemetry.write().await;
                *lock = packet.clone();
            }

            let _ = telemetry_state.telemetry_tx.send(packet);
        }
    });

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let assets_dir = dist_dir.join("assets");
    let images_dir = dist_dir.join("images");
    let public_js_dir = dist_dir.join("js");

    let app = Router::new()
        .route("/api/health", get(routes::health::health_check))
        .route("/api/chat", post(routes::chat::handle_chat))
        .route("/api/live/stream", get(routes::stream::stream_telemetry))
        .route("/api/live/telemetry", get(routes::stream::get_telemetry))
        .nest_service("/assets", ServeDir::new(assets_dir))
        .nest_service("/images", ServeDir::new(images_dir))
        .nest_service("/js", ServeDir::new(public_js_dir))
        .fallback(routes::pages::serve_page)
        .layer(CompressionLayer::new())
        .layer(cors)
        .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    let listener = tokio::net::TcpListener::bind(addr).await?;
    println!("[ONLINE] Sovereign Rust server listening on http://{}", addr);

    axum::serve(listener, app.into_make_service())
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    println!("[SHUTDOWN] Sovereign Rust server closed cleanly.");
    Ok(())
}

async fn shutdown_signal() {
    let ctrl_c = async {
        tokio::signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unslop_invariants() {
        let sample = "AIEN on Grace Blackwell: sovereign compiled execution.";
        assert!(!sample.contains('\u{2014}'), "Forbidden em dash detected");
        assert!(!sample.contains('\u{2013}'), "Forbidden en dash detected");
    }

    #[test]
    fn test_telemetry_defaults() {
        let packet = telemetry::TelemetryPacket::default();
        assert_eq!(packet.system_memory_total_mb, 124608);
        assert!(!packet.aien_agent_status.is_empty());
    }
}
