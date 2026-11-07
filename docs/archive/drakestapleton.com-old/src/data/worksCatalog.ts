import aegis from "../../content/works/aegis.md?raw";
import aien from "../../content/works/aien.md?raw";
import harness from "../../content/works/atlas-harness.md?raw";
import symphony from "../../content/works/atlas-symphony.md?raw";
import beltbrain from "../../content/works/beltbrain.md?raw";
import defiantmob from "../../content/works/defiantmob.md?raw";
import dhg from "../../content/works/dhg-hive.md?raw";
import foundations from "../../content/works/foundations-2025.md?raw";
import mobdev from "../../content/works/mobdev-panel-arena.md?raw";
import research from "../../content/works/research.md?raw";

export type Work = {
  slug: string;
  title: string;
  date: string;
  summary: string;
  markdown: string;
};

export const WORKS: Work[] = [
  {
    slug: "atlas-symphony",
    title: "Atlas Symphony",
    date: "30 July 2026",
    summary:
      "Atlas Symphony is a gated process that divides one task into isolated lanes, assigns an independent gatekeeper, and reserves final approval for the human operator.",
    markdown: symphony,
  },
  {
    slug: "atlas-harness",
    title: "Atlas Harness",
    date: "25 July 2026",
    summary:
      "Atlas Harness, formerly codeharness, is the policy and recovery desk that turns operating prose into typed rules, work lanes, completion checks, and source records.",
    markdown: harness,
  },
  {
    slug: "mobdev-panel-arena",
    title: "MobDev and Panel Arena",
    date: "July 2026",
    summary:
      "Inside MobPay, MobDev turns a task into a build brief and Panel Arena runs a six-vendor review before implementation.",
    markdown: mobdev,
  },
  {
    slug: "defiantmob",
    title: "DefiantMob",
    date: "February 2026 to May 2026",
    summary:
      "DefiantMob is production operator software for member operations, ledgers, training-desk automation, and payouts.",
    markdown: defiantmob,
  },
  {
    slug: "beltbrain",
    title: "BeltBrain",
    date: "Early 2026",
    summary:
      "BeltBrain is a local-first decision engine whose planning and inventory work depend on a strong system of record.",
    markdown: beltbrain,
  },
  {
    slug: "dhg-hive",
    title: "DHG, HiveMind, and Toolbox",
    date: "Early 2026",
    summary:
      "DHG, HiveMind, and Toolbox are the community platform and toolkit where hive became an organization pattern later carried into Atlas.",
    markdown: dhg,
  },
  {
    slug: "foundations-2025",
    title: "2025 Foundations",
    date: "2025",
    summary:
      "The 2025 foundations are the Financial Ledger, ParseSDS, CRM, meetings, and DMAIC systems built before models were orchestrated over them.",
    markdown: foundations,
  },
  {
    slug: "aien",
    title: "AIEN",
    date: "September 2026",
    summary:
      "AIEN is the sovereign cognitive architecture that runs compiled Rust and Mojo, a hardware TPM vault, and local inference on dedicated silicon.",
    markdown: aien,
  },
  {
    slug: "aegis",
    title: "AEGIS",
    date: "20 August 2026",
    summary:
      "AEGIS is the on-prem defensive extension of Atlas that reads existing security signals, contains an intrusion inside the authorized estate, and preserves the evidence.",
    markdown: aegis,
  },
  {
    slug: "research",
    title: "Orchestration Research",
    date: "September 2026",
    summary:
      "This study measures the software orchestration tax in large language model inference and the AIEN Sovereign Inference Stack on Grace Blackwell silicon.",
    markdown: research,
  },
];
