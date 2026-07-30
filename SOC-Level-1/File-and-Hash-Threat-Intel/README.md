# File and Hash Threat Intel

## Overview

This room focuses on enriching file and hash artefacts using threat intelligence, moving through the "verify, enrich, decide" triage workflow. It covers filepath/filename heuristics, hash generation and validation, and using VirusTotal, MalwareBazaar, and Hybrid Analysis (via the offline TryDetectThis platform) to pull sandbox telemetry and map behaviour to MITRE ATT&CK.

## Task 1: Introduction

Scenario: TryDaily's EDR flags multiple binaries across workstations during a routine sweep. As the L1 analyst shadowing an L2 mentor, the task is to determine within 60 minutes whether the flagged files are bait, benign, or malicious, using the offline TryDetectThis tool for all lookups (hash search, vendor detections, file properties, sandbox behaviour).

## Task 2: Filepath and Filename Heuristics

Covered how attacker tradecraft shows up in file paths and filenames even before any dynamic analysis:

- **Filepath red flags**: `C:\`, `C:\Users\Public`, `C:\Users\Public\Public Downloads`, `C:\Windows\Temp\`, `C:\ProgramData\`, all common staging or persistence locations
- **Filename heuristics**: double extensions (`invoice.pdf.exe`), system binary impersonation (`scvhost.exe`), high-entropy strings (`jh8F21.exe`), and masquerading (`backup-2300.exe` or single character substitution)

**Q: One of the files included in the CTI Files folder on the Desktop shows one of the indicators mentioned. Can you identify the file and the indicator?**
```
payroll.pdf, Double extensions
```

## Task 3: Akira Ransomware File Analysis

Enriched a flagged binary using hash lookups and sandbox telemetry to confirm it as Akira ransomware and trace its behaviour.

**Q: What is the SHA256 hash of the file?**
```
43b0ac119ff957bb209d86ec206ea1ec3c51dd87bebf7b4a649c7e6c7f3756e7
```

**Q: What family labels are assigned to the file on VirusTotal?**
```
akira, filecryptor
```

**Q: When was the first time the file was recorded in the wild?**
```
2024-10-30 17:17:24 UTC
```

**Q: Name the text file dropped during the execution of the malicious file.**
```
akira_readme.txt
```

**Q: What PowerShell command is observed to be executed?**
```
Get-WmiObject Win32_Shadowcopy | Remove-WmiObject
```

**Q: What MITRE ATT&CK ID is associated with the actions of the command?**
```
T1490
```

![Akira Ransomware Analysis](Screen%20Shot%202026-07-29%20at%2010.51.43%20PM.png)

## Task 4: bl0gger.exe and payroll.pdf Analysis (Hybrid Analysis)

Pivoted to Hybrid Analysis to enrich a second sample, bl0gger.exe, and cross-referenced back to the payroll.pdf masquerading file found earlier in the CTI Files folder.

**Q: What tags are used to identify the bl0gger.exe malicious file on Hybrid Analysis?**
```
BlackMoon, Discovery, windows-server-utility
```

**Q: What was the stealth command line executed from the file?**
```
regsvr32 %WINDIR%\Media\ActiveX.ocx /s
```

**Q: Which other process was spawned according to the process tree?**
```
werfault.exe
```

**Q: Analyze the payroll.pdf file located in the CTI Files folder. The payroll.pdf application seems to be masquerading as which known Windows file?**
```
svchost.dll
```

**Q: What associated URL is linked to the file?**
```
hxxp://121.182.174.27:3000/server.exe
```

**Q: How many extracted strings were identified from the sandbox analysis of the file?**
```
454
```

![bl0gger.exe and payroll.pdf Hybrid Analysis](Screen%20Shot%202026-07-28%20at%2010.47.52%20PM.png)

## Task 5: bl0gger Hash and Classification Deep Dive

Continued enrichment on the bl0gger sample, confirming its threat classification and comparing vendor detection results, plus a look at a separate Morse-Code-Analyzer file with a MITRE technique flag.

**Q: What is the SHA256 hash of the file bl0gger?**
```
2672b6688d7b32a90f9153d2ff607d6801e6cbde61f509ed36d045074598d58
```

**Q: What is the threat classification label used to identify the malicious file?**
```
trojan.graftor/flystudio
```

**Q: When was the file first submitted for analysis?**
```
2025-05-15 12:03:49
```

**Q: Which vendor classified the Morse-Code-Analyzer file as non-malicious?**
```
CyberFortress
```

**Q: What MITRE technique has been flagged for persistence and privilege escalation for the Morse-Code-Analyzer file?**
```
DLL Side-Loading
```

![bl0gger Hash and Classification](Screen%20Shot%202026-07-28%20at%2010.45.58%20PM.png)

## Key Takeaways

- Filepath and filename heuristics alone never prove maliciousness, but they're the cheapest first signal an analyst has and should always trigger deeper enrichment, not immediate dismissal.
- Cross-referencing multiple platforms (VirusTotal, Hybrid Analysis, and an internal tool like TryDetectThis) surfaces different angles on the same sample: family labels, tags, process trees, dropped files, and network IOCs.
- Vendor detection results are not unanimous. A file flagged malicious by most vendors can still be labeled non-malicious by one outlier, which is why confidence should be built on multiple corroborating sources rather than a single vendor verdict.
- Sandbox telemetry (dropped files, spawned processes, PowerShell commands, stealth command lines) maps directly to MITRE ATT&CK IDs, which is what turns a raw behavior log into an actionable triage note.
- Masquerading can happen at multiple layers, a filename mimicking a legitimate file (payroll.pdf) can itself contain code impersonating a legitimate system DLL (svchost.dll), so enrichment should not stop at the first indicator found.
