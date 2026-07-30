# Alert Triage With Splunk

## Overview

This room covers practical alert triage as an L1 SOC analyst at an MSSP, walking through three realistic scenarios across Linux, Windows, and web application environments. Each scenario starts with an alert containing minimal context, requires reasoning about the alert details before touching the SIEM, and then uses Splunk to confirm or rule out malicious activity, classify it as a True or False Positive, and identify what still needs to be escalated to L2.

## Task 2 - Linux Brute Force Alert

Investigated a Brute Force Activity Detection alert against host tryhackme-2404 from source IP 10.10.242.248, a local (internal) IP address, which immediately raised the question of whether the attacker was already inside the network. Queried Splunk index `linux-alert` for accepted/failed logins and invalid user attempts, discovering login attempts against four different users, with one, john.smith, showing a clear pattern of high volume failed attempts followed by a successful login, confirming a successful brute force and account compromise.

Queries used:

```
index="linux-alert" sourcetype="linux_secure" 10.10.242.248
| search "Accepted password for" OR "Failed password for" OR "Invalid user"
| sort + _time

index="linux-alert" sourcetype="linux_secure" 10.10.242.248
| rex field=_raw "^\d{4}-\d{2}-\d{2}T[^\s]+\s+(?<log_hostname>\S+)"
| rex field=_raw "sshd\[\d+\]:\s*(?<action>Failed|Accepted)\s+\S+\s+for(?: invalid user)? (?<username>\S+) from (?<src_ip>\d{1,3}(?:\.\d{1,3}){3})"
| eval process="sshd"
| stats count values(action) values(src_ip) as src_ip values(log_hostname) as hostname values(process) as process by username
```

**Findings:**

```
Failed login attempts made on the user john.smith: 500
Duration of the brute force attack in minutes: 5
Username the attacker was able to privilege escalate to: root
User account created by the attacker for persistence: system-utm
```

**Verdict:** True Positive, escalated to L2.

![Task 2 answers](Screen%20Shot%202026-07-29%20at%2011.51.39%20PM.png)

## Task 3 - Windows Scheduled Task Persistence Alert

Investigated a Potential Task Scheduler Persistence Identified alert on host WIN-H015 (a workstation, based on naming convention) under user oliver.thompson (a System Engineer), for a scheduled task named AssessmentTaskOne. Queried Splunk index `win-alert` for Event ID 4698 (scheduled task creation), finding a single event where the task ran daily and used certutil to download rv.exe from a suspicious tryhotme domain into the Temp folder as DataCollector.exe, then launched it via a PowerShell Start-Process command, a clear example of Living Off the Land persistence. Traced the task creation back to its originating process, the attacker's discovery activity, and their initial lateral movement into the host.

Queries used:

```
index="win-alert" EventCode=4698 AssessmentTaskOne
| table _time EventCode user_name host Task_Name Message

index="win-alert" EventCode=1 AssessmentTaskOne
| table ComputerName CommandLine ProcessId ParentProcessId ParentName

index="win-alert" oliver.thompson (EventCode=4799 OR "net group" OR "net localgroup" OR "Get-LocalGroup")
| table _time EventCode CommandLine TargetUserName Group_Name

index="win-alert" oliver.thompson EventCode=4624
| table _time Workstation_Name Source_Network_Address LogonType
```

**Findings:**

```
ProcessId of the process that created the malicious task: 5816
Name of the parent process: cmd.exe
Local group the attacker enumerated during discovery: Administrators
Workstation from which the Threat Actor logged into this host: DEV-QA-SERVER
```

**Verdict:** True Positive, escalated to L2.

![Task 3 answers](Screen%20Shot%202026-07-29%20at%2011.52.42%20PM.png)

## Task 4 - Web Shell Alert

Investigated a Potential Web Shell Upload Detected alert against http://web.trywinme.thm from suspicious IP 171.251.232.40, an IP flagged as malicious over 3,000 times on AbuseIPDB. Queried Splunk index `web-alert`, first identifying a Hydra driven brute force against wp-login.php, then, after excluding Hydra traffic, spotting a suspicious POST request to admin-ajax.php with a referer pointing to theme-editor.php?file=b374k.php, a known public web shell. Confirmed the attacker successfully accessed and interacted with the web shell via four POST requests.

Queries used:

```
index=web-alert 171.251.232.40
| table _time clientip useragent uri_path method status
| sort + _time

index=web-alert 171.251.232.40 useragent!="Mozilla/5.0 (Hydra)"
| table _time clientip useragent uri_path referer referer_domain method status

index=web-alert 171.251.232.40 b374k.php
| table _time clientip useragent uri_path referer referer_domain method status
| sort + _time
```

**Findings:**

```
Time the brute-force activity using Hydra began: 2025-09-14 21:20:27
User agent used when interacting with the web shell: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36
Number of requests made to the server via the web shell: 4
```

**Verdict:** True Positive, escalated to L2.

## Key Takeaways

- Every scenario in this room reinforces the same triage discipline: read the alert details fully before opening the SIEM. Recognizing that a source IP was internal, that a hostname followed a workstation naming convention, or that an IP had thousands of prior AbuseIPDB flags all shaped the investigation before a single query was run.
- Brute force detection isn't just about counting failed logins, it's about correlating volume, targeted usernames, and outcome. A handful of failed logins against a real account is very different from 500 failed attempts against one account following invalid user enumeration against several others, and only the full picture confirms malicious intent.
- Living Off the Land techniques (certutil for downloading, PowerShell for execution, scheduled tasks for persistence) appear across both this room and the Windows Threat Detection series, reinforcing that attackers consistently favor built in, trusted tools over custom malware specifically because it blends into normal administrative activity.
- Tracing a malicious scheduled task back through ProcessId to its parent process, then to the discovery commands and lateral movement that preceded it, is the same process tree methodology used throughout the Windows and Linux Threat Detection rooms, applied here directly inside Splunk rather than raw event logs.
- Excluding known noisy traffic (like Hydra's distinctive user agent) to isolate a second, quieter attack stage is a valuable triage technique: the initial brute force alert would have missed the web shell entirely if the investigation had stopped at the first obvious indicator.
- All three scenarios ended the same way: True Positive, with L1 responsibility ending at identification and escalation, and specific open questions handed to L2 (how access was gained, how the web shell was uploaded, what happened after persistence was established), which reflects the real division of labor in a tiered SOC.
