import { Link } from "react-router-dom";
import type { ReactNode } from "react";
import { PageIntro } from "../components/PagePrimitives";
import { HisWords } from "../components/VoiceMark";
import { usePageMeta } from "../lib/usePageMeta";

type PathLink = {
  label: string;
  href: string;
};

type PathChapter = {
  years: string;
  title: string;
  body: ReactNode;
  bridge: string;
  quote?: string;
  quoteNote?: string;
  links?: PathLink[];
};

const chapters: PathChapter[] = [
  {
    years: "The foundation",
    title: "The farm taught me to respect the person closest to the work",
    body: "I grew up in a humble farm home where practical work mattered and every person doing it was visible. I learned that every useful task carries dignity, that the people carrying the work see what outsiders miss, and that trust begins when I am willing to work beside them.",
    bridge:
      "That is what I carried into my first job: notice what people need, help before asking, and carry every task I ask someone else to do.",
  },
  {
    years: "My first job",
    title: "Team member to shift leader, Taco Bell",
    body: "I worked my way from the line into shift leadership. My first concern was whether my crew had everything they needed. I served them, became the fastest worker I could be, and took on every task I asked them to do. That became my first leadership rule: carry the work beside the people you lead. Gina became one of the best mentors I have ever had.",
    bridge:
      "Taco Bell turned the farm lesson into a leadership practice. I learned that trust is earned in the work and carries farther than any title, and I brought that posture into every team and laboratory after it.",
    quote:
      "Remember, Michael: at the end of the day, when you clock out and go home, it's just tacos.",
    quoteNote:
      "I still hear her advice when the pressure rises: it is just chemistry. Keep perspective, serve the people, and solve the next problem.",
  },
  {
    years: "College years",
    title: "Taco Bell in Bowling Green to a Valspar laboratory",
    body: (
      <>
        I carried the same work ethic to Bowling Green and stayed with Taco Bell until I moved into a
        Valspar internship. A chemist mentored me while I learned production paints, color matching,
        sample preparation, and disciplined lab work.{" "}
        <HisWords>
          I was the eager little lab rat, making samples and trying to get every detail right.
        </HisWords>
      </>
    ),
    bridge:
      "Valspar connected my work ethic to chemistry. I learned that the laboratory and production were one chain: a good sample had to become something people could make correctly and repeatedly.",
  },
  {
    years: "2016",
    title: "B.S. in Chemistry and Biology",
    body: "Undergraduate study became four years of exploration. I tested disciplines, futures, and versions of myself, learned which dreams felt like mine, finished with a 3.2 GPA, and graduated with honors from Western Kentucky University.",
    bridge:
      "The degree gave my curiosity scientific structure and moved me from learning laboratory discipline to asking and answering original research questions.",
  },
  {
    years: "2018",
    title: "Master of Science in Chemistry",
    body: "As an inorganic chemist researching under Dr. Lawrence J. Hill at Western Kentucky University, I synthesized colloidal cadmium selenide (CdSe) quantum dot seeds and grew anisotropic cadmium sulfide (CdS) nanorods to form CdSe@CdS dot-in-rod quasi-type-II heterostructures. I investigated noble-metal deposition, using [BMIM]Tf2N room-temperature ionic liquid as solvent, ligand, and reducing agent to deposit metallic platinum nanoparticles onto the semiconductor tips. That research became my master's thesis and a peer-reviewed journal paper under my name at the time, Michael Drake Ballentine. I presented the findings at the American Chemical Society (ACS) National Meeting, navigating the social intensity of national conferences while managing autism and ADHD. The rigor of synthesizing nanomaterials, measuring charge dynamics via TEM, PXRD, and photoluminescence quenching, and testing visible-light photocatalysis formed the foundation for my industrial chemistry career.",
    bridge:
      "Graduate research taught me to turn uncertainty into experiments, measurement, and evidence. I carried that nanoscale precision out of the academic laboratory and directly into industrial formulation at Soudal and Gold Eagle.",
    links: [
      {
        label: "Read my 2018 master's thesis (TopSCHOLAR)",
        href: "https://digitalcommons.wku.edu/theses/2101/",
      },
      {
        label: "Read the 2019 journal paper (PubMed)",
        href: "https://pubmed.ncbi.nlm.nih.gov/30931213/",
      },
    ],
  },
  {
    years: "July 2018 to May 2020",
    title: "R&D Chemist, Soudal",
    body: "I formulated and scaled silicone products, supported quality systems and UL certification, and coordinated with Soudal's Belgian headquarters. Traveling to Belgium and learning from generous mentors brought me fully into industry. Working beside operators taught me to listen before changing anything: they knew where a process behaved differently on the floor than it did in the laboratory.",
    bridge:
      "Soudal taught me that operator knowledge and technical knowledge become more valuable when someone can connect them. That bridge became the core of how I worked at Gold Eagle.",
  },
  {
    years: "May 2020 to March 2024",
    title: "R&D Chemist, Gold Eagle and 303 Products",
    body: "I approached improvement from the formulation side. I developed and improved products, commercialized formulations across the 303 Graphene line, kept building relationships with operators, explained the chemistry on camera, served as a HAZMAT Incident Commander, trained teams, and secured alternate raw materials during COVID-era disruption. That formulation-led work produced about $1.2 million in documented sourcing savings.",
    bridge:
      "Gold Eagle taught me to connect formulation, production reality, supply chain, and the customer. I entered 3M with years of practice listening to operators and translating what they knew into changes a business could act on.",
    links: [
      {
        label: "See the current 303 Graphene line",
        href: "https://www.goldeagle.com/303-graphene/",
      },
    ],
  },
  {
    years: "March 2024 to February 2026",
    title: "Manufacturing Engineer, 3M",
    body: "I led PPU improvements through manufacturing change control, workflow mapping, line balancing, standard work, and operator partnership. The methods mattered, but my connection with operators made them useful. Because Soudal and Gold Eagle had taught me how to listen and work beside people, operators trusted me enough to show me where the process actually slowed, broke, or created waste. We turned that knowledge into $1 million in cost savings.",
    bridge:
      "The savings were the result of the whole ladder: farm-grounded respect, service leadership, scientific discipline, formulation experience, and operator trust. That full combination moved with me into product engineering.",
  },
  {
    years: "February 2026 onward",
    title: "Product Engineer, 3M",
    body: "A second February 13 offer moved me into the product engineer role I hold today. I can improve both sides: the chemistry and performance of the product, and the process, efficiency, and operator experience behind making it.",
    bridge:
      "This title carries the climb forward. I am combining every rung: formulation, product performance, manufacturing, PPU improvements, operator experience, and measurable business impact.",
  },
  {
    years: "Built alongside it all",
    title: "Independent software and AI work",
    body: "I built software, automation, AI systems, research harnesses, and community infrastructure alongside my industrial career. This belongs to the same life. I brought the same habit of listening to people, studying systems, preserving evidence, and improving what others have to use. Atlas became my latest achievement and my greatest so far.",
    bridge:
      "The medium changed while the method stayed. I keep carrying the people, the evidence, and every prior lesson into the next system I build.",
  },
];

const featuredVideos = [
  {
    kind: "303 Products video",
    date: "November 2020",
    title: "303 Graphene Nano Spray Coating Fights Water Spots",
    body: "I demonstrate how the graphene coating's surface-temperature behavior helps reduce water spotting.",
    href: "https://www.youtube.com/watch?v=W3Vu0DMH33E",
    image: "https://i.ytimg.com/vi/W3Vu0DMH33E/hqdefault.jpg",
  },
  {
    kind: "303 Products video",
    date: "December 2021",
    title: "303 Graphene Detailer | Breaking Down The Science",
    body: "I explain how graphene oxide supports gloss, slickness, and protection between washes.",
    href: "https://www.youtube.com/watch?v=uUOqqFfGWvc",
    image: "https://i.ytimg.com/vi/uUOqqFfGWvc/hqdefault.jpg",
  },
  {
    kind: "Television commercial",
    date: "March 2022",
    title: "303 Graphene | 2022 TV Commercial",
    body: "The 303 Graphene television spot that coworkers recognized after I joined 3M.",
    href: "https://www.youtube.com/watch?v=lReSVK2uXGc",
    image: "https://i.ytimg.com/vi/lReSVK2uXGc/hqdefault.jpg",
  },
  {
    kind: "303 Products video",
    date: "June 2022",
    title: "Science Behind 303 Marine Graphene Nano Spray Coating",
    body: "I explain the chemistry behind the marine formulation and its exterior-protection performance.",
    href: "https://www.youtube.com/watch?v=HLax_gGsZyQ",
    image: "https://i.ytimg.com/vi/HLax_gGsZyQ/hqdefault.jpg",
  },
  {
    kind: "303 Products video",
    date: "February 2023",
    title: "Ceramic vs. Graphene: Breaking Down the Science",
    body: "I compare two major detailing technologies and the chemistry each product brings to a surface.",
    href: "https://www.youtube.com/watch?v=Jvgj2LdPpXA",
    image: "https://i.ytimg.com/vi/Jvgj2LdPpXA/hqdefault.jpg",
  },
  {
    kind: "303 Products video",
    date: "March 2023",
    title: "303 Ceramics: Science Behind SiO2 Products",
    body: "I break down the product science behind 303 Spray & Rinse Ceramic Sealant and Slick Shine Ceramic Detailer.",
    href: "https://www.youtube.com/watch?v=B-XLum3HIwY",
    image: "https://i.ytimg.com/vi/B-XLum3HIwY/hqdefault.jpg",
  },
];

export function PathPage() {
  usePageMeta("/path");

  return (
    <main className="wrap portrait-wrap path-page">
      <PageIntro
        eyebrow="Education and work"
        title="Every step taught me how to take the next one."
        className="path-header"
      >
        <p>
          Each job became part of one climb. I carried the farm into Taco Bell,
          service leadership into the laboratory, scientific discipline into
          production, and operator trust into every improvement after that. I am
          still walking up the same ladder.
        </p>
      </PageIntro>

      <section
        className="path-ladder-thesis"
        aria-labelledby="path-ladder-heading"
      >
        <p className="portrait-index">The ladder</p>
        <h2 id="path-ladder-heading">
          The $1 million at 3M began long before I joined 3M.
        </h2>
        <p>
          It began in a humble farm home, moved through the Taco Bell line and
          the Valspar laboratory, gained scientific rigor at Western Kentucky,
          learned operator partnership at Soudal, and deepened through
          formulation work at Gold Eagle. By the time I began leading PPU
          improvements at 3M, every earlier step was already in the room with
          me.
        </p>
      </section>

      <section
        className="path-timeline"
        aria-label="Education and work history"
      >
        {chapters.map((chapter, index) => (
          <article
            className="path-chapter"
            key={`${chapter.years}-${chapter.title}`}
          >
            <div className="path-rung-meta">
              <span className="path-rung-number" aria-hidden="true">
                {String(index + 1).padStart(2, "0")}
              </span>
              <p className="path-years">{chapter.years}</p>
            </div>
            <div className="path-chapter-copy">
              <h2>{chapter.title}</h2>
              <p>{chapter.body}</p>
              {chapter.quote && (
                <blockquote>
                  “{chapter.quote}”<cite>Gina, my Taco Bell mentor</cite>
                </blockquote>
              )}
              {chapter.quoteNote && (
                <p className="path-quote-note">{chapter.quoteNote}</p>
              )}
              {chapter.links && (
                <div className="path-chapter-links">
                  {chapter.links.map((source) => (
                    <a
                      href={source.href}
                      key={source.href}
                      rel="noreferrer"
                      target="_blank"
                    >
                      {source.label}
                    </a>
                  ))}
                </div>
              )}
              <p className="path-step-bridge">
                <strong>What this step built</strong>
                {chapter.bridge}
              </p>
            </div>
          </article>
        ))}
      </section>

      <section
        className="path-resistance path-dual-improvement"
        aria-labelledby="dual-improvement-heading"
      >
        <p className="portrait-index">Both sides of improvement</p>
        <h2 id="dual-improvement-heading">
          I can improve the product and the process that makes it.
        </h2>
        <div className="path-capability-grid">
          <article>
            <p className="capability-label">
              Gold Eagle / Formulation improvement
            </p>
            <div className="capability-result">
              <strong>$1.2M</strong>
              <span>documented sourcing savings</span>
            </div>
            <h3>I approached improvement through formulation.</h3>
            <p>
              I used formulation chemistry, testing, commercialization,
              alternate raw-material sourcing, and technical communication to
              improve products and carry them from the laboratory through
              production and into the market.
            </p>
          </article>
          <article>
            <p className="capability-label">3M / PPU process improvement</p>
            <div className="capability-result">
              <strong>$1M</strong>
              <span>PPU improvement savings</span>
            </div>
            <h3>I approached improvement through Process.</h3>
            <p>
              I used workflow mapping, line balancing, standard work, change
              control, and the knowledge of operators who trusted me enough to
              show me what the process really needed.
            </p>
          </article>
        </div>
        <p className="capability-summary">
          The two dollar figures came from different sides of improvement. Gold
          Eagle was formulation-led. 3M was PPU and process-led. The ability to
          deliver both was built one rung at a time.
        </p>
      </section>

      <section className="path-media" aria-labelledby="graphene-media-title">
        <p className="portrait-index">The chemist on camera</p>
        <div className="path-media-intro">
          <div>
            <h2 id="graphene-media-title">
              Gold Eagle gave me a product line and a microphone.
            </h2>
            <p>
              I formulated products for the 303 Graphene line and became one of
              the chemists trusted to explain their science publicly. It grew
              into one of the brand&apos;s most successful product lines and
              remains in the current 303 catalog. When I joined 3M in 2024,
              coworkers walked up to me with the same sentence.
            </p>
          </div>
          <blockquote>“I saw you on TV last night.”</blockquote>
        </div>
        <div className="path-video-grid">
          {featuredVideos.map((video) => (
            <a
              className="path-video-card"
              href={video.href}
              key={video.href}
              rel="noreferrer"
              target="_blank"
            >
              <img
                alt={`Official 303 Products video: ${video.title}`}
                loading="lazy"
                src={video.image}
              />
              <div>
                <p className="path-video-meta">
                  {video.kind} / {video.date}
                </p>
                <h3>{video.title}</h3>
                <p>{video.body}</p>
                <span>Watch on YouTube</span>
              </div>
            </a>
          ))}
        </div>
      </section>

      <section className="path-resistance" aria-labelledby="education-drive">
        <p className="portrait-index">The drive behind the grades</p>
        <h2 id="education-drive">
          Support gave all that effort room to compound.
        </h2>
        <div className="path-memory-grid">
          <article>
            <span>01</span>
            <h3>High school: 3.92</h3>
            <p>
              Intelligence and athleticism seemed natural in other people. I
              wanted excellence, and work had to carry me there. Football,
              honors classes, autism, and ADHD made every result feel earned. I
              returned to the rep, the page, and the problem until the work
              added up.
            </p>
          </article>
          <article>
            <span>02</span>
            <h3>Undergraduate: 3.2 and honors</h3>
            <p>
              College was exploration. I tried futures on, learned which dreams
              belonged to me, and finished with a 3.2 GPA and graduated with
              honors. Through those eleven years from age thirteen until
              marrying Devin in 2018, I went by Michael Drake Ballentine.
              Ballentine was Dad&apos;s last name, given to me when he chose to
              adopt my brother and me after Mom brought us to safety. Stapleton
              became my married name when Devin and I chose our future together.
            </p>
          </article>
          <article>
            <span>03</span>
            <h3>Graduate school: I became Drake</h3>
            <p>
              A diagnosis of ADHD and Asperger&apos;s (ASD), medication, mental
              healthcare, quiet study and exam rooms, extra time to think, and
              room to stare out the window and let my brain run wild finally
              gave me an equal field. The grit stayed. With support, it
              compounded. Synthesizing nanomaterials, presenting at the ACS
              conference, and defending my thesis proved what I could create. I
              could feel myself becoming Drake, and my growth accelerated from
              there.
            </p>
          </article>
        </div>
      </section>

      <section
        className="path-resistance path-failure"
        aria-labelledby="failure-heading"
      >
        <p className="portrait-index">What failure taught me</p>
        <h2 id="failure-heading">Each hit became another attempt.</h2>
        <div className="path-failure-grid">
          <div className="path-failure-copy">
            <p>
              <HisWords>
                I have spent my life competing, doing my best, and watching the
                result land short of what I wanted.
              </HisWords>{" "}
              The first lesson was painful
              and simple: effort gives me a chance rather than a promise. I
              could prepare, care deeply, and still miss the job, the
              recognition, or the test.
            </p>
            <p>
              Jobs passed me over. People called me too young. Recognition and
              compensation sometimes moved more slowly than the value I knew I
              was creating. Each hit forced me to decide whether the result
              would become a verdict or information. I chose information: study
              what happened, keep what worked, change what failed, and return.
            </p>
            <p>
              The farm taught me to finish the work in front of me. Football
              taught me to get up after contact. Chemistry taught me that an
              unsuccessful experiment still narrows the answer. Manufacturing
              taught me to turn a problem into a process. Software and AI taught
              me to preserve every lesson so the next attempt begins farther
              ahead.
            </p>
            <p>
              Persistence for me is disciplined return: the same purpose with
              better preparation, sharper questions, and a stronger system. I
              enjoy the work, I need the purpose, and each attempt gives the
              next one more to stand on.
            </p>
          </div>
          <div className="attempt-card">
            <strong>4</strong>
            <h3>The fourth attempt passed.</h3>
            <p>
              <HisWords>I failed the Six Sigma exam three times.</HisWords> Each result showed me
              that wanting the credential and earning it were different things.
              I studied again, returned for the fourth attempt, and passed.
            </p>
            <p>
              The credential mattered. The proof that I could keep returning
              mattered more.
            </p>
          </div>
        </div>
      </section>

      <section
        className="path-resistance path-bridge"
        aria-labelledby="bridge-heading"
      >
        <p className="portrait-index">The connective tissue</p>
        <h2 id="bridge-heading">The title changed. The way I work stayed.</h2>
        <div className="path-resistance-grid">
          <p>
            I arrived at 3M already knowing operators mattered. Soudal taught me
            to listen to the people closest to production. Gold Eagle taught me
            to carry their knowledge through formulation, scale-up, sourcing,
            and commercialization. By 3M, connection was already how I worked.
          </p>
          <p>
            The farm boy in me still stands between the rooms. I know the
            dignity of practical work, and I can translate between the people
            setting direction and the people making that direction real. That is
            who I am, and it is why the operators&apos; trust became measurable
            improvement instead of a line on a résumé.
          </p>
        </div>
      </section>

      <section
        className="path-resistance path-leap"
        aria-labelledby="leap-heading"
      >
        <p className="portrait-index">The leap toward home</p>
        <h2 id="leap-heading">
          Intuition carried us through Chicago and back to Springfield.
        </h2>
        <div className="path-resistance-grid">
          <p>
            Papa&apos;s death pulled Granny back to Springfield while graduate
            school kept me in Kentucky. When Gold Eagle offered me a role in
            Chicago, Devin and I followed our intuition and took the leap. We
            built four years of life there, learned from the city, and carried
            our family story with us.
          </p>
          <p>
            Granny&apos;s open-heart surgery in 2023 sharpened the pull toward
            family. The 3M offer brought us to Springfield in 2024. The move
            joined my career to the place my family had already made home.
          </p>
        </div>
      </section>

      <section
        className="portrait-closing compact"
        aria-labelledby="career-record-heading"
      >
        <p className="portrait-index">The project record</p>
        <h2 id="career-record-heading">
          The career behind the AI architecture.
        </h2>
        <p>
          My path from industrial chemistry through manufacturing engineering
          into AI architecture shows how I translate technical systems into
          accountable production work. Continue through the
          <Link to="/evidence"> evidence record</Link>, explore my{" "}
          <Link to="/software">software practice</Link>, or{" "}
          <Link to="/interest">start a conversation</Link>.
        </p>
      </section>
    </main>
  );
}
