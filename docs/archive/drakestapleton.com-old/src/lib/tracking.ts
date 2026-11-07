declare global {
  interface Window {
    dataLayer?: unknown[];
    gtag?: (...args: unknown[]) => void;
  }
}

export function trackEvent(action: string, params: Record<string, unknown> = {}) {
  if (typeof window === "undefined") {
    return;
  }
  if (typeof window.gtag === "function") {
    window.gtag("event", action, params);
  }
}

export function trackRepoOutbound(repoName: string, destinationUrl: string) {
  trackEvent("repo_outbound_click", {
    repo_name: repoName,
    destination_url: destinationUrl,
    event_category: "engagement",
    event_label: repoName,
  });
}
