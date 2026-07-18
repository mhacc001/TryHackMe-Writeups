# Pyramid of Pain
**Platform:** TryHackMe
**Path:** SOC Level 1 / Cyber Defence Frameworks
**Difficulty:** Easy

---

## Objective

Learn what the Pyramid of Pain is and how it ranks indicators of compromise by how much difficulty they cause an adversary when detected and blocked. The pyramid runs from trivial to change (hash values) up to the hardest to change (TTPs): Hash Values, IP Addresses, Domain Names, Host Artifacts, Network Artifacts, Tools, and TTPs.

---

## Task 2: Hash Values

Analyzed a VirusTotal-style report for the hash `b8ef959a9176aef07fdca8705254a163b50b49a17217a4ff0107487f59d4a35d`. The sample was flagged by 37 security vendors as a Trojan (Valyria/X97m family, associated with Dridex).

**Filename of the sample:**
```
Sales_Receipt 5606.xls
```

![VirusTotal detection results](Screen_Shot_2026-07-18_at_3_31_34_PM.png)

![Task 2 correct answer](Screen_Shot_2026-07-18_at_3_32_21_PM.png)

Also covered how trivially an attacker can change a file's hash by appending a single string to the file, demonstrated with `Get-FileHash` before and after an `echo` append.

---

## Task 3: IP Addresses

Reviewed an ANY.RUN sandbox report for a Sodinokibi/REvil ransomware sample (`some_malicious_file.bin.exe`, PID 1632). Checked the Network Activity > Connections tab to find the first outbound connection made by the malicious process.

**First IP address contacted:**
```
50.87.136.52
```

**First domain name contacted:**
```
craftingalegacy.com
```

![Task 3 correct answers](Screen_Shot_2026-07-18_at_3_35_03_PM.png)

Covered Fast Flux as a technique adversaries use to rotate IP addresses behind a single domain to evade IP-based blocking.

---

## Task 4: Domain Names

Continued with the same ANY.RUN report, this time in the DNS Requests tab.

**First suspicious domain request:**
```
craftingalegacy.com
```

**Term for an address used to access websites:**
```
Domain Name
```

**Attack type using Unicode characters to imitate a known domain:**
```
Punycode attack
```

**Redirected website for the shortened URL (tinyurl.com/bw7t8p4u):**
```
https://tryhackme.com/
```

![Task 4 correct answers](Screen_Shot_2026-07-18_at_3_38_15_PM.png)

Covered Punycode/IDN homograph attacks (example: `adıdas.de` resolving to `xn--addas-o4a.de`) and how to preview shortened URLs safely by appending `+` before visiting.

---

## Task 5: Host Artifacts

Reviewed an ANY.RUN report for an Emotet-delivered Word document (`CMO-100120 CDW-102220.doc`). Traced the process tree: `WINWORD.EXE` spawns `powershell.exe`, which drops `G_jugk.exe`, which in turn drops and executes `regidle.exe`.

**IP address contacted by regidle.exe (US, port 8080):**
```
96.126.101.6
```

**Name of the dropped malicious executable:**
```
G_jugk.exe
```

**VirusTotal vendors flagging the host as malicious:**
```
9
```

![VirusTotal 9 vendors flagged malicious](Screen_Shot_2026-07-18_at_3_41_41_PM.png)

![Task 5 correct answers](Screen_Shot_2026-07-18_at_3_42_23_PM.png)

---

## Task 6: Network Artifacts

Looked at a TShark output showing repeated identical User-Agent strings across multiple HTTP POST requests in a PCAP, associated with the Emotet trojan.

**Network indicator that helped identify the malware:**
```
User-Agent
```

**POST requests visible in the PCAP screenshot:**
```
6
```

![Task 6 correct answers](Screen_Shot_2026-07-18_at_3_44_34_PM.png)

---

## Task 7: Tools

Covered how fuzzy hashing (via SSDeep) is used to detect similarity between files even when an attacker has made minor modifications, unlike traditional hashing where a single-bit change produces a completely different hash.

**Method used to determine similarity between files:**
```
Fuzzy Hashing
```

**Alternative name for fuzzy hashes:**
```
context triggered piecewise hashes
```

![Task 7 correct answers](Screen_Shot_2026-07-18_at_3_46_32_PM.png)

---

## Task 8: TTPs

Reached the apex of the pyramid. TTPs (Tactics, Techniques & Procedures) cover the full MITRE ATT&CK Matrix, from initial access through exfiltration.

**Techniques under the Exfiltration category in the ATT&CK Matrix:**
```
9
```

**Chimera's commercial remote access tool for C2 beacons and data exfiltration:**
```
Cobalt Strike
```

![Task 8 correct answers](Screen_Shot_2026-07-18_at_3_48_44_PM.png)

---

## Task 9: Practical - The Pyramid of Pain

Deployed the attached static site and matched each prompt to its correct tier of the pyramid:

| Prompt | Tier |
|---|---|
| The attacker has utilised these to accomplish their objective | Tools |
| The attacker's plans and objectives | TTPs |
| These signatures can be used to attribute payloads and artefacts to an actor | Hash Values |
| An attacker has purchased this and used it in a typo-squatting campaign | Domain Names |
| These addresses can be used to identify the infrastructure an attacker is using for their campaign | IP Addresses |
| These artefacts can present themselves as C2 traffic, for example | Network/Host Artifacts |

![Pyramid matching completed](Screen_Shot_2026-07-18_at_3_52_05_PM.png)

**Flag:**
```
THM{PYRAMIDS_COMPLETE}
```

![Task 9 flag confirmed](Screen_Shot_2026-07-18_at_3_52_18_PM.png)

---

## Key Takeaways

- The Pyramid of Pain ranks indicators of compromise by how much pain it causes an attacker to change them when defenders detect and respond to them, not by how hard the indicator is to find.
- Hash values and IP addresses sit at the bottom because attackers can change them trivially (a single byte change or a new VPS). Domain names take more effort since they require purchase and DNS configuration.
- Host and network artifacts (registry changes, User-Agent strings, dropped file paths) sit in the "Annoying" tier because detecting them forces an attacker to retool.
- Tools and TTPs sit at the top. Disrupting an attacker's tools or their underlying tactics forces them to either invest significant time and resources rebuilding their approach or abandon the target entirely.
- Practical skills reinforced: reading VirusTotal and ANY.RUN sandbox reports, tracing a malware process tree, identifying Fast Flux and Punycode attacks, using TShark to pull User-Agent strings from a PCAP, and understanding fuzzy hashing (SSDeep) versus traditional cryptographic hashing.
