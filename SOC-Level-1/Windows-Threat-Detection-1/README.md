# Windows Threat Detection 1

## Overview

This room builds on Windows Logging for SOC by walking through common Initial Access techniques (T1133/T1190 via exposed services, T1566 phishing, T1091 removable media) and how to detect each one using native Windows Security and Sysmon logs. The room covers three realistic attack chains: an exposed RDP brute force, a set of phishing attachment cases (binary, LNK, and double-extension), and an infected USB delivery scenario.

## Task 2 - Initial Access

Reviewed the two broad categories of Initial Access: those relying on an exposed service (T1133 External Remote Services, T1190 Exploit Public-Facing Application) and those relying on human interaction (T1566 Phishing, T1091 Removable Media). Noted that major ransomware groups like Medusa and Akira have used all of these techniques across their campaigns, reinforcing that a SOC analyst needs to be ready to detect any of them.

**Findings:**

- MITRE technique ID for Initial Access via a vulnerable mail server: T1190
- Initial Access method relying on a user opening a malicious email attachment: Phishing

## Task 3 - Initial Access via RDP

Covered the risks of exposing RDP directly to the Internet, often called the "Ransomware Deployment Protocol" due to how frequently an RDP breach leads directly to ransomware. Walked through detecting a full RDP breach chain in Security logs: brute force (4625, logon types 3/10, external source IPs), successful Initial Access (4624), and follow-on malicious activity (correlating Logon ID between Security and Sysmon logs). Investigated `RDP-Security.evtx` for a scenario where an IT admin exposed RDP with weak credentials (Administrator:Summer2025).

![Task 3 Answers](Screen%20Shot%202026-07-24%20at%2010.57.22%20PM.png)

**Findings:**

- User most actively brute-forced by botnets: Administrator
- IP that managed to breach the host via RDP (Logon Type 10): 203.205.34.107
- Real Workstation Name (hostname) of the threat actor: DESKTOP-QNBC4UU

## Task 4 - Initial Access via Phishing

Covered two phishing techniques: malicious binary attachments (abusing less-common executable extensions like .com/.scr/.cpl and Windows' default hiding of known file extensions to disguise files like "invoice.pdf.exe") and LNK attachments (shortcuts that point to a PowerShell payload instead of the expected file, often used to avoid AV detection). Investigated three phishing cases in `Phishing Case 1-3`, covering a disguised .com binary, an LNK downloading a RemcosRAT-style payload, and a double-extension file.

![Task 4 Answers](Screen%20Shot%202026-07-24%20at%2010.58.54%20PM.png)

**Findings:**

- Flag from running www.skype.com (Phishing Case 1): THM{misleading_extension}
- URL the malicious LNK downloads the next stage malware from (Phishing Case 2): http://wp16.hqywlqpa.thm:8000/cgi-bin/f
- Double-extension file name (Phishing Case 3): best-cat.jpg.exe

## Task 5 - Detecting Malicious Download

Covered the Sysmon event chain for a typical double-extension phishing attachment: browser launch (Event ID 1), archive download to Downloads (Event ID 11), unarchiving to another folder (Event ID 11), and execution of the disguised file (Event ID 1). Also covered why LNK attachments leave minimal execution trace, since Explorer reads the LNK's Target field and makes it appear as if explorer.exe launched PowerShell directly, requiring analysts to look for the preceding file creation event to confirm LNK-based phishing. Investigated `Phishing-Sysmon.evtx` for Phishing Case 3 to trace the full download-to-execution-to-C2 chain.

![Task 5 Answers](Screen%20Shot%202026-07-24%20at%2011.00.34%20PM.png)

**Findings:**

- File downloaded via the web browser: C:\Users\Administrator\Downloads\top-cats.zip
- Folder where the user unarchived the suspicious file: C:\Users\Administrator\Pictures
- Process ID of the launched phishing malware: 5484
- Malicious domain the malware tried to connect to: rjj.store

## Task 6 - Initial Access via USB

Covered the continued relevance of USB-based Initial Access (Camaro Dragon, Raspberry Robin), including delivery scenarios like a "gift" USB mailed to an employee or an infected print service passing malware back onto a customer's flash drive. Covered common USB malware behaviors: hiding legitimate files behind a malicious "RECOVERY.lnk", disguising a binary as a folder icon, or creating double-extension copies of existing files. Investigated `USB-Sysmon.evtx` to trace a full USB infection and propagation chain.

![Task 6 Answers](Screen%20Shot%202026-07-24%20at%2011.02.04%20PM.png)

**Findings:**

- USB file launched by the user: E:\Open Sandisk 4GB USB.exe
- Suspicious file the malware dropped to disk: C:\Users\Public\Documents\winupdate.exe
- Other USB the malware propagated to: F:

## Key Takeaways

- Initial Access almost always falls into one of two buckets: an exposed service being directly attacked (RDP, public-facing apps) or a human being tricked into running something (phishing, USB). Recognizing which bucket an incident falls into immediately narrows down which log sources and Event IDs are worth checking first.
- RDP brute force is one of the noisiest, most detectable attack patterns in Windows logging: hundreds of 4625 events followed by a single 4624 with a mismatched or suspicious source IP and hostname is a pattern that's hard to miss once you know what to filter for.
- Both phishing and USB-based Initial Access rely on tricking a user into launching something via explorer.exe, which makes them look deceptively similar in Sysmon logs. The differentiator is tracing backward to the file creation event, whether that's a download to the Downloads folder or execution from an external drive letter, to establish how the file actually got there.
- LNK-based attacks are especially sneaky because Explorer reading a shortcut's Target field makes it look like explorer.exe launched PowerShell directly, hiding the LNK itself from the process chain. Catching this requires actively looking for the preceding file creation event rather than trusting the parent-child process relationship alone.
- Windows' default behavior of hiding known file extensions is a small design choice with outsized security consequences, since it's the exact mechanism that makes disguises like "invoice.pdf.exe" or "best-cat.jpg.exe" convincing to an untrained user.
