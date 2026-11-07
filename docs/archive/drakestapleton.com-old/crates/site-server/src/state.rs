use crate::telemetry::TelemetryPacket;
use axum::body::Bytes;
use regex::Regex;
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::Arc;
use std::time::Instant;
use tokio::sync::{broadcast, RwLock, Semaphore};

#[derive(Clone)]
pub struct AppState {
    pub routes: Arc<HashMap<String, Bytes>>,
    #[allow(dead_code)]
    pub static_dir: PathBuf,
    pub start_time: Instant,
    pub latest_telemetry: Arc<RwLock<TelemetryPacket>>,
    pub telemetry_tx: broadcast::Sender<TelemetryPacket>,
    pub redactor_patterns: Arc<Vec<(Regex, &'static str)>>,
    pub http_client: reqwest::Client,
    pub chat_semaphore: Arc<Semaphore>,
}

fn build_redactor_patterns() -> Vec<(Regex, &'static str)> {
    vec![
        (Regex::new(r"-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----").unwrap(), "[REDACTED_PRIVATE_KEY]"),
        (Regex::new(r"\b(ey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,})\b").unwrap(), "[REDACTED_JWT_TOKEN]"),
        (Regex::new(r"(?i)\b(bearer\s+)([a-zA-Z0-9_\-\.]{12,})").unwrap(), "[REDACTED_BEARER_TOKEN]"),
        (Regex::new(r"(?i)(api[_-]?key|secret|password|passwd|token)\s*[:=]\s*([^\s,;]{8,})").unwrap(), "=[REDACTED_SECRET]"),
        (Regex::new(r"\b(sk-[a-zA-Z0-9_-]{20,})\b").unwrap(), "[REDACTED_OPENAI_KEY]"),
        (Regex::new(r"\b(sk-ant-[a-zA-Z0-9_-]{20,})\b").unwrap(), "[REDACTED_ANTHROPIC_KEY]"),
        (Regex::new(r"\b(hf_[a-zA-Z0-9]{20,})\b").unwrap(), "[REDACTED_HUGGINGFACE_TOKEN]"),
    ]
}

impl AppState {
    pub fn new(dist_dir: &Path) -> Result<Self, String> {
        let route_mappings = vec![
            ("/", "index.html"),
            ("/aien", "aien/index.html"),
            ("/research", "research/index.html"),
            ("/atlas", "atlas/index.html"),
            ("/aegis", "aegis/index.html"),
            ("/software", "software/index.html"),
            ("/path", "path/index.html"),
            ("/evidence", "evidence/index.html"),
            ("/what-i-learned", "what-i-learned/index.html"),
            ("/interest", "interest/index.html"),
            ("/symphony", "symphony/index.html"),
            ("/symphony/first", "symphony/first/index.html"),
            ("/symphony/workflow", "symphony/workflow/index.html"),
            ("/symphony/map", "symphony/map/index.html"),
            ("/works", "works/index.html"),
            ("/works/atlas-symphony", "works/atlas-symphony/index.html"),
            ("/works/atlas-harness", "works/atlas-harness/index.html"),
            ("/works/mobdev-panel-arena", "works/mobdev-panel-arena/index.html"),
            ("/works/defiantmob", "works/defiantmob/index.html"),
            ("/works/beltbrain", "works/beltbrain/index.html"),
            ("/works/dhg-hive", "works/dhg-hive/index.html"),
            ("/works/foundations-2025", "works/foundations-2025/index.html"),
            ("/works/aien", "works/aien/index.html"),
            ("/works/aegis", "works/aegis/index.html"),
            ("/works/research", "works/research/index.html"),
            ("/404", "404.html"),
        ];

        let mut routes = HashMap::new();
        let ticker_script = "<script defer src=\"/js/live-ticker.js\"></script>";

        for (route, file_rel) in route_mappings {
            let file_path = dist_dir.join(file_rel);
            if !file_path.exists() {
                return Err(format!("Missing required route file: {}", file_path.display()));
            }

            let raw = fs::read_to_string(&file_path)
                .map_err(|e| format!("Failed to read {}: {}", file_path.display(), e))?;

            // Assert unslop invariants
            if raw.contains('\u{2014}') {
                return Err(format!("Forbidden em dash in {}", file_path.display()));
            }
            if raw.contains('\u{2013}') {
                return Err(format!("Forbidden en dash in {}", file_path.display()));
            }

            // Inject live ticker script before </head> if present
            let injected = if raw.contains("</head>") && !raw.contains("/js/live-ticker.js") {
                raw.replace("</head>", &format!("  {}\n</head>", ticker_script))
            } else {
                raw
            };

            routes.insert(route.to_string(), Bytes::from(injected));
        }

        let (telemetry_tx, _) = broadcast::channel(64);
        let initial_telemetry = TelemetryPacket::default();
        let http_client = reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(120))
            .build()
            .map_err(|e| format!("Failed to build reqwest client: {}", e))?;

        // Maximum 2 concurrent visitor chat requests to protect GPU compute
        let chat_semaphore = Arc::new(Semaphore::new(2));

        Ok(Self {
            routes: Arc::new(routes),
            static_dir: dist_dir.to_path_buf(),
            start_time: Instant::now(),
            latest_telemetry: Arc::new(RwLock::new(initial_telemetry)),
            telemetry_tx,
            redactor_patterns: Arc::new(build_redactor_patterns()),
            http_client,
            chat_semaphore,
        })
    }

    pub fn redact(&self, input: &str) -> String {
        let mut result = input.to_string();
        for (pattern, replacement) in self.redactor_patterns.iter() {
            result = pattern.replace_all(&result, *replacement).to_string();
        }
        result
    }
}
