# Detecting Web Attacks

## Overview

This room covers how to detect common web attacks from a SOC perspective, contrasting client-side and server-side attack classes, then walking through log-based and network traffic-based detection methods against a simulated breach at TryBankMe, a small online banking platform. The room closes with an overview of Web Application Firewalls (WAFs) as a mitigation tool.

## Task 2 - Client-Side Attacks

Client-side attacks exploit weaknesses in user behavior or the user's browser/device rather than the server itself. Because these attacks execute inside the browser, they often generate little to no suspicious network traffic or server-side logs, making them difficult for a SOC to detect without endpoint or browser-level monitoring. Covered XSS (the most common client-side attack), CSRF, and clickjacking.

![Task 2 Answers](Screen%20Shot%202026-07-23%20at%209.30.54%20PM.png)

**Findings:**

- Class of attacks that relies on exploiting the user's behavior or device: Client-Side
- Most common client-side attack: XSS

## Task 3 - Server-Side Attacks

Server-side attacks exploit vulnerabilities in the web server, application code, or backend logic rather than the user. Unlike client-side attacks, these leave evidence in logs and network traffic since every request is processed and recorded by the server. Covered brute-force attacks, SQL injection, and command injection, with real-world examples (T-Mobile 2021, MOVEit 2023).

![Task 3 Answers](Screen%20Shot%202026-07-23%20at%209.31.04%20PM.png)

**Findings:**

- Class of attacks that relies on exploiting vulnerabilities within web servers: Server-Side
- Server-side attack that lets attackers abuse forms to dump database contents: SQLi

## Task 4 - Log-Based Detection

Reviewed the standard access log format (client IP, timestamp, status code, response size, referrer, user-agent) and how each field can indicate malicious activity. Investigated a real attack sequence in `access.log` for TryBankMe, tracing an attacker's steps from directory fuzzing through a brute-force login and into SQL injection attempts against the `/search` and `/changeusername.php` forms. Also covered the limitation that access logs typically don't capture POST body data, only that a request occurred.

![Task 4 Answers](Screen%20Shot%202026-07-23%20at%209.31.17%20PM.png)

**Findings:**

- Attacker's User-Agent during the directory fuzz: FFUF v2.1.0
- Page on which the attacker performs the brute-force attack: /login.php
- Complete, decoded SQLi payload used on /changeusername.php: %' OR '1'='1

## Task 5 - Network-Based Detection

Continued the TryBankMe investigation using `traffic.pcap` in Wireshark to recover data that access logs alone couldn't show, including the actual brute-forced credentials and the results of the SQL injection attack. Filtered on destination IP and User-Agent, followed the successful login packet, and used Follow HTTP Stream to reconstruct full requests and responses.

![Task 5 Answers](Screen%20Shot%202026-07-23%20at%209.31.28%20PM.png)

**Findings:**

- Password the attacker successfully identifies in the brute-force attack: astrongpassword123
- Flag found in the database using SQLi: THM{dumped_the_db}

## Task 6 - Web Application Firewalls

Covered WAFs as a mitigation tool that inspects and filters web requests before they reach the server, including four categories of firewall rules (blocking known attack patterns, denying known malicious sources, custom-built rules, and rate-limiting), challenge-response mechanisms like CAPTCHA, and how modern WAFs integrate threat intelligence feeds and OWASP Top 10 coverage.

![Task 6 Answers](Screen%20Shot%202026-07-23%20at%209.32.55%20PM.png)

**Findings:**

- What WAFs inspect and filter: Web Requests
- Custom firewall rule to block User-Agent matching "BotTHM": IF User-Agent CONTAINS "BotTHM" THEN block

## Key Takeaways

- Client-side and server-side attacks require fundamentally different detection approaches: client-side activity happens inside the browser and is largely invisible to a SOC without endpoint monitoring, while server-side activity leaves a trail in logs and network traffic that defenders can actually investigate.
- Access logs and packet captures are complementary, not redundant. Logs are lightweight and always available but miss POST body data, while full packet captures reveal the actual credentials and payloads used, at the cost of being far more verbose and requiring access to unencrypted traffic.
- Reconstructing an attack chain (directory fuzz, then brute-force, then SQLi) from raw logs is a core SOC skill, and recognizing the pattern (repeated 200s during fuzzing, rapid POSTs during brute-force, a 302 marking success, then SQLi payloads against form parameters) is what turns disconnected log lines into a coherent incident timeline.
- WAFs act as a real-time gatekeeper layer in front of the server, and their rule types (pattern blocking, IP/threat-intel denial, custom rules, rate-limiting) map directly onto the attack techniques covered earlier in the room, showing how detection findings translate into concrete mitigation rules.
- A weak or reused password (astrongpassword123 in this case) was enough to fully compromise an account via brute-force, reinforcing why rate-limiting and strong authentication are called out repeatedly as baseline protections across this room and the Web Security Essentials room.
