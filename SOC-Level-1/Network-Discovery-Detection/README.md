# Network Discovery Detection — TryHackMe SOC Level 1

Room: Network Traffic Analysis module
Path: SOC Level 1

## Overview

This room covers how attackers and defenders both perform network discovery, and how a SOC analyst tells the difference between benign scanning and a real threat. It moves from conceptual distinctions (internal vs external scanning, horizontal vs vertical scanning) into hands-on log analysis with CLI tools and Kibana to identify specific scan types: ping sweeps, TCP SYN scans, and UDP scans.

## Attackers and Network Discovery

Attackers scan for more than just IP addresses, ports, and OS versions, they also fingerprint the specific services and versions running on open ports, since that's what determines whether a known exploit applies. Defenders run similar discovery activity for the opposite purpose: inventorying assets, closing unnecessary exposure, and confirming patches are applied. SOC teams differentiate the two using allowlisting of known scanners, threat intelligence integration, and generic scanning-behavior detection rules.

| Question | Answer |
|---|---|
| What do attackers scan (besides IP, ports, OS version) to identify vulnerabilities? | `Services` |

![Attackers and network discovery intro question](Screen%20Shot%202026-07-19%20at%2012.53.03%20AM.png)

## Internal vs External Scanning

External scanning (source IP outside the organization, destination inside) indicates the Reconnaissance phase of the attack lifecycle, lower severity since the attacker has no foothold yet. Internal scanning (both source and destination inside the organization) indicates the Discovery phase, high severity since it means the attacker is already inside the network and preparing for lateral movement. This distinction was confirmed directly from firewall log CSVs exported from a SIEM.

| Question | Answer |
|---|---|
| File containing internal scanning activity | `log-session-2.csv` |
| Number of log entries for the internal scanning IP | `2276` |
| External IP performing external scanning | `203.0.113.25` |

![Internal vs external scanning log analysis](Screen%20Shot%202026-07-19%20at%2012.54.44%20AM.png)

## Horizontal vs Vertical Scanning

A horizontal scan hits the same port across many destination IPs (looking for a specific vulnerable service across the network, like WannaCry hunting for open SMB on port 445). A vertical scan hits many ports on a single destination IP (footprinting one high-value target in depth). The same log file showed both patterns simultaneously against different targets.

| Question | Answer |
|---|---|
| IP range scanned in the horizontal scan | `203.0.113.0/24` |
| IP address targeted by the vertical scan | `192.168.230.145` |
| Ports scanned on that IP (common services) | `80, 445, 3389` |

![Horizontal and vertical scan identification](Screen%20Shot%202026-07-19%20at%2012.55.44%20AM.png)

## Scan Mechanics: Ping Sweep, TCP SYN, and UDP Scans

Ping sweeps use ICMP to find live hosts (easily blocked by modern security controls). TCP SYN scans abuse the three-way handshake, a SYN-ACK response confirms both a live host and an open port, and this method is stealthy enough to blend into normal traffic. UDP scans are slower and less reliable, relying on the absence of an ICMP "port unreachable" response (or a timeout) to infer an open port. This task used Kibana to identify each scan type directly from `zeek.conn.conn_state` values in the logs.

| Question | Answer |
|---|---|
| Source IP performing the ping sweep across a subnet | `192.168.230.127` |
| Scan type performed by 203.0.113.25 against 192.168.230.145 | `TCP SYN Scan` |
| Any UDP scanning attempts present in the logs? | `N` |

![Ping sweep, TCP SYN scan, and UDP scan identification in Kibana](Screen%20Shot%202026-07-19%20at%2012.56.35%20AM.png)

## Key Takeaways

- The single most useful triage question for any scan is "where is the source, and where is the destination": external-to-internal means early-stage reconnaissance, internal-to-internal means the attacker already has a foothold and severity jumps accordingly.
- Horizontal and vertical scans reveal different attacker intent: horizontal scanning is opportunistic (find any host with a specific weakness), vertical scanning is targeted (fully map one asset the attacker already cares about).
- `zeek.conn.conn_state` is a high-value field for scan classification. A state like `S0` (SYN sent, no reply) is the signature of a SYN scan; consistent responses or lack thereof separate SYN scans from UDP scans in the logs.
- CLI tools (`cut`, `uniq -c`) and Kibana's Discover view are two paths to the same answers. Knowing both matters: raw log files are what you get in the field, and Kibana is what a mature SOC actually monitors day to day.
- Even a "boring" technique like ICMP ping sweeps still shows up in real environments, and it's the easiest scan type for defenders to block, which is exactly why more sophisticated attackers lean on stealthier TCP SYN scans instead.
