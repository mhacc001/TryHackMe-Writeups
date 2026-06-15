# Systems as Attack Vectors
**Platform:** TryHackMe  
**Path:** SOC Level 1 / Blue Team Introduction  
**Difficulty:** Easy  

---

## Objective

Learn how attackers exploit vulnerable and misconfigured systems, and how to protect them. This room covers system definitions, human-led attacks, software vulnerabilities, misconfigurations, supply chain attacks, and hands-on practice triaging real system incidents and building a remediation plan.

---

## Tools Used

- TryHackMe Security Dashboard (Systems at Risk + Remediation Plan labs)

---

## Methodology

### Task 1 -- Introduction

Continuing the SOC analyst journey, this room focuses on systems as attack vectors -- learning what systems are, why threat groups target them, and what a SOC analyst can do to protect them.

![Systems as Attack Vectors room introduction](Screen%20Shot%202026-06-15%20at%203.39.30%20PM.png)

### Task 2 -- Attacks on Systems

In most serious attacks, the first goal is to gain **access** to the target system. Nearly all attacks begin the same way. There are three main entry points:

**Human-Led Attacks** -- System users often start attacks themselves by inserting malicious USBs, downloading malware from pirated resources, or reusing weak passwords. 81% of breaches involve stolen or breached passwords.

**Vulnerabilities** -- Every piece of software can have security flaws. In 2024, over 40,000 software vulnerabilities were published and more than 300 were actively exploited. Each system type has a different attack value:

| Breached System | Attack Value |
|----------------|--------------|
| Personal laptop of a school student | Steal Steam profile and add PC to a botnet |
| Laptop of bank's senior IT administrator | Get access to internal banking systems |
| Mail server of a criminal law company | Dump all mailboxes and blackmail the victim |
| Server at the heart of an industrial network | Encrypt the whole network with ransomware |
| Government website management panel | Damage website content (defacement/activism) |

![Human-led attacks showing weak passwords and RubberDucky USB exploit](Screen%20Shot%202026-06-15%20at%203.39.47%20PM.png)

![Breached system attack value table and system definition](Screen%20Shot%202026-06-15%20at%203.40.52%20PM.png)

**Answers:**
- Can cyber attacks happen without victim intervention? **Yea**
- Can a breach of just a single system lead to disastrous consequences? **Yea**

![Task 2 answers confirmed](Screen%20Shot%202026-06-15%20at%203.41.04%20PM.png)

### Task 3 -- Software Vulnerabilities

Every piece of software has flaws, but some take years to be discovered. When attackers discover a vulnerability before anyone else, it is known as a **zero-day**. Once made public, a vulnerability is assigned a CVE number -- triggering a race between attackers developing exploits and defenders rushing to patch.

The answer to a CVE is always **a patch** -- an update supplied by the software vendor. While waiting for a patch on a zero-day, defenders can:
- Restrict access to the system to only trusted IPs
- Apply temporary measures provided by the vendor
- Block known attack patterns on IPS or WAF

![Software vulnerabilities CVE timeline showing EternalBlue, Follina, PrintNightmare](Screen%20Shot%202026-06-15%20at%203.45.01%20PM.png)

**Answers:**
- CVE for the critical SharePoint vulnerability dubbed "ToolShell": **CVE-2025-53770**
- How would you respond to a detected vulnerability on your system? **Patch**

![Task 3 answers -- CVE-2025-53770 and Patch confirmed correct](Screen%20Shot%202026-06-15%20at%203.44.32%20PM.png)

### Task 4 -- Misconfigurations

A misconfiguration is not a bug in software but a mistake in how the system was set up. Common examples include weak default passwords and unrestricted network access. Misconfigurations do not require a software update -- just a better setup.

Proactive responses to misconfigurations:
- **Penetration Testing** -- Hire ethical hackers who simulate attacks and report discovered flaws
- **Vulnerability Scans** -- Periodically run tools that detect default passwords or outdated software
- **Configuration Audits** -- Manually review systems to match best practices like CIS benchmarks

![Misconfigurations diagram showing database setup with weak password and unrestricted access](Screen%20Shot%202026-06-15%20at%203.48.31%20PM.png)

**Answers:**
- Can a system patch or software update fix misconfigurations? **Nay**
- Which activity involves an authorized cyber attack to detect misconfigurations? **Penetration Testing**

![Task 4 answers confirmed](Screen%20Shot%202026-06-15%20at%203.48.43%20PM.png)

### Task 5 -- Supply Chain

A supply chain attack happens when threat actors breach a trusted app or library and push malicious updates to all its users. Famous examples include SolarWinds and 3CX. Even TryHackMe fell victim to a supply chain attack in the Lottie Player animation library.

Supply chain attacks are hard to defend against since you cannot always control all software on laptops, servers, and web apps. SOC analysts must be ready to detect and respond to them.

**Mitigation measures for system protection:**

| Mitigation | Description |
|------------|-------------|
| Patch Management | Track and patch vulnerable systems to reduce exploitation risk |
| Training for IT | Well-informed IT teams are less likely to leave systems unprotected |
| Network Protection | Restrict access to trusted people or IP addresses |
| Antivirus Protection | Detect and stop many different attacks including data stealers and USB worms |

![Supply chain attack concept and mitigation flow diagram](Screen%20Shot%202026-06-15%20at%203.49.45%20PM.png)

**Answers:**
- Term for a security flaw that can be exploited to breach a system: **Vulnerability**
- Name of the attack when malware comes from a trusted app or library: **Supply Chain**

![Task 5 answers -- Vulnerability and Supply Chain confirmed correct](Screen%20Shot%202026-06-15%20at%203.44.32%20PM.png)

### Task 6 -- Protecting Systems (Lab)

Acted as a SOC analyst at TryHackMe with two tasks: triage **Systems at Risk** and prepare a **Remediation Plan**.

![TryHackMe Security Dashboard with Systems at Risk and Remediation Plan tasks](Screen%20Shot%202026-06-15%20at%203.50.10%20PM.png)

**Systems at Risk -- 4 Cases:**

**Case 1 -- HQ-MAIL-02 at Risk**
- Exchange mail server affected by CVE-2024-49040, internet-exposed
- Verdict: **Ask IT to apply a patch and update Exchange**

![HQ-MAIL-02 alert showing CVE-2024-49040 on Exchange server](Screen%20Shot%202026-06-15%20at%203.52.34%20PM.png)

**Case 2 -- Corporate Website at Risk**
- WordPress admin panel brute-forced, main page replaced with malware links and gambling ads
- Verdict: **Change the admin's password to a more secure one**

![Corporate website defacement alert from brute-forced WordPress admin](Screen%20Shot%202026-06-15%20at%203.52.50%20PM.png)

**Case 3 -- Threat Intelligence Alert**
- Neighbor company hit with ransomware starting from exploitation of old Cisco firewall
- Verdict: **Ensure all corporate firewalls are patched and do not have CVEs**

![Threat intelligence alert about Cisco firewall ransomware attack](Screen%20Shot%202026-06-15%20at%203.53.19%20PM.png)

**Case 4 -- LPT-01518 at Risk**
- Trusted 3D design application running malicious CMD commands after recent update
- Verdict: **It is a supply chain attack coming with the recent update**

![LPT-01518 alert showing 3D app running malicious CMD commands after update](Screen%20Shot%202026-06-15%20at%203.53.44%20PM.png)

**Systems at Risk flag:**

![Systems at Risk challenge completed with flag THM{best_systems_defender!}](Screen%20Shot%202026-06-15%20at%203.55.12%20PM.png)

**Remediation Plan Lab:**

Selected the best hardening measures to protect TryHackMe systems. Remediation Plan feedback:

1. **Patch Management Policy** -- An organized patch management is a big step towards reducing the risk of exploitation
2. **Security Training for IT** -- A well-informed IT team is less likely to leave systems unprotected
3. **Secure Password Policy** -- The only way to protect against brute-force attacks
4. **Antivirus Protection** -- A simple and effective response to common threats like data stealers or USB worms

![Remediation Plan feedback showing 4 approved policies](Screen%20Shot%202026-06-15%20at%203.55.06%20PM.png)

**Remediation Plan flag:**

![Remediation Plan challenge completed with flag THM{patch_or_reconfigure?}](Screen%20Shot%202026-06-15%20at%203.53.59%20PM.png)

---

## Flags

```
THM{best_systems_defender!}
THM{patch_or_reconfigure?}
```

---

## Key Takeaways

- Systems are attacked through three main vectors: human mistakes, software vulnerabilities, and misconfigurations -- each requiring a different defensive response.
- Every CVE has a patch as its answer. When a patch is unavailable, restrict access, apply vendor mitigations, and monitor closely.
- Misconfigurations don't need patches -- they need better setup. Penetration testing, vulnerability scans, and configuration audits are the proactive tools.
- Supply chain attacks are among the hardest to defend against since the malware arrives through trusted, legitimate software updates.
- A layered defense combining patch management, network protection, secure passwords, antivirus, and IT training significantly reduces the attack surface.
