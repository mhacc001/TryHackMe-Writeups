# Introduction to SIEM

**Room:** TryHackMe SOC Level 1 -- Core SOC Solutions -- Introduction to SIEM
**Type:** 120 min
**Description:** Learn the fundamentals of SIEM and explore its features and functionality.

## Overview

This room covers why SIEM exists: the flood of logs generated across a network, the problems with analyzing them in isolation, and how a SIEM solution centralizes, normalizes, correlates, and alerts on that data. It ends with a hands-on lab simulating a SIEM dashboard and a triggered alert investigation.

## Task 1 -- Introduction

**Question and answer:**

- What does SIEM stand for?
  **Security Information and Event Management system**

![Task 1 Answer](Screen%20Shot%202026-06-20%20at%2012.53.12%20PM.png)

## Task 2 -- Logs Everywhere

Covers the two categories of log sources: host-centric (file access, authentication attempts, process execution, registry changes, PowerShell execution) and network-centric (SSH connections, FTP access, web traffic, VPN access, network file sharing). Also covers the challenges of working with isolated logs: numerous scattered log sources, no centralization, limited context without correlation, limited manual analysis capacity, and inconsistent log formats.

**Questions and answers:**

- Is Registry-related activity host-centric or network-centric?
  **host-centric**
- Is VPN-related activity host-centric or network-centric?
  **network-centric**

![Task 2 Answers](Screen%20Shot%202026-06-20%20at%2012.56.41%20PM.png)

## Task 3 -- Features of SIEM

Covers SIEM's core features: Centralized Log Collection, Normalization of Logs (parsing logs into fields, then converting everything into one consistent format), Correlation of Logs (connecting individually-harmless events into a bigger picture, like a VPN login from a new IP followed by file access, a PowerShell script, and an outbound connection pointing to data exfiltration), Real-time Alerting based on detection rules, and Dashboards and Reporting.

No graded question for this task, just an acknowledgment step.

## Task 4 -- Log Sources and Ingestion

Covers where logs live on common systems: Windows Event Viewer, Linux log locations (/var/log/httpd for HTTP logs, /var/log/cron for cron jobs, /var/log/auth.log or /var/log/secure for authentication, /var/log/kern for kernel events), and Apache web server logs. Also covers the four common log ingestion methods: Agent/Forwarder, Syslog, Manual Upload, and Port-Forwarding.

**Question and answer:**

- In which location within a Linux environment are HTTP logs stored?
  **/var/log/httpd**

![Task 4 Answer](Screen%20Shot%202026-06-20%20at%2012.58.41%20PM.png)

## Task 5 -- Alerting Process and Analysis

Covers how detection rules work as logical expressions (failed login thresholds, USB insertion alerts, data exfiltration thresholds), with two worked examples: Event ID 104 firing when event logs are cleared, and Event ID 4688 with NewProcessName containing "whoami" firing on whoami command execution. Also covers the alert investigation workflow and the possible outcomes: tuning the rule for false positives, further investigation and host isolation for true positives, or contacting the asset owner.

**Questions and answers:**

- Which Event ID is generated when event logs are removed?
  **104**
- What type of alert may require tuning?
  **False Positive**

![Task 5 Answers](Screen%20Shot%202026-06-20%20at%2012.59.28%20PM.png)

## Task 6 -- Lab Work

A hands-on lab with a static SIEM dashboard (top event codes, top RDP connections, event counts over time, MITRE ATT&CK breakdown, process names, and IP+port destinations) and a "Start Suspicious Activity" button that triggers a live alert to investigate.

Clicking the button triggers an alert tied to **cudominer.exe**, a known cryptomining malware family, executed by user **chris** on host **HR_02**. The detection rule matched on the generic substring **miner** in the process name (rather than the specific "cudominer" string), which would catch any miner-family variant. Given the process is unauthorized cryptomining malware, this is correctly classified as a **True Positive**.

**Questions and answers:**

- After clicking on the Start Suspicious Activity button, which process caused the alert?
  **cudominer.exe**
- Find the event that caused the alert and identify the user responsible for the process execution.
  **chris**
- What is the hostname of the suspect user?
  **HR_02**
- Examine the rule and the suspicious process; which term matched the rule that caused the alert?
  **miner**
- Which option best represents the event? (False Positive / True Positive)
  **True Positive**
- Selecting the right ACTION will display the FLAG. What is the FLAG?
  **THM{000_SIEM_INTRO}** -- obtained by selecting "True positive and isolate the host" as the action.

![Task 6 Lab and Questions](Screen%20Shot%202026-06-20%20at%201.04.49%20PM.png)
![Task 6 All Answers Confirmed](Screen%20Shot%202026-06-20%20at%201.12.43%20PM.png)
![Flag Revealed](Screen%20Shot%202026-06-20%20at%201.12.56%20PM.png)

## Flag

```
THM{000_SIEM_INTRO}
```

## Key Takeaways

- SIEM solves the core problems of isolated logging: scattered log sources, no centralized view, limited context, and inconsistent formats, by collecting, normalizing, and correlating logs from every device in the network.
- Detection rules are just logical expressions built on field-value pairs (Log Source, Event ID, process name, etc.), which is why normalized, consistently-formatted logs matter so much for reliable detection.
- A generic substring match (like "miner" instead of "cudominer") is often a more resilient rule design, since it catches variants of a malware family rather than just one specific sample.
- Correctly identifying a True Positive and choosing the right response action (isolate the host) is what actually resolves an alert, not just naming the suspicious process.
