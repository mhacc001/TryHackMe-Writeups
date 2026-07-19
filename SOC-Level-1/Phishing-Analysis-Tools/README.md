# Phishing Analysis Tools — TryHackMe SOC Level 1

Room: Phishing Analysis module (third room)
Path: SOC Level 1

## Overview

This room builds on the manual header and body analysis covered in the first two rooms of the module by introducing tools that automate and speed up phishing investigations: mail header analyzers, IP/URL reputation lookups, hashing for attachments, and PhishTool as an all-in-one investigation platform. The room closes with three real-world phishing cases pulled into a lab environment to apply everything hands-on.

## Key Artifacts to Collect

Before reaching for any tooling, an analyst needs to know what to collect. From the header: sender address, sender IP, subject line, recipient (To/CC/BCC), Reply-To address, and timestamp. From the body: URLs and hyperlinks (expanded if shortened), attachment names, and attachment hashes.

## Header, IP, and URL Analysis Tools

Tools like Google's Messageheader and Message Header Analyzer (MHA) parse a full raw header and surface routing details, SPF/DKIM/DMARC results, and misconfigurations without manual parsing. IPinfo, URLScan.io, and Talos IP & Domain Reputation Center round out the toolkit for checking whether an IP or URL is tied to known malicious infrastructure, with URLScan in particular allowing a URL to be safely "visited" via simulated browsing rather than a real one.

| Question | Answer |
|---|---|
| According to the Messageheader analysis shown in this task, what is the SPF result for the email? | `Pass` |

![Talos reputation lookup and Messageheader SPF result](Screen%20Shot%202026-07-18%20at%209.01.05%20PM.png)

## Email Body and Attachment Analysis

Links can be extracted manually or with tools like a URL extractor or CyberChef. Attachments should only ever be opened in a sandboxed or lab environment, and hashing them (with a tool like `sha256sum` on Linux) allows for safe reputation lookups on sites like Talos or VirusTotal without having to execute the file.

| Question | Answer |
|---|---|
| What command can you use in a Linux environment to obtain the SHA256 hash value of an attachment? | `sha256sum` |

![VirusTotal detection results](Screen%20Shot%202026-07-18%20at%209.01.37%20PM.png)

## PhishTool

PhishTool centralizes phishing investigation into a single platform: rendered HTML, raw source, authentication results, transmission path, and attachment analysis are all available in one view, with built-in VirusTotal integration. Cases can be formally resolved and documented with flagged artifacts and investigation notes, mirroring real SOC case closure.

| Question | Answer |
|---|---|
| According to the VirusTotal analysis from above, which vendor categorized the URLs as phishing? | `SafeToOpen` |

![PhishTool case resolution](Screen%20Shot%202026-07-18%20at%209.03.13%20PM.png)

## Lab Case 1: Phish3Case1.eml (Netflix Impersonation)

Analyzed a phishing email impersonating Netflix using Thunderbird's message source view.

| Question | Answer |
|---|---|
| What reputable brand is this email tailored to impersonate? | `Netflix` |
| Based on the email headers, who is the intended recipient of this message? | `redacted@yahoo.com` |
| What is the Received: from IP address? | `10.197.37.234` |
| What domain of interest appears in the Return-Path field? | `etekno.xyz` |
| What is the shortened URL behind the UPDATE ACCOUNT NOW button? | `https://t.co/yuxfZm8KPg?amp=1` |

![Netflix impersonation case analysis](Screen%20Shot%202026-07-18%20at%209.08.51%20PM.png)

## Lab Case 2: Update Payment Details (PDF Attachment)

Investigated a suspected phishing email with a malicious PDF attachment using ANY.RUN sandbox analysis.

| Question | Answer |
|---|---|
| How does ANY.RUN classify this suspected phishing email? | `Suspicious activity` |
| What is the name of the PDF attachment? | `Payment-updateid.pdf` |
| What is the SHA256 hash of the PDF file? | `CC6F1A04B10BCB168AEEC8D870B97BD7C20FC161E8310B5BCE1AF8ED420E2C24` |
| Which IP associated with AcroRd32.exe is flagged as malicious? | `2.16.107.24` |
| Which Windows process is classed as Potentially Bad Traffic? | `svchost.exe` |

![Payment Details PDF case analysis](Screen%20Shot%202026-07-18%20at%209.12.42%20PM.png)

## Lab Case 3: Excel Executable (CVE Exploit)

Investigated a phishing email with a malicious .xlsx attachment exploiting a known Office vulnerability.

| Question | Answer |
|---|---|
| How does ANY.RUN classify the .xlsx attachment? | `Malicious activity` |
| What is the file name of the Excel attachment? | `CBJ200620039539.xlsx` |
| What is the SHA256 hash value? | `5f94a66e0ce78d17afc2dd27fc17b44b3ffc13ac5f42d3ad6a5dcfb36715f3eb` |
| What IP is associated with the malicious domain biz9holdings.com? | `204.11.56.48` |
| Which other domain is classified as malicious? | `findresults.site` |
| What vulnerability does this attachment attempt to exploit? | `CVE-2017-11882` |

![Excel executable case analysis](Screen%20Shot%202026-07-18%20at%209.17.57%20PM.png)

## Key Takeaways

- Automated header analyzers (Messageheader, MHA) turn a wall of raw header text into structured, readable authentication results, saving the manual parsing effort covered in the fundamentals room.
- Hashing is the safe way to interact with a suspicious attachment: it enables reputation lookups (Talos, VirusTotal) without ever executing the file locally.
- Sandboxes like ANY.RUN reveal the full behavioral chain of a malicious attachment, from the dropped payload's process name to the specific IPs and domains it reaches out to, which is far more actionable than static analysis alone.
- CVE-2017-11882, an old Microsoft Office Equation Editor memory corruption bug, still shows up in phishing attachments years after being patched. This is a good reminder that legacy vulnerabilities remain a real, ongoing risk when patching lags.
- PhishTool's value is consolidation: instead of jumping between five separate tools, a single platform brings rendered content, raw source, authentication results, and VirusTotal reputation together for faster triage and cleaner case documentation.
