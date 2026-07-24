# Web Security Essentials

## Overview

This room covers the fundamentals of web security: how the request-response cycle works, the three core components of any web service (application, web server, host machine), common web servers, and the best practices and tools used to protect each layer, including WAFs, CDNs, logging, and antivirus. The room closes with a hands-on practical applying these concepts to a simulated site launch.

## Task 1 - Introduction

Reviewed the shift from desktop applications to web-based applications over the past few decades and the tradeoffs that shift introduced from a security perspective, including real-world breach examples (Equifax 2017, Capital One 2019) that illustrate the impact of vulnerable web infrastructure.

**Findings:**

- Have applications shifted from desktop to web over the past couple of decades: Yea
- Who is ultimately responsible for ensuring the security of users' data within a web application: Web App Owner

![Task 1 Answers](Screen%20Shot%202026-07-23%20at%207.53.21%20PM.png)

## Task 3 - How the Web Works

Covered the request-response cycle and the three essential components of any web service (application, web server, host machine), plus an overview of common web servers (Apache, Nginx, IIS) and what they're typically used for.

**Findings:**

- What your browser sends to a server to receive a web page: a request
- Web server most commonly used to host WordPress websites: Apache
- What we call the OS and environment that runs the web server and application: Host Machine

## Task 4 - Best Practices and Logging

Went through security best practices for each of the three components (secure coding, input validation, and access control for the application; logging, WAF, and CDN for the web server; least privilege, system hardening, and antivirus for the host machine), plus strong authentication and patch management as practices that apply across all three. Also covered access logs and the type of data they capture (client IP, timestamp, requested resource, response status, user agent) and how that data supports incident investigation.

**Findings:**

- Cyber security concept that involves stopping or limiting damage from threats: Mitigation
- Security control that ensures all software and components are up to date: Patch Management

![Task 4 Answers](Screen%20Shot%202026-07-23%20at%208.05.45%20PM.png)

## Task 5 - CDNs, WAFs, and Antivirus

Covered CDNs and their security benefits (IP masking, DDoS protection, enforced HTTPS, integrated WAFs), the three types of WAFs (cloud-based/reverse proxy, host-based, network-based) and their detection methods (signature-based, heuristic-based, anomaly/behavioral analysis, IP reputation filtering), and the role of antivirus in endpoint-level protection against known malware and malicious uploads.

**Findings:**

- WAF type that runs on the same system as the application itself: Host-Based
- WAF detection technique that matches incoming requests against known malicious patterns: Signature-Based

![Task 5 Answers](Screen%20Shot%202026-07-23%20at%208.08.11%20PM.png)

## Task 6 - Practical: Securing Secure-A-Site

Applied the best practices from the previous tasks hands-on against a simulated site (Secure-A-Site), working through all three layers (web application, web server, host machine) to harden the site ahead of launch and capture the flag for each layer.

**Findings:**

- Flag for securing the Web Application: THM{web_app_secured!}
- Flag for securing the Web Server: THM{server_security_expert!}
- Flag for securing the Host Machine: THM{the_final_security_layer!}

![Task 6 Answers](Screen%20Shot%202026-07-23%20at%209.21.03%20PM.png)

## Key Takeaways

- Every web service breaks down into three layers that each need their own protections: the application (secure coding, input validation, access control), the web server (logging, WAF, CDN), and the host machine (least privilege, hardening, antivirus). Thinking in terms of these three layers makes it easier to reason about where a given control actually applies.
- Access logs are one of the most valuable and underrated tools for incident investigation. Even mundane request sequences (homepage, login, POST credentials, account page) show how much reconstructive value logs carry once something goes wrong.
- CDNs and WAFs aren't just performance tools, they're a meaningful security layer by design: IP masking and enforced HTTPS reduce the attack surface, and WAF detection methods (signature-based, heuristic, anomaly-based, reputation filtering) each catch different classes of malicious traffic.
- Antivirus is often misunderstood as blanket protection. In a web context, its real value is catching malicious file uploads (web shells, post-exploitation tools) on the host, not defending the application layer itself, which is why it's one layer in a defense-in-depth strategy rather than a standalone solution.
- Real-world breaches like Equifax and Capital One reinforce that these aren't abstract best practices. An unpatched Apache vulnerability and a misconfigured WAF were each enough to expose over 100 million records, which is a direct illustration of why patch management and correct WAF configuration matter in practice.
