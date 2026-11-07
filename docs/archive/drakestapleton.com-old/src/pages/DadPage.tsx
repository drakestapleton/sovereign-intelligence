import { PageIntro } from "../components/PagePrimitives";
import { usePageMeta } from "../lib/usePageMeta";

const chapters = [
  {
    label: "The choice",
    title: "He chose us.",
    body: [
      "He met my mom through work. He was twenty-eight, still young, with his whole life ahead of him. My brother and I were four and six. Most men his age would have walked away from that. He stepped forward instead.",
      "From the first day, I carried none of his blood. He loved me completely anyway. Loving us was his choice, and he made it with everything he had.",
      "He filled the space our biological father left. On December 3, 2007, the court made official what was already true: he adopted my brother and me, and we became Ballentines. We celebrate that date every year as Ballentine Day.",
    ],
  },
  {
    label: "The lessons",
    title: "He taught me how to work, survive, and love.",
    body: [
      "He taught me how to work: show up, finish the job, and take pride in the doing. He taught me how to survive: stand back up, keep moving, and outlast the hard season.",
      "He taught me to give my life to something bigger than myself. He lived that lesson every day, driving nearly two hours each way to provide for us because he loved his craft and took pride in his trade.",
    ],
  },
  {
    label: "The man",
    title: "He showed me how to be a man.",
    body: [
      "Face the hard day head-on. Keep going when quitting looks easy. Love yourself, and love your neighbor more than yourself. Always. Always.",
      "He was a gifted carpenter and a junior preacher who loved the Bible and Jesus. He taught me to love every single person I encounter, and that our highest duty on this earth is to give back to humanity.",
      "He taught me how to love people, kids most of all. He gave me a model of the steady life I could build, at a time when I doubted myself and blamed myself for how my biological father treated me. His steady love taught me otherwise.",
    ],
  },
  {
    label: "The rock",
    title: "Rocks hold steady.",
    body: [
      "A rock holds steady through every storm. That was my dad. He has been gone since 2019, and I still feel him with me, steady as ever, through every new door.",
      "I carry his lessons into everything I build. I miss him, I am grateful for every lesson he put into me, and I still want to make him proud.",
      "Every time I love someone, my dad flows through me: what he taught me, what he instilled in me, what he showed me.",
    ],
  },
];

export function DadPage() {
  usePageMeta("/dad");

  return (
    <main className="wrap portrait-wrap dad-page">
      <PageIntro eyebrow="In loving memory" title="My dad was my rock.">
        <p>
          Mom is my everything. My family is my everything. My dad was my rock.
        </p>
      </PageIntro>

      <figure className="memorial-photo" aria-label="Photograph of Dad, to come">
        <div className="memorial-photo-frame">
          <p>A photograph of Dad will live here.</p>
        </div>
        <figcaption>Russell Ballentine</figcaption>
      </figure>

      <section className="lesson-list" aria-label="Remembering Dad">
        {chapters.map((chapter) => (
          <article key={chapter.title}>
            <p className="lesson-label">{chapter.label}</p>
            <div className="lesson-story">
              <h2>{chapter.title}</h2>
              {chapter.body.map((paragraph, index) => (
                <p key={index}>{paragraph}</p>
              ))}
            </div>
          </article>
        ))}
      </section>
    </main>
  );
}
