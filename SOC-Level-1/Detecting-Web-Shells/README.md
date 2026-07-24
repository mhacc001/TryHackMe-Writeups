# Detecting Web Shells

## Overview

This room covers how to identify web shell activity as a SOC Analyst or Incident Responder, starting with what web shells are and how attackers deploy and abuse them, then moving into practical detection across web server logs, file system analysis, and network traffic. The room closes with a full investigation into a compromised WordPress site, tracing an attacker's steps from initial upload through to a hidden flag inside the web shell itself.

## Task 2 - What Is a Web Shell?

A web shell is a malicious program uploaded to a target web server that enables an attacker to execute commands remotely. Web shells commonly serve as both an initial access vector (via file upload vulnerabilities) and a persistence mechanism. Covered real-world examples, including Hafnium's ProxyLogon exploitation of Exchange servers and Conti Ransomware's similar abuse of the same aspnet_client directory.

![Task 2 Answers](Screen%20Shot%202026-07-23%20at%209.42.12%20PM.png)

**Findings:**

- MITRE ATT&CK Persistence sub-technique associated with web shells: T1505.003
- File extension commonly used for web shells targeting Microsoft Exchange: .aspx

## Task 3 - Anatomy of a Web Shell

Web shells rely on abusing legitimate PHP system execution functions like shell_exec(), exec(), system(), and passthru(). Reviewed a simple PHP web shell that accepts a cmd parameter via URL and executes it, then interacted with a live web shell on the lab machine (awebshell.php) both via browser and via curl with URL-encoded commands.

![Task 3 Answers](Screen%20Shot%202026-07-23%20at%209.43.46%20PM.png)

**Findings:**

- Account accessed via whoami: www-data
- Flag found while listing directory contents: THM{W3b_Sh3ll_Usag3}

## Task 4 - Log-Based Detection

Covered the standard access log format and key indicators of web shell activity: unusual HTTP methods and request patterns (repeated GETs, POST to upload locations, PUT requests), suspicious or altered/outdated/blacklisted User-Agents, suspicious source IPs, abnormal or encoded query strings, and missing referrers. Also covered auditd as a native Linux tool for correlating web logs with file system and process events, and the value of centralizing detection through a SIEM.

![Task 4 Answers](Screen%20Shot%202026-07-23%20at%209.44.52%20PM.png)

**Findings:**

- Part of the URL that associates values to parameters: Query Strings
- auditd syscall confirming a file was written to disk following a suspicious POST to /upload.php: creat

## Task 5 - File System and Network Traffic Analysis

Covered common web shell storage locations (Apache's /var/www/html/, Nginx's /usr/share/nginx/html/, common upload directories, and abusable temp directories), how to spot suspicious or randomly-named files including double extensions, and useful find/grep commands for locating recently modified or suspicious PHP files. Also covered network traffic indicators (unusual HTTP methods, suspicious User-Agents/IPs, encoded payloads, malicious command bodies, unexpected ports/protocols) and useful Wireshark HTTP filters for hunting web shell activity in a PCAP.

![Task 5 Answers](Screen%20Shot%202026-07-23%20at%209.47.53%20PM.png)

**Findings:**

- Command to locate .php files in /var/www/: find /var/www/ -type f -name "*.php"
- Wireshark filter to search specifically for PUT requests: http.request.method == "PUT"

## Task 6 - Investigation: Compromised WordPress Site

Investigated a suspected compromise on a WordPress site using the Apache access log at /var/log/apache2/access.log, filtering with grep for suspicious status codes, repeated requests to .php files, and unusual User-Agents (curl) to reconstruct the full attack chain from initial directory discovery through web shell upload, command execution, tool download, and a hidden flag embedded in the shell's source code.

![Task 6 Answers](Screen%20Shot%202026-07-23%20at%209.50.36%20PM.png)

**Findings:**

- Attacker's IP address: 203.0.113.66
- First directory the attacker successfully identifies: /wordpress
- Name of the .php file the attacker uses to upload the web shell: upload_form.php
- First command run using the newly uploaded web shell: whoami
- Second file downloaded after gaining access: linpeas.sh
- Flag hidden within the web shell code: THM{W3b_Sh3ll_Int3rnals}

## Key Takeaways

- Web shells sit at the intersection of initial access and persistence in the MITRE ATT&CK framework (T1505.003), which is why detecting them early is high-value: catching one can interrupt an attacker before they move into privilege escalation, lateral movement, or exfiltration.
- Web shells work by abusing legitimate, expected functionality (PHP execution functions, file upload forms), which is exactly why they're hard to catch with simple denylists. Detection has to rely on behavioral and contextual indicators (request patterns, User-Agent anomalies, query string content) rather than the presence of any single "bad" function.
- No single data source tells the whole story. Access logs show that a request happened, file system analysis shows what got written to disk, network captures show the actual payload, and auditd ties it all together by showing which user or process actually created or executed a file. Correlating across all of them is what turns isolated anomalies into a confirmed attack chain.
- Reconstructing this investigation followed a consistent pattern: find the attacker's IP through anomalous status codes and User-Agents, trace their directory discovery, identify the exact upload vector, then follow their command history through the shell. This kind of methodical, log-driven reconstruction is a core SOC investigative skill that generalizes well beyond web shells specifically.
- Attackers frequently reuse the same shell for both recon and follow-on tooling (in this case, using the shell to whoami, then downloading linpeas.sh for privilege escalation), which is a strong reminder that a single compromised endpoint often escalates quickly if not caught at the initial upload stage.
