# Introduction to SOAR

Room: [Introduction to SOAR](https://tryhackme.com/room/introtosoar)
Path: SOC Level 1 > Core SOC Solutions > Introduction to SOAR

## Overview

This room covers Security Orchestration, Automation, and Response (SOAR) and how it addresses the common challenges traditional SOC teams face, such as alert fatigue, disconnected tools, manual processes, and talent shortages. It walks through the three core SOAR capabilities (Orchestration, Automation, Response), looks at real playbook examples for Phishing and CVE Patching, and ends with a hands on lab building a Threat Intelligence integration workflow.

---

## Task 1: Introduction

SOC teams rely on tools like SIEM, EDR, firewalls, and threat intelligence platforms, plus coordination with IT and management. As threats grow more complex, SOC teams run into recurring challenges: alert fatigue, manual processes, too many disconnected tools, and difficult cross team communication. SOAR is introduced as the solution to these problems.

**Learning objectives:**
- Understand the traditional SOC and its challenges
- Explore how SOAR overcomes these challenges
- Learn SOAR Playbooks
- Practically walk through a threat intelligence workflow

---

## Task 2: How Traditional SOCs Work

Traditional SOC capabilities:
- **Monitoring and Detection** -- continuous scanning for suspicious activity, mainly through the SIEM
- **Recovery and Remediation** -- first response actions like isolating endpoints, removing malware, stopping malicious processes, often through EDR, firewalls, IAM
- **Threat Intelligence** -- continuous feed of IOCs (IPs, hashes, domains) to inform blocking and detection decisions
- **Communication** -- coordinating with IT and management, such as ticketing IT to verify a patch deployment

**Challenges SOCs face:**
- Alert Fatigue -- too many alerts, many false positive or low value, overwhelming analysts
- Too Many Disconnected Tools -- tools deployed without integration, forcing analysts to manually cross reference
- Manual Processes -- undocumented tribal knowledge instead of repeatable procedure, slowing investigations
- Talent Shortage -- difficulty recruiting and retaining analysts against a growing alert and threat volume

**Q: How would you describe the experience of an overload of security events being triggered within a SOC?**
```
Alert Fatigue
```

![Task 2 answer](Screen%20Shot%202026-06-20%20at%209.53.46%20PM.png)

---

## Task 3: What is SOAR?

SOAR unifies the tools a SOC uses (SIEM, EDR, firewall, threat intel, etc.) into a single interface, and adds ticketing and case management so analysts can track and resolve incidents in one place.

**The three core capabilities:**

1. **Orchestration** -- coordinates multiple security tools together inside SOAR instead of analysts manually switching between them. Defines **Playbooks**: predefined, branching workflows for investigating specific alert types (for example a VPN brute force playbook that checks SIEM history, queries threat intel for IP reputation, checks for successful logins, then escalates to containment).

2. **Automation** -- SOAR executes the playbook steps itself with no manual clicks needed. For the VPN brute force example: SOAR automatically queries SIEM history, checks IP reputation, disables the user in IAM if malicious, and opens a ticket with full details.

3. **Response** -- SOAR takes action directly through connected tools from one interface, such as blocking an IP on the firewall, disabling a user in IAM, and opening a ticket, often as the automated output of a playbook.

SOAR does not replace SOC analysts. Analysts still make the playbooks, handle complex investigations, and provide judgment calls SOAR cannot make on its own. SOAR's value is reducing repetitive manual work and organizing the process, not eliminating the human role.

**Q: The act of connecting and integrating security tools and systems into seamless workflows is known as?**
```
Orchestration
```

**Q: What do we call a predefined list of actions to handle an incident?**
```
Playbook
```

![Task 3 answers](Screen%20Shot%202026-06-20%20at%209.54.50%20PM.png)

---

## Task 4: SOAR Playbooks

Two example playbooks were reviewed via flow diagrams.

**Phishing Playbook**

Starting from "Suspicious email received," the playbook creates an investigation ticket and checks whether the email contains a URL or attachment. If neither, it just notifies users. If either is present:
- Attachments: hash is computed and checked against VirusTotal
- URLs: sent to VirusTotal to check if malicious

If the hash/URL check comes back malicious, the email is deleted. If the hash check is inconclusive, the playbook routes to **manual analysis of the email in a sandbox** before a final malicious determination and deletion. The ticket is updated with IOCs throughout.

**CVE Patching Playbook**

Starts by monitoring advisory lists and extracting new CVE data. SOAR checks if the CVE was already addressed; if not, it checks applicability, and if applicable, creates a CVE ticket and assigns an analyst. The analyst reviews the ticket, SOAR identifies vulnerable assets, queries configuration management, and checks if a patch exists (looping to update the patch database if not). Once a patch exists, SOAR tests it on test machines, logs performance, updates the ticket, and the SOC deploys the patch to assets. After verifying rollout and scanning patched assets for vulnerability, if assets are still vulnerable, the SOC develops and deploys a mitigation plan. If not vulnerable, the ticket is closed and patch management is updated.

Both playbooks automate the majority of steps but keep analysts in the loop at key decision points, reinforcing that SOAR augments rather than replaces the analyst role.

**Q: Is manual analysis vital within a SOAR workflow? Yay or Nay?**
```
Yay
```

**Q: From where is the CVE Patching playbook fetching the new CVEs?**
```
Advisory lists
```

**Q: In the CVE Patching playbook, if the assets are found vulnerable even after the patch is deployed, what does the SOC develop next?**
```
Mitigation plan
```

![Phishing playbook flowchart](Screen%20Shot%202026-06-20%20at%209.55.31%20PM.png)
![CVE Patching playbook flowchart](Screen%20Shot%202026-06-20%20at%209.55.47%20PM.png)
![Task 4 answers](Screen%20Shot%202026-06-20%20at%209.57.14%20PM.png)

---

## Task 5: Hands On -- Threat Intelligence Integration Workflow

This task is an interactive lab simulating a SOAR console. Five panels control different stages of a threat intelligence workflow: Case Ticket, Threat Intel, Data Extraction, Reputation Checks, and Course of Action. Each panel has toggles for sub-actions marked Automated or Manual, and the workflow must be configured correctly across all five panels before running it produces a clean pass through the flowchart.

Working through it, one toggle in each panel was set incorrectly relative to its intended Automated/Manual designation:

- **Case Management Settings:** Delete Case Ticket was toggled on and needed to be off, since the workflow creates, assigns, communicates, and updates a ticket rather than deleting it mid-process
- **Threat Intelligence Feeds:** Discard Old Alerts needed to be off so new alerts continue to be fetched and processed
- **Incident Data Extraction:** Analyst Extraction needed to be off, since this stage automates extraction via VirusTotal lookups for known threats
- **Reputation Checks:** Analyst Validation was marked Manual and needed to be off so Reputation Results Output and Sandbox Testing could run as the automated stage
- **Course of Action:** Analyst Approve COA needed to be off so blocking domains/IPs and updating the case ticket complete as automated remediation

Once all five panels were corrected, running the workflow completed the flowchart end to end.

**Q: What is the flag received?**
```
THM{AUT0M@T1N6_S3CUR1T¥}
```

![Reputation Checks panel corrected](Screen%20Shot%202026-06-20%20at%2010.05.19%20PM.png)
![Workflow completed with flag](Screen%20Shot%202026-06-20%20at%2010.05.44%20PM.png)

---

## Key Takeaways

- SOAR exists to solve the operational pain points of traditional SOCs: alert fatigue, disconnected tooling, undocumented manual processes, and talent shortages
- The three pillars of SOAR are Orchestration (connecting tools into unified workflows), Automation (executing those workflows without manual clicks), and Response (taking action directly through connected tools)
- Playbooks are the predefined, branching logic that tells SOAR what to do for a given alert type, and they are built by analysts based on real investigation experience
- SOAR augments analysts, it does not replace them. Manual checkpoints still exist at key decision points such as sandbox analysis or final approval steps
- In a working SOAR integration, nearly every stage of a threat intel workflow (ticketing, intel feeds, data extraction, reputation checks, course of action) can run automated end to end, with analyst involvement reserved for genuine judgment calls
