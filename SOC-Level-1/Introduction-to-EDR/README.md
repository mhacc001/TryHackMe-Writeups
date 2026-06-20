# Introduction to EDR

**Room:** TryHackMe SOC Level 1 -- Core SOC Solutions -- Introduction to EDR
**Type:** 60 min
**Description:** Learn the fundamentals of EDR and explore its features and working.

## Overview

This room covers Endpoint Detection and Response (EDR) from the ground up: how it differs from a traditional antivirus, how its agents collect telemetry, what detection techniques it applies to that telemetry, and how analysts respond to detections. It wraps up with a hands-on EDR Dashboard simulator where you trace real detections across multiple hosts.

## Task 1 -- Introduction

Context-setting only: EDR monitors, detects, and responds to advanced threats at the endpoint level, and this room covers how it differs from antivirus and what data it collects.

## Task 2 -- EDR Features (the Three Pillars)

Covers EDR's three core pillars using CrowdStrike Falcon screenshots as examples: Visibility (process trees, registry/file modifications, user actions), Detection (signature and behavior-based, including fileless malware), and Response (isolate, terminate, quarantine, remote shell access).

**Questions and answers:**

- Which feature of EDR provides a complete context for all the detections?
  **Visibility** -- the text states detections "land with a whole context" thanks to the deep, structured telemetry EDR collects.
- Which process spawned sc.exe?
  **cmd.exe**

![Task 2 Answers](Screen%20Shot%202026-06-20%20at%2012.19.06%20PM.png)

## Task 3 -- AV vs EDR

Uses an airport analogy: antivirus is like the immigration check (matches known criminals against a list), while EDR is like security officers constantly watching CCTV and motion sensors, catching threats that evade the initial check. Walks through a 6-step attack chain (phishing email -> malicious macro -> PowerShell -> process injection into svchost.exe -> remote access) and compares how AV and EDR respond at each stage. AV would likely mark the whole chain as clean since none of the individual steps trip a signature match; EDR flags it at multiple points due to behavior, obfuscation, and process injection.

**Questions and answers:**

- In the given analogy, what presents an AV?
  **immigration check**
- Which legitimate process was hijacked by the attacker in the scenario?
  **svchost.exe**
- Which security solution might mark this activity as clean?
  **Antivirus**

![Task 3 Answers](Screen%20Shot%202026-06-20%20at%2012.20.41%20PM.png)

## Task 4 -- How EDR Works (Agents and Console)

Explains EDR agents (sensors) deployed on endpoints that monitor activity and send telemetry to a centralized EDR console, where detections are correlated using threat intel and machine learning. Also covers how detections get severity-ranked for triage, and how EDR fits into a larger security ecosystem alongside firewalls, DLPs, email security gateways, and IAM, typically feeding into a SIEM.

**Questions and answers:**

- Which component of the EDR is responsible for collecting telemetry from the endpoints?
  **Agent**
- An EDR agent is also known as a?
  **sensor**

![Task 4 Answers](Screen%20Shot%202026-06-20%20at%2012.22.24%20PM.png)

## Task 5 -- Telemetry

Telemetry is described as the "black box" of an endpoint. Covers the major telemetry types EDR collects: process executions/terminations, network connections, command line activity, file/folder modifications, and registry modifications.

**Questions and answers:**

- Which telemetry data helps in detecting C2 communications?
  **Network Connections**
- Where are the configuration settings of a Windows system primarily stored?
  **registry**

![Task 5 Answers](Screen%20Shot%202026-06-20%20at%2012.23.49%20PM.png)

## Task 6 -- Detection and Response

Covers advanced detection techniques: Behavioral Detection (unusual parent-child process relationships), Anomaly Detection (deviation from baseline), IOC matching (known indicators from threat intel feeds), MITRE ATT&CK Mapping, and Machine Learning Algorithms (catching multi-stage or fileless attacks where no single step looks malicious). Also covers response capabilities: Isolate Host, Terminate Process, Quarantine, Remote Access (RTR), and Artefacts Collection (memory dumps, event logs, registry hives).

**Question and answer:**

- Which feature of the EDR helps you identify threats based on known malicious behaviours?
  **IOC matching** -- flags activity matching published indicators (hashes, IPs, domains) from threat intelligence feeds.

Note: this answer wasn't confirmed with a screenshot, unlike the others in this room.

## Task 7 -- Investigate an Alert on EDR

A hands-on scenario as a SOC analyst at TECH THM, using a live EDR Dashboard simulator to triage real detections across three hosts.

### DESKTOP-HR01 -- Initial Access via Malicious Office Document

Process chain: WINWORD.EXE -> CMD.EXE -> cURL.EXE -> INSTALL.EXE. User alice.thomas opened a macro-enabled document (invoice.docm), which spawned CMD, which used cURL to download a payload from an external domain. The file was saved to disk but never executed -- consistent with malware staging.

IOCs included the dropped payload (install.exe), the blocked C2 domain (ayebd.thm), and the original malicious document, all quarantined or blocked by the EDR.

- Which tool was launched by CMD.exe to download the payload on DESKTOP-HR01?
  **cURL.exe**
- What is the absolute path to the downloaded malware on the DESKTOP-HR01 machine?
  **C:\Users\Public\install.exe**

### WIN-ENG-LAPTOP03 -- Credential Dumping (T1003.001/T1003.002)

Process chain: explorer.exe -> syncsvc.exe -> lsass.exe. User haris.khan ran an unsigned binary (syncsvc.exe) from a Temp folder, which accessed lsass.exe's memory and wrote a dump to disk, then attempted to exfiltrate the dump to a file-sharing site. The exfiltration attempt was blocked by the EDR before it completed.

- What is the absolute path to the suspicious syncsvc.exe on the WIN-ENG-LAPTOP03 machine?
  **C:\Users\haris.khan\AppData\Local\Temp\syncsvc.exe**
- On which URL was the exfiltration attempt being made on WIN-ENG-LAPTOP03?
  **https://files-wetransfer.com/upload/session/ab12cd34ef56/dump_2025.dmp**

### DESKTOP-DEV01 -- UpdateAgent.exe

An unsigned binary running from AppData\Roaming (user daniel.richards), making an outbound HTTP connection to an internal IP on port 8080.

- What was UpdateAgent.exe labelled by Threat Intel on DESKTOP-DEV01?
  **Known internal IT utility tool**

Worth flagging: this label is questionable given the binary is unsigned, runs from a common malware staging location, and makes an unexplained outbound connection. A real investigation would dig deeper rather than trust the Threat Intel label at face value, since attackers sometimes name malicious tools to blend in with legitimate ones.

![Task 7 Scenario and EDR Dashboard](Screen%20Shot%202026-06-20%20at%2012.25.29%20PM.png)
![DESKTOP-HR01 Summary and Question Blanks](Screen%20Shot%202026-06-20%20at%2012.29.53%20PM.png)
![DESKTOP-HR01 Process Chain](Screen%20Shot%202026-06-20%20at%2012.30.10%20PM.png)
![DESKTOP-HR01 IOC/Indicators](Screen%20Shot%202026-06-20%20at%2012.30.22%20PM.png)
![Task 7 All Five Answers Confirmed](Screen%20Shot%202026-06-20%20at%2012.46.44%20PM.png)

Note: the WIN-ENG-LAPTOP03 and DESKTOP-DEV01 detection details were read directly off-screen rather than screenshotted, so no image files exist for those two hosts.

## No Flag for This Room

This room is text-based Q&A throughout (theory plus a practical investigation task), with no flag to capture.

## Key Takeaways

- EDR goes beyond antivirus by adding behavioral and anomaly detection, IOC matching, MITRE ATT&CK mapping, and machine learning on top of basic signature matching, giving visibility into attacks that never trip a known signature.
- Telemetry (process executions, network connections, command line activity, file/registry changes) is what makes EDR's detection and investigation possible. The more detailed the telemetry, the easier it is to spot stealthy, multi-stage attacks.
- A clean process spawning an unusual child process (Word spawning CMD, CMD spawning cURL) is one of the simplest and most reliable behavioral red flags.
- Threat Intel labels aren't infallible. An unsigned binary running from a staging-friendly folder with unexplained network activity deserves scrutiny even if it's labelled as a known/clean tool.
- Real investigations require pivoting through multiple tabs (Summary, Process Info, IOC/Indicators) to build the full picture of a single detection.
