import { useSearchParams } from "react-router-dom";
import { InterestForm } from "../components/InterestForm";
import { PageIntro } from "../components/PagePrimitives";
import { HisWords } from "../components/VoiceMark";
import { usePageMeta } from "../lib/usePageMeta";

export function InterestPage() {
  const [params] = useSearchParams();
  const received = params.get("received") === "1";

  usePageMeta("/interest");

  return (
    <main className="portrait-page interest-page">
      <div className="page-boundary">
        <PageIntro eyebrow="Conversation" title="Walk with me for a while.">
          <p>
            This site is my record of the projects and the life behind them. If something here gives you a
            question, an idea, or a story of your own, leave me a note.
          </p>
          <p>
            <HisWords>
              I am open to good conversation with people who want to walk part of this journey with
              me
            </HisWords>
            , and to research partnerships that advance what our generation can build with AI.
          </p>
        </PageIntro>

        {received ? (
          <div className="interest-received" role="status">
            <p className="portrait-index">Received</p>
            <h2>I have your note.</h2>
            <p>I will write back from this desk.</p>
          </div>
        ) : (
          <InterestForm />
        )}
      </div>
    </main>
  );
}
