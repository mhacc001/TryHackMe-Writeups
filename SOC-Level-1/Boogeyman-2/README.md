# Boogeyman 2

## Overview

Boogeyman 2 is the third capstone challenge in the SOC Level 1 path, continuing directly from Boogeyman 1. After Quick Logistics LLC hardened its defenses following the first attack, the Boogeyman threat group returns with improved TTPs, this time targeting an HR employee (Maxine) with a malicious resume attachment. Unlike Boogeyman 1's log-based investigation, this room centers on memory forensics using Volatility 3 alongside email and macro analysis with olevba, reconstructing the full attack chain directly from a live memory capture of the compromised workstation.

## Task 2 - The Boogeyman Is Back! (Full Investigation)

Investigated a spear-phishing email disguised as a job application sent to Maxine, an HR Specialist, containing a malicious Word document (Resume_WesleyTaylor.doc). Used olevba to extract and analyze the document's VBA macro, revealing a multi-stage download chain: a JavaScript stager (update.js, disguised as update.png) executed via wscript.exe, which in turn downloaded and executed a compiled C2 binary (updater.exe). Correlated the email and macro findings against a memory dump of the victim's workstation (WKSTN-2961.raw) using Volatility 3, reconstructing the full process tree, network connections, and file artefacts, then identified the attacker's scheduled task persistence mechanism.

Key Volatility 3 plugins and commands used:

```
vol -f WKSTN-2961.raw windows.pstree
vol -f WKSTN-2961.raw windows.filescan
vol -f WKSTN-2961.raw windows.dumpfiles --virtaddr <address>
vol -f WKSTN-2961.raw windows.netscan
vol -f WKSTN-2961.raw windows.cmdline
strings WKSTN-2961.raw | grep schtasks
```

**Findings:**

```
Email used to send the phishing email: westaylor23@outlook.com
Email of the victim employee: maxine.beck@quicklogisticsorg.onmicrosoft.com
Name of the attached malicious document: Resume_WesleyTaylor.doc
MD5 hash of the malicious attachment: 52c4384a0b9e248b95804352ebec6c5b
URL used to download the stage 2 payload (via document macro): https://files.boogeymanisback.lol/aa2a9c53cbb80416d3b47d85538d9971/update.png
Process that executed the stage 2 payload: wscript.exe
Full file path of the stage 2 payload: C:\ProgramData\update.js
PID of the process that executed the stage 2 payload: 4260
Parent PID of the process that executed the stage 2 payload: 1124
URL used to download the malicious binary via the stage 2 payload: https://files.boogeymanisback.lol/aa2a9c53cbb80416d3b47d85538d9971/update.exe
PID of the malicious process used to establish the C2 connection: 6216
Full file path of the malicious C2 process: C:\Windows\Tasks\updater.exe
IP address and port of the C2 connection: 128.199.95.189:8080
Full file path of the malicious email attachment (per memory dump): C:\Users\maxine.beck\AppData\Local\Microsoft\Windows\INetCache\Content.Outlook\WQHGZCFI\Resume_WesleyTaylor (002).doc
Command used to establish scheduled task persistence: schtasks /Create /F /SC DAILY /ST 09:00 /TN Updater /TR 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NonI -W hidden -c "IEX ([Text.Encoding]::UNICODE.GetString([Convert]::FromBase64String((gp HKCU:\Software\Microsoft\Windows\CurrentVersion debug).debug)))"'
```

![Task 2 answers](Screen%20Shot%202026-07-30%20at%201.12.12%20AM.png)

## Full Attack Chain

1. **Initial Access** - Spear-phishing email disguised as a job application, targeting an HR employee specifically because HR routinely opens unsolicited resume attachments from strangers
2. **Execution (Stage 1)** - Malicious Word document's VBA macro downloads a disguised JavaScript file (update.png, actually update.js) and executes it via wscript.exe
3. **Execution (Stage 2)** - The JavaScript stager downloads a compiled C2 binary (updater.exe) to C:\Windows\Tasks and executes it
4. **C2 Establishment** - updater.exe (identified via VirusTotal as Sharpire, a C# port of the Empire C2 framework) connects to 128.199.95.189:8080
5. **Persistence** - A daily scheduled task (Updater) re-executes a base64-encoded PowerShell payload stored in the registry (HKCU:\Software\Microsoft\Windows\CurrentVersion\debug) every day at 09:00

## Key Takeaways

- Targeting HR with a resume-themed lure is a deliberate and effective social engineering choice: HR employees are professionally obligated to open unsolicited attachments from unknown senders, which removes one of the most common phishing red flags (an unexpected attachment from a stranger) entirely.
- Multi-stage payload delivery (macro to JavaScript to compiled binary) exists specifically to frustrate detection at each layer: a macro alone looks relatively benign, a JavaScript stager disguised with an image file extension (update.png containing JS) evades simple extension-based filtering, and only the final binary carries the actual C2 capability.
- Memory forensics with Volatility 3 made it possible to reconstruct process relationships (pstree), recover deleted or in-memory-only files (filescan plus dumpfiles), and confirm live network connections (netscan) entirely from a single RAM capture, without needing disk images or live system access, which is a critical DFIR capability when a system can't be taken offline for imaging.
- Registry-based payload storage (stashing a base64-encoded PowerShell payload in a custom registry value like HKCU:\...\debug) is a stealthy persistence variant, since the payload itself doesn't need to touch disk as a standalone file, only the small scheduled task trigger does.
- Using VirusTotal to identify updater.exe as Sharpire (a known open-source C2 framework) demonstrates how threat intelligence enrichment complements memory forensics: recognizing a known tool immediately provides context about the attacker's likely capabilities and typical behavior patterns without needing to reverse-engineer the binary from scratch.
