Defensive Security Intro
Platform: TryHackMe
Category: Pre-Security
Date: May 31, 2026

Objective
Act as a SOC analyst investigating and responding to a live web discovery attack against a fictional banking application.

Tools Used

SOC monitoring dashboard
Firewall Manager
Alert triage and investigation interface


Methodology
Step 1 -- Detect Suspicious Activity
Opened the SOC monitoring dashboard and identified an active alert: Web Discovery Attack showing automated directory enumeration on admin endpoints.
Suspicious source IP identified: 32.122.195.63
Step 2 -- Identify the Attack
Investigated Event ID SEC-000001. Attack summary showed:

Attack started: 14/07/2025 10:21:39
Duration: 16 minutes 32 seconds
URLs attempted: 31
Blocked requests: 10

Reviewed the URL Discovery Attempts log and identified the latest URL the attacker attempted: https://fakebank.com/admin (404 response)
Step 3 -- Stop the Attack
Navigated to the Firewall Manager and added a block rule for the attacker's IP address 32.122.195.63. Applied the rule which immediately stopped the incoming traffic.
Flag: THM{FAKEBANK-SECURED}

Vulnerability Identified
Insufficient monitoring and delayed incident response -- the attack ran for over 16 minutes before containment action was taken.

Remediation Recommendations

Implement automated blocking rules that trigger on directory enumeration detection
Set up real-time alerting for HIGH and CRITICAL severity events
Establish faster SOC response SLAs for active attack scenarios
Regularly review and tune firewall rules to block known malicious IPs proactively


Key Takeaway
Defensive security requires continuous monitoring and fast response. Identifying the source IP, understanding the attack pattern, and implementing containment quickly are the core skills of a SOC analyst. Detection without response is not enough.
