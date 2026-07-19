# NetworkMiner — TryHackMe SOC Level 1

Room: Network Traffic Analysis module
Path: SOC Level 1

## Overview

This room introduces NetworkMiner, a network forensics analysis tool used for quickly overviewing captured traffic before diving deeper with Wireshark. Unlike Wireshark, NetworkMiner excels at OS fingerprinting, easy file extraction, credential grabbing, and host categorization, but trades off protocol/payload/statistical analysis depth. The room covers the tool's interface, works through several example captures, and highlights meaningful differences between NetworkMiner's v1.6 and v2.7.

## Tool Overview 1: Hosts, Sessions, DNS, Credentials

The Hosts tab surfaces IP/MAC addresses, OS fingerprints, open ports, and traffic volume per host. The Credentials tab extracts cleartext and hashed authentication data (NTLM, Kerberos, HTTP, FTP, IMAP, SMTP, MS SQL) directly from a capture.

| Question | Answer |
|---|---|
| Total number of frames (mx-3.pcap) | `460` |
| IP addresses sharing MAC with host 145.253.2.203 | `2` |
| Packets sent from host 65.208.228.223 | `72` |
| Webserver banner under host 65.208.228.223 | `Apache` |
| Extracted username for 02694W-WIN10 (mx-4.pcap) | `#B\Administrator` |
| Extracted password (full NTLM hash) | `$NETNTLMv2$#B$136B077D942D9A63$FBFF3C253926907AAAAD670A9037F2A5$0101000000000000094D71AE38CD60170A8D571127AE49E000000000200040033...` |

![Tool Overview 1: mx-3 and mx-4 answers](Screen%20Shot%202026-07-18%20at%2011.15.17%20PM.png)

## Tool Overview 2: Files, Images, Anomalies, Messages

The Files/Assembled Files tab reconstructs transferred files directly from a capture, viewable as a raw hex/ASCII dump, useful for pulling text content (like a name buried in an HTML page) straight out of a reassembled file without needing a browser. The Anomalies tab flags known patterns like possible TLS issues, and the Messages tab reconstructs emails and chats.

| Question | Answer |
|---|---|
| Linux distro mentioned in the file at frame 63602/63075 | `CentOS` |
| Name and surname in the file at frame 76469/75942 | `Ned Flanders` |
| Source address of image "ads.bmp.2E5F0FD9[1].bmp" | `80.239.178.187` |
| Frame number of the possible TLS anomaly | `36255` |
| Platform that sent the "You have more..." email | `Facebook` |
| Email address of Branson Matheson | `branson@sandsite.org` |

![Tool Overview 2: mx-7 and mx-9 answers, including the raw hex dump used to find Ned Flanders](Screen%20Shot%202026-07-18%20at%2012.28.45%20AM.png)

## Version Differences (v1.6 vs v2.7)

The lab includes both major NetworkMiner versions since features shifted between them: v2.7+ added MAC address conflict detection and richer parameter parsing, while v1.6 uniquely handled frame-level detail and more granular sent/received packet data that later versions dropped.

| Question | Answer |
|---|---|
| Version that can detect duplicate MAC addresses | `2.7` |
| Version that can handle frames | `1.6` |
| Version that provides more detail on packet details | `1.6` |

![Version differences between NetworkMiner 1.6 and 2.7](Screen%20Shot%202026-07-18%20at%2012.29.41%20AM.png)

## Exercises: case1.pcap and case2.pcap

Hands-on practice combining everything covered: OS fingerprinting, session byte counts by port, frame-level sequence numbers (v1.6 only), detected content types, and file/image extraction with embedded credentials.

| Question | Answer |
|---|---|
| Full OS name of host 131.151.37.122 | `Windows - Windows NT 4` |
| Bytes sent by client (*.32.91) through port 1065 | `192` |
| Bytes sent back by server (*.37.122) through port 143 | `20769` |
| Sequence number of frame 9 | `2AD77400` |
| Number of detected "content types" | `2` |
| USB product's brand name (case2.pcap) | `asix` |
| Phone model name | `Lumia 535` |
| Source IP of the fish image | `50.22.95.9` |
| Password of homer.pwned.se@gmx.com | `spring2015` |
| DNS query of frame 62001 | `pop.gmx.com` |

![Exercises: case1.pcap and case2.pcap answers](Screen%20Shot%202026-07-18%20at%2012.31.50%20AM.png)
![Exercises: case2.pcap remaining answers](Screen%20Shot%202026-07-18%20at%2012.31.58%20AM.png)

## Key Takeaways

- NetworkMiner and Wireshark are complementary, not competing: the recommended workflow is record traffic, get a quick overview and pull low-hanging fruit with NetworkMiner, then go deep with Wireshark for anything that needs full protocol/payload analysis.
- Credential extraction (NTLM hashes, HTTP Basic Auth, FTP/IMAP/SMTP logins) is one of NetworkMiner's strongest features, surfacing authentication material directly without manually following streams.
- Reconstructed files can be inspected as raw hex/ASCII directly inside NetworkMiner, which is often faster than exporting and opening a file externally when hunting for a specific string or value.
- Version differences matter in practice: some investigative questions (frame-level detail, sequence numbers) are genuinely only answerable in the older v1.6 branch, so knowing when to switch tool versions is itself a practical skill.
