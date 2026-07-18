# MITRE — TryHackMe SOC Level 1

Room: Cyber Defence Frameworks module
Path: SOC Level 1

## Overview

This room explores the suite of frameworks and resources MITRE has made available to the cyber security community: ATT&CK, the Cyber Analytics Repository (CAR), D3FEND, AADAPT, and ATLAS. Together these tools give defenders and red teams a shared language for describing adversary behavior and translating threat intelligence into real detections.

## Task 1 — Introduction

No answer needed. Acknowledged the learning objectives and prerequisites before diving into the room.

![Task 1](Screen%20Shot%202026-07-18%20at%205.37.12%20PM.png)

## Task 2 — ATT&CK Framework

ATT&CK documents adversary TTPs (Tactics, Techniques, Procedures) at three levels: the Tactic is the "why," the Technique is the "how," and the Procedure is the specific implementation. The framework was created in 2013 and has expanded from Windows-only coverage to Enterprise, Mobile, and ICS matrices.

| Question | Answer |
|---|---|
| What Tactic does the Phishing technique belong to in the ATT&CK Matrix? | `Initial Access` |
| Which ID is associated with the Create Account technique? | `T1136` |

![Task 2](Screen%20Shot%202026-07-18%20at%205.40.02%20PM.png)

## Task 3 — ATT&CK in Operation (CTI Mapping)

Different teams use ATT&CK differently: CTI teams build actionable threat profiles, SOC analysts add context to alerts, detection engineers map rules to techniques, incident responders visualize attack timelines, and red/purple teams build emulation plans. This task analyzed the threat group Mustang Panda (G0129) using its dedicated ATT&CK page and Navigator layer.

| Question | Answer |
|---|---|
| In which country is Mustang Panda based? | `China` |
| Which ATT&CK technique ID maps to Mustang Panda's Reconnaissance tactics? | `T1598` |
| Which software is Mustang Panda known to use for Access Token Manipulation? | `Cobalt Strike` |

![Task 3](Screen%20Shot%202026-07-18%20at%205.41.45%20PM.png)

## Task 4 — ATT&CK and Threat Intelligence (Scenario)

Scenario: as a security analyst in the aviation sector migrating infrastructure to the cloud, the goal was to identify an APT group known to target the sector, map its TTPs, and assess gaps in cloud defensive coverage using the Groups section and Navigator.

| Question | Answer |
|---|---|
| Which APT group has targeted the aviation sector and has been active since at least 2013? | `APT33` |
| Which ATT&CK sub-technique used by this group is a key area of concern for companies using Office 365? | `Cloud Accounts` |
| According to ATT&CK, what tool is linked to the APT group and the sub-technique you identified? | `Ruler` |
| Which mitigation strategy advises removing inactive or unused accounts to reduce exposure to this sub-technique? | `User Account Management` |
| What Detection Strategy ID would you implement to detect abused or compromised cloud accounts? | `DET0546` |

![Task 4](Screen%20Shot%202026-07-18%20at%205.47.23%20PM.png)

## Task 5 — MITRE CAR (Cyber Analytics Repository)

CAR is a collection of ready-made detection analytics built around ATT&CK. Each analytic includes pseudocode and, in many cases, tool-specific implementations (Splunk, LogPoint) that translate ATT&CK TTPs into real detection logic. Analytics can also include unit tests to validate that a detection works as intended.

| Question | Answer |
|---|---|
| Which ATT&CK Tactic is associated with CAR-2019-07-001? | `Defense Evasion` |
| What is the Analytic Type for Access Permission Modification? | `Situational Awareness` |

![Task 5](Screen%20Shot%202026-07-18%20at%205.49.10%20PM.png)

## Task 6 — MITRE D3FEND

D3FEND (Detection, Denial, and Disruption Framework Empowering Network Defense) maps defensive techniques and gives defenders a common language for describing how security controls work, complementing ATT&CK's offensive perspective.

| Question | Answer |
|---|---|
| Which sub-technique of User Behavior Analysis would you use to analyze the geolocation data of user logon attempts? | `User Geolocation Logon Pattern Analysis` |
| Which digital artifact does this sub-technique rely on analyzing? | `Network Traffic` |

![Task 6](Screen%20Shot%202026-07-18%20at%205.51.03%20PM.png)

## Task 7 — AADAPT and ATLAS

AADAPT (Adversarial Actions in Digital Asset Payment Technologies) covers threats to blockchain networks, smart contracts, and digital wallets. ATLAS (Adversarial Threat Landscape for Artificial-Intelligence Systems) covers threats targeting AI and machine learning systems. Both follow the same tactic/technique structure as ATT&CK.

| Question | Answer |
|---|---|
| What technique ID is associated with Scrape Blockchain Data in the AADAPT framework? | `ADT3025` |
| Which tactic does LLM Prompt Obfuscation belong to in the ATLAS framework? | `Defense Evasion` |

![Task 7](Screen%20Shot%202026-07-18%20at%205.52.48%20PM.png)

## Key Takeaways

- ATT&CK's Tactic, Technique, Procedure structure gives a consistent language for describing adversary behavior across CTI, SOC, detection engineering, incident response, and red team functions.
- Mapping a threat group's page and Navigator layer (as done with Mustang Panda and APT33) is a practical way to build sector-specific threat profiles and spot gaps in defensive coverage before an incident happens.
- MITRE's ecosystem extends well past ATT&CK: CAR turns TTPs into ready-made detection logic, D3FEND catalogs the defensive countermeasures, and AADAPT/ATLAS extend the same framework structure to blockchain and AI-specific threats.
- Mitigation IDs (like M1018 User Account Management) and Detection Strategy IDs (like DET0546) are the actionable output of ATT&CK research, turning intelligence into concrete controls and detections.
