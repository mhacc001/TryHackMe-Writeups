# Snort

## Overview

This room covers Snort in depth: its operating modes (sniffer, packet logger, NIDS/NIPS), configuration and rule structure, and investigating both live traffic and PCAP files. Work was done in the provided Task-Exercises VM using the built-in traffic-generator script to simulate traffic for each exercise.

## Task 2 - Interactive Material and Exercise Setup

Confirmed access to the Task-Exercises folder and its Config-Sample and Exercise-Files subfolders, and ran the hidden setup script to confirm the environment was ready.

**Findings:**

- Output of `./.easy.sh`: Too Easy!

## Task 3 - IDS and IPS Overview

Reviewed the distinction between IDS (passive, detects and alerts) and IPS (active, blocks/terminates), across host-based and network-based deployments, plus signature-based, behaviour-based, and policy-based detection techniques. Also covered Snort's official description and its three primary modes (sniffer, packet logger, NIDS/NIPS).

![Task 3 Answers](Screen%20Shot%202026-07-23%20at%206.58.06%20PM.png)

**Findings:**

- IDS/IPS type that stops threats on a local machine: HIPS
- IDS/IPS type that detects threats on a local network: NIDS
- IDS/IPS type that detects threats on a local machine: HIDS
- IDS/IPS type that stops threats on a local network: NIPS
- Solution that works by detecting anomalies in the network: NBA
- According to Snort's official description, what kind of NIPS it is: full-blown
- NBA training period is also known as: baselining

## Task 4 - First Interaction with Snort

Verified the Snort installation, validated the configuration file, and tested rule loading against both configuration files provided in the lab.

Commands used:

```
snort -V
sudo snort -c /etc/snort/snort.conf -T
sudo snort -c /etc/snort/snortv2.conf -T
```

![Task 4 Answers](Screen%20Shot%202026-07-23%20at%206.59.57%20PM.png)

**Findings:**

- Snort build number: 149
- Rules loaded with /etc/snort/snort.conf: 4151
- Rules loaded with /etc/snort/snortv2.conf: 1

## Task 5 - Sniffer Mode

Practiced Snort's sniffer mode parameters (-v, -d, -e, -X, -i) against generated ICMP/HTTP traffic to compare verbosity levels, from basic TCP/IP output up to full packet hex dumps. No answer needed for this task, it was a hands-on practice exercise.

## Task 6 - Packet Logger Mode

Logged traffic in both binary and ASCII formats, then read the logs back with Snort's `-r` flag, filtered with BPF expressions, and cross-checked with tcpdump.

Commands used:

```
sudo snort -dev -K ASCII -l .
sudo ./traffic-generator.sh
snort -r snort.log.1640048004 -n 10
```

![Task 6 Answers](Screen%20Shot%202026-07-23%20at%207.01.45%20PM.png)

**Findings:**

- Source port used to connect to port 53 (folder 145.254.160.237): 3009
- IP ID of the 10th packet in snort.log.1640048004: 49313
- Referer of the 4th packet: http://www.ethereal.com/development.html
- Ack number of the 8th packet: 0x38AFFFF3
- Number of "TCP port 80" packets: 41

## Task 7 - IDS/IPS Mode

Ran Snort in NIDS/NIPS mode using the pre-defined ICMP rule and generated traffic against it, exploring the -c, -T, -N, -D, and -A (full/fast/console/cmg/none) parameters, plus a brief look at true inline IPS mode with `-Q --daq afpacket`.

Command used:

```
sudo snort -c /etc/snort/snort.conf -A full -l .
sudo ./traffic-generator.sh
```

![Task 7 Answer](Screen%20Shot%202026-07-23%20at%207.02.35%20PM.png)

**Findings:**

- Number of detected HTTP GET methods: 2

## Task 8 - PCAP Investigation Mode

Used Snort's PCAP read mode (`-r`, `--pcap-list`, `--pcap-show`) to investigate multiple provided PCAP files against both configuration files, reading Action Stats, Stream Statistics, and HTTP Inspect sections of the output for specific figures.

Commands used:

```
sudo snort -c /etc/snort/snort.conf -A full -l . -r mx-1.pcap
sudo snort -c /etc/snort/snortv2.conf -A full -l . -r mx-1.pcap
sudo snort -c /etc/snort/snort.conf -A full -l . -r mx-2.pcap
sudo snort -c /etc/snort/snort.conf -A full -l . --pcap-list="mx-2.pcap mx-3.pcap"
```

![Task 8 Answers](Screen%20Shot%202026-07-23%20at%207.04.28%20PM.png)

**Findings:**

- mx-1.pcap alerts (default config): 170
- TCP Segments Queued: 18
- HTTP response headers extracted: 3
- mx-1.pcap alerts (snortv2.conf): 68
- mx-2.pcap alerts (default config): 340
- Detected TCP packets (mx-2.pcap): 82
- mx-2.pcap + mx-3.pcap combined alerts: 1020

## Task 9 - Snort Rule Structure

Built and tested custom local rules against task9.pcap, covering IP ID filtering, TCP flag filtering (SYN, Push-Ack), and the sameip option for detecting matching source/destination addresses.

Rules used:

```
alert udp any any <> any any (msg:"ID TEST"; id:35369; sid:1000001; rev:1;)
alert tcp any any <> any any (msg:"FLAG TEST"; flags:S; sid:1000002; rev:1;)
alert tcp any any <> any any (msg:"FLAG TEST"; flags:PA; sid:1000003; rev:1;)
alert udp any any <> any any (msg:"SAME-IP TEST"; sameip; sid:1000004; rev:1;)
```

Command used:

```
snort -c local.rules -A full -l . -r task9.pcap
```

![Task 9 Answers](Screen%20Shot%202026-07-23%20at%207.06.10%20PM.png)

**Findings:**

- Request name of the detected packet (IP ID 35369): TIMESTAMP REQUEST
- Number of detected packets with SYN flag: 1
- Number of detected packets with Push-Ack flags: 216
- Number of packets with same source/destination IP (UDP, sameip): 7
- Rule option an analyst must change after modifying an existing rule: rev

## Task 10 - Snort Operation Logic: Points to Remember

Reviewed Snort's core components (Packet Decoder, Pre-processors, Detection Engine, Logging and Alerting, Outputs and Plugins), the three rule tiers (Community, Registered, Subscriber), key snort.conf sections (network variables, decoder/DAQ config, output plugins, custom ruleset), and the six available DAQ modules. No answer needed for this task, it was a reference/summary section.

## Key Takeaways

- Snort's operating modes build on each other: sniffer mode is the foundation for understanding packet visibility, packet logger mode adds persistence for forensic review, and NIDS/NIPS mode is where rules actually turn that visibility into detections.
- The difference between binary and ASCII logging matters for workflow: binary logs need Snort or tcpdump to read but preserve full fidelity, while ASCII logs (`-K ASCII`) are immediately human-readable and organized by source IP, which is faster for quick triage.
- PCAP investigation mode (`-r`, `--pcap-list`) turns Snort into a forensic tool as much as a real-time IDS, letting historical traffic be replayed against current rulesets, which is directly relevant to incident investigation work.
- Rule structure (action, protocol, IP/port with direction operators, and general/payload/non-payload options like msg, sid, rev, content, flags, sameip) is consistent regardless of complexity, and getting comfortable with the non-payload options (flags, dsize, sameip) unlocks a lot of detection precision beyond basic content matching.
- The `rev` field exists specifically to track rule changes over time. Every successful modification to an existing rule should increment it, since Snort has no built-in rule history and analysts are expected to track that themselves.
