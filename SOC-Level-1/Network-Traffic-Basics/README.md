# Network Traffic Basics — TryHackMe SOC Level 1

Room: Network Traffic Analysis module (first room)
Path: SOC Level 1

## Overview

This room lays the foundation for network traffic analysis: why it matters, what can be observed at each layer of the TCP/IP stack, how traffic sources and flows are categorized in a corporate network, and the practical methods (logs, full packet capture, network statistics) used to collect that traffic for analysis.

## Why Analyze Network Traffic

The room opens with a DNS tunneling scenario: an SOC analyst notices an unusual volume of DNS queries from a host, each using a different subdomain against the same TLD. Firewall logs show the query and query type but not the content, so inspecting the raw DNS reply is the only way to catch a C2 command hidden in a TXT record.

| Question | Answer |
|---|---|
| What is the name of the technique used to smuggle C2 commands via DNS? | `DNS Tunneling` |

![DNS tunneling question](Screen%20Shot%202026-07-18%20at%2010.09.57%20PM.png)

## The TCP/IP Stack

Each layer of the TCP/IP model carries information that logs typically don't fully capture. HTTP headers and payload live at the application layer; TCP sequence numbers at the transport layer matter for detecting session hijacking; fragmentation and TTL live at the internet layer and can reveal evasion techniques like overlapping fragment offsets; MAC addressing at the link layer is key to catching ARP poisoning.

| Question | Answer |
|---|---|
| What is the size of the ZIP attachment in the HTTP response example (in bytes)? | `10485760` |
| Which attack do attackers use to try to evade an IDS? | `Fragmentation attack` |
| What field in the TCP header can we use to detect session hijacking? | `Sequence Number` |

![TCP/IP stack questions](Screen%20Shot%202026-07-18%20at%2010.11.02%20PM.png)

## Sources and Flows

Network traffic sources split into intermediary devices (firewalls, switches, routers) and endpoint devices (servers, hosts, IoT, laptops), with endpoints generating the bulk of traffic. Flows split into North-South (traffic crossing the firewall to/from the WAN) and East-West (traffic staying inside the LAN, often used by attackers for lateral movement once inside).

| Question | Answer |
|---|---|
| Which category of devices generates the most traffic in a network? | `Endpoint` |
| Before an SMB session can be established, which service needs to be contacted first for authentication? | `Kerberos` |
| What does TLS stand for? | `Transport Layer Security` |

![Sources and flows questions](Screen%20Shot%202026-07-18%20at%2010.12.05%20PM.png)

## Collecting Network Traffic

Three main methods exist for gathering traffic data: logs (vendor-specific, rarely full packet detail), full packet capture (via a physical network TAP or port mirroring/SPAN), and network statistics (via protocols like NetFlow or its vendor-neutral successor IPFIX). The room closes with a hands-on exercise placing a virtual TAP correctly and extracting flags from both HTTP and DNS traffic.

| Question | Answer |
|---|---|
| What is the flag found in the HTTP traffic in scenario 1? | `THM{FoundTheMalware}` |
| What is the flag found in the DNS traffic in scenario 2? | `THM{C2CommandFound}` |

![Exercise flags](Screen%20Shot%202026-07-18%20at%2010.13.27%20PM.png)

## Key Takeaways

- Logs almost never contain full packet content, only the fields a vendor chose to record, which is exactly why full packet capture matters when an investigation needs to go deeper than "what happened" into "what was actually sent."
- DNS tunneling is a good reminder that a protocol's metadata (query type, frequency, subdomain pattern) can flag something suspicious well before the payload itself is inspected.
- Understanding North-South vs East-West traffic patterns helps prioritize monitoring: East-West traffic gets less scrutiny by default, which is exactly why it's a common path for lateral movement once an attacker is already inside the network.
- A physical TAP and port mirroring/SPAN solve the same problem (getting a copy of traffic to a monitoring tool) but with different tradeoffs: TAPs add essentially zero performance overhead, while mirroring can degrade performance on heavily loaded ports.
