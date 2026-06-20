# Splunk: The Basics

**Room:** TryHackMe SOC Level 1 -- Core SOC Solutions -- Splunk: The Basics
**Type:** Premium room, 30 min
**Description:** Understand how SOC analysts use Splunk for log investigations.

## Overview

This room introduces Splunk as a SIEM platform: its three core components, how to navigate the home screen and add data, and a hands-on practical uploading and searching real VPN log data.

![Room Overview](Screen%20Shot%202026-06-20%20at%201.29.36%20PM.png)

## Task 1 -- Introduction

Context-setting only, completed without a specific captured question.

## Task 2 -- Connect with the Lab

Sets up the attacker/lab machine pair and starts the Splunk instance. No graded question, just "Connect with the lab" with no answer needed.

![Task 2 Lab Setup](Screen%20Shot%202026-06-20%20at%201.32.35%20PM.png)

## Task 3 -- Splunk Components

Covers Splunk's three main components: the **Forwarder** (a lightweight agent installed on endpoints that collects data and sends it to the Splunk instance, e.g. web servers, Windows Event Logs/PowerShell/Sysmon, Linux host logs, database logs), the **Indexer** (parses and normalizes data into field-value pairs and stores it as searchable events), and the **Search Head** (where users run SPL queries against indexed data and build visualizations).

**Question and answer:**

- Which component is used to collect and send data over the Splunk instance?
  **Forwarder**

![Task 3 Answer](Screen%20Shot%202026-06-20%20at%201.33.08%20PM.png)

## Task 4 -- Navigating Splunk

Covers the default Splunk home screen layout: the **Splunk Bar** (Messages, Settings, Activity, Help, Find, and app switching), the **Apps Panel** (installed apps, with Search & Reporting as the default), **Explore Splunk** (quick links to add data, add apps, view docs), and the **Home Dashboard** (selectable from a dropdown or the dashboards listing page, with a separate "Yours" tab for custom dashboards). Also covers the Add Data screen's three options: Upload (one-time file add), Monitor (continuous collection from files/directories/ports), and Forward (from another Splunk instance).

**Question and answer:**

- In the Add Data tab, which option is used to collect data from files and ports?
  **Monitor**

![Task 4 Answer](Screen%20Shot%202026-06-20%20at%201.34.48%20PM.png)

## Task 5 -- Practical: Uploading and Searching VPN Logs

A hands-on exercise uploading a VPN_logs file, creating an index named "VPN_Logs," and running searches against it. The five-step upload process: Select Source, Select Source Type, Input Settings (index + hostname), Review, and Done.

The uploaded data's actual field names turned out to be `UserName`, `Source_ip`, and `Source_Country` (discovered by inspecting a raw event in the Search & Reporting app), which were used to build the search queries:

```
source="VPNlogs.json" host="VPN_Connections" index="vpn_logs" sourcetype="_json"
```

**Questions and answers:**

- Upload the data and create an index "VPN_Logs." How many events are present in the log file?
  **2862**
- How many log events are captured by the user Maleena?
  **60**
- What is the username associated with IP 107.14.182.38?
  **Smith**
- What is the number of events that originated from all countries except France?
  **2814**
- How many VPN events were associated with the IP 107.3.206.58?
  **14**

![Splunk Search Interface with VPN Log Data](Screen%20Shot%202026-06-20%20at%202.10.46%20PM.png)
![Task 5 All Five Answers Confirmed](Screen%20Shot%202026-06-20%20at%202.17.56%20PM.png)

## No Flag for This Room

This room is text-based Q&A throughout, with no flag to capture.

## Key Takeaways

- Splunk's three components (Forwarder, Indexer, Search Head) map cleanly onto the general SIEM pipeline: collect, normalize/store, then search and analyze.
- Knowing the Add Data options (Upload vs. Monitor vs. Forward) matters for picking the right ingestion method depending on whether the data is a one-time file, a continuously-generated log, or coming from another Splunk instance.
- Before writing any SPL query against unfamiliar data, inspect a raw event first to confirm actual field names. Guessing field names (user vs. UserName, ip vs. Source_ip) wastes time and returns zero results.
- Basic SPL filtering (field="value", NOT field="value") combined with `stats count` covers a surprising amount of real investigative work.
