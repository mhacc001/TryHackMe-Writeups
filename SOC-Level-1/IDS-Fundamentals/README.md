# IDS Fundamentals

## Overview

This room covers the fundamentals of Intrusion Detection Systems (IDS), including deployment modes, detection modes, and hands-on experience with Snort, one of the most widely used open-source IDS solutions. The room walks through Snort's operating modes, rule syntax, custom rule creation, and running Snort against a PCAP file to investigate a simulated attack.

## Task 1 - What Is an IDS

An IDS monitors network or host activity and generates alerts when it detects suspicious behavior, but it does not take action to block or prevent the threat itself. That is the key distinction between an IDS (passive, detects and alerts) and an IPS (active, can block traffic).

**Findings:**

- Can an IDS prevent the threat after it detects it: No, an IDS is passive by design and only alerts on detected threats.

![Task 1 Answer](Task%201%20-%20IDS%20Prevention%20Answer.png)

## Task 2 - IDS Deployment and Detection Modes

IDS solutions are categorized by deployment (where they run) and detection method (how they identify threats).

**Deployment modes:**

- Host Intrusion Detection System (HIDS) - installed on individual hosts, monitors only that host's activity.
- Network Intrusion Detection System (NIDS) - monitors traffic across the whole network from a centralized point.

**Detection modes:**

- Signature-based IDS - matches traffic against known attack patterns (signatures), fast and reliable for known threats but blind to zero-days.
- Anomaly-based IDS - baselines normal behavior and flags deviations, can catch zero-days but prone to false positives.
- Hybrid IDS - combines signature-based and anomaly-based detection to cover both known and novel threats.

**Findings:**

- IDS type deployed to detect threats throughout the network: Network Intrusion Detection System (NIDS)
- IDS that leverages both signature-based and anomaly-based detection: Hybrid IDS

![Task 2 Answers](Task%202%20-%20Deployment%20and%20Detection%20Modes%20Answers.png)

## Task 3 - Snort and Its Modes

Snort is an open-source IDS first developed in 1998 that uses signature-based detection defined in rule files. It can run in three modes:

- Packet Sniffer mode - reads and displays traffic without analysis, useful for troubleshooting.
- Packet Logging mode - logs traffic (including detections) to a PCAP file for later forensic analysis.
- Network Intrusion Detection System (NIDS) mode - Snort's primary mode, monitors traffic in real time and generates alerts on rule matches.

**Findings:**

- Mode that logs network traffic to a PCAP file: Packet Logging mode
- Primary mode of Snort: Network Intrusion Detection System mode

![Task 3 Answers](Task%203%20-%20Snort%20Modes%20Answers.png)

## Task 4 - Snort Rule Structure and Custom Rules

Snort's core files live in `/etc/snort`, including the configuration file `snort.lua` and the `rules` directory. A Snort rule is made up of an action, protocol, source IP/port, destination IP/port, and metadata (msg, sid, rev). Custom rules are added to `local.rules` in the rules directory.

Sample rule added and tested:

```
alert icmp any any -> 127.0.0.1 any (msg:"Loopback Ping Detected"; sid:10003; rev:1;)
```

Command used to run Snort in NIDS mode against the loopback interface:

```
sudo snort -q -l /var/log/snort -i lo -A alert_fast -c /etc/snort/snort.lua
```

Command used to run Snort against a PCAP file for offline/forensic analysis:

```
sudo snort -q -l /var/log/snort -r Task.pcap -A alert_fast -c /etc/snort/snort.lua
```

**Findings:**

- Main directory of Snort that stores its files: /etc/snort
- Field in a Snort rule that indicates the revision number: rev
- Protocol defined in the sample rule created in the task: icmp
- File name that contains custom rules for Snort: local.rules

![Task 4 Answers](Task%204%20-%20Snort%20Rule%20Structure%20Answers.png)

## Task 5 - Practical Lab: Investigating Intro_to_IDS.pcap

Scenario: acting as a third-party forensic investigator, given a PCAP file (`Intro_to_IDS.pcap`) captured during an attack on a client network. Ran Snort against the PCAP in read mode from `/etc/snort` to identify what triggered alerts.

Command used:

```
sudo snort -q -l /var/log/snort -r /etc/snort/Intro_to_IDS.pcap -A alert_fast -c /etc/snort/snort.lua
```

**Findings:**

- IP address that attempted to connect to the subject machine via SSH: 10.11.90.211
- Other rule message detected in the PCAP besides SSH: Ping Detected
- sid of the rule that detects SSH: 1000002

## Key Takeaways

- The core distinction between IDS and IPS is that an IDS only detects and alerts, it never blocks traffic on its own, which shapes how it fits into a broader detection and response workflow.
- NIDS deployment gives centralized visibility across a whole network, while HIDS gives deep visibility into a single host at the cost of per-host management overhead.
- Signature-based detection is fast and low-noise for known threats but structurally blind to zero-days, which is why hybrid approaches that layer in anomaly-based detection matter for modern threat coverage.
- Snort's rule syntax (action, protocol, source/destination IP and port, msg/sid/rev metadata) is the same whether you are writing a simple ICMP rule or something far more targeted, and understanding that structure is what makes custom rule writing straightforward.
- Snort's PCAP mode (`-r`) makes it just as useful for after-the-fact forensic investigation as it is for real-time monitoring, which is directly relevant to SOC-style incident investigation work.
Snort's core files live in `/etc/snort`, including the configuration file `snort.lua` and the `rules` directory. A Snort rule is made up of an action, protocol, source IP/port, destination IP/port, and metadata (msg, sid, rev). Custom rules are added to `local.rules` in the rules directory.

Sample rule added and tested:

```
alert icmp any any -> 127.0.0.1 any (msg:"Loopback Ping Detected"; sid:10003; rev:1;)
```

Command used to run Snort in NIDS mode against the loopback interface:

```
sudo snort -q -l /var/log/snort -i lo -A alert_fast -c /etc/snort/snort.lua
```

Command used to run Snort against a PCAP file for offline/forensic analysis:

```
sudo snort -q -l /var/log/snort -r Task.pcap -A alert_fast -c /etc/snort/snort.lua
```

**Findings:**

- Main directory of Snort that stores its files: /etc/snort
- Field in a Snort rule that indicates the revision number: rev
- Protocol defined in the sample rule created in the task: icmp
- File name that contains custom rules for Snort: local.rules

## Task 5 - Practical Lab: Investigating Intro_to_IDS.pcap

Scenario: acting as a third-party forensic investigator, given a PCAP file (`Intro_to_IDS.pcap`) captured during an attack on a client network. Ran Snort against the PCAP in read mode from `/etc/snort` to identify what triggered alerts.

Command used:

```
sudo snort -q -l /var/log/snort -r /etc/snort/Intro_to_IDS.pcap -A alert_fast -c /etc/snort/snort.lua
```

**Findings:**

- IP address that attempted to connect to the subject machine via SSH: 10.11.90.211
- Other rule message detected in the PCAP besides SSH: Ping Detected
- sid of the rule that detects SSH: 1000002

## Key Takeaways

- The core distinction between IDS and IPS is that an IDS only detects and alerts, it never blocks traffic on its own, which shapes how it fits into a broader detection and response workflow.
- NIDS deployment gives centralized visibility across a whole network, while HIDS gives deep visibility into a single host at the cost of per-host management overhead.
- Signature-based detection is fast and low-noise for known threats but structurally blind to zero-days, which is why hybrid approaches that layer in anomaly-based detection matter for modern threat coverage.
- Snort's rule syntax (action, protocol, source/destination IP and port, msg/sid/rev metadata) is the same whether you are writing a simple ICMP rule or something far more targeted, and understanding that structure is what makes custom rule writing straightforward.
- Snort's PCAP mode (`-r`) makes it just as useful for after-the-fact forensic investigation as it is for real-time monitoring, which is directly relevant to SOC-style incident investigation work.
