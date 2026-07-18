# Cyber Kill Chain
**Platform:** TryHackMe
**Path:** SOC Level 1 / Cyber Defence Frameworks
**Difficulty:** Medium

---

## Objective

Learn the Lockheed Martin Cyber Kill Chain framework, a military-derived model that breaks an intrusion into seven phases: Reconnaissance, Weaponization, Delivery, Exploitation, Installation, Command and Control, and Actions on Objectives. Understanding each phase helps a defender recognize intrusion attempts and understand an intruder's goals at each stage. The room uses a fictional attacker, "Megatron," to walk through each phase from the adversary's perspective.

---

## Task 2: Reconnaissance

Covered OSINT (Open-Source Intelligence) and how attackers gather information passively or actively before an attack, including email harvesting for phishing purposes.

**Web-based OSINT tool that indexes common open-source intelligence tools and resources:**
```
OSINT Framework
```

**Term for the process of collecting email addresses from public, paid, or free sources:**
```
Email harvesting
```

![Task 2 correct answers](Screen%20Shot%202026-07-18%20at%204.02.02%20PM.png)

---

## Task 3: Weaponization

Covered how an attacker turns raw recon data into an actionable attack tool by pairing malware with an exploit to build a payload, including buying pre-built payloads on the dark web versus custom-writing malware.

**Term for automated scripts embedded in Microsoft Office documents that can be exploited by attackers:**
```
Macro
```

![Task 3 correct answer](Screen%20Shot%202026-07-18%20at%204.03.35%20PM.png)

---

## Task 4: Delivery

Covered the methods used to transmit a payload to a target: phishing email, USB drops, and watering hole attacks.

**Attack targeting a specific group by compromising a website they frequently visit:**
```
Watering hole attack
```

![Task 4 correct answer](Screen%20Shot%202026-07-18%20at%204.04.50%20PM.png)

---

## Task 5: Exploitation

Covered the moment the attacker's code executes on the target, including malicious macro execution, zero-day exploits, and known CVEs, along with signs of exploitation to watch for (unexpected process spawns, registry changes, suspicious command-line arguments).

**Term for an attack that exploits a vulnerability unknown to software vendors:**
```
Zero-day
```

![Task 5 correct answer](Screen%20Shot%202026-07-18%20at%204.06.14%20PM.png)

---

## Task 6: Installation

Covered how an attacker establishes persistence after initial access: web shells, Meterpreter backdoors, creating or modifying Windows services (MITRE T1543.003), and adding entries to Registry run keys or the Startup folder. Also covered timestomping as an anti-forensics technique.

**Technique used to modify file time attributes to hide new or changed files:**
```
Timestomping
```

**Malicious script planted on a web server to maintain remote access to a compromised system:**
```
Web shell
```

![Task 6 correct answers](Screen%20Shot%202026-07-18%20at%204.09.19%20PM.png)

---

## Task 7: Command and Control

Covered how the attacker opens a C2 (Command and Control) channel to remotely control the compromised host, also known as C2 beaconing. Covered common C2 channels: HTTP/HTTPS (blends with legitimate traffic) and DNS Tunneling.

**C2 communication where the victim makes regular DNS requests to an attacker-controlled DNS server and domain:**
```
DNS Tunneling
```

![Task 7 correct answer](Screen%20Shot%202026-07-18%20at%204.11.40%20PM.png)

---

## Task 8: Actions on Objectives

Covered the final phase, where the attacker achieves their original goals: credential collection, privilege escalation, internal reconnaissance, lateral movement, data exfiltration, and destroying backups/shadow copies to hinder recovery.

**Microsoft Windows technology that creates backup copies or snapshots of files/volumes, even while in use:**
```
Shadow Copy
```

![Task 8 correct answer](Screen%20Shot%202026-07-18%20at%204.12.41%20PM.png)

---

## Task 9: Practice Analysis - The Target Breach (2013)

Applied the full Cyber Kill Chain to the real-world 2013 Target data breach, one of the largest data breaches in history (~40 million credit/debit card accounts impacted, $18.5 million multistate settlement). Deployed the attached static site and mapped 6 real techniques used in the breach to their correct Kill Chain phase (Reconnaissance was not applicable to this scenario):

| Kill Chain Phase | Technique |
|---|---|
| Weaponization | PowerShell |
| Delivery | Spearphishing Attachment |
| Exploitation | Exploit Public-Facing Application |
| Installation | Dynamic Linker Hijacking |
| Command & Control | Fallback Channels |
| Actions on Objectives | Data From Local System |

![Kill Chain diagram completed](Screen%20Shot%202026-07-18%20at%204.18.21%20PM.png)

**Flag:**
```
THM{7HR347_1N73L_12_4w35om3}
```

![Task 9 flag confirmed](Screen%20Shot%202026-07-18%20at%204.18.36%20PM.png)

---

## Key Takeaways

- The Cyber Kill Chain models an intrusion as seven sequential phases. An adversary needs to succeed at every phase to reach their objective, which means a defender only needs to break one link to stop the chain.
- Reconnaissance is often invisible to defenders since passive recon (WHOIS, social media scraping, breach data review) leaves no trace on the target's systems.
- Delivery, Exploitation, and Installation are where most detection opportunities exist: phishing indicators, unexpected process spawns, registry/service changes, and persistence mechanisms like run keys or DLL/dynamic linker hijacking.
- C2 traffic increasingly hides in legitimate-looking channels (HTTPS on 443, DNS tunneling) specifically to blend in with normal business traffic and evade firewalls.
- Real breaches, like the 2013 Target breach, map cleanly onto this framework: a third-party vendor compromise (Delivery via spearphishing), lateral movement into POS systems (Exploitation and Installation), and exfiltration of cardholder data (Actions on Objectives) via C2 channels resilient enough to survive partial blocking (Fallback Channels).
- Practical takeaway for SOC work: the earlier in the kill chain an analyst detects and disrupts an intrusion, the less damage and cost is incurred, reinforcing why proactive threat hunting and early-stage detection (recon and delivery) are high-value defensive investments.
