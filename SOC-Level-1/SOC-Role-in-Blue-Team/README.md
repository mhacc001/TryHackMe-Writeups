# SOC Role in Blue Team
**Platform:** TryHackMe  
**Path:** SOC Level 1 / Blue Team Introduction  
**Difficulty:** Easy  

---

## Objective

Discover the different security roles within a SOC team and learn how to advance a SOC career starting from the L1 analyst level. This room covers the security hierarchy, alert management platforms, events and alerts, and a final drag-and-drop challenge assigning the right roles to real-world incidents.

---

## Tools Used

- TryHackMe SIEM (alert triage simulation)
- TrySecureMe (drag-and-drop role assignment challenge)

---

## Methodology

### Task 1 -- Security Hierarchy

Explored how cybersecurity priorities differ by organization type. Every company has a unique security structure built around their most critical assets. The high-level hierarchy from top to bottom:

- **Executives** (CEO/CFO): Focus on global business objectives
- **Security Leadership** (CTO/CIO/CISO): Lead company-wide IT or security program
- **Security Managers** (SOC Manager/Red Team Lead): Manage a single team or department
- **Technical** (SOC Analyst/Engineer/GRC Specialist/Penetration Tester): Perform technical tasks like log analysis

Security departments vary by company size -- small companies may have a single IT team while larger ones have dedicated Red Team, GRC, and Blue Team functions.

![Security hierarchy pyramid showing roles from CEO to SOC Analyst](Screen%20Shot%202026-06-01%20at%205.56.35%20PM.png)

### Task 2 -- Events and Alerts

Learned the difference between events and alerts. Events are logged actions (user login, file download, process launch). Alerts are generated when a specific event or sequence of events triggers a rule in a security solution, saving analysts from manually reviewing millions of raw logs.

Alert management platforms used by SOC teams:

| Solution | Examples | Description |
|----------|----------|-------------|
| SIEM System | Splunk ES, Elastic | Solid alert management, perfect choice for most SOC teams |
| EDR or NDR | MS Defender, CrowdStrike | Preferred to use via SIEM or SOAR |
| SOAR System | Splunk SOAR, Cortex SOAR | Aggregates and centralises alerts from multiple solutions |
| ITSM System | Jira, TheHive | Custom ticket management for SOC workflows |

![Events and Alerts dashboard showing True Positives, False Positives, and Archive columns](Screen%20Shot%202026-06-01%20at%206.35.04%20PM.png)

![Alert Management Platforms table and L1 Role in Alert Triage](Screen%20Shot%202026-06-01%20at%206.27.23%20PM.png)

### Task 3 -- L1 Role in Alert Triage

Practiced alert triage using the TryHackMe SIEM. The dashboard showed 5 alerts with varying severity levels, statuses, verdicts, and assignees:

| Time | Alert | Severity | Status | Verdict | Assignee |
|------|-------|----------|--------|---------|----------|
| Mar 21 13:58 | Double-Extension File Creation | High | Awaiting action | None | None |
| Mar 21 13:30 | Potential Data Exfiltration | Critical | Awaiting action | None | None |
| Mar 21 13:02 | Download from GitHub Repository | Low | Awaiting action | None | None |
| Mar 21 12:40 | Unusual VPN Login Location | Medium | Closed | False Positive | T.Ross (L1) |
| Mar 21 11:53 | Bruteforce Attack from External | Medium | Closed | True Positive | J.Adams (L2) |

![TryHackMe SIEM alert triage dashboard with 5 alerts](Screen%20Shot%202026-06-01%20at%206.38.46%20PM.png)

### Task 4 -- Final Challenge

Acted as CISO of TrySecureMe, a multinational company with 7 simultaneous security incidents. Dragged and dropped the correct role to each scenario:

- **SIEM alert about FW-NY-01 firewall brute-force** -- triage the alert → **Susan** (SOC L2 Analyst)
- **HR manager Anna launched phishing malware** -- deep analysis → **Alice** (Threat Researcher)
- **Office in France hit with ransomware** -- immediate response → **Incident Responder**
- **Credit card servers require PCI DSS audit** → **Nick** (GRC Auditor)
- **Check new version of TryHackMe for vulnerabilities** → **Penetration Tester**
- **SIEM unavailable due to storage limit** → **SOC Engineer**
- **FIN7 threat group actively targeting company** -- analyze tactics → **Alice** (Threat Researcher)

![TrySecureMe final challenge drag-and-drop role assignment](Screen%20Shot%202026-06-01%20at%206.38.59%20PM.png)

---

## Flag

```
THM{trysecureme_is_secured!}
```

---

## Key Takeaways

- SOC analysts are the first line of defense but never work alone -- every role in the hierarchy plays a part in keeping the organization secure.
- Alert triage is about prioritization: Critical and High severity alerts with active status require immediate attention.
- True Positive vs False Positive verdicts are core SOC decisions -- closing a False Positive incorrectly can mask real threats.
- Different incidents require different specialists -- knowing when to escalate and to whom is a critical SOC skill.
