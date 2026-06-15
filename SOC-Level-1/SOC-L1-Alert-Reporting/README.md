# SOC L1 Alert Reporting
**Platform:** TryHackMe  
**Path:** SOC Level 1 / SOC Team Internals  
**Difficulty:** Easy  

---

## Objective

Learn how to properly report, escalate, and communicate about high-risk SOC alerts. This room introduces alert reporting using the Five Ws framework, alert escalation to L2, and cross-department communication best practices -- then applies those skills in a live SOC dashboard simulation.

---

## Tools Used

- TryHackMe SOC Dashboard (alert triage, report writing, and escalation lab)

---

## Methodology

### Task 1 -- Introduction

L1 analysts may deal with real cyberattacks and breaches that require immediate attention and documentation beyond a simple True/False Positive verdict. This room covers three core concepts: **alert reporting**, **escalation**, and **communication**.

**Learning Objectives:**
- Understand the need for SOC alert reporting and escalation
- Learn how to write alert comments or case reports properly
- Explore escalation methods and communication best practices
- Apply the knowledge to triage alerts in a simulated environment
- Feel more confident in the SOC Simulator and during SAL1 certification

![SOC L1 Alert Reporting room introduction](Screen_Shot_2026-06-15_at_4_01_58_PM.png)

---

### Task 2 -- SOC Dashboard

Continuing work in the SOC dashboard, this time focused on writing professional reports and practicing alert escalation.

![SOC dashboard access granted for Alert Reporting room](Screen_Shot_2026-06-15_at_4_02_35_PM.png)

---

### Task 3 -- Alert Reporting

L1 analysts must document their investigations before closing or escalating alerts. Alert reporting serves three key purposes:

| Alert Report Purpose | Explanation |
|----------------------|-------------|
| Provide context for escalation | A well-written report saves L2 analysts time and helps them quickly understand what happened |
| Save findings for the records | Raw SIEM logs are stored for 3-12 months, but alerts are kept indefinitely -- all context should live inside the alert |
| Improve investigation skills | Report writing forces clarity; if you can't explain it simply, you don't understand it well enough |

The **Five Ws** framework is the standard for writing alert reports:

- **Who** -- Which user logs in, runs the command, or downloads the file
- **What** -- What exact action or event sequence was performed
- **When** -- When exactly did the suspicious activity start and end
- **Where** -- Which device, IP, or website was involved in the alert
- **Why** -- The most important W: the reasoning behind the final verdict

![Five Ws framework and example alert report checklist](Screen_Shot_2026-06-15_at_4_06_38_PM.png)

![Alert report purposes table](Screen_Shot_2026-06-15_at_4_06_48_PM.png)

---

### Task 4 -- Alert Escalation Guide

After making a verdict and writing a report, L1 must decide whether to escalate. Escalate the alert if:

1. The alert is an indicator of a major cyberattack requiring deeper investigation or DFIR
2. Remediation actions like malware removal, host isolation, or password reset are required
3. Communication with customers, partners, management, or law enforcement is required
4. The alert is not fully understood and senior analyst support is needed

**Escalation Steps in the SOC Dashboard:**
1. Move the alert to **In Progress** status and complete the analysis
2. Write an alert report and set the **verdict** (e.g., True Positive)
3. If escalation is required, assign the alert **to your L2 on shift**
4. L2 receives a notification and starts from the alert report

L2 will then deep investigate, validate the True Positive, communicate with other departments if needed, and initiate a formal Incident Response process for major incidents.

![Escalation guide showing L1-to-L2 escalation flow with phishing credential rotation example](Screen_Shot_2026-06-15_at_4_19_46_PM.png)

**Answers:**
- Who is your current L2 in the SOC dashboard? **E.Fleming**
- Flag received after correctly escalating the phishing alert to L2: **THM{good_job_escalating_your_first_alert}**

![Task 4 answers -- E.Fleming and escalation flag confirmed](Screen_Shot_2026-06-15_at_4_19_59_PM.png)

---

### Task 5 -- SOC Communication

In critical scenarios, L1 analysts must know how to communicate effectively even when standard procedures break down. The SOC team relies on **Crisis Communication** procedures for these cases.

**Communication Cases:**

- **L2 is unavailable for 30+ minutes on a critical alert** -- Try L2, then L3, then your manager. Know where emergency contacts are.
- **Slack/Teams account compromise alert** -- Do not contact the user through the breached chat. Use a phone call or alternative channel.
- **Overwhelming alert volume with critical alerts in the mix** -- Prioritize by workflow, but inform your L2 on shift immediately.
- **You realize days later you may have misclassified an alert** -- Reach out to L2 right away. Threat actors can stay silent for weeks before striking.
- **SIEM logs are not parsed correctly or not searchable** -- Do not skip the alert. Investigate what you can and report the issue to L2 or the SOC engineer.

**Communication By L2 -- flow:**
1. L1 escalates alert to L2 with report and alert details link
2. L2 acknowledges and begins investigation
3. L2 initiates Incident Response with the DFIR team if needed
4. L2 contacts Team Managers and legal/PR teams if the incident requires broader response

![SOC communication cases and L2 communication flow diagram](Screen_Shot_2026-06-15_at_4_20_37_PM.png)

**Answers:**
- Should you first try to contact your manager in case of a critical threat? **Nay**
- Should you immediately contact your L2 if you think you missed the attack? **Yea**

![Task 5 answers confirmed -- Nay and Yea](Screen_Shot_2026-06-15_at_4_28_22_PM.png)

---

### Task 6 -- Alert Lab: Phishing and Domain Discovery

Investigated two active alerts in the SOC dashboard and wrote Five Ws reports for both.

**SOC Dashboard -- Active Alerts:**

| Time | Alert | Severity | Status |
|------|-------|----------|--------|
| Mar 27th 2025 at 19:56 | Spike of Domain Discovery Commands | Medium | Awaiting action |
| Mar 27th 2025 at 19:25 | Email Marked as Phishing after Delivery | Medium | Awaiting action |
| Mar 27th 2025 at 19:10 | Web Scanning of Corporate Resources | Low | In Progress (E.Fleming L2) |
| Mar 27th 2025 at 18:30 | Sensitive Document Share to External | Medium | In Progress (E.Fleming L2) |
| Mar 27th 2025 at 18:02 | Fast Beaconing to Untrusted Domain | High | Closed -- False Positive (S.Todd L1) |

![SOC dashboard showing 5 active alerts](Screen_Shot_2026-06-15_at_4_15_53_PM.png)

---

**Alert 1 -- Email Marked as Phishing after Delivery**

- **Sender:** Microsoft Support `<support@microsoft.com>`
- **Recipient:** Eddie Huffman, IT Manager `<e.huffman@tryhackme.thm>`
- **Subject:** Important Update: Microsoft Teams Pricing Increase
- **Body keywords:** 600% price increase; urgent notice; download the report; read the details
- **Security checks:** SPF/Fail; DKIM/Fail
- **Attached URLs:** None
- **Attached files:** REPORT.rar
- **Verdict:** True Positive

**Five Ws Analyst Comment:**

> On March 27, 2025 at 19:25, Eddie Huffman (IT Manager) received a phishing email spoofing Microsoft Support (support@microsoft.com) with subject "Important Update: Microsoft Teams Pricing Increase." The email failed both SPF and DKIM checks, confirming sender spoofing. It contained urgency-driven language around a fabricated 600% price increase and a suspicious attachment (REPORT.rar) designed to lure the recipient into downloading malware. The email was flagged post-delivery by automated analysis. The attachment was not executed; the email has been quarantined pending further investigation.

![Phishing alert edit view showing Five Ws comment submitted](Screen_Shot_2026-06-15_at_4_20_37_PM.png)

**Flag received after correct Five Ws report:** `THM{nice_attempt_faking_microsoft_support}`

![Phishing alert flag -- THM{nice_attempt_faking_microsoft_support}](Screen_Shot_2026-06-15_at_4_19_03_PM.png)

---

**Alert 2 -- Spike of Domain Discovery Commands**

- **Host:** DMZ-MSEXCHANGE-2013 (Windows Server 2012 R2)
- **User:** NT AUTHORITY\SYSTEM
- **Invoked commands:** `dir hostname whoami /priv net group "Domain Admins" /domain nltest /dclist:tryhackme.thm`
- **Source process:** `C:\Windows\System32\cmd.exe`
- **Parent process:** `C:\Users\Public\revshell.exe`
- **Grandparent process:** `C:\Windows\System32\inetsrv\w3wp.exe`
- **Verdict:** True Positive -- escalated to E.Fleming (L2)

The process chain reveals a web shell compromise: `w3wp.exe` (IIS) spawned `revshell.exe` from a public directory, which then launched `cmd.exe` to run Active Directory reconnaissance commands. This is a live post-exploitation scenario on the Exchange server.

**Five Ws Analyst Comment:**

> On March 27, 2025 at 19:56, NT AUTHORITY\SYSTEM on DMZ-MSEXCHANGE-2013 executed AD discovery commands (whoami, net group, nltest) via cmd.exe spawned from revshell.exe, which was launched by IIS worker process w3wp.exe, indicating an active web shell compromise and post-exploitation domain reconnaissance. Escalated to L2.

![Spike of Domain Discovery alert details showing process chain](Screen_Shot_2026-06-15_at_4_26_50_PM.png)

![Edit alert view for Spike of Domain Discovery Commands](Screen_Shot_2026-06-15_at_4_26_41_PM.png)

**Flag received after correct escalation:** `THM{looks_like_webshell_via_old_exchange}`

![Domain discovery escalation flag -- THM{looks_like_webshell_via_old_exchange}](Screen_Shot_2026-06-15_at_4_29_16_PM.png)

**Task 6 answers confirmed:**
- Which user email leaked the sensitive document? **m.boslan@tryhackme.thm**
- Who is the sender of the suspicious phishing email? **support@microsoft.com**
- Flag after writing good Five Ws report: **THM{nice_attempt_faking_microsoft_support}**

![Task 6 all answers confirmed correct](Screen_Shot_2026-06-15_at_4_30_12_PM.png)

![Task 6 completion confirmation](Screen_Shot_2026-06-15_at_4_30_23_PM.png)

---

## Flags

```
THM{nice_attempt_faking_microsoft_support}
THM{good_job_escalating_your_first_alert}
THM{looks_like_webshell_via_old_exchange}
```

---

## Key Takeaways

- Alert reporting is not optional documentation -- it is a core L1 responsibility that enables L2 escalation, preserves findings beyond SIEM log retention, and sharpens investigative thinking.
- The Five Ws framework (Who, What, When, Where, Why) is the standard for writing clear, useful alert comments and reports.
- SPF and DKIM failures together are hard indicators of sender spoofing -- a confirmed fail on both eliminates any ambiguity about email legitimacy.
- Process chain analysis is critical: `w3wp.exe` spawning `revshell.exe` spawning `cmd.exe` is a textbook web shell compromise, not legitimate IT activity.
- Escalation means reassigning the alert to your L2 on shift with a complete report -- the report is what allows L2 to investigate without starting from scratch.
- Crisis communication protocols matter: never contact a potentially compromised account through that account, always escalate concerns even days after a possible misclassification, and know your emergency contact chain.
