# SOC Workbooks and Lookups

**Room:** TryHackMe SOC Level 1 -- SOC Workbooks and Lookups
**Type:** Premium room, ~45 min
**Description:** Discover useful corporate resources to help structure and simplify L1 alert triage.

## Overview

This room covers the resources SOC analysts lean on to speed up alert triage: asset inventory, identity inventory, network diagrams, and SOC workbooks (playbooks). It runs a recurring scenario where G.Baker logs into a financial server (HQ-FINFS-02) and shares a file with R.Lund, then expands into network-based investigation and workbook-driven triage practice.

## Task 1 -- Introduction

No graded question here, just context-setting on what the room covers and its prerequisites (SOC L1 Alert Triage and Alert Reporting rooms).

![Room Introduction](Screen%20Shot%202026-06-19%20at%206.59.07%20PM.png)

## Task 2 -- Assets & Identities

Scenario: G.Baker logged into the HQ-FINFS-02 server, downloaded "Financial Report US 2024.xlsx," and shared it with R.Lund. Asset inventory and identity inventory provide the context needed to judge if this is expected behavior.

**Questions and answers:**

- Looking at the identity inventory, what is the role of R.Lund at the company?
  **US Financial Adviser**
- Checking the asset inventory, what data does the HQ-FINFS-02 server store?
  **Financial records**
- Finally, does the file sharing from the scenario look legitimate and expected? (Yea/Nay)
  **Yea**

A financial adviser pulling financial records lines up with their role, so the activity checks out as expected.

![Task 2 Answers](Screen%20Shot%202026-06-20%20at%2010.47.02%20AM.png)

## Task 3 -- Network Diagrams

This task builds an attack chain from firewall logs: a threat actor (103.61.240.174) brute forces the VPN, pivots to an internal IP (10.10.0.53), gets blocked scanning the Database Subnet, then moves to scan the Office Subnet. A network diagram maps the exposed ports and subnets involved.

**Questions and answers:**

- According to the network diagram, which service is exposed on the TCP/10443 port?
  **VPN**
- Now, which subnet would the server behind 172.16.15.99 IP belong to?
  **Database subnet**
- Finally, does the scenario look like a True Positive (TP) or False Positive (FP)?
  **TP**

172.16.15.99 falls inside the 172.16.15.0/24 Database Subnet range, and the chain (successful VPN brute force, lateral movement, blocked scan attempt, pivot to a new subnet) is a real, ongoing intrusion rather than benign activity.

![Task 3 Answers](Screen%20Shot%202026-06-20%20at%2010.52.34%20AM.png)

## Task 4 -- Workbooks Theory

This task introduces SOC workbooks (also called playbooks or runbooks) as structured guides that walk L1 analysts through Enrichment, Investigation, and Escalation stages, using an Unusual Login Location workbook as the example.

**Questions and answers:**

- Which SOC role would use workbooks the most (e.g. SOC Manager)?
  **SOC L1 Analyst**
- What is the process of gathering user, host, or IP context using TI and lookups?
  **Enrichment**
- Looking at the workbook example, what platform is used as an identity inventory source?
  **BambooHR**

Workbooks exist specifically to guide junior L1 analysts through consistent triage steps. In the example, the Enrichment stage pulls the expected user location from BambooHR before moving into Investigation.

![Task 4 Answers](Screen%20Shot%202026-06-20%20at%2011.06.28%20AM.png)

## Task 5 -- Workbooks Practice

A hands-on drag-and-drop builder with three separate workbooks. Each presents 8 step cards (2 of which are decoys) that have to be placed into the correct positions in a flowchart, including branching logic based on a yes/no decision.

### Workbook 1 -- Email Analysis

Scenario: an external email with a script or binary attachment.

Correct order:
1. Take ownership of the alert, use identity inventory to get context of the email recipients
2. Investigate the email using EML analyser: its SPF/DKIM, content, and sender domain reputation
3. Continue to the attachment analysis: use sandbox for binaries and manual code review for scripts

Decision: Is the attachment malicious, origin faked, or email is unexpected for the recipients' roles?

- **YES** -- Gather triage evidence: recipient list, sandbox report, EML analyser results, other attack indicators -- Write an alert report for L2 explaining the findings, attach the triage evidence to the report -- Escalate to L2
- **NO** -- Write a short alert comment explaining why you are confident that the email is safe and expected -- Close as FP

Decoys (not used): "Investigate login events of all the email recipients to the corporate servers and VPN" and "Notify all employees in chat to avoid using corporate email until the investigation is over"

Flag: `THM{the_most_common_soc_workbook}`

### Workbook 2 -- PowerShell Analysis

Scenario: an alert involving unexpected PowerShell usage.

Correct order:
1. Assign the alert to yourself, get context of the affected machine using asset inventory
2. Use threat intel to analyse the URL, and perform static analysis of the downloaded executable
3. Build a process tree to find out the parent process and account used to start PowerShell

Decision: Is the file malicious, downloaded from untrusted resource, or originates from a suspicious process?

- **YES** -- Save the results of the "[WIN] Process Tree" and "[WIN] Login Timeline" SIEM searches -- Write an alert report for L2. Attach your evidence, assumptions, and SIEM search results -- Escalate to L2
- **NO** -- Write a brief comment explaining your verdict. Reach SOC engineers to tune the detection rule -- Close as FP

Decoys (not used): "Contact the user in alert via email and confirm if the user approves PowerShell usage" and "Assign the alert to the system owner (IT team) and change alert's severity to Critical"

Flag: `THM{be_vigilant_with_powershell}`

### Workbook 3 -- Network Analysis

Completed and confirmed correct.

Flag: `THM{asset_inventory_is_essential}`

![Workbook 1 Flag](Screen%20Shot%202026-06-20%20at%2011.12.59%20AM.png)
![Workbook 2 Flag](Screen%20Shot%202026-06-20%20at%2011.16.22%20AM.png)
![All Three Workbook Flags Confirmed](Screen%20Shot%202026-06-20%20at%2011.21.24%20AM.png)

## Flags

```
THM{the_most_common_soc_workbook}
```

```
THM{be_vigilant_with_powershell}
```

```
THM{asset_inventory_is_essential}
```

## Key Takeaways

- Asset and identity inventories (AD, SIEM/EDR, MDM, SSO, HR systems) give the context needed to judge whether activity is expected for a given user or server.
- Network diagrams turn raw IPs and ports into a readable map of subnets, exposed services, and likely attack paths, which is essential for reconstructing lateral movement.
- SOC workbooks (playbooks/runbooks) standardize L1 triage across Enrichment, Investigation, and Escalation stages, reducing the chance of a verdict made without enough evidence.
- Workbook decision points generally branch into "Escalate to L2" or "Close as FP," and reaching either requires gathering and documenting evidence at each stage, not skipping straight to a verdict.
