# Data Exfiltration Detection
**Platform:** TryHackMe
**Path:** SOC Level 1 / Network Traffic Analysis
**Difficulty:** Medium

## Overview

This room covers how to detect data exfiltration attempts across four common channels: DNS, FTP, HTTP, and ICMP. Data exfiltration is the unauthorized transfer of data from an organization to an external, attacker-controlled destination. It can happen through insider action, malware, or compromised credentials.

The room walks through detection using both Wireshark (packet-level analysis) and Splunk (log correlation), covering indicators of attack for each protocol and how to isolate suspicious traffic from normal baseline activity.

## Task 1: Introduction

Adversaries exfiltrate data for financial gain, espionage, ransomware/extortion, sabotage, or reconnaissance. Common exfiltration phases include discovery/collection, staging/compression, exfiltration transport, and C2 coordination.

**Question:** Exfiltrating the data through HTTP comes under which technique?

```
Network-based
```

![Task 1 - Introduction question](Screen%20Shot%202026-07-23%20at%204.57.49%20PM.png)

## Task 3: Detection - Data Exfil through DNS

DNS is frequently abused for exfiltration because it is almost always allowed through firewalls and rarely inspected closely. Data gets encoded into subdomain labels or TXT responses.

**Indicators of attack:**
- Many DNS queries to a single external domain
- Long subdomain labels or unusually long query names (60-100+ characters)
- High entropy or base32/base64-like patterns in query names
- Rare record types (TXT, NULL)
- Frequent NXDOMAIN responses
- Regular query intervals (beaconing)

**Wireshark filters used:**
```
dns
dns.flags.response == 0
dns && frame.len > 70
dns && dns.qry.name contains "tunnelcorp.net"
```

**Splunk queries used:**
```
index=data_exfil sourcetype=DNS_logs
index="data_exfil" sourcetype="DNS_logs" | stats count by src_ip
index="data_exfil" sourcetype="DNS_logs" | stats count by query | sort -count
index="data_exfil" sourcetype="DNS_logs" | where len(query) > 30
```

**Questions:**

What is the suspicious domain receiving the DNS traffic?
```
tunnelcorp.net
```

How many suspicious traffic/logs related to DNS tunneling were observed?
```
315
```

Which local IP sent the maximum number of suspicious requests?
```
192.168.1.103
```

![Task 3 - DNS tunneling answers](Screen%20Shot%202026-07-23%20at%205.03.33%20PM.png)

## Task 5: Detection - Data Exfil through FTP

FTP is one of the oldest file transfer protocols and is still abused for exfiltration via compromised credentials, misconfigured servers, or ephemeral accounts. Detection relies on packet inspection, server logs, and flow/pattern analysis.

**Indicators of attack:**
- `USER` and `PASS` commands showing cleartext credentials
- `STOR` (upload) and `RETR` (download) commands with repeated or large transfers
- Large data connections to unusual external IPs, especially outside business hours
- PASV data channel openings paired with large payloads

**Wireshark filters used:**
```
ftp || ftp-data
ftp.request.command == "USER" || ftp.request.command == "PASS"
ftp contains "STOR"
ftp contains "csv"
ftp && frame.len > 90
```

**Questions:**

How many connections were observed from the guest account?
```
5
```

Apply the filter; what is the name of the customer-related file exfiltrated from the root account?
```
customer_data.xlsx
```

Which internal IP was found to be sending the largest payload to an external IP?
```
192.168.1.105
```

What is the flag hidden inside the FTP stream transferring the CSV file to the suspicious IP?
```
THM{ftp_exfil_hidden_flag}
```

![Task 5 - FTP exfiltration answers](Screen%20Shot%202026-07-23%20at%205.16.47%20PM.png)

## Task 7: Detection - Data Exfil through HTTP

HTTP is commonly abused for exfiltration because it blends with normal web traffic and traverses most firewalls and proxies. Techniques include POST uploads, encoded GET requests, custom headers, chunked/multipart transfers, and staging through legitimate cloud services.

**Indicators of attack:**
- Unusually large HTTP POST requests to external or unexpected hosts
- Requests to low-reputation or rarely seen domains
- Frequent small requests (beaconing) followed by a large upload
- Chunked or multipart transfers composing a larger file

**Splunk queries used:**
```
index="data_exfil" sourcetype="http_logs"
index="data_exfil" sourcetype="http_logs" method=POST
index="data_exfil" sourcetype="http_logs" method=POST | stats count avg(bytes_sent) max(bytes_sent) min(bytes_sent) by domain | sort - count
index="data_exfil" sourcetype="http_logs" method=POST bytes_sent > 600 | table _time src_ip uri domain dst_ip bytes_sent | sort - bytes_sent
```

**Wireshark filters used:**
```
http
http.request.method == "POST"
http.request.method == "POST" and frame.len > 500
http.request.method == "POST" and frame.len > 750
```

**Questions:**

Which internal compromised host was used to exfiltrate this sensitive data?
```
192.168.1.103
```

What's the flag hidden inside the exfiltrated data?
```
THM{http_raw_3xf1ltr4t10n_succ3ss}
```

![Task 7 - HTTP exfiltration answers](Screen%20Shot%202026-07-23%20at%205.18.35%20PM.png)

## Task 9: Detection - Data Exfil through ICMP

ICMP is a diagnostic protocol that is commonly allowed through firewalls and inspected less strictly than TCP/UDP, making it attractive for tunneling. Attackers encode data (often base64 or hex) inside ICMP echo request/reply payloads.

**Indicators of attack:**
- Persistent ICMP sessions to an external host with no legitimate monitoring purpose
- Unusually large ICMP payloads (normal pings are around 74 bytes total)
- High entropy data or base64/hex patterns inside payloads
- Regular, evenly spaced packet timing (periodicity)
- Fragmentation and reassembly across multiple ICMP packets

**Wireshark filters used:**
```
icmp
icmp.type == 8
icmp.type == 8 and frame.len > 100
```

**Question:**

What is the flag found in the exfiltrated data through ICMP?
```
THM{1cmp_3ch0_3xf1ltr4t10n_succ3ss}
```

![Task 9 - ICMP exfiltration answer](Screen%20Shot%202026-07-23%20at%205.19.37%20PM.png)

## Key Takeaways

- The same internal host (192.168.1.103) was responsible for both the DNS tunneling and HTTP exfiltration activity, showing how a single compromised endpoint can be used across multiple exfiltration channels.
- Effective exfiltration detection depends on correlating host, network, and log telemetry rather than relying on single-point alerts. Splunk was used to narrow down suspicious traffic at scale, while Wireshark confirmed findings at the packet level.
- Payload size and frame length thresholds (frame.len filters) were consistently useful across DNS, FTP, HTTP, and ICMP for separating normal baseline traffic from anomalous transfers.
- Protocols that are typically allowed through firewalls with minimal inspection (DNS, ICMP) are attractive covert channels precisely because they are trusted by default, reinforcing the need for payload-level inspection rather than protocol-level allowlisting alone.
