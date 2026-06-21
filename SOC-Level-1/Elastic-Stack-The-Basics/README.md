# Elastic Stack: The Basics

**Room:** TryHackMe SOC Level 1 -- Core SOC Solutions -- Elastic Stack: The Basics
**Type:** Premium room, 180 min
**Description:** Understand how SOC analysts use the Elastic Stack (ELK) for log investigations.

**Status:** Tasks 1-6 complete.

## Overview

This room covers the Elastic Stack (ELK) as a SIEM-like tool: its components, the Kibana Discover tab, KQL (Kibana Query Language), and building visualizations, all worked through a hands-on lab investigating VPN connection logs.

![Room Overview](Screen%20Shot%202026-06-20%20at%207.20.40%20PM.png)

## Task 1 -- Introduction

Context-setting only: ELK isn't a traditional SIEM, but many SOC teams use it like one for its search and visualization capability. Learning objectives cover ELK's components, searching/filtering data, investigating VPN logs for anomalies, and building visualizations/dashboards.

No graded question, just "I am all set!" with no answer needed.

## Task 2 -- ELK Components

Covers the four core components: **Elasticsearch** (full-text search/analytics engine for JSON documents, RESTful API), **Logstash** (data processing engine with Input/Filter/Output stages that normalizes data before sending it on), **Beats** (lightweight host-based data shippers, one per data type, e.g. Winlogbeat for Windows event logs, Packetbeat for network traffic), and **Kibana** (the web-based visualization layer). The pipeline: Beats collect data -> Logstash parses/normalizes it -> Elasticsearch stores and indexes it -> Kibana visualizes it.

**Questions and answers:**

- Logstash is used to visualize the data. (yay/nay)
  **nay** -- Logstash filters/normalizes data; Kibana handles visualization.
- Elasticsearch supports all data formats apart from JSON. (yay/nay)
  **nay** -- the opposite is true. Elasticsearch is specifically built for JSON-formatted documents.

Note: these answers weren't confirmed with a screenshot, unlike the rest of this room.

## Task 3 -- Lab Connection

Sets up the attacker/lab machine pair and starts the ELK instance, accessible at `http://MACHINE_IP` with credentials **Analyst / analyst123**.

No graded question, just "Move to the next task!" with no answer needed.

## Task 4 -- Discover Tab

Covers Kibana's Discover tab: the Logs view, Fields Pane (click a field to see its top 5 values and filter with +/-), Index Pattern (selects which Elasticsearch data to explore, here `vpn_connections`), Search Bar, Time Filter, Time Interval histogram (useful for spotting spikes), and the ability to build a clean table by selecting specific fields as columns.

**Questions and answers** (all against the `vpn_connections` index, time range Dec 31, 2021 to Feb 2, 2022):

- How many hits are returned in that time range?
  **2861**
- Which IP address has the maximum number of connections?
  **238.163.231.224** (3.2%)
- Which user is responsible for the overall maximum traffic?
  **James** (4.0%)
- Apply filter on UserName Emanda; which SourceIP has max hits?
  **107.14.1.247** (53.6% of Emanda's 56 connections)
- On 11th Jan, which IP caused the spike observed in the time chart?
  **172.201.60.191** (98.2% of that day's 280 hits)
- How many connections were observed from IP 238.163.231.224, excluding the New York state?
  **48** (all from Michigan once New York was excluded)
- Create a table with IP, UserName, Source_Country and save.
  No answer needed -- table built and saved.

![Time Range Set, 2861 Hits](Screen%20Shot%202026-06-20%20at%207.58.32%20PM.png)
![Source_ip Top Values](Screen%20Shot%202026-06-20%20at%208.00.17%20PM.png)
![UserName Top Values](Screen%20Shot%202026-06-20%20at%208.01.10%20PM.png)
![Emanda Filter, Source_ip Top Value](Screen%20Shot%202026-06-20%20at%208.04.10%20PM.png)
![11th Jan Spike, Source_ip Top Value](Screen%20Shot%202026-06-20%20at%208.08.24%20PM.png)
![238.163.231.224 Excluding New York](Screen%20Shot%202026-06-20%20at%208.11.26%20PM.png)

## Task 5 -- KQL (Kibana Query Language)

Covers KQL's two search modes: free text search (matches whole terms anywhere, supports `*` wildcards) and field-based search (`Field : Value` syntax), plus logical operators AND/OR/NOT for combining conditions.

**Questions and answers:**

- Filter where Source_Country is the United States and show logs from User James or Albert. How many records were returned?
  Query: `Source_Country : "United States" AND (UserName : James OR UserName : Albert)`
  **161**
- User Johny Brown was terminated on 1st January 2022. How many VPN connections were observed after his termination?
  Query: `UserName : "Johny Brown"` with time range starting Jan 1, 2022
  **1**

![James/Albert Query, 161 Hits](Screen%20Shot%202026-06-20%20at%208.29.05%20PM.png)
![Johny Brown Query Result](Screen%20Shot%202026-06-20%20at%208.30.41%20PM.png)
![Task 5 Both Answers Confirmed](Screen%20Shot%202026-06-20%20at%208.30.35%20PM.png)

## Task 6 -- Visualization Tab

Covers building visualizations (tables, pie charts, bar charts) from the Discover tab, the Correlation option (dragging a second field in to compare against a primary one), and saving visualizations with a title and description.

**Questions and answers:**

- Which user was observed with the greatest number of failed attempts?
  Filter: `action : failed`
  **Simon** (100% of the filtered failed-attempt records)
- How many wrong VPN connection attempts were observed in January?
  Same filter narrowed to January 2022
  **274**

![Simon at 100% of Failed Attempts](Screen%20Shot%202026-06-20%20at%209.06.55%20PM.png)
![Task 6 Both Answers Confirmed](Screen%20Shot%202026-06-20%20at%209.09.46%20PM.png)

## Key Takeaways

- ELK's pipeline mirrors a general SIEM architecture: Beats collect, Logstash normalizes, Elasticsearch indexes, Kibana visualizes.
- Kibana's Discover tab makes ad hoc investigation fast: clicking any field shows its top 5 values with one-click +/- filtering, no query writing required for basic exploration.
- KQL's field-based search (`Field : Value`) combined with AND/OR/NOT covers most real investigative questions, and free text search with wildcards handles looser searches.
- A field value can hide in plain sight. The "failed" action value existed in the data the whole time and was initially missed while scanning the field list, which cost real time before the right filter (`action : failed`) was applied.
- Time range filtering is often the hidden first step. Several questions returned nothing or the wrong count until the date range was actually narrowed to the relevant window.
