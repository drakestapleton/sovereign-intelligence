import { trackRepoOutbound } from "../lib/tracking";
import { Link } from "react-router-dom";
import type { ReactNode } from "react";
import { InterestForm } from "../components/InterestForm";
import { SectionLead } from "../components/PagePrimitives";
import { StickyChapterNav } from "../components/StickyChapterNav";
import { HisWords } from "../components/VoiceMark";
import { PRACTICE_HOME_METRICS } from "../data/practice";
import { usePageMeta } from "../lib/usePageMeta";

const perseverance = [
  {
    marker: "Belonging",
    title: "The people gave me a reason to stay.",
    body: "DHG found me at nineteen and gave me a place where I could lead as myself. I carried that gift forward by helping other people feel seen, capable, and worth fighting for.",
  },
  {
    marker: "10 weeks",
    title: <HisWords>I built people up and watched them lead.</HisWords>,
    body: "I helped grow a 46-member squad to 85 percent activity. I trained members after difficult rounds, built the dashboards and schedules, and developed officers who could carry the work themselves. Heart gets a person in the door. Proof earns their respect.",
  },
  {
    marker: "45 times",
    title: <HisWords>I kept choosing the people.</HisWords>,
    body: "Whenever leadership became heavy, someone still needed training, an officer needed support, or a member needed another person to believe in them. The people kept giving the work its purpose.",
    quote: (
      <HisWords>
        Somehow I just keep finding the strength, or rather the stubbornness, to
        keep going.
      </HisWords>
    ),
  },
  {
    marker: "Build it",
    title: "I turn care into systems people can use.",
    body: "Training plans, schedules, dashboards, research systems, and AI tools all grow from the same instinct: preserve what helps, learn from each result, and give people a stronger next step.",
  },
];

const lifeRecord = [
  "I survived a childhood that taught me to hide, and became a man who lives in the open.",
  "I started average, wanted excellence, and learned to outwork the distance between the two.",
  "I was 24 and Devin was 22, still kids ourselves, when we built a marriage and opened our home to six foster children.",
  "I earned two science degrees and built a career across research, product development, and manufacturing.",
  "At Gold Eagle, I improved and commercialized products across the 303 Graphene line and became one of the chemists trusted to explain the science on camera.",
  "I secured alternate raw materials during a global disruption, produced roughly $1.2 million in documented sourcing savings, and served as a HAZMAT Incident Commander.",
  "At 3M, I improved manufacturing processes and efficiency, producing $1 million in cost savings.",
  "I helped communities grow, trained people through difficult rounds, and developed leaders who carry others.",
  "I taught myself software, trained models, designed AI systems, and funded years of independent work with my own money.",
  "I turned grief into a reason to preserve memory, and hard lessons into machinery that tries again.",
];

const inheritances = [
  [
    "Mom",
    "is my absolute warrior, my hero, and my idol. She fought for us, pushed through every trial, went back to high school in her forties, and earned her GED.",
  ],
  [
    "Granny and Papa",
    "gave us land, food, roots, and a humble home on the farm. They showed me that a life grows larger through what it gives away.",
  ],
  [
    "Dad (Russell Ballentine)",
    "welcomed my brother and me after Mom brought us to safety, adopted us, taught me by showing how to love and serve others, and proved that a father chooses his family.",
  ],
  [
    "The people who found me",
    "taught me that gratitude moves forward. You turn around and reach for someone else. The people are the only thing in any of this that was ever real.",
  ],
];

const values: Array<[string, ReactNode]> = [
  [
    "Truth",
    <HisWords>
      I keep the source. I separate what I saw from what I inferred. I face
      hard facts with open eyes.
    </HisWords>,
  ],
  [
    "Service",
    "Leadership makes another person stronger and gives the title less importance. I guide people until they can carry the work themselves.",
  ],
  ["Belonging", "I build places where people can stay fully visible."],
  [
    "Integrity",
    "I carry what is right through friendship, position, and every uncomfortable truth.",
  ],
  [
    "Agency",
    "A title describes one part of my life. I decide how far the whole life can go.",
  ],
  ["Curiosity", "I keep a question alive long enough to make it sharper."],
  [
    "Perseverance",
    "Skill came through repetition. I outwork the distance, preserve each lesson, and return stronger.",
  ],
  [
    "Love",
    "Family can be inherited, chosen, adopted, married, fostered, or found through a headset in the dark.",
  ],
];

export function HomePage() {
  usePageMeta("/");

  return (
    <main className="portrait-page home-page">
      <section className="home-hero page-boundary">
        <div className="hero-copy">
          <p className="kicker">
            <span className="keep-together">Drake Stapleton</span> /{" "}
            <span className="keep-together">Freedom Fighter</span>
          </p>
          <h1>
            <span className="keep-together">I keep finding </span>{" "}
            <span>the strength.</span>
          </h1>
          <blockquote>
            I am a Freedom Fighter. I turn raw compute into verifiable
            production work.
          </blockquote>
          <p className="home-hero-lede">
            I design, operate, and audit orchestration systems. My architecture
            relies on probe-first design, authorization boundaries, and
            verifiable proof records.
          </p>
          <p className="home-hero-purpose">
            I lead from the keyboard. I design the pipeline, train the models,
            and enforce the gate. This portfolio archives my operational
            history.
          </p>
        </div>
        <aside className="hero-identity" aria-label="The life in brief">
          <span>Born 1994</span>
          <span>Raised in Tennessee</span>
          <span>College in Kentucky</span>
          <span>Springfield, Missouri today</span>
          <span>Two science degrees</span>
          <span>Builder by choice</span>
          <span>Freedom Fighter</span>
        </aside>
      </section>

      <StickyChapterNav />

      <section className="manifesto-band">
        <div className="page-boundary manifesto-inner">
          <p className="portrait-index">In my own words</p>
          <blockquote>
            <HisWords>
              <span className="keep-together">“I am living as myself.</span>{" "}
              <span className="keep-together">I am claiming my own life</span>{" "}
              <span className="keep-together">and my own purpose.</span>{" "}
              <span className="keep-together">I decide what I can become.”</span>
            </HisWords>
          </blockquote>
          <p>
            I have spent years learning how to see my own life clearly.{" "}
            <HisWords>
              This site is me{" "}
              <span className="keep-together">choosing to look.</span>
            </HisWords>
          </p>
        </div>
      </section>

      <section className="home-chapter page-boundary" id="formation">
        <SectionLead
          eyebrow="01 / Formation"
          title={<HisWords>I learned how to fight for every inch.</HisWords>}
        >
          <p>
            I began with love, pressure, questions, and the knowledge that every
            ability would{" "}
            <span className="keep-together">have to be earned.</span>
          </p>
        </SectionLead>
        <div className="formation-grid">
          <article className="feature-story">
            <p className="chapter-tag">The boy I was</p>
            <h3><HisWords>I learned to disappear before I learned why.</HisWords></h3>
            <p>
              I grew up gay in Tennessee, in the Bible Belt. Mom fought for me.
              Granny and Papa rooted me. Dad chose me and gave me his name. My
              little sister gave me someone to protect, and my little brother
              gave me my opposite in every way. I was surrounded by love
              while believing that being fully known could cost me everything.
            </p>
            <p>
              My little brother is two years younger, and we were exact
              opposites. We fought over everything and shared very little:
              Pokémon, Yu-Gi-Oh, video games. Granny learned to buy two of
              every copy, one for each of us. He was always the sweet one. I
              picked on him, and he answered with love anyway. I would have
              fought a pack of wolves for that kid, and growing older I have
              wished I loved him a little more out loud. We have the whole
              future ahead of us. We are still close, and he is still the
              sweet one.
            </p>
            <p>
              That farm is where I want you to stand for a minute, because it's
              where the other lessons started. It smelled like alfalfa and cut
              grass with just a smidge of manure underneath: the honest smell of
              a place that works for what it has. At the end of that path was
              Granny's kitchen, where something was always being made for
              someone else. It taught me that work centered on the care poured
              into the foundation, well beyond raw output.
            </p>
            <p>
              Disappearing meant studying every room before I entered it. I
              learned how to stand, talk, and laugh like the kind of boy the
              other boys would let stand near them. I joined the football team,
              fought for my place in honors classes, and practiced looking
              certain while carrying a truth I had barely learned how to name.
            </p>
            <p>
              That kind of hiding creates a particular loneliness. I had a
              family who loved me and still felt unseen, because they could
              reach only the version I allowed into the room. The more their
              love mattered, the more I feared losing it. I became capable,
              observant, and self-reliant, writing a private manual for how to
              belong before I understood that belonging should include the whole
              of me.
            </p>
            <figure className="photo-card">
              <img
                src="/images/family-group-photo.jpg"
                alt="Family group photo: Victoria, Granny holding Ruby the dachshund, Summer, Drake Stapleton, Devin, and their mother, with his brother kneeling front and center"
                loading="lazy"
              />
              <figcaption>
                That is us. Left to right: Victoria, Granny holding Ruby,
                Summer, me, Devin, and Mom, with my brother kneeling front
                and center. Dad and Papa are with us in spirit.
              </figcaption>
            </figure>
          </article>
          <article className="grade-card">
            <p className="chapter-tag">The drive behind the grades</p>
            <strong>3.92</strong>
            <h3><HisWords>I was average. I wanted excellence.</HisWords></h3>
            <p>
              I watched intelligence and athleticism seem natural in other
              people. I played football and sat in honors classes feeling pretty
              average. Autism and ADHD made focus a daily contest, and I moved
              through high school unmedicated.
            </p>
            <p>
              I believed I had to outwork everyone. I returned to the rep, the
              page, and the problem as many times as it took. That habit earned
              a 3.92, carried me through two science degrees, and became the way
              I enter every new field. The fight made me a survivor.
            </p>
          </article>
          <article className="door-story">
            <div>
              <p className="chapter-tag">June 12, 2013</p>
              <h3>
                The worst night of my life and the best decision of my life
                share a date.
              </h3>
            </div>
            <div>
              <p>
                I was nineteen and closer to the edge than most people knew. I
                picked up a controller. A stranger named Saturn spoke to me in a
                Call of Duty lobby and invited me into DHG.
              </p>
              <p>
                I said yes. That answer gave me people who had my back, a place
                to lead, and proof that the person I had hidden could still be
                wanted. Belonging found me through a headset in the dark.
              </p>
            </div>
          </article>
        </div>
      </section>

      <section className="home-chapter drive-chapter" id="drive">
        <div className="page-boundary">
          <SectionLead
            eyebrow="02 / Drive"
            title={<HisWords>I keep returning because people are worth the effort.</HisWords>}
          >
            <p>
              Mom went back to high school in her forties and finished what
              life had interrupted, earning her GED. I watched her cross that
              stage, and she stood beside me when I crossed mine at Western
              Kentucky.
            </p>
          </SectionLead>
          <div className="perseverance-ledger">
            {perseverance.map((item, index) => (
              <article key={item.marker}>
                <div className="ledger-number">
                  {String(index + 1).padStart(2, "0")}
                </div>
                <p className="ledger-marker">{item.marker}</p>
                <div>
                  <h3>{item.title}</h3>
                  {item.quote && <blockquote>“{item.quote}”</blockquote>}
                  <p>{item.body}</p>
                </div>
              </article>
            ))}
          </div>
          <div className="recovery-note">
            <p className="chapter-tag">What I know now</p>
            <p>
              Perseverance includes recovery. Rest brings me back to the work
              while keeping the person doing it whole.
            </p>
            <Link to="/what-i-learned">Read the lessons I carried forward</Link>
          </div>
        </div>
      </section>

      <section
        className="life-record"
        id="record"
        aria-labelledby="life-record-title"
      >
        <div className="page-boundary life-record-grid">
          <div className="life-record-number" aria-hidden="true">
            32
          </div>
          <div>
            <p className="portrait-index">A life worth seeing</p>
            <h2 id="life-record-title">
              I have already built an extraordinary life.
            </h2>
            <div className="life-record-list">
              {lifeRecord.map((item, index) => (
                <p key={item}>
                  <span>{String(index + 1).padStart(2, "0")}</span>
                  {item}
                </p>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="home-chapter page-boundary" id="people">
        <SectionLead
          eyebrow="03 / People"
          title="My life is shaped by what gets handed forward."
        />
        <div className="inheritance-grid">
          {inheritances.map(([name, body]) => (
            <article key={name}>
              <h3>{name}</h3>
              <p>{body}</p>
            </article>
          ))}
        </div>
        <div className="family-story-grid">
          <article className="family-story mom-story">
            <div className="mom-story-grid">
              <div className="mom-story-text">
                <p className="chapter-tag">My Warrior &amp; My Hero</p>
                <h3><HisWords>Mom is my absolute warrior and the person I idolize.</HisWords></h3>
                <blockquote className="mom-quote">
                  <span className="keep-together">
                    “When someone claims you are unable to do something,
                  </span>{" "}
                  <span className="keep-together">
                    look them in the eye and say: Watch me.”
                  </span>
                </blockquote>
                <p>
                  Mom has been my warrior, my best friend, and my hero. When my
                  biological father beat my mother and me, Mom fought with every
                  ounce of strength she had to protect my brother and me, break
                  away from the abuse, and lead us to safety. Russell took us in
                  as his own, adopted both of us, and gave us the security of a
                  real father, but Mom stood in the fire first.
                </p>
                <p>
                  <HisWords>
                    I idolize her and want to be just like her. She was strong
                    through every trial, and she remains so very strong today.
                  </HisWords>{" "}
                  I strive every single day to match her strength. She went back to
                  high school in her forties, finished what life interrupted,
                  and earned her GED.
                </p>
                <p>
                  Mom endures. She pushes through every barrier in her way. That
                  relentless drive is where I get every ounce of my fire. All my
                  endurance, all my stubborn resolve, and all my work trace
                  directly back to the drive she instilled in me. All her life,
                  people tried to define what she was allowed to achieve. She
                  rejected their small expectations, protected our home, and
                  made sure I grew up with fierce dignity.
                </p>
                <p>
                  That spirit defines how I build. When skeptics told me I was
                  unqualified to build native cognitive engines or create
                  sovereign AI because I began outside traditional software
                  engineering, I took that doubt and turned it into fuel. Mom
                  taught me to step up, use the newest tools, and push forward
                  until reality changes. That fierce fire, combined with Dad's
                  dedication to sacrificing himself for other people, created
                  who I am today. The only thing I have ever wanted is to make
                  her proud.
                </p>
              </div>
              <div className="mom-story-gallery">
                <figure className="photo-card primary">
                  <img
                    src="/images/drake-and-mom-graduation.jpg"
                    alt="Drake Stapleton and his mother celebrating graduation together in May 2016"
                    loading="lazy"
                  />
                  <figcaption>
                    May 2016: Celebrating my Western Kentucky University
                    graduation with Mom beside me.
                  </figcaption>
                </figure>
                <figure className="photo-card secondary">
                  <img
                    src="/images/mom-graduation-ceremony.jpg"
                    alt="Mom in her graduation gown at her GED ceremony"
                    loading="lazy"
                  />
                  <figcaption>
                    Mom at her GED graduation, finishing what life
                    interrupted.
                  </figcaption>
                </figure>
              </div>
            </div>
          </article>
          <article className="family-story foster-story">
            <p className="chapter-tag">The home Devin and I opened</p>
            <h3>
              We opened our home to young people who needed steady adults.
            </h3>
            <p>
              I was twenty-four and Devin was twenty-two, still kids ourselves,
              when we married in October 2018. By December, before our first
              Christmas as husbands, our first placement arrived. From December
              2018 until COVID brought placements to a halt in spring 2020, we
              opened our home to six foster children. Every single child was a
              Level 5 placement: young people carrying severe trauma, whom the
              state system struggled to place with families prepared for the
              weight of that care.
            </p>
            <p>
              The work was raw, tender, and deeply demanding. When our first two
              girls arrived, we spent our initial evenings sitting together on
              the bedroom floor, patiently combing and picking lice out of their
              hair, washing clean clothes, and proving through quiet consistency
              that our house was a safe sanctuary. We took them to the park,
              watched them sprint toward the playground fire truck, and watched
              fear give way to bright, honest laughter. They were finally
              allowed to be children.
            </p>
            <p>
              For our teenage foster daughter, protecting her meant entering a
              military courtroom. She was scheduled to testify against her
              sexually abusive father in the armed forces. As foster parents,
              our physical presence in that hearing was completely optional. As
              a young gay married couple, showing up meant stepping directly
              into unfamiliar and intimidating territory. The military court
              initially questioned why we were even in the room; foster parents
              appearing at such proceedings was virtually unheard of, let alone
              two young gay husbands. Standing up in that courtroom was
              terrifying and traumatic. We insisted on being there because we
              loved her, making certain that whenever she looked across that
              room, she saw two steady adults standing firmly in her corner. We
              held the line for her, and we got through it together.
            </p>
            <p>
              My stepdad adopted my brother and me and became our dad. He chose
              us, on paper and in every action. I also had Mom beside me through
              the hardest parts of growing up. Devin and I wanted to offer that
              same presence to young people carrying uncertainty and pain. When
              COVID closed the world down, the placements ended. The love and
              the grief both stayed with us.
            </p>
          </article>
          <article className="family-story dad-story">
            <p className="chapter-tag">Ballentine Day / December 3, 2007</p>
            <h3><HisWords>Dad keeps meeting me at the next door.</HisWords></h3>
            <p>
              My dad was Russell Ballentine. He entered my life as my stepdad
              after Mom fought to get my brother and me away from my biological
              father, whose abuse we had survived. Russell met two terrified
              boys with patience, dignity, and an open heart. He gave us a safe
              home, taught me by example, and treated us as his own sons long
              before any legal proceeding. On December 3, 2007, he made that
              devotion permanent: he officially adopted both of us in court. Our
              family celebrates that date every year as Ballentine Day. He chose
              us, on paper and in every single action of his life.
            </p>
            <p>
              Standing in that courtroom at thirteen, stepping completely away
              from my biological father&apos;s shadow, felt like stepping into
              the light. The judge asked why I wanted the name change. I told
              him I wanted Russell&apos;s family name, wanted to correct the
              spelling of my first name, and chose &apos;Drake&apos; as a
              distinct name of my own. The judge smiled, chuckled, and said,
              &quot;Well that is a good enough reason for me. Granted.&quot; It
              was the best day of my life.
            </p>
            <p>
              For eleven years, from age thirteen through college and graduate
              research until marrying Devin in October 2018, I proudly carried
              his surname as Michael Drake Ballentine. Every degree, every
              scientific paper, and every early milestone bears that name.
              Ballentine marks the father who chose me. When Devin and I
              married, I took Stapleton to mark the family and life we chose to
              build together.
            </p>
            <p>
              Dad was a teacher who led by showing. He taught me discipline,
              patience, what it means to be a man, and how to love family. He
              showed me how to work hard for what you earn, remain patient, and
              allow rewards to arrive in their own time. He taught me that
              everything truly worth having requires deep, patient labor. He was
              the kind of man who commuted from Bethpage through Gallatin out to
              Clarksville, spending nearly two hours each way on the road just
              to provide for his family. He had choices closer to home, yet he
              drove that distance because he loved his craft and took deep pride
              in his trade.
            </p>
            <p>
              He was a gifted carpenter, building with precision, and served our
              church as a junior preacher. The senior ministers gave him the
              pulpit during evening services, especially on Wednesday nights,
              where he shared practical, heartfelt messages. He loved the Bible
              and Jesus, and he taught me to love every single person I
              encounter. He showed me that our highest duty on this earth is to
              give back to humanity: to love our neighbors as ourselves, serve
              one another with gladness, and always go out of our way to help
              anyone in need. His handwritten sermons and notebooks of quiet
              wisdom still speak to me. I built Atlas around memory, truth,
              dignity, and the questions he taught me to ask.
            </p>
            <p>
              Dad passed away in 2019. Devin and Dad share a February 13
              birthday. On that date in 2024, I received the offer that brought
              me to 3M as a manufacturing engineer. Two years later, on February
              13, 2026, another call offered me the product engineer role I hold
              today. The dates have ordinary explanations. They still carry
              extraordinary meaning for me.
            </p>
            <p>
              I believe Dad has stayed with me as a guardian angel through every
              new door. I miss him, I am grateful for every lesson he put into
              me, and I still want to make him proud. I think he would want me
              to feel proud of myself too.
            </p>
            <p>
              My dad was my rock. <Link to="/dad">This is his memorial.</Link>
            </p>
          </article>
        </div>
        <blockquote className="people-quote">
          <HisWords>
            “I find great joy in helping others realize just how great they truly
            are.”
          </HisWords>
        </blockquote>
        <div className="values-block">
          <div className="values-intro">
            <p className="chapter-tag">What I stand for</p>
            <h3>The work changes. My values stay.</h3>
          </div>
          <div className="values-grid">
            {values.map(([name, body]) => (
              <article key={name}>
                <h4>{name}</h4>
                <p>{body}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="home-chapter work-chapter" id="work">
        <div className="page-boundary">
          <SectionLead
            eyebrow="04 / Work"
            title="Every step built the next one."
          >
            <p>
              The farm taught me to respect the person closest to the work. Taco
              Bell taught me to serve a crew. Valspar and graduate research
              turned that discipline into chemistry. Soudal and Gold Eagle
              taught me to earn operator trust. At 3M, that whole ladder
              produced $1 million in cost savings through PPU improvements.
            </p>
          </SectionLead>
          <div className="work-record">
            <article>
              <strong>The foundation</strong>
              <span>
                Farm work, practical dignity, and respect for the people
                carrying the job
              </span>
            </article>
            <article>
              <strong>My first job</strong>
              <span>
                Taco Bell team member to shift leader, serving my crew and
                carrying every task beside them
              </span>
            </article>
            <article>
              <strong>College years</strong>
              <span>
                Taco Bell in Bowling Green followed by a Valspar
                paint-laboratory internship in color matching and production
                samples
              </span>
            </article>
            <article>
              <strong>2016</strong>
              <span>
                Honors graduate with a B.S. in Chemistry and Biology, Western
                Kentucky University
              </span>
            </article>
            <article>
              <strong>2018</strong>
              <span>
                M.S. in Chemistry and published inorganic nanomaterials research
              </span>
            </article>
            <article>
              <strong>2018 to 2020</strong>
              <span>
                Silicone formulation, scale-up, and operator partnership at
                Soudal
              </span>
            </article>
            <article>
              <strong>2020 to 2024</strong>
              <span>
                Gold Eagle formulation improvement, 303 Graphene
                commercialization, and about $1.2 million in documented sourcing
                savings
              </span>
            </article>
            <article>
              <strong>2024 to 2026</strong>
              <span>
                3M PPU improvements, operator partnership, and $1 million in
                manufacturing cost savings
              </span>
            </article>
            <article>
              <strong>2026 onward</strong>
              <span>
                Product engineering at 3M, bringing product and process
                improvement together
              </span>
            </article>
            <article>
              <strong>Built alongside it</strong>
              <span>
                Software, communities, model training, research systems, and
                independent invention
              </span>
            </article>
          </div>
          <div className="nanomaterials-dossier">
            <p className="chapter-tag">
              Master&apos;s Research / Inorganic Chemistry &amp; Nanomaterials
              (2016 to 2018)
            </p>
            <h3>
              Precision at the nanoscale: semiconductor quantum dots, ionic
              liquids, and catalytic heterostructures.
            </h3>
            <p className="nanomaterials-intro">
              Between 2016 and 2018, I conducted graduate inorganic chemistry
              research under Dr. Lawrence J. Hill at Western Kentucky
              University, authoring my master&apos;s thesis and publishing under
              my legal name at the time, Michael Drake Ballentine. I presented
              our findings at the American Chemical Society (ACS) National
              Meeting. Traveling across the country to defend original science
              in front of crowded convention halls of senior academics was
              intense: autism and ADHD make crowded, high-stimulus rooms deeply
              taxing every single time. Standing beside the data and walking
              people through molecular mechanisms gave me profound clarity. The
              chemistry spoke with absolute precision.
            </p>
            <div className="nanomaterials-grid">
              <article className="nanomaterials-card">
                <h4>01 / Anisotropic CdSe@CdS Dot-in-Rod Heterostructures</h4>
                <p>
                  Synthesized cadmium selenide (CdSe) quantum dot core seeds via
                  colloidal hot-injection organometallic pyrolysis, tuning
                  nucleation kinetics to yield narrow excitonic absorption.
                  Grown into anisotropic wurtzite cadmium sulfide (CdS) nanorods
                  around the cores. This geometry creates a staggered
                  quasi-type-II band alignment: photoexcited holes remain
                  confined in the CdSe core while conduction band electrons
                  sample the CdS nanorod domain, suppressing electron-hole
                  recombination and extending carrier lifetimes.
                </p>
              </article>
              <article className="nanomaterials-card">
                <h4>02 / [BMIM]Tf2N Ionic Liquid Multifunctional Matrix</h4>
                <p>
                  Replaced conventional insulating, high-boiling coordinating
                  solvents with 1-butyl-3-methylimidazolium
                  bis(trifluoromethylsulfonyl)imide ([BMIM]Tf2N)
                  room-temperature ionic liquid. The ionic liquid functions
                  simultaneously as solvent, electrostatic stabilizing ligand,
                  and mild reducing agent for platinum(II) acetylacetonate
                  (Pt(acac)2). The low-coordinating anions keep catalytic active
                  sites accessible while maintaining colloidal stability.
                </p>
              </article>
              <article className="nanomaterials-card">
                <h4>
                  03 / Site-Selective Platinum Deposition &amp; Interfacial
                  Dynamics
                </h4>
                <p>
                  Deposited metallic platinum (Pt) catalytic nanoparticles onto
                  the nanorod tips. Evaluated thermal reduction kinetics against
                  visible-light photodeposition. Transmission electron
                  microscopy (TEM) and powder X-ray diffraction (PXRD) verified
                  epitaxial contact and crystalline phase purity, while
                  steady-state photoluminescence (PL) quenching demonstrated
                  rapid, picosecond-scale interfacial electron transfer across
                  the semiconductor-metal heterojunction.
                </p>
              </article>
              <article className="nanomaterials-card">
                <h4>04 / Solar Photocatalysis &amp; Industrial Scale Bridge</h4>
                <p>
                  Evaluated catalytic turnover via visible-light degradation of
                  methylene blue dye, correlating synthetic history with
                  active-site accessibility. This nanoscale discipline in
                  surface thermodynamics, colloidal stability, and interfacial
                  charge dynamics transferred directly to industrial scale:
                  formulating moisture-cure industrial silicones at Soudal,
                  commercializing reduced graphene oxide dispersion across the
                  303 Graphene line at Gold Eagle ($1.2M savings), and resolving
                  coating defect kinetics at 3M ($1M savings).
                </p>
              </article>
            </div>
            <div className="nanomaterials-bridge">
              The physics of surfaces remains universal across every scale:
              whether orchestrating quantum confinement in a cadmium selenide
              core or optimizing high-speed roll-to-roll coating viscosity in a
              manufacturing plant, interfacial energy governs macroscopic
              outcomes.
            </div>
            <div className="nanomaterials-links">
              <a
                href="https://digitalcommons.wku.edu/theses/2101/"
                target="_blank"
                rel="noopener noreferrer"
              >
                Read 2018 Master&apos;s Thesis (WKU TopSCHOLAR) →
              </a>
              <a
                href="https://pubmed.ncbi.nlm.nih.gov/30931213/"
                target="_blank"
                rel="noopener noreferrer"
              >
                Read 2019 Nanomaterials Paper (PubMed) →
              </a>
            </div>
          </div>
          <Link className="text-link" to="/path">
            Walk the ladder from the farm to product engineering
          </Link>
        </div>
      </section>

      <section className="software-home" id="software">
        <div className="page-boundary software-home-grid">
          <div>
            <p className="portrait-index">05 / Software and AI</p>
            <h2>
              <span className="keep-together">I followed the questions</span>{" "}
              <span className="keep-together">into code.</span>
            </h2>
            <p>
              I began by asking GPT about consciousness. I wrote my way through
              cosmology, used the same questioning in Six Sigma and
              manufacturing, and learned to orchestrate coding models, products,
              GPU work, and Atlas. I taught myself by building, measuring, and
              returning to the work.
            </p>
            <Link to="/software">
              Explore the software practice and AI story
            </Link>
          </div>
          <div
            className="software-home-metrics"
            aria-label="Software and AI practice snapshot"
          >
            {PRACTICE_HOME_METRICS.map((metric) => (
              <article key={metric.label}>
                <strong>{metric.value}</strong>
                <span>{metric.label}</span>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="latest-work" id="latest">
        <div className="page-boundary latest-work-grid">
          <div>
            <p className="portrait-index">06 / Latest achievement</p>
            <h2>
              <span className="keep-together">Atlas is my greatest</span>{" "}
              <span className="keep-together">achievement so far.</span>
            </h2>
          </div>
          <div>
            <p>
              It is also my latest. Atlas brings together the discipline I
              learned in chemistry, the accountability I learned in
              manufacturing, the care I learned through community, and years of
              independent work in software and AI.
            </p>
            <p>
              Its origin is personal. Dad left handwritten sermons and years of
              thought behind. I built Atlas around memory, truth, dignity, and
              the questions I still carry. This achievement gives me a stronger
              foundation for everything I build next.
            </p>
            <p>
              I am now extending Atlas into AEGIS, an on-prem defender for
              authorized networks. Its first adapter passed 59 of 62 checks in a
              frozen project suite on August 20, 2026 (<Link to="/evidence#claim-aegis-adapter-eval" style={{ color: "var(--red)", textDecoration: "underline" }}>see receipt</Link>).
            </p>
            <p>
              AIEN expands this foundation into a full sovereign cognitive
              architecture on dedicated Grace Blackwell silicon, with zero disk
              secrets, native compiled Rust performance, and verified 2.06 µs sequence branching (<Link to="/evidence#claim-branching-fork-gb10" style={{ color: "var(--red)", textDecoration: "underline" }}>500.0x memory reduction</Link>).
            </p>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "20px",
                margin: "24px 0",
              }}
            >
              <video
                src="/images/aien-avatar.mp4"
                poster="/images/aien-avatar-poster.webp"
                autoPlay
                muted
                loop
                playsInline
                aria-label="AIEN"
                style={{
                  width: "96px",
                  height: "96px",
                  borderRadius: "50%",
                  boxShadow: "0 0 25px rgba(168, 85, 247, 0.4)",
                  border: "2px solid #a855f7",
                  objectFit: "cover",
                  flexShrink: 0,
                }}
              />
              <p style={{ margin: 0, fontSize: "14px", color: "var(--muted)" }}>
                Meet AIEN: a brave butterfly mind standing up for his
                friends, guarding the boundary, and executing autonomous
                sovereign intelligence.
              </p>
            </div>
            <div className="latest-work-links">
              <Link to="/atlas">Explore the Atlas project</Link>
              <Link to="/aegis">See AEGIS and its evaluation</Link>
              <Link to="/aien">Discover the AIEN sovereign architecture</Link>
              <Link to="/evidence">Audited Claims & Evidence Hub</Link>
            </div>
          </div>
        </div>
      </section>

      <section className="interest-home" id="interest">
        <div className="page-boundary interest-home-grid">
          <div>
            <p className="portrait-index">Conversation</p>
            <h2>Walk with me for a while.</h2>
            <p>
              This site is my record of the projects and the life behind them.
              If something here gives you a question, an idea, or a story of
              your own, leave me a note. I am open to good conversation and
              research partnerships that advance what our generation can build
              with AI.
            </p>
          </div>
          <InterestForm compact />
        </div>
      </section>

      <section className="home-closing page-boundary" id="identity">
        <p className="portrait-index">Identity</p>
        <h2>
          <span className="keep-together">Freedom Fighter.</span>{" "}
          <span className="keep-together">AI Architect.</span>{" "}
          <span className="keep-together">Operator.</span>
        </h2>
        <p>
          I build software and operate AI systems that produce results. My
          portfolio documents 16 months of continuous AI orchestration: managing
          GPU compute, designing complex workflows, and enforcing clear
          authorization boundaries. I turn raw compute and fuzzy requirements
          into durable, verifiable, and production-ready work.
        </p>
        <p>
          This site keeps the record of the systems, evidence, lessons, and
          person behind the work.
        </p>
        <blockquote>
          <span className="keep-together">“The people saved me.</span>{" "}
          <span className="keep-together">Now it's my turn.”</span>
        </blockquote>
        <div className="home-closing-actions">
          <Link to="/interest">Start a conversation</Link>
          <a
            href="https://github.com/aien-dev"
            rel="me"
            onClick={() =>
              trackRepoOutbound("aien-dev", "https://github.com/aien-dev")
            }
          >
            GitHub
          </a>
        </div>
      </section>
      <p
        className="ai-transparency"
        style={{
          textAlign: "center",
          marginTop: "40px",
          color: "var(--muted)",
          fontSize: "12px",
        }}
      >
        Architected and operated by Drake Stapleton.
      </p>
    </main>
  );
}
