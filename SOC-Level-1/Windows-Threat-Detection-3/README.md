# Windows Threat Detection 3

## Overview

This room completes the Windows threat detection series, covering what happens after a threat actor has breached a host and wants to stay: Command and Control, Persistence, and Impact. The room walks through detecting a C2 setup, backdoored user accounts, malicious services and scheduled tasks, per-user persistence via Run keys and the Startup folder, and closes with a discussion of why persistence matters and where in the attack chain detection is most valuable.

## Task 2 - Command and Control

Covered the MITRE Command and Control (C2) tactic and why most threat actors set up a C2 channel immediately after breach rather than relying solely on something like an open RDP session. Covered both simple C2 (the initial payload itself connects back) and more advanced setups (the initial payload downloads and stages a separate, stealthier C2 malware). Investigated `Sysmon.evtx` to trace a full C2 setup from download through execution to callback.

![Task 2 Answers](Screen%20Shot%202026-07-24%20at%2011.22.09%20PM.png)

**Findings:**

- Suspicious archive the user downloaded: URGENT!.zip
- Where the attackers hid the C2 malware file: C:\Users\Administrator\AppData\Roaming\update.exe
- Domain of the Command and Control server: route.m365officesync.workers.dev

## Task 3 - Persistence via Backdoored User

Covered Persistence as a MITRE tactic focused on maintaining long-term, reboot-and-password-change-resistant access. Covered how backdoored user accounts work: creating a new user (T1136), making it privileged (T1098), or resetting an old/unused account's password, and the corresponding Security Event IDs (4720 for creation, 4732 for group membership, 4724 for password reset). Investigated `Security.evtx` to trace an RDP brute force through to backdoor account creation.

![Task 3 Answers](Screen%20Shot%202026-07-24%20at%2011.23.31%20PM.png)

**Findings:**

- Number of failed login attempts to Administrator: 6
- Backdoor user the attacker created after the successful login: support
- Privileged group the backdoor user was added to: Administrators

## Task 4 - Malware Persistence (Services and Scheduled Tasks)

Covered two common system-level persistence methods for malware that doesn't rely on RDP access: creating a malicious Windows Service (Security Event ID 4697 / System Event ID 7045) or a malicious Scheduled Task (Security Event ID 4698), both launched via Sysmon Event ID 1 for the sc.exe or schtasks.exe process. Investigated two backdoors left behind after a system restart.

![Task 4 Answers](Screen%20Shot%202026-07-24%20at%2011.24.29%20PM.png)

**Findings:**

- Windows service created to persist the Nessie malware: Data Protection Service
- Scheduled task created to persist the Troy malware: AmazonSync
- Flag from finding and running the Troy malware: THM{c2_is_on_schedule!}

## Task 5 - Run Keys and Startup

Covered two per-user persistence methods that trigger on login rather than system boot: the Startup folder (`%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\`, detected via Sysmon Event ID 11 for new file creation) and Run registry keys (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, detected via Sysmon Event ID 13 for new registry values). Noted that both methods result in an explorer.exe parent process, making them easy to confuse with legitimate user-launched activity. Investigated additional backdoors using both techniques.

![Task 5 Answers](Screen%20Shot%202026-07-24%20at%2011.26.02%20PM.png)

**Findings:**

- Parent process image of the "Odin" malware: C:\Windows\explorer.exe
- Last line the "Odin" malware outputs: Done doing bad stuff!
- Flag from finding and running the "Kitten" malware: THM{persisting_in_basket!}

## Task 7 - Need for Persistence and Impact

Covered why threat actors invest in persistence rather than simply stealing data and leaving: adding the host to a botnet (Kraken Botnet), long-term espionage as part of a state-sponsored campaign (Volt Typhoon staying undetected in the US electric grid for nearly a year), or using the host as an entry point into a larger network (a 29-day breach chain from IcedID to Dagon Locker ransomware). Discussed ransomware as the most disruptive Impact outcome for corporate Windows networks, citing the McLaren Health Care breach affecting 743,000 patients, and reinforced that detection is always most valuable as early in the attack chain as possible, ideally right after Initial Access.

**Findings:**

- Biggest threat to most corporate Windows networks: Ransomware
- Best stage to detect and stop the attack: Initial Access

## Key Takeaways

- C2 detection often comes down to tracing a small number of Sysmon events: an archive download, a dropped executable staged somewhere unassuming like %APPDATA%, and its first outbound connection. Catching any one of these three stages early can prevent the attacker from ever gaining a reliable communication channel.
- Persistence techniques span multiple privilege levels and trigger conditions: backdoored user accounts survive independently of any single process, services and scheduled tasks trigger on system boot and require admin rights, and Run keys/Startup folder entries trigger per-user on login without needing elevated privileges. A thorough persistence hunt has to check all of these layers, not just one.
- Explorer.exe as a parent process is a recurring theme across this whole room series (GUI-driven Discovery, phishing/USB execution, and now Startup/Run key persistence), which is exactly why parent process alone is never sufficient context. Correlating with the preceding file creation or registry modification event is what actually confirms malicious intent.
- Persistence exists because attackers see more value in staying than in a quick smash-and-grab: botnet recruitment, long-term espionage, and network-wide ransomware deployment all depend on maintaining access well beyond the initial breach, which is why early detection at Initial Access has disproportionate value compared to catching the same actor weeks later.
- Across the full Windows Threat Detection series (1 through 3), the same core methodology repeats: correlate Sysmon Event ID 1 process creation with Security log authentication and account events, and always trace backward to the originating file creation, download, or login event rather than trusting any single log entry in isolation.
