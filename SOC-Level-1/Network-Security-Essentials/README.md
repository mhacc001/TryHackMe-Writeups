# Network Security Essentials — TryHackMe SOC Level 1

Room: Network Traffic Analysis module
Path: SOC Level 1

## Overview

This room steps back from tool mechanics to cover the conceptual foundation of network security: what makes up an enterprise network, why network visibility matters, what a network perimeter is and why it's the first line of defense, and how to monitor it in practice. It closes with a full incident investigation across firewall, WAF, VPN, and IDS logs, tracing an attacker from initial reconnaissance through to data exfiltration.

## Network Components

A small enterprise network is built from user workstations (the most common entry point for attackers), file/database servers (high-value targets for ransomware and data theft), application servers like web/email/VPN (externally facing and constantly scanned), Active Directory (the identity backbone, and a prime target for privilege escalation), and routers/switches/firewalls (the infrastructure and gatekeepers tying it all together). No answer needed for this task.

## Network Visibility

Visibility comes from two log categories: host-centric logs (OS logs, application logs, EDR/AV) which show what happened on a specific machine, and network-centric logs (firewall, IDS/IPS, routers, proxies, VPN) which show what happened between machines. Correlating both is what lets an analyst build a full incident timeline. No answer needed for this task.

## The Network Perimeter

The perimeter is the boundary between the trusted internal network and the untrusted internet, made up of firewalls, routers/gateways, a DMZ for public-facing services, and remote access/VPN gateways. It's the first place attackers probe and the first place a SOC analyst typically sees signs of malicious activity. No answer needed for this task.

## Monitoring the Perimeter in Action

Three example scenarios demonstrate common perimeter attack patterns: port scanning (one source IP hitting many ports on one destination), a WAF catching web attacks (SQL injection, XSS, directory traversal) from a single malicious source, and VPN brute-forcing (a flood of failed logins from one IP against common usernames).

| Question | Answer |
|---|---|
| IP address performing the port scan | `203.0.113.10` |
| Single source IP responsible for all blocked web attacks (WAF) | `198.51.100.12` |
| Number of failed VPN brute-force attempts | `90` |
| Suspicious IP attempting the VPN brute-force | `45.137.22.13` |

![Perimeter monitoring scenario answers](Screen%20Shot%202026-07-19%20at%2012.43.58%20AM.png)

## Challenge: Investigating the Breach

A full incident investigation across a month of firewall, WAF/IDS, and VPN logs for Initech Corp, tracing the complete attack chain: reconnaissance and port scanning, a successful VPN brute-force against a service account, lateral movement via SMB exploitation, C2 beaconing from a compromised host, and evidence of data exfiltration via large HTTP POST uploads.

| Question | Answer |
|---|---|
| External IP that performed the most reconnaissance | `203.0.113.45` |
| Internal host targeted by scans | `10.0.0.20` |
| Username targeted in VPN logs | `svc_backup` |
| Internal IP assigned after successful VPN login | `10.8.0.23` |
| Port used for lateral SMB attempts | `445` |
| Host that beaconed to the C2 (IDS logs) | `10.0.0.60` |
| IP observed to be associated with the C2 | `198.51.100.77` |
| Host that showed exfiltration attempts | `10.0.0.51` |

![Breach investigation: reconnaissance through lateral movement](Screen%20Shot%202026-07-19%20at%2012.47.25%20AM.png)
![Breach investigation: C2 and exfiltration](Screen%20Shot%202026-07-19%20at%2012.47.31%20AM.png)

## Key Takeaways

- The network perimeter isn't a single device, it's a collection of controls (firewall, WAF, VPN gateway, DMZ) working together, and each one generates a different type of evidence for the same underlying attack.
- Attack patterns have recognizable shapes in logs: one-source-to-many-destinations is scanning, one-source-to-one-destination repeated is brute-forcing, and traffic at perfectly regular intervals is beaconing.
- A full breach investigation is really a pivot chain: identify a suspicious IP in one log source, then use that IP (or the account/host it touches) to search the next log source, building the timeline one correlated data point at a time.
- Host-centric and network-centric logs answer different questions and neither is sufficient alone: network logs show the "who talked to whom," while host logs would confirm what actually happened on the compromised machine itself.
- Data exfiltration in this investigation showed up as a pattern, not a single event: sustained large HTTP POST uploads to unusual destination ports from an already-compromised host, flagged automatically by the IDS as "Possible HTTP POST Large Upload."
