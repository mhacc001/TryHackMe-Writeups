# Defensive Security Intro
**Platform:** TryHackMe  
**Path:** SOC Level 1 / Pre-Security  
**Difficulty:** Easy  

---

## Objective

Step into the role of a SOC analyst and experience defensive security firsthand. This room simulates a real incident -- detecting suspicious activity, identifying the attack, and containing the threat by blocking the attacker's IP on the firewall.

---

## Tools Used

- Security Monitoring Dashboard (alert triage)
- Attack Investigation Panel (event details)
- Firewall Manager (IP blocking / containment)

---

## Methodology

### Task 1 -- Detect Suspicious Activity

Opened the monitoring dashboard and reviewed recent alerts. One alert stood out immediately:

**Web Discovery Attack** -- Automated directory enumeration detected on admin endpoints  
- Source IP: `32.122.195.63`  
- Status: Unassigned  

Other alerts on the dashboard included Suspicious Port Scanning (High, assigned to John Smith), Unusual Database Query Pattern (Medium, assigned to Sarah Johnson), and a Critical SQL Injection Attack on the payment form.

![Monitoring dashboard showing Web Discovery Attack alert from 32.122.195.63](Screen_Shot_2026-05-31_at_9_23_02_PM.png)

### Task 2 -- Identify the Attack

Clicked into the Web Discovery Attack alert to investigate further. The attack detail panel revealed:

- **Event ID:** SEC-000001
- **Source IP:** `32.122.195.63`
- **Attack Started:** 14/07/2025 at 10:21:39
- **Duration:** 16 minutes 32 seconds
- **URLs Attempted:** 31
- **Blocked Requests:** 10
- **Latest URL attempted:** `https://fakebank.com/admin` (404)

The attacker was running automated directory enumeration against admin endpoints -- the same technique used in Offensive Security Intro with `dirb`.

![Web Discovery Attack detail showing attack summary and URL discovery attempts](Screen_Shot_2026-05-31_at_9_24_19_PM.png)

### Task 3 -- Stop the Attack

Navigated to the Firewall Manager to contain the threat. Added a block rule for the attacker's IP:

- **Source IP:** `32.122.195.63`
- **Action:** BLOCK
- Clicked **Apply**

The firewall rule was applied successfully, stopping further requests from the attacker.

![Firewall Manager with block rule applied for IP 32.122.195.63](Screen_Shot_2026-05-31_at_9_24_19_PM.png)

---

## Flag

```
THM{FAKEBANK-SECURED}
```

---

## Key Takeaways

- Defensive security analysts monitor dashboards for suspicious activity and must prioritize alerts by severity and context.
- Directory enumeration attacks leave clear footprints -- high volumes of requests to sequential or common paths in a short timeframe.
- Containment is the immediate priority once an attacker is identified -- blocking their IP stops the attack while deeper investigation continues.
- Every alert on a SOC dashboard tells a story; reading the event details carefully reveals the attacker's intent and method.
