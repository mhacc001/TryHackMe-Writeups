# IP and Domain Threat Intel

## Overview

This room covers how to enrich IP addresses and domains using open source threat intelligence, turning a raw indicator from a SIEM/EDR alert into contextual, actionable evidence. It walks through DNS and WHOIS/RDAP enrichment, IP reputation and ASN analysis, exposed service and TLS certificate enrichment, and VPN/proxy detection, closing with a full APT infrastructure investigation.

## Task 2 - Domain Enrichment

Covered core domain enrichment techniques: A/AAAA records (mapping a domain to its IP and revealing hosting/CDN infrastructure), TXT records (mail security settings like SPF/DKIM, or the tools a domain uses), and WHOIS/RDAP (registrar, registration/expiry dates, and domain age, since malicious infrastructure is rarely registered for long). Covered common DNS-based attack techniques: CDN abuse (hiding origin servers behind legitimate CDNs), typosquatting, and IDN homograph attacks (using look-alike non-ASCII characters, decodable via Punycode).

Investigated a flagged domain, `purematrixa[.]com`, using the attached NSLookup and WHOIS reports.

**Findings:**

- CDN used by purematrixa[.]com: Cloudflare
- Domain age when the SIEM alert was raised: 1 day old (registered 2026-05-31, alert raised 2026-06-01)

![NSLookup CDN](Task%202%20-%20NSLookup%20CDN.jpg)
![WHOIS Domain Age](Task%202%20-%20WHOIS%20Domain%20Age.jpg)

## Task 3 - IP Enrichment

Covered IP enrichment fundamentals: AbuseIPDB and VirusTotal for reputation and abuse history, and Autonomous System (AS) analysis via BGP.Tools to assess an IP's likely role (residential ASNs suggesting VPN/compromised consumer devices, server hosting ASNs being highest-risk for malware distribution, and cloud/CDN ASNs requiring deeper analysis since they're used by both legitimate and malicious actors). Covered GeoIP enrichment for spotting anomalous logons (unexpected country/city relative to expected user or organizational behavior).

Investigated a suspected C2 IP, `2[.]58[.]56[.]50`, using the attached BGP.Tools and VirusTotal reports.

**Findings:**

- Country the malicious IP resolves to: The Netherlands
- C2 server hosted behind the IP (per VirusTotal comments): Remcos
- Autonomous System the IP belongs to: 1337 Services GmbH
- Two tags BGP.Tools attributes to the ASN: Server Hosting, Tor services

![BGP Tools ASN](Task%203%20-%20BGP%20Tools%20ASN.jpg)
![VirusTotal C2 Comment](Task%203%20-%20VirusTotal%20C2%20Comment.jpg)

## Task 4 - Exposed Services

Covered Shodan and Censys as reconnaissance tools for identifying open ports, service banners, and system configurations on an IP, useful both for understanding how a victim was breached (e.g. exposed SSH) and for profiling attacker infrastructure (e.g. outdated or exposed RDP indicating a compromised jump host). Covered TLS certificate enrichment via crt.sh, Censys, or SSL Shopper, focusing on issuer (self-signed certs are a strong red flag), validity period, and subject fields.

Investigated a malicious IP, `64[.]89[.]160[.]44`, using the attached Censys screenshots.

**Findings:**

- Remote access service exposed: RDP
- Number of open ports identified on the server: 9
- C2 hosted behind one of the exposed services: AsyncRAT
- Certificate validity period: 3935 days

![Censys AsyncRAT Cert](Task%204%20-%20Censys%20AsyncRAT%20Cert.png)

## Task 5 - VPN Detection

Covered IP2Proxy and Spur as tools for identifying VPN, proxy, and Tor exit nodes, critical for correctly interpreting geolocation on login alerts, since a matching location doesn't rule out an attacker using a VPN to spoof it. Reviewed the full SOC analyst workflow for IP/domain enrichment: for domains, check legitimacy/typosquatting, reputation, and registration age, then resolve to IP; for IPs, check whether it's a CDN range, its reputation, its geolocation relative to the alert, and its AS type relative to expected behavior.

**Findings:**

- Would you raise the alarm for a London-based user logging in from a London IP confirmed as Mullvad VPN: Yea
- Would you close the alert as a False Positive if the IP doesn't match any known VPN provider: Nay (the rest of the enrichment workflow, reputation, AS type, and expected behavior, still needs to be checked before closing)

## Task 6 - Challenge: APT Infrastructure Investigation

Investigated a domain tied to a real APT compromise, `raytracingengine[.]com`, using the attached NSLookup, WHOIS, and Censys incident reports to identify the resolved IP, hosting provider, server location, domain registration date, and exposed service OS.

**Findings:**

- IP the domain resolves to: 35.188.105.97
- Cloud provider the attacker used: Google Cloud
- Country the malicious server is located in: United States
- When the malicious domain name was created: 21.02.2026
- Attack server's OS (per exposed service): Linux

![Challenge Censys Report](Task%206%20-%20Challenge%20Censys%20Report.jpg)
![Challenge WHOIS Report](Task%206%20-%20Challenge%20WHOIS%20Report.jpg)

## Key Takeaways

- Domain and IP enrichment exists to answer one core question: is this indicator legitimate infrastructure, or something worth escalating? A CDN-fronted IP or a decade-old domain is reassuring, while a domain registered the day before an alert (as with purematrixa[.]com, just 1 day old) is a textbook sign of disposable attacker infrastructure.
- ASN and hosting-type context turns a bare IP into something actionable. Server hosting ASNs (like 1337 Services GmbH in this room) carry meaningfully higher risk than residential or well-known cloud ASNs, and that distinction should directly shape how aggressively an analyst investigates or blocks.
- Exposed service and TLS certificate data can directly confirm C2 infrastructure, not just suggest it. In this room, a self-signed certificate with the subject "AsyncRAT Server" was effectively a confession, and Censys showing outdated or unusual open ports (SMB, NETBIOS, RDP alongside game-server ports) painted a clear picture of a compromised, multi-purpose host.
- VPN/proxy awareness fundamentally changes how geolocation should be interpreted on login alerts: a matching location is not reassuring on its own if the IP resolves to a known VPN exit node, and conversely, a non-VPN IP still requires the full enrichment workflow before being closed as benign.
- Real APT infrastructure investigations combine every technique from this room in sequence: DNS resolution, WHOIS/registration timing, cloud/hosting attribution, and exposed service fingerprinting, all pulled together to build a complete infrastructure profile rather than relying on any single indicator in isolation.
