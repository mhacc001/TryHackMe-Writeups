# Humans as Attack Vectors
**Platform:** TryHackMe  
**Path:** SOC Level 1 / Blue Team Introduction  
**Difficulty:** Easy  

---

## Objective

Understand why and how people are targeted in cyber attacks and how the SOC helps defend them. This room covers social engineering techniques, human attack vectors, and hands-on practice triaging real employee incidents and building a corporate security policy.

---

## Tools Used

- TryHackMe Security Dashboard (Employees at Risk + Security Policy labs)

---

## Methodology

### Task 1 -- Introduction

The SOC protects organizations not just from technical threats, but from attacks targeting the weakest link in cybersecurity: humans. This room explores how attackers exploit human psychology and what SOC analysts can do to respond.

### Task 2 -- Why Humans Are Targeted

Attackers target humans because of the **access** they can provide -- to websites, mailboxes, or databases. Key examples:

| Attack Example | Next Step of Attackers |
|----------------|------------------------|
| Breach Google account of HR manager | Steal and sell the entire employee database |
| Trick a wealthy person into running malware | Hijack a web banking session from their PC |
| Breach the IT administrator's VPN account | Access the heart of a big corporate network |
| Trick a government worker into sharing secrets | Use the information to simplify next attacks |

**Answers:**
- Weakest link in cyber security: **Humans**
- What attackers seek when targeting humans: **Access**

![Why humans are targeted -- attack examples and attacker next steps](Screen%20Shot%202026-06-15%20at%203.13.14%20PM.png)

### Task 3 -- Attacks on Humans

All attacks targeting humans share a common trait: **social engineering** -- manipulating victims by exploiting human psychology rather than technical flaws. To succeed, attacks are designed to be:

- **Trustworthy:** The attacker must appear legitimate
- **Emotional:** The attack must trigger urgency, fear, or curiosity

**Phishing Attacks** -- The most common form, with an estimated 3.4 billion malicious emails sent daily. Attackers send fake emails with malicious links or attachments impersonating trusted brands.

**Malware Downloads** -- Attackers use fake CAPTCHAs, malicious QR codes, and SEO poisoning to trick users into downloading malware disguised as legitimate software.

**Deepfakes** -- AI-generated video or audio used to impersonate colleagues or executives. In one documented case, a finance worker wired $25 million after a deepfake video call from someone appearing to be their boss.

**Impersonation** -- Attackers pretend to be IT support, colleagues, or partners to extract credentials or access. Many ransomware attacks start with a simple phone call.

![Phishing attack examples showing fake sender email and malicious URL](Screen%20Shot%202026-06-15%20at%203.13.24%20PM.png)

![Malware download techniques including fake Firefox update and fake CAPTCHA](Screen%20Shot%202026-06-15%20at%203.13.32%20PM.png)

**Answers:**
- Name of attack tactic that manipulates human psychology: **Social Engineering**
- Social engineering method about pretending to be someone else: **Impersonation**

![Task 3 answers -- Social Engineering and Impersonation](Screen%20Shot%202026-06-15%20at%203.14.38%20PM.png)

### Task 4 -- Protecting Humans (SOC Role + Lab)

Every organization faces constant attacks targeting employees. The SOC's role in responding varies -- some teams monitor alerts while others are deeply involved in employee protection through:

- Keeping tight connections with IT and HR teams
- Proposing security improvements and running company-wide trainings
- Answering hotline calls from employees suspecting an attack

**Lab: TryHackMe Security Dashboard**

Acted as a SOC analyst at TryHackMe with two tasks: investigate **Employees at Risk** and update the **Security Policy**.

![TryHackMe Security Dashboard showing pending tasks](Screen%20Shot%202026-06-15%20at%203.19.14%20PM.png)

**Employees at Risk -- 4 Cases:**

**Case 1 -- Suspicious Email Attachment**
- Email from `noreply@stripe-payments.xyz` to Mark Phillips (Finance Director)
- Fake Stripe invoice with a password-protected `.rar` attachment
- Verdict: **Block the email and start the analysis -- phishing attempt**

![Suspicious email attachment alert from fake Stripe domain](Screen%20Shot%202026-06-15%20at%203.16.48%20PM.png)

**Case 2 -- Anomalous Login Location**
- User: Rose Lewis, HR Assistant
- Login to Microsoft 365 from London, UK (typical: Oxford, UK)
- Visited suspicious URLs before login including a fake Microsoft 365 domain
- Verdict: **Disable the account until more confident in verdict**

![Anomalous login location alert for Rose Lewis](Screen%20Shot%202026-06-15%20at%203.17.14%20PM.png)

**Case 3 -- Malware Download (Lucas Martinez)**
- New software engineer downloaded `Setup.exe` from `best-freeapps-2025.top`
- Antivirus blocked it 6 times
- Verdict: **Quarantine the Setup.exe and instruct Lucas to use the official 7-Zip installer**

![Chat message from Lucas Martinez about blocked Setup.exe](Screen%20Shot%202026-06-15%20at%203.18.22%20PM.png)

**Employees at Risk flag:**

![Employees at Risk challenge completed with flag](Screen%20Shot%202026-06-15%20at%203.18.31%20PM.png)

**Security Policy Lab:**

Reviewed and selected security policies to protect TryHackMe from human-targeted attacks. Policy feedback received:

1. **Access Management Policy** -- Makes it harder for deepfakes to trick IT support
2. **Security Awareness Program** -- Educating employees is always a great idea
3. **Antivirus Solution** -- Strong response to malicious phishing attachments and malware downloads
4. **Anti-Phishing Solution** -- Excellent response since most threats come through email

![Security Policy feedback showing 4 approved policies](Screen%20Shot%202026-06-15%20at%203.23.14%20PM.png)

**Security Policy flag:**

![Security Policy challenge completed with flag](Screen%20Shot%202026-06-15%20at%203.23.20%20PM.png)

---

## Flags

```
THM{anyone_else_at_risk?}
THM{human_protection_expert!}
```

---

## Key Takeaways

- Humans are the weakest link in cybersecurity -- attackers exploit psychology, not just technology.
- Social engineering attacks succeed by appearing trustworthy and triggering emotional responses like urgency or fear.
- SOC analysts must be prepared to triage human-targeted incidents including phishing emails, anomalous logins, and malware downloads.
- Protecting employees requires both technical controls (antivirus, anti-phishing) and human controls (security awareness training, access management policies).
- When in doubt, disable the account first and investigate -- it is easier to re-enable access than to recover from a breach.
