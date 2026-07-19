# Wireshark: The Basics — TryHackMe SOC Level 1

Room: Network Traffic Analysis module
Path: SOC Level 1

## Overview

This room introduces Wireshark, the open-source packet analyzer used throughout the rest of the Network Traffic Analysis module. It covers the GUI layout, loading and inspecting PCAP files, dissecting packets across OSI layers, navigating and exporting objects from a capture, and building basic display filters. Two capture files are used throughout: `http1.pcapng` to follow along with the room's screenshots, and `Exercise.pcapng` to actually answer the questions.

## Environment Setup

| Question | Answer |
|---|---|
| Which file is used to simulate the screenshots? | `http1.pcapng` |
| Which file is used to answer the questions? | `Exercise.pcapng` |

![Environment setup](Screen%20Shot%202026-07-18%20at%2010.21.35%20PM.png)

## Tool Overview

Wireshark's main window has five key sections: toolbar, display filter bar, recent files, capture filter/interfaces, and status bar. Loading a capture reveals the packet list, packet details, and packet bytes panes. This task also covers viewing file-level metadata through Capture File Properties, including comments, packet counts, and hash values.

| Question | Answer |
|---|---|
| Read the capture file comments. What is the flag? | `TryHackMe_Wireshark_Demo` |
| What is the total number of packets? | `58620` |
| What is the SHA256 hash value of the capture file? | `f446de335565fb0b0ee5e5a3266703c778b2f3dfad7efeaeccb2da5641a6d6eb` |

![Tool overview and capture file properties](Screen%20Shot%202026-07-18%20at%2010.22.39%20PM.png)

## Packet Dissection

Every packet breaks down across up to seven layers matching the OSI model: frame, source MAC, source IP, transport protocol (with reassembly detail), and application protocol/data. Walking through a single HTTP packet (number 38) surfaces details at each layer, from arrival timestamp and TTL down to the TCP payload size and an HTTP response's e-tag value.

| Question | Answer |
|---|---|
| Which markup language is used under the HTTP protocol? | `eXtensible Markup Language` |
| What is the arrival date of the packet? | `05/13/2004` |
| What is the TTL value? | `47` |
| What is the TCP payload size? | `424` |
| What is the e-tag value? | `9a01a-4696-7e354b00` |

![Packet dissection of packet 38](Screen%20Shot%202026-07-18%20at%2010.24.17%20PM.png)

## Packet Navigation

Beyond scrolling, Wireshark supports jumping to a specific packet number, searching packet content (display filter, hex, string, or regex), marking and commenting on packets of interest, and exporting objects (files transferred over protocols like HTTP, SMB, or TFTP) directly out of a capture. Expert Info surfaces protocol-level anomalies at a glance, grouped by severity.

| Question | Answer |
|---|---|
| Search the "r4w" string in packet details. What is the name of artist 1? | `r4w8173` |
| Go to packet 12 and read the comments. What is the answer? | `911cd574a42865a956ccde2d04495ebf` |
| There is a .txt file inside the capture. What is the alien's name? | `PACKETMASTER` |
| Look at the expert info section. What is the number of warnings? | `1636` |

![Packet navigation and expert info](Screen%20Shot%202026-07-18%20at%2010.26.01%20PM.png)

## Packet Filtering

Display filters narrow a capture down to the traffic that matters. Wireshark offers several point-and-click ways to build these filters (Apply as Filter, Conversation Filter, Prepare as Filter, Apply as Column) in addition to typing queries directly, plus the ability to follow a full TCP/UDP/HTTP stream to reconstruct application-level data.

| Question | Answer |
|---|---|
| Apply the HTTP protocol as a filter on packet 4. What is the filter query? | `http` |
| What is the number of displayed packets? | `1089` |
| Follow the HTTP stream on packet 33790. What is the total number of artists? | `3` |
| What is the name of the second artist? | `Blad3` |

![Packet filtering and HTTP stream follow](Screen%20Shot%202026-07-18%20at%2010.27.09%20PM.png)

## Key Takeaways

- Wireshark is a passive analysis tool, not an IDS: it never modifies packets and doesn't make judgment calls on its own, so spotting anomalies still depends entirely on the analyst's knowledge of what "normal" traffic looks like.
- OSI-layer dissection (frame through application data) means a single packet can answer very different questions depending on which layer you're looking at, from TTL and MAC addressing up to HTTP headers and payload content.
- Capture File Properties (file hash, comments, packet counts) is often the fastest way to fingerprint and triage a PCAP before diving into individual packets.
- Export Objects is a genuinely practical incident response technique: pulling a transferred file (image, text, executable) directly out of a capture without needing to reconstruct it manually from raw bytes.
- Following a TCP/HTTP stream reconstructs the full application-level conversation, useful for recovering plaintext credentials or, in this case, comparing artist metadata across an entire request/response cycle instead of packet by packet.
