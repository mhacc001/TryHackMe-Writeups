# Summit — TryHackMe SOC Level 1

Room: Cyber Defence Frameworks module
Path: SOC Level 1

## Overview

Summit is a purple-team simulation built on PicoSecure. A penetration tester (Sphinx) repeatedly executes malware samples against a simulated workstation, and each time a detection rule is created, the malware is recompiled to evade it. The room follows the Pyramid of Pain in practice: each successive sample forces a move up the pyramid, from a trivial indicator to a much harder one to change.

Detection escalated across the six samples using PicoSecure's tools:

- **Manage Hashes** — blocking a static file hash (the easiest indicator for an attacker to change)
- **Firewall Manager** — blocking a malicious IP address once the malware began reaching out over the network
- **DNS Filter** — blocking a malicious domain once the attacker moved off a raw IP
- **Sigma Rule Builder** — writing behavior-based detection rules (registry changes, file paths, process activity) once static indicators alone were no longer enough

Each successful detection triggered a follow-up email from Sphinx in the Mail section, containing the next malware sample and a flag confirming the detection worked.

## Flags

| Sample | Detection Method | Flag |
|---|---|---|
| sample1.exe | Hash blocklist (SHA256) | `THM{f3cbf08151a11a6a331db9c6cf5f4fe4}` |
| sample2.exe | Firewall rule on malicious IP | `THM{2ff48a3421a938b388418be273f4806d}` |
| sample3.exe | DNS filter on malicious domain | `THM{4eca9e2f61a19ecd5df34c788e7dce16}` |
| sample4.exe | Sigma rule on registry/behavior artifact | `THM{c956f455fc076aea829799c0876ee399}` |
| sample5.exe | Sigma rule on file/process artifact | `THM{46b21c4410e47dc5729ceadef0fc722e}` |
| Final flag from Sphinx | Room completion | `THM{c8951b2ad24bbcbac60c16cf2c83d92c}` |

![Summit final answers](Screen%20Shot%202026-07-18%20at%207.00.02%20PM.png)

## Key Takeaways

- The Pyramid of Pain isn't just theory: this room makes the escalating cost of detection concrete. Hashes are trivial for an attacker to change, IPs and domains take more effort, and behavioral indicators (TTPs, registry artifacts) are by far the hardest for an attacker to evade.
- Each detection method maps to a different tool in a typical SOC stack: hash blocklists, firewall rules, DNS filtering, and Sigma rules for behavior-based detection.
- As static indicators get burned, the response has to move toward detecting what the malware does rather than what it is, which is the entire point of climbing the pyramid.
