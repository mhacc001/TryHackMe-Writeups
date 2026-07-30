 # Log Analysis with SIEM

## Overview

This room covers how SIEM solutions are used to detect and analyze malicious behavior. It walks through the core benefits of SIEM (centralization, correlation, historical analysis), the major log source categories an analyst encounters (host based, network based, web based), and hands on Splunk investigations across Windows, Linux, and web application log sources using realistic SOC alert scenarios.

## Task 2 - Benefits of SIEM for Analysts

Covered the three core benefits SIEM provides a SOC:

- **Centralisation**: gathering logs from disparate systems like IPS, EDR, and endpoints into a single searchable platform.
- **Correlation**: linking separate events, like an IDS alert with a bare source IP, to Windows Event Logs or Sysmon to build full context on who performed an activity and how.
- **Historical Events**: reviewing past logs to spot patterns, such as checking whether a user has previously logged in from an unusual location before treating a new login as suspicious.

**Findings:**

```
Process of linking data from multiple sources to identify relationships between individual events: Correlation
Process of collecting and storing log data from multiple systems and sources into a single, unified location: Centralisation
```

![Task 2 answers](Screen%20Shot%202026-07-29%20at%2011.35.49%20PM.png)

## Task 3 - Log Sources Overview

Covered the three major log source categories that feed a SIEM:

- **Host-Based**: workstations and servers, covering nearly every attack in some way.
- **Network-Based**: firewalls, routers, IDS/IPS, providing visibility into device to device communication.
- **Web-Based**: application logs, critical since web vulnerabilities are a common initial access vector.

Also covered two supporting SIEM concepts: Time Pitfalls (logs from different systems may be in UTC, local time, or no timezone at all, and SIEM normalized time can differ from an analyst's local time) and Logs Normalisation (converting varied log formats like JSON, XML, and plain text into a single consistent structure for easier searching and correlation).

**Findings:**

```
Process of converting logs from different formats into a single format for easier analysis in a SIEM: Normalisation
Log source type that can be used to detect the execution of a malicious script: Host-Based
```

![Task 3 answers](Screen%20Shot%202026-07-29%20at%2011.36.34%20PM.png)

## Task 4 - Windows Logs

Covered the two main Windows data sources in a SIEM:

- **Sysmon**: must be installed and configured separately, provides deep visibility into process execution, network connections, process injection, registry changes, and file creation.
- **WinEventLogs**: over 200 log channels, with Security logs covering authentication, account changes, and policy changes, and System logs covering services and system level activity useful for spotting persistence or privilege escalation via services.

Walked through a worked example tracing a compromised host (WINHOST05) from an encoded PowerShell execution alert, to a suspicious network connection, to a new user account creation, to a malicious service installation, illustrating a full attacker persistence and privilege escalation chain.

Investigated a suspicious network connection alert on port 5678 (host WIN-105) using Splunk index `task4`.

Queries used:

```
index="task4" ComputerName=WIN-105 DestinationPort=5678
| table Time host User EventType EventCode Image SourceIp SourcePort DestinationIp DestinationPort Message

index=task4 EventCode=1 Image="*SharePoInt.exe"
| table _time ComputerName User EventType EventCode Image CommandLine Hashes

index=task4 *schtasks /create*
```

**Findings:**

```
IP address the connection was established with: 10.10.114.80
Process that initiated the suspicious connection: SharePoInt.exe (note the typosquat, a capital "I" substituted for a lowercase "n")
MD5 hash of the malicious process: 770D14FFA142F09730B415506249E7D1
Name of the scheduled task created on the system: Office365 Install
```

![Task 4 answers](Screen%20Shot%202026-07-29%20at%2011.40.19%20PM.png)

## Task 5 - Linux Logs

Covered the two key Linux data sources:

- **auth.log**: authentication related activity such as logins, sudo usage, and privilege escalation.
- **syslog**: general system level events such as service restarts, cron jobs, and background processes.

Walked through a worked example detecting a successful SSH brute force against the ubuntu user, followed by a privilege escalation to root, and a persistence mechanism established via a suspicious cron job running a shell script and a Perl reverse shell.

Investigated a possible persistence alert involving a new remote-ssh user account on an Ubuntu server using Splunk index `task5`.

Queries used:

```
index=task5 useradd remote-ssh
index=task5 | search sudo
index=task5 | search jack-brown | search ssh
index=task5 | search "Failed password for jack-brown"
index=task5 *port*
```

**Findings:**

```
Timestamp of the remote-ssh account creation: 2025-08-12 09:52:57
User that successfully escalated privileges to root: jack-brown
IP address the user logged in from: 10.14.94.82
Number of failed login attempts prior to the successful login: 4
Port the persistence mechanism is configured to connect to: 7654
```

![Task 5 answers](Screen%20Shot%202026-07-29%20at%2011.41.50%20PM.png)

## Task 6 - Web Application Logs

Covered web log sources (Apache, Nginx access and error logs) and three common attack patterns detectable through them:

- **Brute Force Activity**: repeated POST requests to a login page like /wp-login.php, thresholded by count within a time window and grouped by client IP.
- **Possible Web Shell**: requests to script or executable file types with a 200 status, thresholded and grouped by domain.
- **DDoS Activity**: 503 status codes with very high request volume in a short window.

Investigated a spike in activity on the organization's web server using Splunk index `task6`.

**Findings:**

```
URI path with the highest number of requests: /wp-login.php
IP address that was the source of the activity: 10.10.243.134
How the activity can be classified: Brute Force
Tool the threat actor used: WPScan
```

![Task 6 answers](Screen%20Shot%202026-07-29%20at%2011.43.06%20PM.png)

## Key Takeaways

- SIEM's core value isn't just log storage, it's centralization and correlation working together. A bare IP from an IDS alert becomes actionable only once it's correlated against Windows Event Logs or Sysmon to establish who, where, and how, which is exactly the workflow used across every practical task in this room.
- Time normalization is an easy to overlook but critical pitfall. Two log sources timestamped in different timezones can make an attack timeline look wrong even when nothing is actually delayed, so confirming timezone alignment should be a habitual first step before building any incident timeline.
- Typosquatted process names (SharePoInt.exe instead of SharePoint.exe) are a recurring evasion technique across this whole SOC Level 1 path, and catching them requires actually reading process names carefully rather than pattern matching on what looks roughly right.
- The same investigative pattern repeats across Windows, Linux, and Web log sources: identify the alerting indicator (a port, a username, a URI), pivot to the relevant log source, and then follow the trail backward or forward in time to build the full context. That consistency is what makes SIEM query writing a transferable skill across very different log formats.
- Splunk's message deduplication (the "message repeated N times" pattern) is a small but important detail. Miscounting failed login attempts because of a collapsed duplicate log line, as seen in the failed login count question, is a realistic and easy mistake, which reinforces the value of carefully reading raw log output rather than trusting event counts at a glance.
