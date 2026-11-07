import { Link } from "react-router-dom";
import { PageIntro } from "../components/PagePrimitives";
import { HisWords } from "../components/VoiceMark";
import { usePageMeta } from "../lib/usePageMeta";

const lessons = [
  {
    when: "Community / Belonging",
    title: "People gave me a reason to stay.",
    experience:
      "At nineteen, an invitation through a headset gave me belonging at the exact moment I needed it. Leadership later gave me a way to pass that gift forward.",
    lesson:
      "I built training, schedules, dashboards, and leadership paths that helped members see their ability, support each other, and carry the community forward.",
  },
  {
    when: "Leadership / The shepherd",
    title: "The rank is made up. The people are real.",
    experience:
      "Leading a squad taught me that titles, tags, and structures can vanish overnight. When squads closed, the grief was real, and the only work that mattered was gathering the people and keeping them safe.",
    lesson:
      "I lead by going first, giving the credit away, and building people who can run the work on their own. The chain I build outlasts any title I hold.",
  },
  {
    when: "MobHub / Production",
    title: "Production taught me to make every path explicit.",
    experience:
      "The live service used systemd while an older Docker path still existed. Remote SSH found a different Node runtime. Standalone builds needed an explicit static asset step.",
    lesson:
      "Each lesson became a deployment rule: one service owner, an explicit runtime path, a deliberate artifact copy, migration gates, backoff, and health checks.",
  },
  {
    when: "Defiant / Production",
    title: "Security controls made the application stronger.",
    experience:
      "Inherited file permissions, content-security policy, redirects, and a database safety setting interrupted real flows at different points. One release returned to its prior version.",
    lesson:
      "I treated every control as a useful signal. I repaired the permissions, policies, and migration state, then verified the recovery before moving forward.",
  },
  {
    when: "Independent AI / Model training",
    title: "Model training gave me two deeper loader lessons.",
    experience:
      "A personal Devstral adapter trained on an H100. The first merge exposed Float8 promotion behavior. The second showed how the model configuration differed from the generic loader.",
    lesson:
      "I repaired the source and brought private inference live through the adapter path.",
  },
  {
    when: "Independent AI / Evaluation",
    title: "A score of 90 invited a closer look.",
    experience:
      "A synthetic fixture scored 90 out of 100 because the evaluator rewarded the shape of a convincing answer more than the source behind it.",
    lesson:
      "I repaired the method. The score became 58, with a human score of 54. The lower number gave me a truer picture of the system.",
  },
  {
    when: "Personal / The harder lesson",
    title: (
      <HisWords>I learned that survival also means protecting myself.</HisWords>
    ),
    experience:
      "For years, I survived by outworking every limit and carrying more than people saw. That strength built my life, and at one point I carried the work past my body’s limits.",
    lesson:
      "Perseverance now means returning with my health, judgment, and sense of self intact.",
  },
];

export function WhatILearnedPage() {
  usePageMeta("/what-i-learned");

  return (
    <main className="wrap portrait-wrap learned-page">
      <PageIntro eyebrow="Learning is part of the record" title="Every hard turn taught me how to return." className="learned-hero">
        <p>
          The strongest evidence of who I am lives in the choices I made when a plan met reality. I learned,
          repaired what I could, and carried the lesson forward.
        </p>
      </PageIntro>

      <section className="lesson-list" aria-label="Lessons and repairs">
        {lessons.map((lesson, index) => (
          <article key={lesson.when}>
            <div className="lesson-label">
              <span>{String(index + 1).padStart(2, "0")}</span>
              <p>{lesson.when}</p>
            </div>
            <div className="lesson-story">
              <h2>{lesson.title}</h2>
              <dl>
                <div>
                  <dt>The experience</dt>
                  <dd>{lesson.experience}</dd>
                </div>
                <div>
                  <dt>What I carried forward</dt>
                  <dd>{lesson.lesson}</dd>
                </div>
              </dl>
            </div>
          </article>
        ))}
      </section>

      <section className="learned-rule">
        <p className="portrait-index">The rule I carry</p>
        <blockquote>Every problem deserves an honest repair.</blockquote>
        <p>I preserve the lesson, strengthen the system, and carry both into the next attempt.</p>
        <div className="portrait-actions">
          <Link className="portrait-link" to="/">
            Return to the whole story
          </Link>
          <Link className="portrait-link quiet" to="/evidence">
            Review the evidence record
          </Link>
        </div>
      </section>
    </main>
  );
}
