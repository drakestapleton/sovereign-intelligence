use axum::extract::State;
use axum::Json;
use serde_json::{json, Value};
use crate::state::AppState;

pub async fn health_check(State(state): State<AppState>) -> Json<Value> {
    let telemetry = state.latest_telemetry.read().await;
    Json(json!({
        "status": "ok",
        "host": "spark-gb10",
        "runtime": "rust-axum-sovereign",
        "uptime_seconds": state.start_time.elapsed().as_secs(),
        "active_goal": telemetry.active_goal,
        "latest_milestone": telemetry.latest_milestone,
        "gpu_utilization_pct": telemetry.gpu_utilization_pct,
        "gpu_temperature_c": telemetry.gpu_temperature_c
    }))
}
