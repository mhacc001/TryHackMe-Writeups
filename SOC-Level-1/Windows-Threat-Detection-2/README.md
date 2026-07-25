# Windows Threat Detection 2

## Overview

This room continues from Windows Threat Detection 1 and covers what threat actors typically do after Initial Access: Discovery, Collection, Credential Access, and Exfiltration, plus Ingress Tool Transfer. The room walks through detecting Discovery commands, tracing a phishing payload's behavior via Sysmon, hunting for collected sensitive data, analyzing a data stealer, and identifying common tool transfer techniques used to bring additional malware onto a compromised host.

## Task 2 - Situational Awareness (Discovery)

Covered the MITRE Discovery tactic and the common commands attackers use to understand a victim environment: files/folders, users/groups, system/apps, network settings, and active antivirus checks. Practiced running a Discovery command (`net user Administrator`) and locating its corresponding Sysmon Event ID 1 entry.

![Task 2 Answers](Screen%20Shot%202026-07-24%20at%2011.07.23%20PM.png)

**Findings:**

- Privileged group the user belongs to: Administrators
- "Image" field of the net command in Sysmon logs: C:\Windows\System32\net.exe

## Task 3 - Discovery via CMD and GUI

Covered how Discovery commands appear as a process tree in Sysmon logs, whether launched via CMD (from a phishing payload like invoice.pdf.exe) or via GUI tools after an interactive login (Computer Management, Task Manager, Notepad, etc). Emphasized correlating ProcessId and ParentProcessId to reconstruct the full command sequence and distinguish malicious activity from legitimate IT usage. Investigated a live phishing attachment (`invoice.pdf.exe`) to trace its Discovery behavior end to end.

![Task 3 Answers](Screen%20Shot%202026-07-24%20at%2011.08.26%20PM.png)

**Findings:**

- First command invoice.pdf.exe executes: whoami
- Command used to check for MS Defender EDR presence: cmd /c "tasklist /v | findstr MsSense.exe || echo No MS Defender EDR"
- Domain the malware sent the discovered data to: exfil.beecz.cafe

## Task 4 - Searching Secrets (Collection, Credential Access, Exfiltration)

Covered common Collection targets depending on attacker motive: personal data (photos, chats, browser history) for blackmail, financial data (banking sessions, crypto wallets) for theft, and corporate data (SSH keys, databases) for broader compromise. Covered common Exfiltration destinations attackers use to blend in with legitimate traffic: trusted cloud storage (Dropbox, Mega, S3), code repositories or messengers (GitHub, Telegram), or convincingly-named lookalike domains. Investigated the VM directly to find sensitive data an attacker would target.

![Task 4 Answers](Screen%20Shot%202026-07-24%20at%2011.11.45%20PM.png)

**Findings:**

- Facebook password saved in Chrome: nsAghv51BBav90!
- Interesting SSH key stored on disk: thm-access-database.key
- Secret PDF file explaining TryHackMe's internal network: thm-network-diagram-2025.pdf

## Task 5 - Detecting Collection (Data Stealer Analysis)

Ran a simulated data stealer and traced its full behavior through Sysmon logs: creation of a staging directory, targeted file extension search, clipboard content capture via PowerShell, and final exfiltration of the compressed archive to a cloud storage domain.

![Task 5 Answers](Screen%20Shot%202026-07-24%20at%2011.12.46%20PM.png)

**Findings:**

- Staging directory the stealer creates: staging_58f1
- Three file extensions the malware searches for: docx, pdf, xlsx
- PowerShell cmdlet used to get clipboard content: Get-Clipboard
- Domain the malware exfiltrates data to: collecteddata-storage-2025.s3.amazonaws.com

## Task 6 - Ingress Tool Transfer

Covered MITRE's Ingress Tool Transfer technique (T1105) and the common methods attackers use to bring additional tools onto a compromised host: web browser download, curl.exe, certutil.exe, and PowerShell's Invoke-WebRequest. Downloaded the same file via each of the four methods to compare how each appears in logs.

![Task 6 Answers](Screen%20Shot%202026-07-24%20at%2011.14.35%20PM.png)

**Findings:**

- Flag from downloading via Chrome browser: THM{just_use_web_browser}
- Flag from downloading via curl.exe: THM{curl_is_cool}
- Flag from downloading via certutil.exe: THM{abusing_certutil}
- Flag from downloading via PowerShell Invoke-WebRequest: THM{power_of_powershell}

## Key Takeaways

- Discovery is often the first observable post-compromise activity, and because it relies on built-in Windows commands (whoami, net user, ipconfig, tasklist), it generates process creation events that are relatively easy to catch with Sysmon Event ID 1, provided you're actively looking for unusual sequences rather than individual commands in isolation.
- Malware increasingly checks for the presence of specific EDR products (like MsSense.exe for Microsoft Defender EDR) before proceeding, which means seeing that kind of conditional check in a process tree is itself a strong indicator of deliberate, security-aware malicious activity rather than benign automation.
- Collection targets are highly predictable once you understand attacker motive: browser-stored credentials, SSH keys, and sensitive documents are consistently high-value regardless of whether the end goal is blackmail, financial theft, or corporate compromise, which makes them a reasonable starting point for proactive threat hunting.
- Data stealers follow a consistent lifecycle: create a staging directory, search for specific file types, optionally grab clipboard contents, compress everything, then exfiltrate to a destination designed to blend in (commonly cloud storage). Recognizing this lifecycle in Sysmon logs is more valuable than memorizing any single malware family's specific IOCs.
- Ingress Tool Transfer can happen through four completely different mechanisms (browser, curl, certutil, PowerShell) that all accomplish the same goal but leave very different log signatures, which is why defenders need visibility into all of them rather than assuming a single "malicious downloader" pattern.
