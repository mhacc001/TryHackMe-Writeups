# Invite Only

## Overview

This room simulates a real SOC investigation at a fictional Managed Server Provider, TrySecureMe. Acting as an L1 analyst supporting an L3 investigation, the task is to take two flagged indicators (a suspicious IP and a SHA256 hash) from an escalated alert and turn them into usable, actionable threat intelligence using a threat intelligence platform (TryDetectThis2.0, a VirusTotal-backed tool) and open-source research.

## Task 1 - Invite Only

Investigated two flagged indicators escalated by an L1 analyst:

- Flagged IP: 101.99.76.120
- Flagged SHA256 hash: 5d0509f68a9b7c415a726be75a078180e3f02e59866f193b0a99eee8e39c874f

Used TryDetectThis2.0 to pivot from the hash to its file identity, type, execution parents, and dropped files, then researched the second execution-parent hash to trace the full dropped-file chain. Investigated the flagged IP through VirusTotal Community Comments to identify the malware family, then used Google to locate the original threat research report describing this campaign, cross-referencing it to answer the remaining questions about the attackers' tooling, phishing technique, and delivery platform.

![Task 1 Answers](Screen%20Shot%202026-07-29%20at%2011.27.32%20PM.png)

**Findings:**

- Name of the file identified with the flagged SHA256 hash: syshelpers.exe
- File type associated with the flagged SHA256 hash: Win32 EXE
- Execution parents of the flagged hash (chronologically): 361GJX7J, installer.exe
- Name of the file being dropped: Aclient.exe
- Four malicious dropped files from the second execution-parent hash (installer.exe), in order: searchhost.exe, syshelpers.exe, nat.vbs, runsys.vbs
- Malware family linking the files related to the flagged IP: AsyncRAT
- Title of the original report: From Trust to Threat: Hijacked Discord Invites Used for Multi-Stage Malware Delivery (Check Point Research)
- Tool used to steal cookies from the Google Chrome browser: ChromeKatz
- Phishing technique used by the attackers: ClickFix
- Platform used to redirect users to malicious servers: Discord

## Key Takeaways

- A single hash rarely tells the whole story on its own. Pivoting through Execution Parents and Dropped Files in a platform like VirusTotal is what turns one isolated indicator into a full, multi-stage infection chain (installer.exe leading to syshelpers.exe leading to Aclient.exe and beyond).
- Community context (VirusTotal comments, malware family tags) is often the fastest path from a raw hash to a named threat actor's campaign, and cross-referencing that context against the original public research report is what validates it rather than taking a single comment at face value.
- This investigation traced back to a real Check Point Research campaign (hijacked Discord invite links redirecting victims through a ClickFix phishing page to a multi-stage AsyncRAT and Skuld Stealer delivery chain), which is a good reminder that TryHackMe rooms like this one are frequently modeled directly on live, documented threat campaigns rather than fabricated scenarios.
- ClickFix as a phishing technique (presenting a fake "broken" verification step that tricks a user into manually pasting and running a malicious PowerShell command) is notable because it deliberately avoids the common red flag of asking a user to download and run a file, making it more likely to bypass both user suspicion and some automated detections.
- Attackers increasingly rely on trusted, legitimate platforms (Discord, GitHub, Bitbucket, Pastebin) at every stage of a delivery chain specifically because it blends malicious traffic in with normal, expected activity, which is exactly why indicator and infrastructure enrichment (not just file-based detection) is such a critical SOC skill.
