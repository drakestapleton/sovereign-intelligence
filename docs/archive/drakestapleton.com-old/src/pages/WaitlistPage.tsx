import { FormEvent, useMemo, useState } from "react";
import { usePageMeta } from "../lib/usePageMeta";

const WAITLIST_ENDPOINT =
  import.meta.env.VITE_WAITLIST_ENDPOINT ||
  "https://waitlist-api.drakestapleton.com:8443/api/signup";

type FormState = "idle" | "submitting" | "success" | "error";

export function WaitlistPage() {
  usePageMeta({
    title: "Drake Stapleton | A Life in People, Science, and Systems",
    description:
      "A human portrait and body of work by Drake Stapleton is in development. Join the waiting list for the first public release.",
    path: "/",
  });

  const openedAt = useMemo(() => Date.now(), []);
  const [state, setState] = useState<FormState>("idle");
  const [message, setMessage] = useState("");

  async function joinWaitlist(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const email = String(form.get("email") || "").trim();
    const consent = form.get("consent") === "on";
    const website = String(form.get("website") || "");

    if (!email || !consent) {
      setState("error");
      setMessage("Enter your email and confirm how it will be used.");
      return;
    }

    setState("submitting");
    setMessage("");

    try {
      const response = await fetch(WAITLIST_ENDPOINT, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email,
          consent,
          consentVersion: "2026-08-13-v1",
          website,
          elapsedMs: Date.now() - openedAt,
        }),
      });

      if (!response.ok) {
        throw new Error(`waitlist request failed with ${response.status}`);
      }

      setState("success");
      setMessage("You are on the list. I will write when the first public release is ready.");
      formElement.reset();
    } catch {
      setState("error");
      setMessage("Please try again in a moment so I can add your email.");
    }
  }

  return (
    <main className="waitlist-shell">
      <section className="waitlist-copy">
        <p className="waitlist-kicker">Drake Stapleton / Thirty-two years alive</p>
        <h1>
          A life in <span className="waitlist-keep">people, science,</span>{" "}
          <span className="waitlist-keep">and <em>systems.</em></span>
        </h1>
        <p className="waitlist-lede">
          I am writing the full story now: Tennessee, Kentucky, family, chemistry, manufacturing,
          communities, independent projects, and the determination that carried me through every hard turn.
        </p>
        <p className="waitlist-rule">The work is technical. The reason is human.</p>
      </section>

      <aside className="waitlist-panel" aria-labelledby="waitlist-title">
        <p className="waitlist-number">Private development / 2026</p>
        <h2 id="waitlist-title">Join the waiting list.</h2>
        <p>
          I am finishing the record and telling it in my own voice. Leave one email and I will write when
          the complete portrait opens.
        </p>

        {state === "success" ? (
          <div className="waitlist-success" role="status">
            <span>Received</span>
            <p>{message}</p>
          </div>
        ) : (
          <form className="waitlist-form" onSubmit={joinWaitlist}>
            <label htmlFor="email">Email address</label>
            <input
              id="email"
              name="email"
              type="email"
              inputMode="email"
              autoComplete="email"
              maxLength={254}
              required
              disabled={state === "submitting"}
            />
            <div className="waitlist-honeypot" aria-hidden="true">
              <label htmlFor="website">Website</label>
              <input id="website" name="website" type="text" tabIndex={-1} autoComplete="off" />
            </div>
            <label className="waitlist-consent">
              <input name="consent" type="checkbox" required disabled={state === "submitting"} />
              <span>
                Use my email solely for the announcement that this portfolio is open. My address stays
                private and leaves the list whenever I ask.
              </span>
            </label>
            <button type="submit" disabled={state === "submitting"}>
              {state === "submitting" ? "Joining..." : "Join the list"}
            </button>
            {message ? (
              <p className="waitlist-message" role="alert">
                {message}
              </p>
            ) : null}
          </form>
        )}

        <p className="waitlist-privacy">
          Stored with consent: email address, consent version, and signup time. Your address supports this
          single announcement and stays private.
        </p>
      </aside>

      <footer className="waitlist-footer">
        <span>Drake Stapleton</span>
        <span>Springfield, Missouri</span>
      </footer>
    </main>
  );
}
