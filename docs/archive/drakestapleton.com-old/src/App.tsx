import { Navigate, Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { AegisPage } from "./pages/AegisPage";
import { AienPage } from "./pages/AienPage";
import { DadPage } from "./pages/DadPage";
import { AtlasPage } from "./pages/AtlasPage";
import { EvidencePage } from "./pages/EvidencePage";
import { FirstRunPage } from "./pages/FirstRunPage";
import { HomePage } from "./pages/HomePage";
import { InterestPage } from "./pages/InterestPage";
import { MapPage } from "./pages/MapPage";
import { NotFoundPage } from "./pages/NotFoundPage";
import { OmegaPage } from "./pages/OmegaPage";
import { PathPage } from "./pages/PathPage";
import { ScholarPage } from "./pages/ScholarPage";
import { SoftwarePage } from "./pages/SoftwarePage";
import { SymphonyPage } from "./pages/SymphonyPage";
import { WhatILearnedPage } from "./pages/WhatILearnedPage";
import { ResearchPage } from "./pages/ResearchPage";
import { WorkflowPage } from "./pages/WorkflowPage";
import { WorkReaderPage } from "./pages/WorkReaderPage";
import { WorksIndexPage } from "./pages/WorksIndexPage";

function Portfolio() {
  return (
    <Routes>
      <Route element={<Layout />}>
        <Route path="/" element={<HomePage />} />
        <Route path="/interest" element={<InterestPage />} />
      <Route path="/dad" element={<DadPage />} />
        <Route path="/atlas" element={<AtlasPage />} />
        <Route path="/aegis" element={<AegisPage />} />
        <Route path="/aien" element={<AienPage />} />
        <Route path="/research" element={<ResearchPage />} />
        <Route path="/scholar" element={<ScholarPage />} />
        <Route path="/scholar/omega" element={<OmegaPage />} />
        <Route path="/path" element={<PathPage />} />
        <Route path="/software" element={<SoftwarePage />} />
        <Route path="/evidence" element={<EvidencePage />} />
        <Route path="/what-i-learned" element={<WhatILearnedPage />} />
        <Route path="/what-broke" element={<Navigate to="/what-i-learned" replace />} />
        <Route path="/symphony" element={<SymphonyPage />} />
        <Route path="/symphony/first" element={<FirstRunPage />} />
        <Route path="/symphony/workflow" element={<WorkflowPage />} />
        <Route path="/symphony/map" element={<MapPage />} />
        <Route path="/works" element={<WorksIndexPage />} />
        <Route path="/works/:slug" element={<WorkReaderPage />} />
        <Route path="/atlas-symphony" element={<Navigate to="/symphony" replace />} />
        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  );
}

export function App() {
  return <Portfolio />;
}
