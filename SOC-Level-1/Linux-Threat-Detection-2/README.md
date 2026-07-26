# Linux Threat Detection 2

## Overview

This room continues from Linux Threat Detection 1 and covers what happens after a Linux host is breached: Discovery, Ingress Tool Transfer, and the common "Hack and Forget" attack outcomes (cryptominers, botnets, proxies). The room closes with a full end-to-end analysis of a real-world malware campaign, Dota3, tracing its infection chain from SSH brute force through Discovery, Persistence, and cryptominer deployment.

## Task 2 - Discovery

Covered why Discovery is usually the first thing an attacker does after breaching a Linux host, since botnets automate Initial Access but a human attacker still needs to orient themselves once they take over. Covered common Discovery command categories: OS/filesystem (pwd, uname, hostname), users/groups (id, whoami, /etc/passwd), process/network (ps aux, ss, netstat), and cloud/sandbox detection (systemd-detect-virt, lsmod). Practiced running Discovery commands directly on the VM to identify the host's cloud environment and any installed antimalware.

![Task 2 Answers](Screen%20Shot%202026-07-25%20at%2010.26.07%20PM.png)

**Findings:**

- systemd-detect-virt output: Amazon
- Full path to the detected antimalware binary: /var/lib/ultrasec/malscan

## Task 3 - Specialized Discovery

Covered more targeted Discovery commands attackers use once they've established their objective: credential/secret hunting (history | grep pass, find for .env or id_rsa files), cryptomining suitability checks (cpuinfo, lscpu, free), and internal network scanning (ping sweeps, netcat port checks). Covered process tree reconstruction using `ausearch -i -x` and `ausearch -i --pid/--ppid` to trace a suspicious command like whoami back to its originating script. Investigated a SIEM alert scenario where the itsupport user's hostname command turned out to originate from a legitimate troubleshooting script.

![Task 3 Answers](Screen%20Shot%202026-07-25%20at%2010.27.22%20PM.png)

**Findings:**

- Path of the script that initiated the "hostname" command: /home/itsupport/debug.sh
- Last Discovery command launched by the script: ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu
- Email of the script author: greg@tryhackme.thm

## Task 4 - Hack and Forget Attacks and Ingress Tool Transfer

Covered "Hack and Forget" attacks as opportunistic, at-scale campaigns that typically end in one of three outcomes: cryptominer installation, botnet enrollment (e.g. Mirai), or use as a proxy for phishing/malware hosting/traffic routing. Covered MITRE's Ingress Tool Transfer technique and the three most common delivery methods: wget, curl, and SSH-based transfer (scp/sftp), including the detection nuance that an attacker-initiated scp pull won't appear in the victim's auditd logs but will show up as a new SSH login. Covered supplementary detection angles beyond process logs: network traffic (known-bad IPs/domains, GitHub-hosted tools), file events (new files in /tmp), and EDR/antivirus alerts.

![Task 4 Answers](Screen%20Shot%202026-07-25%20at%2010.29.38%20PM.png)

**Findings:**

- Domain the Elastic agent was downloaded from: artifacts.elastic.co
- Full path to the downloaded "helper.sh" script: /var/tmp/helper.sh
- Which downloaded file is more likely to be malicious: curl

## Task 5 - Dota3 Malware Analysis (Initial Access, Discovery, Persistence)

Walked through the real-world Dota3 malware campaign (referencing CounterCraft and SANS reports) as a case study of the full attack chain covered throughout the room: a global botnet SSH-brute-forcing the root user, rapid-fire Discovery commands to fingerprint the host for cryptomining suitability, and Persistence via a changed root password and replaced SSH keys (tagged with the distinctive "mdrfckr" comment). Investigated a similar infection chain in `/home/ubuntu/scenario` using auth.log and auditd logs.

![Task 5 Answers](Screen%20Shot%202026-07-25%20at%2010.30.26%20PM.png)

**Findings:**

- IP address that managed to brute-force the exposed SSH: 45.9.148.125
- Command the attacker used to list the last logged-in users: last
- Three EDR processes the attacker looked for with "egrep": ds_agent, falcon, sentinel

## Task 6 - Cryptominer Setup

Continued the Dota3 analysis into its final stage: transferring the cryptominer archive via SCP, unpacking it into a hidden, legitimate-sounding folder under /tmp, and launching both a network scanner (tsm) and the XMRig-based cryptominer (initall) using nohup to persist beyond the SSH session. Covered detection indicators specific to this stage: hidden file/folder creation in /tmp, known malware archive names, nohup usage, internal network SSH scanning, and EDR detection of the XMRig binary itself.

![Task 6 Answers](Screen%20Shot%202026-07-25%20at%2010.31.18%20PM.png)

**Findings:**

- Name of the malicious archive transferred via SCP: kernupd.tar.gz
- Full command line of the cryptominer launch: nohup /tmp/.apt/kernupd/kernupd
- IP address range the attacker scanned for exposed SSH: 10.10.12.1-10.10.12.10

## Key Takeaways

- Discovery on Linux follows a highly predictable pattern regardless of the attacker's ultimate goal: the same handful of OS, user, process, and network commands show up across nearly every intrusion, which makes them a strong candidate for baseline detection rules (the room specifically calls out whoami as high-signal since legitimate services almost never run it).
- Context is everything when triaging Discovery activity. The exact same hostname command was legitimate when traced back to an IT script (debug.sh) versus what would be a red flag if traced back to a web server process, reinforcing that process tree analysis, not the command in isolation, is what separates false positives from real incidents.
- Ingress Tool Transfer has a detection blind spot worth remembering: when an attacker pulls a file from the victim using their own scp/sftp client, it won't appear in the victim's auditd process logs at all, only as a new SSH login, which is why auth.log and auditd need to be correlated together rather than relied on independently.
- "Hack and Forget" attacks like Dota3 are opportunistic and automated at massive scale, but their attack chain (brute force, Discovery, Persistence, malware deployment) is fully traceable through the exact same log sources covered throughout this whole two-room series, proving that even simple, high-volume attacks leave a complete forensic trail when you know where to look.
- Malware operators deliberately choose folder and file names that resemble legitimate system paths (like .X26-unix or kernupd) specifically to discourage a cursory investigation. Knowing this pattern is itself a detection heuristic: unusual, hidden, or oddly-named directories under /tmp deserve scrutiny even when they superficially look like normal system artifacts.
