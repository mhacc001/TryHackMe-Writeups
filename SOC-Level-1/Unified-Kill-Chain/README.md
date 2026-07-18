# Unified Kill Chain — TryHackMe SOC Level 1

Room: Cyber Defence Frameworks module
Path: SOC Level 1

## Overview

The Unified Kill Chain (UKC) is a framework developed by Paul Pols in 2017 that expands on earlier kill chain models like Lockheed Martin's Cyber Kill Chain and MITRE ATT&CK. Instead of a small handful of phases, the UKC breaks an attack down into 18 phases spanning the full attack lifecycle, from initial reconnaissance through data exfiltration and the adversary's final objectives.

The UKC also accounts for the fact that real attacks are not strictly linear. Attackers frequently loop back through earlier phases, for example returning to reconnaissance after gaining a foothold in order to pivot to another system.

## Task 2 — What is a Kill Chain

A "Kill Chain" originates from a military context and describes the stages an attacker moves through to intrude on a target.

| Question | Answer |
|---|---|
| Where does the term "Kill Chain" originate from? | `Military` |

![Task 2](Screen%20Shot%202026-07-18%20at%205.15.04%20PM.png)

## Task 3 — What is Threat Modelling

Threat modelling is the process of identifying critical assets, assessing their vulnerabilities, and building a plan to reduce risk. An asset in IT is any piece of software or hardware.

| Question | Answer |
|---|---|
| What is the technical term for a piece of software or hardware in IT? | `Asset` |

![Task 3](Screen%20Shot%202026-07-18%20at%205.16.37%20PM.png)

## Task 4 — Unified Kill Chain Framework

The UKC was released in 2017 and updated in 2022. Compared to older frameworks like MITRE ATT&CK (2013), it is more modern, far more granular at 18 phases, and covers the entire attack lifecycle including the attacker's motive.

| Question | Answer |
|---|---|
| In what year was the Unified Kill Chain framework released? | `2017` |
| According to the Unified Kill Chain, how many phases are there to an attack? | `18` |
| What is the name of the attack phase where an attacker employs techniques to evade detection? | `Defense Evasion` |
| What is the name of the attack phase where an attacker employs techniques to remove data from a network? | `Exfiltration` |
| What is the name of the attack phase where an attacker achieves their objectives? | `Objectives` |

![Task 4](Screen%20Shot%202026-07-18%20at%205.18.17%20PM.png)

## Task 5 — In (Initial Foothold)

This phase group covers how an attacker gains an initial foothold on a target: reconnaissance, weaponization, social engineering, exploitation, persistence, defence evasion, command and control, and pivoting.

| Question | Answer |
|---|---|
| What is an example of a tactic to gain a foothold using emails? | `Phishing` |
| Impersonating an employee to request a password reset is a form of what? | `Social Engineering` |
| An adversary setting up the Command & Control server is what phase of the Unified Kill Chain? | `Weaponization` |
| Exploiting a vulnerability present on a system is what phase of the Unified Kill Chain? | `Exploitation` |
| Moving from one system to another is an example of? | `Pivoting` |
| Leaving behind a malicious service that allows the adversary to log back into the target is what? | `Persistence` |

![Task 5](Screen%20Shot%202026-07-18%20at%205.22.39%20PM.png)

## Task 6 — Through (Network Propagation)

Once a foothold is established, the attacker uses the compromised system as a pivot point to discover the internal network, escalate privileges, execute malicious code, harvest credentials, and move laterally to other systems.

| Scenario | Answer |
|---|---|
| Failed logins observed from an administrator account | `Privilege Escalation` |
| Mimikatz detected dumping OS and user secrets | `Credential Access` |

![Task 6](Screen%20Shot%202026-07-18%20at%205.23.43%20PM.png)

## Task 7 — Out (Action on Objectives)

The final phase group covers the attacker achieving their end goal against the CIA triad: collecting valuable data, exfiltrating it, and causing impact through manipulation, disruption, or destruction of assets.

| Scenario | Answer |
|---|---|
| Large traffic spike sent to an unknown suspicious IP address | `Exfiltration` |
| PII released publicly causing reputational damage | `Confidentiality` |

## Practical — Scenario Matching Exercise

Deployed the static site attached to the task and matched each attacker action to its correct Unified Kill Chain phase to reveal the flag.

Flag:
```
THM{UKC_SCENARIO}
```

![Practical flag](Screen%20Shot%202026-07-18%20at%205.27.27%20PM.png)

## Key Takeaways

- The Unified Kill Chain's 18 phases give a far more granular and realistic model of an attack than older frameworks, and account for attackers looping back through phases (e.g. returning to reconnaissance after a foothold to pivot).
- The framework groups naturally into three stages: In (initial foothold), Through (network propagation), and Out (action on objectives).
- Mapping SOC alerts to UKC phases (failed admin logins to Privilege Escalation, Mimikatz activity to Credential Access, traffic spikes to unknown IPs to Exfiltration) is a practical triage skill for identifying where in the attack lifecycle an incident sits.
