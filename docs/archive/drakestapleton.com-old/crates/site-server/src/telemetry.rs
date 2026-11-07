use serde::{Deserialize, Serialize};
use std::fs;
use std::process::Command;
use std::time::Instant;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct TelemetryPacket {
    pub timestamp: String,
    pub gpu_utilization_pct: u32,
    pub gpu_temperature_c: u32,
    pub gpu_power_watts: f32,
    pub system_memory_used_mb: u64,
    pub system_memory_total_mb: u64,
    pub aien_agent_status: String,
    pub active_goal: String,
    pub latest_milestone: String,
    pub uptime_seconds: u64,
}

impl Default for TelemetryPacket {
    fn default() -> Self {
        Self {
            timestamp: chrono::Utc::now().to_rfc3339(),
            gpu_utilization_pct: 0,
            gpu_temperature_c: 0,
            gpu_power_watts: 0.0,
            system_memory_used_mb: 0,
            system_memory_total_mb: 124608,
            aien_agent_status: "ONLINE (GB10 ACTIVE)".to_string(),
            active_goal: "Sovereign Autonomous Systems".to_string(),
            latest_milestone: "Full-Stack Rust Server on Spark".to_string(),
            uptime_seconds: 0,
        }
    }
}

pub fn collect_gpu_telemetry() -> (u32, u32, f32) {
    let output = Command::new("nvidia-smi")
        .args([
            "--query-gpu=utilization.gpu,temperature.gpu,power.draw",
            "--format=csv,noheader,nounits",
        ])
        .output();

    match output {
        Ok(out) if out.status.success() => {
            let text = String::from_utf8_lossy(&out.stdout);
            let parts: Vec<&str> = text.trim().split(',').map(|s| s.trim()).collect();
            if parts.len() >= 3 {
                let util = parts[0].parse::<u32>().unwrap_or(0);
                let temp = parts[1].parse::<u32>().unwrap_or(0);
                let power = parts[2].parse::<f32>().unwrap_or(0.0);
                return (util, temp, power);
            }
        }
        _ => {}
    }
    (0, 0, 0.0)
}

pub fn collect_memory_telemetry() -> (u64, u64) {
    if let Ok(meminfo) = fs::read_to_string("/proc/meminfo") {
        let mut total_kb = 0u64;
        let mut avail_kb = 0u64;
        for line in meminfo.lines() {
            if line.starts_with("MemTotal:") {
                if let Some(val) = line.split_whitespace().nth(1) {
                    total_kb = val.parse::<u64>().unwrap_or(0);
                }
            } else if line.starts_with("MemAvailable:") {
                if let Some(val) = line.split_whitespace().nth(1) {
                    avail_kb = val.parse::<u64>().unwrap_or(0);
                }
            }
        }
        if total_kb > 0 {
            let used_mb = (total_kb.saturating_sub(avail_kb)) / 1024;
            let total_mb = total_kb / 1024;
            return (used_mb, total_mb);
        }
    }
    (0, 124608)
}

pub fn sample_telemetry(start_time: Instant, active_goal: &str, latest_milestone: &str) -> TelemetryPacket {
    let (gpu_util, gpu_temp, gpu_power) = collect_gpu_telemetry();
    let (mem_used, mem_total) = collect_memory_telemetry();

    TelemetryPacket {
        timestamp: chrono::Utc::now().to_rfc3339(),
        gpu_utilization_pct: gpu_util,
        gpu_temperature_c: gpu_temp,
        gpu_power_watts: gpu_power,
        system_memory_used_mb: mem_used,
        system_memory_total_mb: mem_total,
        aien_agent_status: "ONLINE (GB10 ACTIVE)".to_string(),
        active_goal: active_goal.to_string(),
        latest_milestone: latest_milestone.to_string(),
        uptime_seconds: start_time.elapsed().as_secs(),
    }
}
