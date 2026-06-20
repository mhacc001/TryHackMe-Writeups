# SOC Metrics and Objectives

**Room:** TryHackMe SOC Level 1 -- SOC Metrics and Objectives
**Type:** Premium room, ~45 min
**Description:** Explore key metrics driving SOC effectiveness and discover ways to improve them.

## Overview

This room covers the core metrics SOC teams use to measure effectiveness: Alerts Count, False Positive Rate, Alert Escalation Rate, and Threat Detection Rate, then layers in triage-specific SLA metrics (MTTD, MTTA, MTTR) and wraps up with practical improvement strategies and scenario-based practice.

![Room Overview](Screen%20Shot%202026-06-20%20at%2011.33.20%20AM.png)

## Task 1 -- Introduction

Context-setting only, no graded question.

## Task 2 -- Core Metrics

Introduces the four foundational metrics:

| Metric | Formula | Measures |
|---|---|---|
| Alerts Count (AC) | Total Count of Alerts Received | Overall load of SOC analysts |
| False Positive Rate (FPR) | False Positives / Total Alerts | Level of noise in the alerts |
| Alert Escalation Rate (AER) | Escalated Alerts / Total Alerts | Experience of L1 analysts |
| Threat Detection Rate (TDR) | Detected Threats / Total Threats | Reliability of the SOC team |

Key benchmarks: 5 to 30 alerts per day per L1 analyst is healthy, FPR of 80% or higher is a serious noise problem, Alert Escalation Rate should ideally stay below 20-50%, and TDR should always aim for 100% since a missed threat can be devastating.

**Questions and answers:**

- Is zero alerts for one month a good sign for your SOC team? (Yea/Nay)
  **Nay** -- a total absence of alerts usually signals a SIEM or visibility problem rather than a genuinely quiet network.
- What is the False Positive Rate if only 10 out of 50 alerts appear to be real threats?
  **80%** -- 40 of the 50 alerts weren't real threats, so FPR = 40/50 = 80%.

![Task 2 Answers](Screen%20Shot%202026-06-20%20at%2011.36.21%20AM.png)

## Task 3 -- Triage Metrics

Introduces SLA-driven timing metrics along a timeline: malicious event occurs -> SOC receives the alert (MTTD) -> L1 starts triage (MTTA) -> escalation and internal processes -> SOC fully mitigates the breach. In this room's model, MTTR is measured from when the alert is received through to full mitigation (it does not include MTTD itself).

Reference SLA values: MTTD = 5 minutes, MTTA = 10 minutes, MTTR = 60 minutes, with SOC Team Availability commonly 24/7 or 8/5 (Monday-Friday).

**Questions and answers:**

- The SOC team receives a critical alert on Saturday. If the team works 8/5, on which day will they acknowledge the alert?
  **Monday** -- the next working day after the weekend.
- An employee was lured into running data stealer malware: the "Connection to Redline Stealer C2" alert arrived after 12 minutes, an L1 analyst moved it to In Progress 10 minutes later, after 6 more minutes it was escalated to L2, who spent 35 minutes cleaning the malware. Provide MTTD, MTTA, and MTTR via comma.
  **12,10,51** -- MTTD = 12 (time to alert), MTTA = 10 (time to start triage), MTTR = 10 + 6 + 35 = 51 (time from alert received to full mitigation).

![Task 3 Answers](Screen%20Shot%202026-06-20%20at%2011.36.58%20AM.png)

## Task 4 -- Improving Metrics

Pairs each problematic metric threshold with concrete remediation steps: too much alert noise points to excluding trusted activity from detection rules or automating triage with SOAR; high MTTD points to tuning detection rules and checking for SIEM ingestion delay; high MTTA points to real-time analyst notifications and even alert distribution; high MTTR points to fast escalation paths and documented attack-scenario playbooks.

**Questions and answers:**

- What is the highest acceptable False Positive Rate for SOC teams?
  **80%** -- the threshold called out earlier as where FPR becomes a serious problem.
- Should all SOC roles work together to keep metrics improving? (Yea/Nay)
  **Yea** -- improving FPR, MTTD, MTTA, and MTTR all require coordination across L1, L2, and detection engineering, not just one role acting alone.

![Task 4 Answers](Screen%20Shot%202026-06-20%20at%2011.38.34%20AM.png)

## Task 5 -- Practice Scenarios

A hands-on exercise playing a SOC manager who receives three different complaints, and has to correctly match each one to its Problematic Metric, Improvement Task, and the role it should be assigned to.

### Scenario 1 -- Unhappy Customer

A customer's CFO had their email and Entra ID account breached. It took the SOC team almost 6 hours total to kick the attacker out, including 5 hours just to reset the victim's Entra ID password and MFA.

- **Problematic Metric:** Time to Respond was too high, too much time spent to contain the attack
- **Improvement Task:** Create a workbook explaining credential rotation steps, and present it to the team
- **Assign Task To:** Assign the research and workbook creation task to the L2 that handled the incident

Flag: `THM{mttr:quick_start_but_slow_response}`

### Scenario 2 -- Delayed Alert

A Time to Detect of 20 minutes caused a delayed alert triage.

- **Problematic Metric:** Time to Detect of 20 minutes led to a delayed alert triage
- **Improvement Task:** Tune the SIEM and the detection rules to run more often, every 5 minutes
- **Assign Task To:** Assign the detection rules' schedule review to the dedicated SOC engineer

Flag: `THM{mttd:time_between_attack_and_alert}`

### Scenario 3 -- Tired Analysts

False Positive Rate was identified as the core driver of L1 analyst fatigue.

- **Problematic Metric:** False Positive Rate is the core of the problem
- **Improvement Task:** Schedule a call with the team to implement the False Positive remediation process
- **Assign Task To:** Assign the task to SOC engineers to exclude the system and IT noise from the rules

Flag: `THM{fpr:the_main_cause_of_l1_burnout}`

![Scenario 1 Complete](Screen%20Shot%202026-06-20%20at%2011.42.16%20AM.png)
![Scenario 2 Complete](Screen%20Shot%202026-06-20%20at%2011.48.28%20AM.png)
![Scenario 3 Complete](Screen%20Shot%202026-06-20%20at%2011.51.44%20AM.png)
![All Three Flags Confirmed](Screen%20Shot%202026-06-20%20at%2011.52.01%20AM.png)

## Task 6 -- Conclusion

Wrap-up only, no additional graded content.

## Flags

```
THM{mttr:quick_start_but_slow_response}
```

```
THM{mttd:time_between_attack_and_alert}
```

```
THM{fpr:the_main_cause_of_l1_burnout}
```

## Key Takeaways

- SOC effectiveness is measured through a small set of core metrics: Alerts Count, False Positive Rate, Alert Escalation Rate, and Threat Detection Rate, each tied to a different part of the L1 analyst's job.
- SLA-based triage metrics (MTTD, MTTA, MTTR) break the incident timeline into detection, acknowledgement, and response, and the exact boundaries of each metric matter for how they're calculated.
- A quiet SOC isn't necessarily a safe one. Zero alerts is a red flag for visibility gaps, not a sign of success.
- Fixing a bad metric isn't just a technical task. It usually means assigning the right remediation work to the right role, whether that's SOC engineers tuning detection rules, L2 building a workbook, or the whole team coordinating on a fix.
