use serde::Deserialize;
use std::fs;
use std::path::Path;

#[derive(Deserialize, Debug, Clone)]
struct Milestone {
    title: String,
    #[serde(default)]
    status: String,
}

#[derive(Deserialize, Debug, Clone)]
struct Goal {
    title: String,
    #[serde(default)]
    #[allow(dead_code)]
    status: String,
    #[serde(default)]
    milestones: Vec<Milestone>,
}

#[derive(Deserialize, Debug, Clone)]
struct GoalsFile {
    goals: Vec<Goal>,
}

pub fn get_active_goal_and_milestone() -> (String, String) {
    let goals_path = Path::new("/home/drakestapleton/basecamp/goals.json");
    if let Ok(content) = fs::read_to_string(goals_path) {
        if let Ok(data) = serde_json::from_str::<GoalsFile>(&content) {
            for goal in data.goals.iter().rev() {
                let latest_completed = goal
                    .milestones
                    .iter()
                    .rev()
                    .find(|m| m.status == "completed" || m.status == "done")
                    .map(|m| m.title.clone());

                let active_or_first = goal
                    .milestones
                    .iter()
                    .find(|m| m.status == "in_progress" || m.status == "active")
                    .map(|m| m.title.clone());

                let milestone_str = active_or_first
                    .or(latest_completed)
                    .unwrap_or_else(|| "Milestone in progress".to_string());

                return (goal.title.clone(), milestone_str);
            }
        }
    }
    (
        "Autonomous Sovereign Systems".to_string(),
        "Native Rust Server Execution".to_string(),
    )
}
