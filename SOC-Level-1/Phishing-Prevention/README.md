# Phishing Prevention — TryHackMe SOC Level 1

Room: Phishing Analysis module (fourth room)
Path: SOC Level 1

## Overview

This room closes out the Phishing Analysis module by covering the authentication standards and defensive controls organizations use to prevent phishing before it reaches a user, and analyzing real SMTP traffic in Wireshark to see those controls in action. It wraps up with the technical and user-facing defenses (filtering, sandboxing, training) that round out a modern anti-phishing program.

## Sender Policy Framework (SPF)

SPF authenticates the sending mail server by publishing a DNS TXT record listing which IPs or domains are authorized to send mail on a domain's behalf. Verification results map to specific actions: Pass/Neutral/None accepts the email, SoftFail/PermError flags it as suspicious but still delivers it, and Fail/TempError rejects it outright.

| Question | Answer |
|---|---|
| Based on TryHackMe's SPF record, how many domains are authorized to send email on its behalf? | `3` |
| What is the intended action of an email that returns a SoftFail verification result? | `Flag` |

![SPF record and Messageheader softfail example](Screen%20Shot%202026-07-18%20at%209.22.45%20PM.png)

## DomainKeys Identified Mail (DKIM)

DKIM adds a digital signature to outgoing mail using a private key, which the receiving server verifies against a public key published in DNS. Unlike SPF, DKIM survives forwarding, making it a stronger authentication layer. A `permerror` result signals a permanent verification failure, often due to a missing or invalid key.

| Question | Answer |
|---|---|
| Based on the sample header, what is the reason for the permerror? | `no key for signature` |

![DKIM permerror sample header](Screen%20Shot%202026-07-18%20at%209.23.05%20PM.png)

## Domain-Based Message Authentication, Reporting, and Conformance (DMARC)

DMARC ties SPF and DKIM results together through alignment, checking that the domain in the visible From address matches what SPF and DKIM verified. Its policy tag (`p=`) tells the receiving server what to do on failure: none, quarantine, or reject.

| Question | Answer |
|---|---|
| Which DMARC policy provides the greatest protection by blocking emails that fail the DMARC check? | `p=reject` |

![DMARC Domain Checker result for microsoft.com](Screen%20Shot%202026-07-18%20at%209.23.38%20PM.png)

## Secure/Multipurpose Internet Mail Extensions (S/MIME)

S/MIME uses public key cryptography to provide two protections: a digital signature (authentication, non-repudiation, data integrity) and encryption (confidentiality). The sender signs with their private key and encrypts with the recipient's public key; the recipient reverses both steps to verify and read the message.

| Question | Answer |
|---|---|
| Which S/MIME component ensures that only the intended recipient can read the email contents? | `Encryption` |

![S/MIME public key cryptography example](Screen%20Shot%202026-07-18%20at%209.24.36%20PM.png)

## Analyzing SMTP Responses (Wireshark)

Using a provided PCAP (`traffic.pcap`), this task filtered SMTP traffic by response code to identify delivery outcomes, including rejections tied to Spamhaus blocklisting and messages blocked for security concerns.

| Question | Answer |
|---|---|
| Which Wireshark filter narrows results by SMTP response code? | `smtp.response.code` |
| How many packets contain response code 220 Service ready? | `19` |
| What response code did the server return for an email blocked by spamhaus.org? | `553` |
| What is the full Response code message? | `Requested action not taken: mailbox name not allowed (553)` |
| How many messages were blocked for response code 552 (security issues)? | `6` |

![SMTP response code analysis in Wireshark](Screen%20Shot%202026-07-18%20at%209.25.40%20PM.png)

## Inspecting Emails and Attachments (IMF)

Continuing with the same PCAP, this task used the Internet Message Format (IMF) dissector in Wireshark to dig into individual email contents, sender/recipient fields, attachments, and encoding, surfacing one attachment (`attachment.scr`) as a likely malicious payload.

| Question | Answer |
|---|---|
| How many SMTP packets are available for analysis? | `512` |
| What is the name of the attachment in packet 270? | `document.zip` |
| Which Host IP is not responding, per packet 270? | `212.253.25.152` |
| Which email client sent the message containing attachment.scr? | `Microsoft Outlook Express 6.00.2600.0000` |
| What encoding is used for this potentially malicious attachment? | `base64` |

![IMF analysis of SMTP attachments](Screen%20Shot%202026-07-18%20at%209.29.04%20PM.png)

## How Organizations Stop Phishing

Beyond authentication standards, organizations layer in technical controls (email filtering by reputation, secure email gateways, link rewriting, sandboxing) and user-facing measures (trust banners, in-email reporting, awareness training, and simulated phishing exercises) to catch what authentication alone can't.

| Question | Answer |
|---|---|
| Which protective technique allows a security team to safely analyze suspicious files for hidden malware? | `Sandboxing` |

![Phishing simulation and sandboxing conclusion](Screen%20Shot%202026-07-18%20at%209.29.40%20PM.png)

## Key Takeaways

- SPF, DKIM, and DMARC work as a layered system rather than standalone checks: SPF authenticates the sending server, DKIM verifies message integrity via signature, and DMARC ties both together through domain alignment to decide the final action.
- DKIM's advantage over SPF is that it survives forwarding, since the signature travels with the message rather than depending on the originating IP.
- SMTP response codes in a packet capture tell a real delivery story: a 553 tied to Spamhaus shows a reputation-based block in action, while a 552 reflects content-based rejection for security concerns.
- IMF analysis in Wireshark makes it possible to reconstruct the inner details of an email (attachments, encoding, sending client) directly from network traffic, which is valuable when only a PCAP is available rather than the original message.
- No single control stops phishing on its own. Authentication standards, technical filtering, sandboxing, and user training/reporting all need to work together, since attackers will eventually find a gap in any one layer.
