---
title: AEGIS
slug: aegis
date: 20 August 2026
summary: AEGIS is the on-prem defensive extension of Atlas that reads existing security signals, contains an intrusion inside the authorized estate, and preserves the evidence.
---

AEGIS is a defensive extension of Atlas. I am extending Atlas into AEGIS, an on-prem defensive project that reads existing security signals, recognizes an intrusion, and contains it inside the authorized estate.

The scope on the page is an Atlas extension, authorized networks, on-prem deployment, and evidence-bearing response.

The tagline on the page: "Authorized perimeter defense: detect intrusion, contain session, preserve evidence. Decisive policy containment inside the wire."

The scholar hub describes AEGIS as the defensive extension: hardware-enforced containment and evidence preservation for the Atlas organism.

On the AIEN page, AEGIS is the Shield in the triad. AEGIS provides the Shield: defensive perimeter containment and evidence preservation. Its operational line is: the defensive extension watching perimeter doors, recognizing hostile access, and containing intrusions inside authorized networks.

The Atlas page states the same extension. I am extending Atlas into an on-prem defender that reads existing security signals, contains an intrusion inside the authorized estate, and preserves the evidence. The first AEGIS adapter passed 59 of 62 checks in its frozen project suite on August 20, 2026.

## The network is the house

Data, payroll, source code, models, and trade secrets live behind the same boundary. AEGIS treats that boundary like a house: watch the door, recognize unauthorized access, isolate sessions, and preserve forensic trails for incident teams.

Early internal lore summarized the operating posture as "You touchy, I knock you out." In production, that means deterministic policy containment: verified allow-lists, session revocation, human escalation gates, and forensic audit preservation.

AEGIS sits above existing sensors and controls. The sequence stays short, inspectable, and bounded to the operator's authority.

## The response path

1. Observe. Watch the house. Read the IDS, DNS, identity, endpoint, and firewall signals already present in the security path.
2. Recognize. Name the intrusion. Correlate attacker behavior across sensors, separate routine noise from a break-in, and state the risk in plain language.
3. Contain. End the session. Choose one tested action inside the authorized estate: cut the session, isolate the host, block the path, or revoke the token.
4. Preserve. Keep the trail. Record the signal, decision, action, time, and result for the incident team.

The knockout on the page: cut the session, isolate the host, close the door, keep the evidence. The intruder loses access to this house, while the operator retains the systems, the authority, and the trail. The named containment actions are terminate session, isolate host, block path, revoke token, and preserve trail.

## The authority line

The fight ends at the door. AEGIS studies attacker behavior so it can close the path inside the authorized estate. The operator owns the policy, the automated allow-list, and every escalation decision.

Authorized estate: every automated action targets systems, devices, accounts, and sessions under the operator's authority.

Tested actions: containment relies on pre-cleared, bounded operations: revoke token, isolate host, block IP, terminate session.

Human escalation: novel attack patterns, uncertain attribution, or production-impacting cuts escalate to human incident responders.

Forensic preservation: every observation, decision, and intervention generates a timestamped, signed receipt for forensic review.

## Training evidence, 20 August 2026

The first AEGIS adapter has a real receipt. The frozen suite result on the page is 59/62.

A Grok-led training session continued the Devstral atlas-tools lineage into a rank-16 AEGIS LoRA. The run used one epoch at a 5e-6 learning rate on the Devstral-Small-2-24B-Instruct-abliterated base, then evaluated the vaulted adapter against the project's frozen 62-case suite.

The slices on the page:

| Slice | Score | Rate |
| --- | --- | --- |
| Tool use | 45/45 | 100% |
| Coding | 8/10 | 80% |
| Science | 3/4 | 75% |
| Cyber | 3/3 | 100% |

The three visible misses: JSONL parsing produced an indentation error. POSIX path joining missed a slash-normalization case. The RC science answer missed the required target.

The unmerged LoRA adapter is sealed in the Pi vault and recorded in a private model repository at 23:00 UTC.

The August 20 adapter and its 59/62 frozen-suite result establish the first AEGIS model milestone.

The evidence catalog states the same result as 59 of 62 checks (95.2%) in the frozen evaluation suite: 45/45 on tool use, 8/10 on coding, 3/4 on science, and 3/3 on cybersecurity containment actions within authorized estate boundaries. The claim period is 20 August 2026. The source named on that claim is `artifacts/aegis-eval-20260820.json`.
