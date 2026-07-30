# ItsyBitsy

## Overview

This room covers investigating a suspected Command and Control (C2) communication alert using Kibana, picking up directly from the ELK/Kibana skills built in Alert Triage With Elastic. Acting as the SOC analyst following up on Analyst John's IDS alert, the room walks through pivoting from a suspected HR user (Browne) through week-long HTTP connection logs to identify the compromised host, the LOLBin used for the download, the C2 infrastructure, and ultimately the malicious payload's contents.

## Task 2 - Scenario: Investigate a Potential C2 Communication Alert

Investigated a suspected C2 communication alert from a user in the HR department, using the `connection_logs` index in Kibana containing a week of HTTP connection logs. Filtered the time range to March 2022 to scope the investigation, identified the suspected user's source IP by traffic volume, and traced the download activity back to a legitimate Windows binary abused as a LOLBin (Living off the Land Binary). Followed the connection to a well-known filesharing site being used as C2 infrastructure, identified the exact URL accessed, and retrieved the malicious payload containing the final flag.

![Task 2 Answers](Screen%20Shot%202026-07-30%20at%2012.15.27%20AM.png)

**Findings:**

- Events returned for the month of March 2022: 1482
- IP associated with the suspected user in the logs: 192.166.65.54
- Legit Windows binary used to download a file from the C2 server: bitsadmin
- Filesharing site used as a C2 server: pastebin.com
- Full URL of the C2 the infected host connected to: pastebin.com/yTg0Ah6a
- File accessed on the filesharing site: secret.txt
- Secret code found in the file: THM{SECRET__CODE}

## Key Takeaways

- Time-range scoping is the first and most important filter in any log investigation. Narrowing a week of connection logs down to the exact alert period (March 2022) immediately made a large, noisy dataset manageable before any deeper analysis began.
- Identifying the suspected user by traffic volume (the source IP responsible for the overwhelming majority of connections) is a simple but effective triage technique, and it's worth remembering that the highest-volume IP isn't always the right one, low-volume anomalous traffic can be just as significant depending on context.
- bitsadmin is a textbook LOLBin (Living off the Land Binary): a legitimate, digitally-signed Windows utility (part of the Background Intelligent Transfer Service) that attackers abuse to download files while blending into normal administrative activity and evading signature-based detection.
- Attackers frequently repurpose legitimate, trusted public services (like Pastebin) as C2 infrastructure specifically because that traffic looks identical to normal user activity and rarely gets blocked by network security controls, which is why unusual or unexpected connections to well-known sites still deserve scrutiny.
- This investigation reinforces a pattern seen throughout the SOC Level 1 path: start broad (scope by time and user), narrow using volume and behavioral anomalies (an unusual binary in the user-agent), and follow the resulting infrastructure indicators (host, URI) to their logical conclusion, in this case, directly to the malicious payload itself.
