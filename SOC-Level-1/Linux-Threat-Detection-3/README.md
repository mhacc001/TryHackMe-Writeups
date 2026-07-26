# Linux Threat Detection 3

## Overview

This final room in the Linux Threat Detection series covers the more advanced, manual attack stages seen in targeted Linux intrusions: reverse shells, privilege escalation, and the five most common Linux persistence techniques. The room continues the TryPingMe investigation from Linux Threat Detection 1, tracing the attacker's full post-exploitation chain from establishing a reverse shell through privilege escalation and multiple persistence mechanisms.

## Task 2 - Reverse Shells

Covered why attackers often need to establish a reverse shell after Initial Access via an exploit or web vulnerability, since that access path frequently comes with limitations (no Ctrl+C, execution delays, rate limits) compared to a full SSH terminal. Reviewed three common reverse shell methods (bash -i, socat, python3) and how to detect and trace them using auditd, correlating PPID/PID to reconstruct the process tree back to the vulnerable application. Practiced exploiting the TryPingMe app directly and investigated exported auditd logs to identify a matching real-world attack.

![Task 2 Answers](Screen%20Shot%202026-07-25%20at%2010.37.03%20PM.png)

**Findings:**

- Output seen after ping results (whoami): svctrypingme
- Flag returned in the TryPingMe response (reverse shell attempt): THM{revshells_practitioner!}
- IP that spawned a similar reverse shell via the TryPingMe app: 10.14.105.255

## Task 3 - Privilege Escalation Basics

Covered why Initial Access doesn't always mean full compromise, since web attacks and exploits often land as a low-privilege service user first. Reviewed common Privilege Escalation triggers (unpatched kernels enabling exploits like PwnKit, SUID misconfigurations, exposed credential files) and a universal detection approach: watching for a spike of Discovery commands, a download to a temp directory, and a change in effective UID (before vs after the exploit) as confirmed through auditd. Continued the TryPingMe investigation to trace the attacker's search for credentials and their escalation to root.

![Task 3 Answers](Screen%20Shot%202026-07-25%20at%2010.38.55%20PM.png)

**Findings:**

- Command line used to look for the "pass" keyword in files: grep -iR pass .
- Command line used to escalate privileges to root: su root
- Root password found in the .env file: nGql1pQkGa

## Task 4 - Persistence: Cron and Systemd

Covered the two most common Linux persistence methods: cron jobs (real-world examples include APT29's GoldMax malware and the Rocke cryptominer's self-healing /etc/cron.d/root entry) and systemd services (Sandworm's GOGETTER malware disguised as a fake "cloud-online" service). Covered detection via auditd, monitoring both file changes in cron/systemd locations and execution of related commands (crontab, systemctl). Investigated and triggered both persistence mechanisms directly on the VM.

![Task 4 Answers](Screen%20Shot%202026-07-25%20at%2010.39.34%20PM.png)

**Findings:**

- Flag from running the malware persisting as a service: THM{hidden_penguin!}
- Flag from running the malware persisting as a cron job: THM{ressurect_on_reboot!}

## Task 5 - Account Persistence

Covered account-based persistence methods: creating a new privileged user or planting a backdoor SSH key in an authorized_keys file, mirroring the backdoor user and SSH key techniques already seen in the Windows Threat Detection series. Investigated auth.log and auditd logs to identify a newly created backdoor account and the specific file modified to enable SSH key-based persistence.

![Task 5 Answers](Screen%20Shot%202026-07-25%20at%2010.41.40%20PM.png)

**Findings:**

- User created and added to the sudo group: koichi
- File changed to allow SSH key persistence: /root/.ssh/authorized_keys

## Task 6 - Targeted Attacks and Recap

Closed the room (and the full three-part Linux Threat Detection series) with a discussion of targeted attacks, referencing MITRE Impact (TA0040), the Springtail/Kimsuky backdoor espionage campaign, and the growing reality of Linux ransomware, including attacks against VMware ESXi infrastructure. Reinforced that Linux threat knowledge is valuable even for analysts primarily focused on Windows environments, given how much enterprise infrastructure runs on Linux.

![Task 6 Answers](Screen%20Shot%202026-07-25%20at%2010.42.32%20PM.png)

**Findings:**

- Does Linux ransomware exist and impact organizations worldwide: Yea
- Should you learn Linux threats even if working with Windows: Yea

## Key Takeaways

- Reverse shells exist specifically to overcome the limitations of exploit-based access (no interactivity, timeouts, rate limits), and because they represent an active human attacker rather than automated botnet activity, they should be treated as one of the highest-severity alert categories a SOC can receive.
- Privilege escalation detection doesn't require knowing every specific exploit technique. Watching for the surrounding pattern (a spike of Discovery, a download to /tmp, and a UID change before and after execution) catches PwnKit, SUID abuse, and countless other techniques through the same universal detection logic.
- Linux persistence techniques map closely to their Windows equivalents: cron jobs and systemd services function like scheduled tasks and services, while backdoor accounts and SSH key persistence mirror the user account and Run key techniques covered in the Windows Threat Detection series. Recognizing this parallel makes cross-platform threat detection far more approachable.
- Real-world APT groups (APT29, Sandworm, Springtail/Kimsuky) use the exact same persistence categories covered in this room, just implemented with more polish. GoldMax's cron entry and GOGETTER's disguised systemd service both rely on techniques any analyst can detect with auditd once they know what to monitor.
- This three-part Linux Threat Detection series traced a complete, realistic attack lifecycle: Initial Access (SSH brute force, vulnerable web app, supply chain), Discovery, Ingress Tool Transfer, Privilege Escalation, and Persistence, all detectable through the same core toolset of auth.log, auditd, and process tree analysis. That consistency is the main takeaway: a small number of log sources and one core methodology (correlating PID/PPID and building process trees) covers the overwhelming majority of Linux post-exploitation activity.
