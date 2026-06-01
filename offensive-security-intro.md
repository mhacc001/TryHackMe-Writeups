Room: Offensive Security Intro
Platform: TryHackMe
Category: Pre-Security
Date: May 31, 2026

Objective
Simulate an ethical hacker attacking a fictional banking application to identify and exploit security vulnerabilities.

Tools Used

dirb (directory enumeration)


Methodology
Step 1 -- Reconnaissance
Identified the target application FakeBank running at http://fakebank.thm. Observed the application had a bank account number (8881) and a negative balance of -$1,232.32.
Step 2 -- Directory Enumeration
Ran the following command to discover hidden pages on the web application:
bashdirb http://fakebank.thm
Output revealed two hidden URLs:

http://fakebank.thm/images (CODE:301)
http://fakebank.thm/bank-transfer (CODE:200)

Step 3 -- Accessing the Hidden Admin Panel
Navigated to http://fakebank.thm/bank-transfer and discovered an unauthenticated admin panel that allowed transferring money to any account with no login or authorization required.
Step 4 -- Exploitation
Used the exposed admin panel to deposit $2000 into account 8881. The application returned the flag confirming successful exploitation.
Flag: BANK-HACKED

Vulnerability Identified
Security Misconfiguration -- OWASP Top 10 A05
An administrative bank transfer panel was publicly accessible with no authentication or authorization controls. Any user who discovered the URL could perform privileged financial transactions without logging in.

Remediation Recommendations

Implement authentication requirements on all admin and sensitive pages
Apply role-based access control to restrict financial transaction endpoints
Conduct regular directory enumeration audits to identify exposed endpoints
Remove or restrict access to sensitive pages that should not be publicly accessible


Key Takeaway
Hidden pages are not secure pages. Directory enumeration tools like dirb can quickly expose sensitive endpoints that developers assume are secret. Security through obscurity is not a valid control.
