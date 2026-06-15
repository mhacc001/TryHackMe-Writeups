# Junior Security Analyst Intro
**Platform:** TryHackMe  
**Path:** SOC Level 1 / Blue Team Introduction  
**Difficulty:** Easy  

---

## Objective

Simulate a full day in the life of a Junior SOC Analyst -- monitoring a SIEM dashboard, triaging critical alerts, investigating a malicious IP using threat intelligence, escalating to a senior analyst, and containing the threat via firewall block.

---

## Tools Used

- SIEM Dashboard (alert monitoring)
- IP Hunter (threat intelligence / IP reputation lookup)
- Escalation Module
- Firewall Manager

---

## Methodology

### Task 1 -- Security Analyst Journey

Reviewed the daily context of a Junior Security Analyst (SOC L1). As a first line of defense, the role involves monitoring and investigating security alerts, participating in SOC brainstorms, cooperating with other teams, and constantly learning new attack techniques and defenses.

![Security Analyst Journey -- daily duties and cyber news overview](Screen%20Shot%202026-06-01%20at%2010.29.52%20AM.png)

### Task 2 -- SOC and Your Team

Met the SOC team members who support the Junior Analyst role:

- **Will Griffin** -- Senior Analyst: handles complex cases after initial triage
- **Corey Stevens** -- SOC Engineer: maintains security tools and configures alerts
- **Emily Conway** -- SOC Manager: reports results to management and keeps the team on track
- **Daniel Herrera** -- Incident Responder: called in during major incidents

![SOC team members and their roles](Screen%20Shot%202026-06-01%20at%2010.30.16%20AM.png)

### Task 3 -- Being a Security Analyst (Hands-On Lab)

Launched the interactive Junior SOC Analyst Web App. The SIEM dashboard showed 5 alerts:

| Time | Severity | Message |
|------|----------|---------|
| Jun 1st 2026 at 09:22 | Critical | Successful SSH login from suspicious IP 221.181.185.159 |
| Jun 1st 2026 at 09:18 | Critical | Unauthorized login attempts from IP 221.181.185.159 to port 22 |
| Jun 1st 2026 at 08:32 | Low | User John Doe logged into LPT-JDOE after 3 failed attempts |
| Jun 1st 2026 at 07:22 | Medium | Multiple failed login attempts from IT Automation service account |
| Jun 1st 2026 at 07:12 | Low | Logon Error: password of "IT Automation" has expired |

Two Critical alerts from the same IP stood out immediately -- an SSH brute force followed by a successful login. This was the priority.

![SIEM dashboard showing critical alerts from IP 221.181.185.159](Screen%20Shot%202026-06-01%20at%2010.32.25%20AM.png)

### Task 4 -- Investigate the Malicious IP

Switched to the IP Hunter tab and ran a reputation lookup on `221.181.185.159`. Results confirmed:

- **Status:** Malicious -- involved in 4 cyber attacks
- **ISP:** China Mobile Communications
- **Domain:** chinamobile.thm
- **Country:** China
- **Categories:** Port Scan, C2 Server, PlugX malware

![IP Hunter results confirming 221.181.185.159 as malicious](Screen%20Shot%202026-06-01%20at%2010.35.47%20AM.png)

### Task 5 -- Escalate the Alert

Navigated to the Escalation tab and escalated the confirmed malicious IP to Senior Analyst **Will Griffin** for deeper investigation while proceeding with containment.

### Task 6 -- Block the IP on the Firewall

Navigated to the Firewall tab and added a block rule for `221.181.185.159`. The rule was applied successfully and a congratulations popup appeared with the flag.

![Firewall block rule applied for 221.181.185.159 with flag revealed](Screen%20Shot%202026-06-01%20at%2010.38.13%20AM.png)

---

## Flag

```
THM{until-we-meet-again}
```

---

## Key Takeaways

- Critical alerts should always be triaged first -- two Critical alerts from the same IP in quick succession is a strong indicator of an active attack.
- Threat intelligence tools like IP Hunter (similar to AbuseIPDB and Cisco Talos) allow analysts to quickly confirm whether a source IP is malicious.
- SOC analysts do not work alone -- escalating to senior analysts and collaborating with the team is a core part of the job.
- Containment via firewall block is the immediate response to stop an active attack while deeper investigation continues.
