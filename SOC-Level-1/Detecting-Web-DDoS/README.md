# Detecting Web DDoS

## Overview

This room covers Denial-of-Service (DoS) and Distributed Denial-of-Service (DDoS) attacks against the application layer (Layer 7), including attacker motives, log-based detection, SIEM-driven investigation using Splunk, and defensive strategies. The room ties together log analysis, Splunk queries, and mitigation concepts across a simulated attack against a bicycle parts e-commerce website.

## Task 2 - What Is a DoS/DDoS Attack?

A DoS attack overwhelms a web service so legitimate users can't access it, whether through a flood of requests or a single malformed request that causes the application to hang or crash. DDoS scales this up using a botnet, a network of compromised devices under an attacker's control, allowing far greater impact than a single machine could achieve alone. Covered common attack types: Slowloris, HTTP Flood, Cache Bypass, Oversized Query, Login/Form Abuse, and Faulty Input Validation Abuse.

![Task 2 Answers](Screen%20Shot%202026-07-23%20at%209.58.25%20PM.png)

**Findings:**

- Class of attack that relies on disrupting the availability of a web service: Denial-of-Service
- Network of compromised machines used to launch DDoS attacks: Botnet

## Task 3 - Attacker Motives

Reviewed common motives behind DoS/DDoS attacks: financial loss, extortion, hacktivism, distraction, competition, denial of wallet, and reputational damage. Covered two real-world examples: the 2015 BBC DDoS (claimed by New World Hacking as a capability test) and the 2023 Microsoft Azure/OneDrive/Outlook outage caused by Anonymous Sudan using HTTP flooding and Slowloris techniques.

![Task 3 Answers](Screen%20Shot%202026-07-23%20at%209.59.14%20PM.png)

**Findings:**

- Attacker motive that aims to make customers lose confidence in a company: Reputational Damage
- Motive most likely behind the 2023 DDoS attack against Microsoft: Hacktivism

## Task 4 - Log-Based Detection

Covered key indicators of DoS/DDoS activity in web server logs: high request rate to resource-heavy pages, odd or spoofed User-Agents, geographic anomalies, burst timestamps, spikes in 5xx server errors, and logic abuse via crafted queries. Reviewed commonly targeted endpoints (/login, /search, /api, /register, /contact, /checkout) due to their higher processing cost per request. Investigated `access.log` for the bicycle parts website to identify the attacker and the resulting impact on legitimate users.

![Task 4 Answers](Screen%20Shot%202026-07-23%20at%2010.00.16%20PM.png)

**Findings:**

- Attacker's IP address: 203.12.23.195
- Page repeatedly targeted by the attacker's requests: /login
- Error code legitimate users receive after the attack: 503

## Task 5 - Leveraging SIEMs

Used Splunk to investigate a suspected DDoS attack against the same website, querying the main index to identify the most targeted URI, the top attacking clientip, the size of the botnet, the most common attacking useragent, and the peak request rate using the timechart command, then identified the first legitimate client to receive a 503 error once the server became overwhelmed.

Queries used:

```
index="main"
index="main" | top uri
index="main" | top clientip
index="main" clientip="203*"
index="main" uri="/search" clientip="203.0.113.*" | top useragent
index="main" | timechart span=1s count by clientip
index="main" status="503" NOT clientip="203.0.113.*"
```

![Task 5 Answers](Screen%20Shot%202026-07-23%20at%2010.02.28%20PM.png)

**Findings:**

- Most frequently requested uri: /search
- clientip that made the most requests to the target uri: 203.0.113.7
- Number of IP addresses part of the botnet: 60
- Most commonly used useragent by attacking traffic: Java/1.8.0_181
- Peak number of requests per second during the attack: 207
- First legitimate clientip to receive a 503 post-attack: 10.10.0.27

## Task 6 - Defense

Covered application-level defenses (secure input validation, CAPTCHA and JavaScript challenges) and network/infrastructure defenses (CDNs for caching and load-balancing, integrated WAFs with rate-limiting rules). Reviewed large-scale real-world mitigation examples (Google's 398M req/s mitigation in 2023, Cloudflare's 11.5 Tbps mitigation) and common attacker techniques to bypass these defenses, such as appending random query parameters to force cache misses.

![Task 6 Answers](Screen%20Shot%202026-07-23%20at%2010.03.17%20PM.png)

**Findings:**

- Security challenge that blocks bots by asking users to solve a simple puzzle: CAPTCHA
- CDN feature that spreads traffic across multiple servers to prevent overload: Load-Balancing

## Key Takeaways

- DoS and DDoS attacks don't require sophisticated exploits, sometimes a single unvalidated search field or a flood of requests to a resource-heavy endpoint like /login is enough to take a service down, which is why input validation and rate-limiting matter as baseline defenses regardless of attack sophistication.
- Attacker motives shape the expected attack profile: understanding whether an attack is financially motivated, hacktivist, or a distraction for another intrusion changes how a SOC should prioritize response, since a DDoS masking a separate attack requires a very different investigative posture than a straightforward extortion attempt.
- Endpoints that require database queries, authentication checks, or session management (/login, /search, /checkout) are disproportionately expensive to process per request, making them the highest-value targets for attackers and the highest-priority endpoints to monitor and rate-limit.
- SIEM platforms turn what would be an unmanageable manual log review into a fast, field-driven investigation. Being able to pivot from top uri to top clientip to a timechart of request volume is what makes it possible to characterize a botnet's size, behavior, and impact in minutes rather than hours.
- Defenses layer on top of each other rather than replacing one another: CDNs absorb and cache traffic, WAFs apply rule-based filtering and rate-limiting, and challenges like CAPTCHA filter out non-human traffic, but attackers actively probe for gaps between these layers (like cache-busting query strings), so no single control is sufficient on its own.
