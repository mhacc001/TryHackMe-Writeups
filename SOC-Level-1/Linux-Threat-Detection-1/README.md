# Linux Threat Detection 1

## Overview

This room builds on Linux Logging for SOC and covers common Linux Initial Access techniques: SSH brute force, exploitation of a vulnerable public-facing web application (T1190), and Supply Chain Compromise. The room ties together auth.log analysis, web application logs, and auditd-based process tree analysis to fully reconstruct two separate attack chains on the same VM.

## Task 2 - Popularity of SSH

Covered SSH as one of the most common Linux Initial Access vectors (MITRE T1133, External Remote Services), the same technique category as RDP on Windows. Covered common risk scenarios for both key-based authentication (stolen keys from a breached repo or infected admin laptop) and password-based authentication (weak test passwords, contractor accounts, accidentally exposed legacy servers). Investigated `/var/log/auth.log` to establish a baseline of the ubuntu user's normal login behavior.

![Task 2 Answers](Screen%20Shot%202026-07-25%20at%2010.12.50%20PM.png)

**Findings:**

- When the ubuntu user first logged in via SSH: 2024-10-22
- Did the ubuntu user use SSH keys instead of a password: Yea

## Task 3 - Detecting SSH Attacks

Covered how to distinguish legitimate from malicious SSH logins by examining a handful of key fields: authentication method (key vs password), source IP (internal vs external, trusted vs unknown), and timing (matches expected user/automation behavior or not). Walked through a worked example comparing a legitimate Ansible key-based login against two suspicious password-based logins from external IPs. Investigated `/var/log/auth.log` to trace a full SSH password brute force campaign to its successful breach.

![Task 3 Answers](Screen%20Shot%202026-07-25%20at%2010.14.07%20PM.png)

**Findings:**

- When the SSH password brute force started: 2025-08-21
- Four users the botnet attempted to breach: root, roy, sol, user
- IP that managed to breach the root user: 91.224.92.79

## Task 4 - Initial Access via Public-Facing Application

Covered MITRE T1190 (Exploit Public-Facing Application) with real-world examples (Zimbra Collaboration CVE, exposed Docker API, Palo Alto firewall CVE, WordPress plugin abuse). Covered the limitation of application logs: they rarely explicitly say "I am being exploited," but still provide artifacts for analysis. Walked through a command injection example against a fictional TryPingMe web app, where an attacker injected OS commands into a vulnerable ping parameter. Investigated `/var/log/nginx/access.log` to trace the exploitation and recover a flag from the exposed application source code.

![Task 4 Answers](Screen%20Shot%202026-07-25%20at%2010.17.35%20PM.png)

**Findings:**

- Path to the Python file the attacker attempted to open: /opt/trypingme/main.py
- Flag found inside the opened file: THM{i_am_vulnerable!}

## Task 5 - Building a Process Tree

Covered process tree analysis as a method for tracing suspicious command execution (like whoami) back to its originating process, using auditd's `ausearch -i` to pivot from a child process's PPID up through the process chain to identify the ultimate parent (in this case, the vulnerable web application itself). Continued the TryPingMe investigation using auditd logs to fully reconstruct the exploitation chain from the injected shell command back to the vulnerable application, and further to the attacker's reverse shell.

![Task 5 Answers](Screen%20Shot%202026-07-25%20at%2010.19.32%20PM.png)

**Findings:**

- PPID of the suspicious whoami command: 1018
- PID of the TryPingMe app: 577
- Program the attacker used to open a reverse shell: python

## Task 6 - Human-Led Attacks and Supply Chain Compromise

Covered why phishing and USB-based Initial Access are less common on Linux servers (technical operators, no GUI, no physical USB ports on cloud infrastructure) but still a real risk, with examples like blindly piping a shell script from a forum or a typosquatted PyPI package. Covered Supply Chain Compromise as a distinct risk category, citing the XZ Utils backdoor and the tj-actions GitHub Action breach as real-world examples. Tied together all techniques covered in the room under a single detection methodology: process tree analysis, starting from a trigger (a SIEM alert or suspicious connection) and tracing backward to determine whether the originating process is a web server, an internal service, or a user's SSH session.

![Task 6 Answers](Screen%20Shot%202026-07-25%20at%2010.20.48%20PM.png)

**Findings:**

- Initial Access technique likely used if a trusted app suddenly runs malicious commands: Supply Chain Compromise
- Detection method used to detect a variety of Initial Access techniques: Process Tree Analysis

## Key Takeaways

- SSH and RDP share the same MITRE technique (T1133, External Remote Services) and the same fundamental detection approach: a handful of fields (auth method, source IP, timing) are usually enough to separate legitimate access from a breach, provided you have an established baseline of normal behavior to compare against.
- Application logs rarely announce an exploitation attempt directly, but unusual patterns (shell metacharacters in query parameters, unexpected 500-then-200 response sequences, requests that don't fit the application's intended use) are consistently strong indicators worth building detection logic around.
- Process tree analysis is the single most versatile detection technique covered in this room, since it applies identically whether the Initial Access vector was SSH, a vulnerable web app, or a supply chain compromise. The differentiator is always which process sits at the root of the suspicious activity, not the specific technique used to get there.
- auditd's ausearch is what actually makes process tree reconstruction possible on Linux, since it lets an analyst pivot from a suspicious command's PID up to its PPID and beyond, mirroring how ProcessId/ParentProcessId correlation worked in Sysmon on Windows.
- Supply Chain Compromise is uniquely dangerous because it breaks the usual assumption that "a trusted internal service acting maliciously" is impossible. When a well-known application or dependency starts running unexpected commands, this technique, rather than a fresh external breach, should be the first hypothesis considered.
