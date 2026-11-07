import { Link } from "react-router-dom";
import { WORKS } from "../data/worksCatalog";
import "../styles/reader.css";

export function WorksIndexPage() {
  return (
    <main className="reader">
      <h1>Works</h1>
      <ul className="reader-index">
        {WORKS.map((work) => (
          <li key={work.slug}>
            <article>
              <Link to={`/works/${work.slug}`}>
                <h2>{work.title}</h2>
                <p className="reader-date">{work.date}</p>
                <p>{work.summary}</p>
              </Link>
            </article>
          </li>
        ))}
      </ul>
    </main>
  );
}
