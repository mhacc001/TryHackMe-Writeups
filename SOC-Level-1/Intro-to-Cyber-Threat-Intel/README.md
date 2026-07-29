# Intro to Cyber Threat Intel

## Overview

This room introduces Cyber Threat Intelligence (CTI) for SOC Level 1 analysts, covering why CTI matters to front line triage, the data-to-intelligence pipeline, the six-phase CTI lifecycle, key standards and frameworks (MITRE ATT&CK, MITRE D3FEND, Cyber Kill Chain, CVE/CVSS/NVD, STIX/TAXII), and dissemination through published threat reports. It closes with a hands on adversary mapping exercise.

## Task 1: Introduction

CTI helps a SOC analyst answer three core questions about an alert indicator: who or what is behind it, what its past behaviour has been, and how the organisation should respond right now. Prerequisite path recommended before starting: Cyber Security 101.

## Task 2: From Raw Data to Usable Intelligence

Information security separates data, information, and intelligence:

- **Data**: an unprocessed observable (an IP address on its own)
- **Information**: data plus factual annotation (who the IP is registered to, first seen date)
- **Intelligence**: analysed information that answers the "so what" (this IP belongs to an active C2, block it now)

Three key labels used during this process:

- **Indicator of Compromise (IOC)**: evidence a breach has occurred
- **Indicator of Attack (IOA)**: a malicious action currently underway
- **Tactics, Techniques, and Procedures (TTP)**: an adversary's detailed methodology, expressed via MITRE ATT&CK IDs

Indicator types analysts triage include IPv4/IPv6, domains/FQDNs, URLs, file hashes, email addresses, and local artefacts (like registry run keys), each with its own enrichment path (WHOIS, VirusTotal, urlscan.io, Sigma rules, etc.).

Feeds (scheduled indicator streams in CSV/JSON/STIX/TAXII) differ from platforms (structured repositories like MISP or OpenCTI that store, enrich, and map indicator relationships). Sources of CTI fall into four categories: internal telemetry, commercial services, OSINT, and communities/ISACs.

Threat intelligence classifications:

- **Strategic intel**: high level trends shaping business decisions
- **Tactical intel**: adversary TTPs
- **Operational intel**: campaign-specific motive and intent
- **Technical intel**: atomic indicators like IPs and hashes

**Q: What does CTI stand for?**
```
Cyber Threat Intelligence
```

**Q: IP addresses, Hashes and other threat artefacts would be found under which Threat Intelligence classification?**
```
Technical Intel
```

![Task 2 Answers](Screen%20Shot%202026-07-28%20at%2010.23.25%20PM.png)

## Task 3: The CTI Lifecycle

Walked through the six-phase CTI lifecycle via a narrative scenario (Alex, an L1 analyst, protecting TryHatMe Corp's production PostgreSQL database):

1. **Direction**: define the intelligence requirement and guiding questions (e.g. which IPs/domains target PostgreSQL, which malware families are active)
2. **Collection**: gather raw intel from commercial feeds, OSINT (AbuseIPDB), internal MISP, and vendor threat reports
3. **Processing**: normalise indicator syntax, correlate and deduplicate against existing records, tag with source/date/TLP, output action files (firewall blocklist, YARA rules)
4. **Analysis**: validate relevance against local telemetry, grade confidence (High/Medium/Low) based on source agreement and local sightings, decide on block/alert/monitor
5. **Dissemination**: tailor output format and depth to each stakeholder (firewall team, endpoint team, CTI platform, management)
6. **Feedback**: measure KPIs after the cycle (e.g. dwell time, false-positive rate) and refine direction for the next iteration

Also covered: the Traffic Light Protocol (TLP CLEAR/GREEN/AMBER/RED) for governing how widely intel may be shared, with the stricter label always winning on conflict, and STIX as the JSON schema for machine-readable threat intel.

**Q: At which phase of the CTI lifecycle is data converted into usable formats through sorting, organising, correlation and presentation?**
```
Processing
```

**Q: During which phase do security analysts get the chance to define the questions to investigate incidents?**
```
Direction
```

![Task 3 Answers](Screen%20Shot%202026-07-28%20at%2010.24.02%20PM.png)

## Task 4: Standards and Frameworks

- **MITRE ATT&CK**: catalogues adversary tactics/techniques (e.g. T1059.001 PowerShell) as a shared reference language for triage notes
- **MITRE D3FEND**: catalogues corresponding defensive techniques and practical mitigations
- **Cyber Kill Chain** (Lockheed Martin): seven stages of an attack, Reconnaissance, Weaponisation, Delivery, Exploitation, Installation, Command & Control, Actions on Objectives
- **CVE / CVSS / NVD**: CVE catalogues vulnerabilities, CVSS scores their severity (0 to 10), NVD links CVEs to CVSS scores and affected products
- **STIX / TAXII**: STIX is the structured schema for describing threat data, TAXII is the API standard for exchanging it, supporting Collection (producer-hosted) and Channel (published to subscribers) sharing models

**Q: What sharing models are supported by TAXII?**
```
Collection and Channel
```

**Q: When an adversary has obtained access to a network and is extracting data, what phase of the kill chain are they on?**
```
Actions on Objectives
```

![Task 4 Answers](Screen%20Shot%202026-07-28%20at%2010.24.42%20PM.png)

## Task 5: Threat Reports and Adversary Mapping

Published threat reports (Mandiant, Palo Alto Unit42) are a key dissemination channel, consolidating research on emerging threat vectors for stakeholders. This task used a Static Site Lab to walk through a simplified engagement, tracing a phishing email to a malicious download and building a threat profile.

**Q: What was the source email address?**
```
vipivillain@badbank.com
```

**Q: What was the name of the file downloaded?**
```
flbpfuh.exe
```

**Q: After building the threat profile, what message do you receive?**
```
THM{NOW_I_CAN_CTI}
```

![Task 5 Answers](Screen%20Shot%202026-07-28%20at%2010.26.45%20PM.png)

## Key Takeaways

- Threat intelligence's job is to turn raw data into a "so what": context that tells an analyst whether to escalate, suppress, or keep watching.
- The Direction phase matters more than it looks: clear guiding questions up front shape everything collected, processed, and analysed downstream.
- TLP labels travel with an indicator wherever it goes, and the stricter label always wins when sources disagree.
- MITRE ATT&CK and D3FEND work as a pair, one names the adversary behaviour, the other supplies the matching defensive control.
- STIX/TAXII give CTI a common machine-readable language and transport layer, which is what makes feed sharing between organisations actually scale.
