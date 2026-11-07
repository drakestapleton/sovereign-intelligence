const INTAKE_ACTION = "https://formsubmit.co/dhgmonkey94@gmail.com";
const THANKS_URL = "https://www.drakestapleton.com/interest?received=1";

export function InterestForm({ compact = false }: { compact?: boolean }) {
  return (
    <form
      className={compact ? "interest-form is-compact" : "interest-form"}
      action={INTAKE_ACTION}
      method="POST"
    >
      <input type="hidden" name="_subject" value="Conversation from drakestapleton.com" />
      <input type="hidden" name="_captcha" value="true" />
      <input type="hidden" name="_template" value="table" />
      <input type="hidden" name="_next" value={THANKS_URL} />
      <div className="interest-honeypot" aria-hidden="true">
        <label htmlFor="interest-website">Website</label>
        <input id="interest-website" type="text" name="_gotcha" tabIndex={-1} autoComplete="off" />
      </div>

      <div className="interest-card-grid">
        <p className="interest-card-label">Your note</p>
        <div className="interest-fields">
          <label htmlFor="interest-name">
            Name
            <input id="interest-name" name="name" type="text" autoComplete="name" maxLength={120} required />
          </label>
          <label htmlFor="interest-email">
            Email
            <input
              id="interest-email"
              name="email"
              type="email"
              inputMode="email"
              autoComplete="email"
              maxLength={254}
              required
            />
          </label>
          <label htmlFor="interest-org">
            Your project or story
            <input
              id="interest-org"
              name="project_or_story"
              type="text"
              maxLength={160}
            />
          </label>
        </div>
      </div>

      <details className="interest-more">
        <summary>A few questions</summary>
        <div className="interest-fields">
          <label htmlFor="interest-brought">
            What brought you here?
            <textarea id="interest-brought" name="what_brought_you_here" rows={3} maxLength={800} />
          </label>
          <label htmlFor="interest-work">
            What are you working on?
            <textarea id="interest-work" name="what_are_you_working_on" rows={3} maxLength={800} />
          </label>
        </div>
      </details>

      <label htmlFor="interest-questions">
        Questions for me
        <textarea id="interest-questions" name="questions_for_me" rows={4} maxLength={1200} />
      </label>

      <label className="interest-consent">
        <input name="reply_ok" type="checkbox" value="yes" required />
        <span>Use this email only to continue this conversation.</span>
      </label>

      <button type="submit">Send the note</button>
    </form>
  );
}
