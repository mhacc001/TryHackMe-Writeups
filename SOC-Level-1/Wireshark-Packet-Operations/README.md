# Wireshark: Packet Operations — TryHackMe SOC Level 1

Room: Network Traffic Analysis module
Path: SOC Level 1

## Overview

This room is the second in the Wireshark trio, building on The Basics by covering Wireshark's Statistics menu, protocol-level statistics, and query-based display filtering. It moves from point-and-click filtering into writing actual filter expressions, operators, and advanced functions to answer specific questions about a single large capture file (`Exercise.pcapng`).

## Statistics | Summary

The Statistics menu surfaces a quick overview of a capture: Resolved Addresses (IP-to-hostname mappings from DNS answers), Protocol Hierarchy (a tree view of protocol usage by packet count), Conversations (traffic between endpoint pairs), and Endpoints (unique addresses, with optional MAC vendor, geolocation, and AS organization resolution).

| Question | Answer |
|---|---|
| IP address of the hostname starting with "bbc" | `199.232.24.81` |
| Number of IPv4 conversations | `435` |
| Bytes (k) transferred from the "Micro-St" MAC address | `7474` |
| Number of IP addresses linked with "Kansas City" | `4` |
| IP address linked with "Blicnet" AS Organisation | `188.246.82.7` |

![Statistics summary answers](Screen%20Shot%202026-07-18%20at%2010.36.46%20PM.png)

## Statistics | Protocol Details

Beyond the general summary, Wireshark offers protocol-specific statistics windows for IPv4/IPv6, DNS, and HTTP, breaking down request/response codes, query types, and service timing.

| Question | Answer |
|---|---|
| Most used IPv4 destination address | `10.100.1.33` |
| Max service request-response time of DNS packets | `0.467897` |
| Number of HTTP Requests accomplished by rad[.]msn[.]com | `39` |

![Protocol details answers](Screen%20Shot%202026-07-18%20at%2010.37.40%20PM.png)

## Packet Filtering | Principles and Protocol Filters

Display filters use comparison operators (`==`, `!=`, `>`, `<`, etc.) and logical operators (`and`, `or`, `not`) against protocol fields. Common filters target IP-level fields (`ip.addr`, `ip.src`, `ip.dst`), transport-level fields (`tcp.port`, `udp.port`), and application-level fields (`http.response.code`, `http.request.method`, `dns.qry.type`).

| Question | Answer |
|---|---|
| Number of IP packets | `81420` |
| Packets with a TTL value less than 10 | `66` |
| Packets using TCP port 4444 | `632` |
| HTTP GET requests sent to port 80 | `527` |
| Type A DNS Queries | `51` |

![Protocol filter answers](Screen%20Shot%202026-07-18%20at%2010.38.58%20PM.png)

## Advanced Filtering

Wireshark supports advanced comparison and function operators beyond the basics: `contains` (case-sensitive substring search), `matches` (regex), `in` (set membership), and string functions like `upper`, `lower`, and `string` (type conversion, useful for regex-matching numeric fields like TTL). The room also covers saving filters as bookmarks or buttons, and using Configuration Profiles to switch between saved sets of preferences, colouring rules, and filter buttons for different investigation types.

| Question | Answer |
|---|---|
| IIS server packets not originating from port 80 | `21` |
| IIS server packets with version 7.5 | `71` |
| Packets using ports 3333, 4444, or 9999 | `2235` |
| Packets with even TTL numbers | `77289` |
| Bad TCP Checksum packets (Checksum Control profile) | `34185` |
| Displayed packets from the existing filter button | `261` |

![Advanced filtering answers](Screen%20Shot%202026-07-18%20at%2010.43.02%20PM.png)

## Key Takeaways

- The Statistics menu turns a massive capture into an immediately actionable overview before diving into individual packets, which is exactly the "form a hypothesis first" approach an analyst needs on a large PCAP.
- Endpoints and Conversations answer different questions: Endpoints shows unique participants, Conversations shows paired traffic between two of them. Knowing which one to reach for saves time.
- The `string()` function is a handy trick for applying regex against fields that are normally typed as integers, like using it to isolate even or odd TTL values.
- Configuration Profiles are the practical solution to a real pain point: instead of rebuilding coloring rules and filter buttons every time an investigation type changes, a saved profile (like "Checksum Control") gets an analyst straight to the relevant view.
- Filter operators like `contains`, `matches`, and `in` cover the vast majority of real investigative questions, isolating a keyword, matching a pattern, or checking membership in a small set of values, without needing to memorize the exact protocol field syntax every time.
