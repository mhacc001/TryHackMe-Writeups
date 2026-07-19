# Wireshark: Traffic Analysis — TryHackMe SOC Level 1

Room: Network Traffic Analysis module (final Wireshark room)
Path: SOC Level 1

## Overview

This is the third and final room in the Wireshark trio, moving from tool mechanics into full traffic analysis: detecting Nmap scans, ARP poisoning/MITM attacks, host identification via DHCP/NetBIOS/Kerberos, ICMP and DNS tunneling, cleartext FTP and HTTP credential/data exposure, a Log4j exploitation attempt, decrypting HTTPS with a key log file, hunting cleartext credentials, and generating firewall ACL rules directly from Wireshark. Each section uses a separate exercise capture file.

## Nmap Scans

TCP Connect scans complete the full three-way handshake and typically show a window size above 1024 bytes. SYN scans never complete the handshake and use smaller window sizes. UDP scans get no response on open ports but trigger an ICMP Type 3, Code 3 (destination/port unreachable) on closed ones.

| Question | Answer |
|---|---|
| Total number of "TCP Connect" scans | `1000` |
| Scan type used to scan TCP port 80 | `TCP Connect` |
| Number of "UDP close port" messages | `1083` |
| Open UDP port in the 55-70 range | `68` |

![Nmap scan detection](Screen%20Shot%202026-07-18%20at%2010.50.04%20PM.png)

## ARP Poisoning & Man In The Middle

An attacker crafting duplicate ARP responses for the same IP (especially a likely gateway address) and flooding requests across an IP range is a strong MITM signal. Adding MAC address columns to the packet list exposes the real destination of traffic that looks normal at the IP layer alone.

| Question | Answer |
|---|---|
| Number of ARP requests crafted by the attacker | `284` |
| Number of HTTP packets received by the attacker | `90` |
| Number of sniffed username&password entries | `6` |
| Password of "Client986" | `clientnothere!` |
| Comment provided by "Client354" | `Nice work!` |

![ARP poisoning and MITM detection](Screen%20Shot%202026-07-18%20at%2010.52.34%20PM.png)

## Identifying Hosts: DHCP, NetBIOS, and Kerberos

DHCP Request packets carry hostname info, NetBIOS (NBNS) queries reveal names tied to IP addresses, and Kerberos CNameString fields expose usernames (filtered to exclude the `$`-suffixed hostname entries).

| Question | Answer |
|---|---|
| MAC address of the host "Galaxy A30" | `9a:81:41:cb:96:6c` |
| NetBIOS registration requests by "LIVALJM" | `16` |
| Host that requested IP 172.16.13.85 | `Galaxy-A12` |
| IP address of user "u5" (defanged) | `10[.]1[.]12[.]2` |
| Hostname in the Kerberos packets | `xp1$` |

## Tunneling Traffic: DNS and ICMP

ICMP tunneling shows up as anomalous packet sizes carrying encapsulated protocol data (in this case, SSH traffic hidden inside ICMP payloads). DNS tunneling shows up as unusually long query names with encoded subdomains routed to a single suspicious domain.

| Question | Answer |
|---|---|
| Protocol used in ICMP tunnelling | `SSH` |
| Suspicious main domain (defanged) | `dataexfil[.]com` |

![ICMP and DNS tunneling detection](Screen%20Shot%202026-07-18%20at%2010.54.40%20PM.png)

## Cleartext Protocol Analysis: FTP

FTP response code 530 marks failed logins, and following the TCP stream reveals uploaded files and any post-upload commands used to modify permissions.

| Question | Answer |
|---|---|
| Number of incorrect login attempts | `737` |
| Size of the file accessed by the "ftp" account | `39424` |
| Filename uploaded by the adversary | `resume.doc` |
| Command used to change executing permissions | `CHMOD 777` |

![FTP cleartext analysis](Screen%20Shot%202026-07-18%20at%2010.55.58%20PM.png)

## Cleartext Protocol Analysis: HTTP

Anomalies in the user-agent field (spoofed OS versions, audit tool signatures, subtle misspellings) are a useful signal, though never sufficient on their own. This section also traces a live Log4j exploitation attempt from its initial POST request through the base64-decoded payload to the callback IP.

| Question | Answer |
|---|---|
| Number of anomalous "user-agent" types | `6` |
| Packet number with a subtle spelling difference | `52` |
| Log4j attack starting packet number | `444` |
| IP address contacted by the adversary (defanged) | `62[.]210[.]130[.]250` |

## Encrypted Protocol Analysis: Decrypting HTTPS

A TLS key log file (containing per-session key pairs, e.g. captured via `SSLKEYLOGFILE`) lets Wireshark decrypt an otherwise opaque HTTPS session, revealing the underlying HTTP2 requests, headers, and payload.

| Question | Answer |
|---|---|
| Frame number of the Client Hello to accounts.google.com | `16` |
| Number of HTTP2 packets after decryption | `115` |
| Authority header of Frame 322 (defanged) | `safebrowsing[.]googleapis[.]com` |
| Flag found in the decrypted traffic | `FLAG{THM-PACKETMASTER}` |

![HTTPS decryption with key log file](Screen%20Shot%202026-07-18%20at%2010.59.31%20PM.png)

## Bonus: Hunt Cleartext Credentials

Wireshark's built-in credential dissectors (FTP, HTTP, IMAP, POP, SMTP) surface cleartext usernames and passwords directly via **Tools → Credentials**, without needing to manually follow every stream.

| Question | Answer |
|---|---|
| Packet number of credentials using HTTP Basic Auth | `237` |
| Packet number where an empty password was submitted | `170` |

## Bonus: Actionable Results

Wireshark can generate ready-to-deploy firewall ACL rules directly from a selected packet, across formats like Netfilter, Cisco IOS, IPFilter, IPFirewall, pf, and Windows Firewall, turning an identified malicious packet into an immediate defensive action.

| Question | Answer |
|---|---|
| ipfw rule denying source IPv4 address (packet 99) | `add deny ip from 10.121.70.151 to any in` |
| ipfw rule allowing destination MAC address (packet 231) | `add allow MAC 00:d0:59:aa:af:80 any in` |

![Firewall ACL rule generation](Screen%20Shot%202026-07-18%20at%2011.01.49%20PM.png)

## Key Takeaways

- Nmap scan types leave distinct, memorizable TCP flag and window size signatures (Connect completes the handshake with a large window; SYN doesn't finish it; UDP relies on the absence or presence of an ICMP unreachable response), making them detectable with simple, reusable filters.
- ARP poisoning detection is a layered process: spotting duplicate IP-to-MAC claims, then noticing a flood of requests, then confirming the pivot by adding MAC columns to otherwise-normal-looking HTTP traffic. No single filter catches it alone.
- Host and user identification via DHCP, NetBIOS, and Kerberos gives an analyst a way to tie network-layer activity back to real hostnames and usernames, which is often the missing link between "suspicious traffic" and "which machine and user this actually involves."
- Tunneling detection (ICMP and DNS) comes down to recognizing when a normally-trusted, rarely-inspected protocol is carrying more data or more unusual patterns than its baseline behavior would suggest.
- Wireshark's credential-hunting and firewall-rule-generation tools turn packet-level findings into immediately actionable output, closing the loop between detection and response without leaving the tool.
