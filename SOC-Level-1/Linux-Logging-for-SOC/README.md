# Linux Logging for SOC

## Overview

This room covers the fundamentals of Linux logging for SOC analysts: where key log sources live, how to filter and interpret them, and where native logging falls short. It walks through syslog, auth.log, package manager and bash history logs, the concept of system calls, and closes with a hands-on investigation using auditd to uncover a threat actor's actions on a compromised host.

## Task 2 - Log Format

Covered how Linux logs most events as unstructured plain text (unlike Windows' structured, event-coded EVTX format), primarily under `/var/log`. Reviewed how to filter noisy logs with `grep` and how to discover relevant log sources by searching for keywords like "login," "auth," or "session" across the entire `/var/log` directory. Investigated `/var/log/syslog` to find both a benign system event and a kernel security module message.

![Task 2 Answers](Screen%20Shot%202026-07-25%20at%209.57.29%20PM.png)

**Findings:**

- Time server domain the VM contacted to sync its time: ntp.ubuntu.com
- Kernel message from Yama in /var/log/syslog: Becoming mindful.

## Task 3 - Authentication Logs

Covered `/var/log/auth.log` (or `/var/log/secure` on RHEL-based systems) as the primary log source for login/logout events (local, SSH, sudo, cron sessions), SSH-specific Accepted/Failed events, user management events (useradd/usermod/userdel/passwd), and commands run via sudo. Investigated `/var/log/auth.log` to trace an SSH brute force attempt and a subsequent backdoor user creation.

![Task 3 Answers](Screen%20Shot%202026-07-25%20at%2010.00.11%20PM.png)

**Findings:**

- IP address that failed to log in on multiple users via SSH: 10.14.94.82
- User created and added to the "sudo" group: xerxes

## Task 4 - Package Manager and Bash History Logs

Covered how package manager logs (dpkg.log/apt logs on Debian-based systems) can confirm installed software versions, and how bash history (`~/.bash_history`) can reveal a user's command activity, with the caveat that not every account uses bash or leaves a reliable history file. Investigated both log types, finding that the relevant history entry was in root's history rather than the initially logged-in user's.

![Task 4 Answers](Screen%20Shot%202026-07-25%20at%2010.02.50%20PM.png)

**Findings:**

- Version of unzip installed on the system (per package manager logs): 6.0-28ubuntu4.1
- Flag seen in one of the users' bash history: THM{note_to_remember}

## Task 5 - Runtime Monitoring: System Calls

Covered the gap in default Linux logging: process creation, file changes, and network activity (runtime events) aren't logged out of the box, mirroring the same limitation Windows has without Sysmon. Introduced system calls as the foundational OS concept behind all modern EDR and logging tools, since user-space actions like opening a file or launching a process must go through the kernel via a syscall, making them a reliable point of visibility that's effectively impossible for a typical program to bypass.

![Task 5 Answers](Screen%20Shot%202026-07-25%20at%2010.03.47%20PM.png)

**Findings:**

- Linux system call commonly used to execute a program: execve
- Can a typical program open a file or create a process bypassing system calls: Nay

## Task 6 - Auditd and Runtime Investigation

Covered auditd as Linux's native runtime monitoring solution, plus modern alternatives built on the same system-call-monitoring principle (Sysmon for Linux, Falco, Osquery, EDRs). Investigated auditd logs using `ausearch -i` and `grep` to trace a full runtime attack chain: a sensitive file access, a tool downloaded via wget, and a subsequent network scan.

**Findings:**

- When secret.thm was opened for the first time: 08/13/25 18:36:54
- Original file name downloaded from GitHub via wget: naabu_2.3.5_linux_amd64.zip
- Network range scanned using the downloaded tool: 192.168.50.0/24

## Key Takeaways

- Linux logging is fundamentally less structured than Windows: plain text files under /var/log instead of event-coded EVTX, which makes grep-based filtering a core skill rather than an optional convenience. Knowing which keywords to search for (session opened/closed, useradd, COMMAND=, Failed/Accepted) is what actually makes /var/log/auth.log usable at scale.
- Default Linux logging has the exact same blind spot as default Windows logging: neither captures process creation, file changes, or network activity without additional tooling. Just as Sysmon fills that gap on Windows, auditd (or a modern alternative like Falco or Osquery) fills it on Linux, and understanding system calls is the shared foundation behind both.
- Bash history is a useful but unreliable artifact: it's easy to check the wrong user's history (or miss that an attacker escalated privileges and left evidence in root's history instead of their own), so a thorough investigation checks every account's history, not just the one that logged in first.
- Reconstructing this investigation followed a familiar pattern from the Windows Threat Detection rooms: authentication logs to establish initial access, package/history logs for supporting context, and auditd for the definitive forensic trail of what the attacker actually did (accessed a sensitive file, downloaded a tool, ran a network scan).
- Because system calls are the one layer a typical attacker cannot bypass, they're the most trustworthy source of runtime evidence on a Linux host, which is exactly why every serious Linux monitoring tool, from auditd to EDRs, is built around watching them.
