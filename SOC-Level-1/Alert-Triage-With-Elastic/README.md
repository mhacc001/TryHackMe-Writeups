# Alert Triage With Elastic

## Overview

This room covers alert triage using the Elastic Stack (Kibana), investigating suspicious activity on SomeCorp's IIS and Windows server infrastructure. Acting as the on-call SOC analyst at an MSSP, the room walks through reconstructing a full multi-stage attack: a ProxyLogon exploitation of the web application, web shell deployment, an Administrator RDP logon, backdoor account creation, privilege escalation, PowerShell-based discovery, and data staging via RAR compression, correlating IIS web logs, Windows Security logs, Sysmon logs, and PowerShell logs throughout.

## Task 2 - Setting Up Kibana

Set up the Kibana environment by selecting the "Alert Triage With Elastic" data view and the Entire data range, then filtered to the weblogs index using `_index:weblogs` to begin investigating IIS web server logs.

**Findings:**

```
Number of logs available for analysis within the entire time range: 1467
Field value for client.ip in the weblogs index: 203.0.113.55
```

![Task 2 answers](Screen%20Shot%202026-07-30%20at%2012.01.13%20AM.png)

## Task 3 - Investigating the Web Alert

Investigated the first alert, showing IP 203.0.113.55 making POST requests to `proxyLogon.ecp`, related to the ProxyLogon vulnerability affecting Microsoft Exchange's Explicit Logon functionality. Confirmed the traffic was automated (via the python-requests user agent) rather than legitimate browser activity. Followed up on a second high-severity alert seven minutes later involving the `cmd=` parameter, a hallmark of web shell activity, and confirmed a web shell was active via `errorEE.aspx`, with commands appended directly to GET requests. Both alerts were classified as True Positives requiring escalation.

Queries used:

```
_index:weblogs and client.ip:203.0.113.55 and http.request.method:POST
_index:weblogs and client.ip:203.0.113.55 and http.request.method:GET and errorEE.aspx
```

**Findings:**

```
POST requests IP 203.0.113.55 made to proxyLogon.ecp: 3
User agent that made the POST requests: python-requests/2.25.1
Logs containing the cmd= query parameter in url.path: 20
Command run utilizing errorEE.aspx on Jul 20, 2025 @ 04:45:50.000: hostname
```

![Task 3 answers](Screen%20Shot%202026-07-30%20at%2012.03.03%20AM.png)

## Task 4 - Windows Logon and Process Investigation

Pivoted from web-based evidence to host-based evidence after noting the Administrator account accessed the server outside business hours. Investigated Windows Security Event ID 4624 (Logon) to confirm the Administrator logged on from the same IP (203.0.113.55) seen in the web alerts, then correlated with Sysmon Event ID 1 (Process Creation) to trace the resulting process chain. Investigated a follow-up alert showing a new user account was created shortly after the logon.

Queries used:

```
@timestamp >= "2025-07-20T05:11:22" and winlog.event_id:4624 and host.name:winserv2019.some.corp and winlog.event_data.TargetUserName:Administrator
@timestamp >= "2025-07-20T05:11:22" and winlog.event_id:1 and user.name:Administrator
@timestamp >= "2025-07-20T05:13:10.000" and winlog.channel:Security and winlog.task:"User Account Management"
```

**Findings:**

```
winlog.record_id of the Administrator 4624 logon event: 17166
process.pid of the Sysmon Event 1 at 05:11:27.996: 964
winlog.event_id for the new user account being created: 4720
Name of the new user account: svc_backup
```

![Task 4 answers](Screen%20Shot%202026-07-30%20at%2012.05.24%20AM.png)

## Task 5 - Command Execution and Privilege Escalation

Investigated suspicious command-line activity from the Administrator account, tracing child processes launched by cmd.exe, correlating with Windows Security Event ID 4732 (Security Group Management) to confirm the new account was added to privileged groups, and examining PowerShell Script Block Logging (Event Code 4104) to uncover post-compromise discovery commands (whoami, whoami /priv). Finally, investigated the use of Rar.exe by the newly created account, a legitimate tool that generated no SOC alert on its own but, in context, indicated data staging for exfiltration.

Queries used:

```
@timestamp >= "2025-07-20T05:13:15" and process.parent.name:cmd.exe and user.name:Administrator
@timestamp >= "2025-07-20T05:13:15" and (winlog.event_id:4732 or process.parent.name:cmd.exe)
@timestamp >= "2025-07-20T05:13:15" and event.module:powershell and event.code:4104
process.name:"Rar.exe"
```

**Findings:**

```
Command used to add the new account to "Remote Desktop Users": net localgroup "Remote Desktop Users" svc_backup /add
winlog.record_id of the 4732 event adding the user to Administrators: 17254
PowerShell command run on Jul 20, 2025 @ 05:16:14.628: net group "Domain Admins" /domain
Name of the archive created with Rar.exe: finance_it_archive.rar
```

![Task 5 answers](Screen%20Shot%202026-07-30%20at%2012.06.50%20AM.png)

## Attack Timeline

1. **04:38:00** - ProxyLogon exploitation of the web application (proxyLogon.ecp)
2. **~04:40:30** - Web shell deployed (errorEE.aspx)
3. **04:45:50** - Command execution via web shell (hostname)
4. **05:11:22** - RDP logon as Administrator from 203.0.113.55
5. **05:13:09** - Backdoor account created (svc_backup)
6. **05:13:15** - Backdoor account added to Remote Desktop Users and Administrators groups
7. **05:16:14** - PowerShell discovery commands run (whoami, net group "Domain Admins" /domain)
8. **~05:18:20** - Data staged via RAR compression (finance_it_archive.rar)

## Key Takeaways

- Confirming a single suspicious event is never the end of an investigation. The initial ProxyLogon POST requests alone weren't enough to prove malicious intent, it took correlating the web shell activity, the out-of-hours Administrator logon from the same IP, and the subsequent account creation to build a complete, defensible case.
- Windows Security, Sysmon, and PowerShell Script Block Logging each captured a different layer of the same attack. Security Event 4624 confirmed the logon, Sysmon Event 1 revealed the process chain, and PowerShell logging (Event Code 4104) exposed the plaintext discovery commands, no single source told the whole story on its own.
- Legitimate software can still be a strong indicator of compromise when the context is wrong. Rar.exe generated no SOC alert because it's approved client software, but its use by a newly created backdoor account, at that specific point in the attack chain, was a clear sign of data staging for exfiltration, reinforcing that context and correlation matter more than the tool itself.
- This investigation mirrors the exact kill chain structure covered throughout the SOC Level 1 path: Initial Access (ProxyLogon exploitation), Execution (web shell commands), Persistence (backdoor account), Privilege Escalation (group membership changes), Discovery (whoami, net group), and Collection (RAR archive), demonstrating how the same MITRE-aligned framework applies whether the tooling is Splunk or Elastic.
- Building structured Kibana tables (adding relevant fields as columns, sorting Old-New) is what makes a large, noisy dataset navigable. The technique of iteratively narrowing a KQL query, starting broad by IP, then narrowing by method, endpoint, or event ID, is a transferable triage skill regardless of which SIEM platform is in use.
