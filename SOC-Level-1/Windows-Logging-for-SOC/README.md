# Windows Logging for SOC

## Overview

This room covers the fundamentals of Windows event logging for SOC analysts and DFIR professionals: where logs live, how to read them in Event Viewer, and how to use Security logs, Sysmon, and PowerShell history to investigate a simulated multi-stage compromise. The room ties together authentication events, user management events, process/file/network monitoring via Sysmon, and PowerShell command history to reconstruct a full attack chain from initial RDP brute force through backdoor persistence and malware download.

## Task 2 - What Is Logged

Covered where Windows stores event logs (`C:\Windows\System32\winevt\Logs`, binary EVTX format) and how to read them using Event Viewer, including log sources, the log list (keywords, timestamps, Event IDs), log details, and the filter/find tools. Noted that Windows has over 500 documented Event IDs just for Security logs alone, and not all events are logged or documented by default.

**Findings:**

- Event ID that describes a successful login: Security / 4624

## Task 3 - Security Log: Authentication

Covered the two most important Security log events for authentication: 4624 (Successful Logon) and 4625 (Failed Logon), including their purpose, logging behavior, and limitations (noisy for 4624, inconsistent caveats for 4625). Reviewed the core fields to check in a 4624 event: Logon ID, logon type, username, source IP, and hostname. Investigated `Practice-Security.evtx` to trace a brute force attack against THM-PC through to a successful RDP compromise.

**Findings:**

- IP that performed the brute force of THM-PC: 10.10.53.248
- User breached as a result of the attack: Administrator
- Logon ID of the malicious RDP login (Logon Type 10): 0x183C36D

## Task 4 - Security Log: User Management

Covered the key user management Event IDs: 4720/4722/4738 (account created/enabled/changed), 4725/4726 (account disabled/deleted), 4723/4724 (password changed/reset), and 4732/4733 (added to/removed from a security group). Reviewed the common Subject/Object/Details structure shared across these events and how the Logon ID field can correlate a user management event back to its preceding 4624 login. Continued the `Practice-Security.evtx` investigation to find the backdoor account created after the malicious RDP login.

**Findings:**

- User created by the attacker soon after the RDP login: svc_sysrestore
- Two privileged groups the backdoor user was added to: Backup Operators, Remote Desktop Users
- Does the Logon ID field match what was seen in the previous task: Yea

## Task 5 - Sysmon: Process Monitoring

Covered Sysmon as a more powerful alternative to the default (and disabled-by-default) 4688 Process Creation event, including its key field groups in Event ID 1: Process Info, Parent Info, Binary Info, and User Context (including Logon ID for correlation with Security logs). Investigated `Practice-Sysmon.evtx` to trace Sarah's browsing activity and the resulting malware download.

![Task 5 Answers](Screen%20Shot%202026-07-23%20at%2010.20.27%20PM.png)

**Findings:**

- Web browser Sarah uses to browse the web: Google Chrome
- File Sarah downloaded from the browser: C:\Users\sarah.miller\Downloads\ckjg.exe
- URL the file was downloaded from: http://gettsveriff.com/bgj3/ckjg.exe

## Task 6 - Sysmon: Files and Network

Covered four additional Sysmon Event IDs beyond process creation: 11/13 (File Create / Registry Value Set, alternatives to the disabled-by-default 4656/4657) and 3/22 (Network Connection / DNS Query, with no direct Security log alternative). Noted that all these events share the same process-related fields but require correlation with Event ID 1 via ProcessId to get full context (parent process, Logon ID). Continued the investigation into `Practice-Sysmon.evtx` to trace the malware's persistence mechanism and C2 infrastructure.

![Task 6 Answers](Screen%20Shot%202026-07-23%20at%2010.22.53%20PM.png)

**Findings:**

- File created by the downloaded malware to persist on the host: C:\Users\sarah.miller\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\DeleteApp.url
- Command & Control server malware connected to: 193.46.217.4:7777
- Domain the malicious IP corresponds to: hkfasfsafg.click

## Task 7 - PowerShell: Logging Commands

Covered why PowerShell activity isn't captured by process creation logs alone (a single powershell.exe process can run hundreds of distinct commands within one session), and introduced the PowerShell history file (`ConsoleHost_history.txt`, found per-user under `AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\`) as a simple, effective way to track executed commands. Noted its key properties: created per user, survives reboots, logs commands but not their output or script contents. Reviewed the Administrator's PS history on the VM to find evidence of malicious activity.

![Task 7 Answers](Screen%20Shot%202026-07-23%20at%2010.24.36%20PM.png)

**Findings:**

- First PowerShell command executed: Get-ComputerInfo
- Date the Administrator ran the first PS command: May 18, 2025
- Flag stored in the PowerShell history: THM{it_was_me!}

## Key Takeaways

- Windows logging is powerful but fragmented: Security logs (4624/4625/4720/4732), Sysmon (Event ID 1/3/11/13/22), and PowerShell history each capture a different slice of activity, and no single source tells the full story. Reconstructing an attack chain requires pulling from all three.
- Correlation fields are what tie separate log sources together: Logon ID links a 4624 authentication event to subsequent user management events, and ProcessId links a Sysmon Event ID 1 process creation to its file, registry, and network events (3, 11, 13, 22).
- Default Windows logging has real gaps that matter operationally: 4688 (process creation) and 4656/4657 (file/registry changes) are all disabled by default, which is exactly why Sysmon has become a de facto standard for endpoint visibility in most SOC environments.
- PowerShell is uniquely hard to monitor at the process level because a single powershell.exe process can execute an unlimited number of distinct commands without generating new process creation events, which is why a supplementary source like the PS history file (or more advanced options like Transcript Logging or AMSI) is necessary to see what was actually run.
- This room's attack chain (RDP brute force to compromised admin account to backdoor user creation to privilege group additions to malware download to persistence to C2 callback) is a realistic, complete example of how isolated log entries only become a coherent incident narrative once analyzed in sequence and cross-referenced across log sources.
