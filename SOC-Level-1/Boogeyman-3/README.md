# Boogeyman 3

## Overview

Boogeyman 3 is the fourth and final capstone challenge in the SOC Level 1 path, closing out the Boogeyman series with the most advanced attack chain yet. After two prior compromises, Quick Logistics LLC brought in a managed security service provider, but the Boogeyman group returns undetected, using previously gained email access to target the CEO, Evan Hutchinson, with a weaponized ISO payload. The investigation uses Elastic Stack (ELK) and Sysmon logs to trace the full attack from initial execution through UAC bypass, credential dumping, lateral movement, domain compromise via DCSync, and an attempted ransomware deployment.

## Task 2 - Lurking in the Dark (Full Investigation)

Investigated a phishing email that had gone undetected from a previous compromise, used by the attacker to target the CEO with a malicious ISO attachment disguised as a PDF. Set the Kibana time range to the presumed incident window (August 29-30, 2023) and used Sysmon Event ID 1 (Process Creation) and Event ID 3 (Network Connection) logs to reconstruct the complete attack chain: initial HTA-based execution, file implantation and scheduled task persistence, C2 callback, UAC bypass, credential dumping with Mimikatz, lateral movement across two additional hosts, a DCSync attack against the domain controller, and an attempted ransomware download.

**Findings:**

```
PID of the process that executed the initial stage 1 payload: 6392 (mshta.exe launching an HTA file masquerading as a PDF)
Full command-line value of the file implant: "C:\Windows\System32\xcopy.exe" /s /i /e /h D:\review.dat C:\Users\EVAN~1.HUT\AppData\Local\Temp\review.dat
Full command-line value of the implanted file execution: "C:\Windows\System32\rundll32.exe" D:\review.dat,DllRegisterServer
Name of the scheduled task created for persistence: Review
IP and port of the C2 connection: 165.232.170.151:80
Process used to execute a UAC bypass: fodhelper.exe
GitHub link used to download the credential dumping tool: https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip
Username and hash of the new credential pair (first machine): itadmin:F84769D250EB95EB2D7D8B4A1C5613F2
File accessed by the attacker from a remote share: IT_Automation.ps1
New credentials discovered for lateral movement: QUICKLOGISTICS\allan.smith:Tr!ckyP@ssw0rd987
Hostname of the attacker's lateral movement target machine: WKSTN-1327
Parent process name of the malicious command on the second machine: wsmprovhost.exe
Username and hash of the newly dumped credentials (second machine): administrator:00f80f2538dcb54e7adc715c0e7091ec
Account dumped via DCSync besides administrator: backupda
Link used to download the ransomware binary: http://ff.sillytechninja.io/ransomboogey.exe
```

![Task 2 answers](Screen%20Shot%202026-07-30%20at%201.23.06%20AM.png)

## Full Attack Chain

1. **Persistence from Prior Compromise** - Previously gained email access used to send a phishing email to CEO Evan Hutchinson, undetected by the new MSSP
2. **Initial Execution** - Malicious ISO attachment disguised as a PDF; mshta.exe (PID 6392) executes an embedded HTA payload
3. **File Implant** - xcopy copies review.dat to the user's Temp directory
4. **Execution** - rundll32.exe executes review.dat via DllRegisterServer
5. **Persistence** - A scheduled task named "Review" is created to maintain access
6. **C2 Establishment** - Connection established to 165.232.170.151:80 within one second of review.dat's execution
7. **Discovery & Privilege Confirmation** - Attacker enumerates local users/groups, confirms local administrator access
8. **Privilege Escalation** - fodhelper.exe abused for a UAC bypass, executing a base64-encoded PowerShell payload from the registry
9. **Credential Access** - Mimikatz downloaded from GitHub, dumps credentials for itadmin
10. **Discovery (Shares)** - itadmin's credentials used to enumerate and read IT_Automation.ps1 from a remote \ITFiles share
11. **Credential Access (via script)** - Discovers QUICKLOGISTICS\allan.smith's plaintext credentials inside the script
12. **Lateral Movement** - allan.smith's credentials used to remotely execute commands on WKSTN-1327 via WinRM (wsmprovhost.exe)
13. **Credential Access (second host)** - Mimikatz used again on WKSTN-1327, dumping administrator's NTLM hash via pass-the-hash
14. **Domain Compromise** - Attacker reaches the domain controller (DC01) and performs a DCSync attack via Mimikatz, dumping both the administrator and backupda accounts
15. **Impact (Attempted)** - PowerShell (Invoke-WebRequest) used to download ransomboogey.exe from a remote server, presumably for ransomware deployment

## Key Takeaways

- This room demonstrates the danger of undetected persistence from a prior breach: because the earlier email compromise was never fully remediated, the attacker retained the ability to launch a new, more sophisticated attack against a higher-value target (the CEO) without needing to re-establish Initial Access from scratch.
- HTA files masquerading as PDFs, combined with mshta.exe execution, is a classic technique for bypassing a user's expectation of what a "document" should do, and it's a pattern worth actively hunting for regardless of the specific payload involved.
- fodhelper.exe is a well-documented UAC bypass technique (abusing the way Windows handles unregistered file handler associations for high-integrity processes), and its appearance in a process tree following privilege enumeration is a strong, specific indicator worth building detection logic around.
- Credential reuse and plaintext credentials stored in scripts (as seen with allan.smith's password embedded in IT_Automation.ps1) remain one of the most reliable ways attackers achieve lateral movement, reinforcing why secrets management and credential scanning of internal scripts matters as much as endpoint detection.
- A DCSync attack targeting a domain controller represents one of the most severe possible outcomes in an Active Directory environment, since it allows an attacker to replicate password hashes for any account, including highly privileged ones like backupda, effectively achieving full domain compromise. Detecting Mimikatz process execution on a DC should be treated as a critical-severity event every time.
- The full Boogeyman series (1 through 3) traces a coherent, escalating narrative: email-based Initial Access, to endpoint memory forensics, to full domain compromise, demonstrating how a single unremediated phishing email compromise can cascade into a ransomware-capable breach of an entire enterprise network if not caught and contained early.
