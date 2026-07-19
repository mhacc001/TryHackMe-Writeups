# Phishing Analysis Fundamentals — TryHackMe SOC Level 1

Room: Phishing Analysis module (first room)
Path: SOC Level 1

## Overview

This room covers the fundamentals needed before diving into real phishing investigations: how an email address is structured, the protocols that move a message from sender to recipient, how to read email headers and body source, and the common characteristics that mark an email as phishing. It closes with a look at Business Email Compromise (BEC).

## The Email Address

An email address is made up of a username, the `@` symbol, and a domain name, similar to a name and street address on a mailing envelope.

| Question | Answer |
|---|---|
| Identify the domain used in `hatsalesman@tryhatme.com` | `tryhatme.com` |

![Email address anatomy](Screen%20Shot%202026-07-18%20at%208.14.05%20PM.png)

## Email Delivery

Sending and receiving email relies on a handful of protocols working together: SMTP sends the message, DNS resolves the recipient's mail server, and either POP3 or IMAP is used to retrieve it depending on whether the mailbox needs to sync across multiple devices.

| Question | Answer |
|---|---|
| Which protocol is responsible for sending an email from a client to a mail server? | `SMTP` |
| Which service is used to look up the recipient domain's mail server? | `DNS` |
| Bob wants to access his email from multiple devices. Which protocol should he use? | `IMAP` |

![Email delivery protocols](Screen%20Shot%202026-07-18%20at%208.14.30%20PM.png)

## Email Headers

Email headers hold metadata like sender, recipient, subject, and date. Viewing the raw message source in Thunderbird (View > Message Source, or `ctrl+u`) exposes additional technical detail, including the originating IP address, that isn't visible in the standard inbox view.

| Question | Answer |
|---|---|
| What is the full subject line of email1.eml? | `Help protect your budget by protecting your home` |
| What is the IP address listed as the X-Originating-Ip? | `43.255.56.161` |

![Raw message source snippet](Screen%20Shot%202026-07-18%20at%208.16.40%20PM.png)
![Confirmed header answers](Screen%20Shot%202026-07-18%20at%208.20.14%20PM.png)

## Email Body

The email body can be plain text or HTML, and attachments are embedded in the source with their own headers (Content-Type, Content-Disposition, Content-Transfer-Encoding). Base64-encoded attachments can be decoded and reconstructed for analysis.

| Question | Answer |
|---|---|
| What is the Content-Type of the attachment in email2.txt? | `application/pdf` |
| What is the name of the attachment? | `zmqpalgh.pdf` |
| What is the hidden flag value after decoding the base64 string? | `THM{BENIGN_PDF_ATTACHMENT}` |

![Email body and attachment analysis](Screen%20Shot%202026-07-18%20at%208.22.31%20PM.png)

## Types of Malicious Email

Malicious emails fall into categories like spam, phishing, spear phishing, whaling, smishing, and vishing. Phishing emails typically share common traits: spoofed sender addresses, urgency, brand impersonation, generic greetings, hidden links, and malicious attachments. Hyperlinks and IPs should be defanged before sharing to avoid accidental clicks.

| Question | Answer |
|---|---|
| Which reputable organization is being spoofed in email3.eml? | `Home Depot` |
| What is the sender's email address? | `support@teckbe.com` |
| What is the defanged X-Originating-IP? | `103[.]234[.]236[.]83` |
| Which mail server generated the Authentication-Results header? | `atlas102.free.mail.gq1.yahoo.com` |

![Types of phishing analysis](Screen%20Shot%202026-07-18%20at%208.24.35%20PM.png)

## Conclusion

| Question | Answer |
|---|---|
| What attack, signified by the acronym BEC, uses a compromised email to trick employees into fraud? | `Business Email Compromise` |

![Conclusion answer](Screen%20Shot%202026-07-18%20at%208.26.07%20PM.png)

## Key Takeaways

- Understanding the mechanics of legitimate email (address structure, SMTP/DNS/IMAP flow, header fields) is the foundation for spotting what's abnormal in a phishing attempt.
- The raw message source, not the rendered inbox view, is where the real evidence lives: originating IPs, authentication results, and attachment encoding are only visible there.
- Defanging IOCs (URLs, IPs, domains) before sharing them is a basic but essential habit to avoid accidental clicks when passing indicators along to a team.
- BEC is a distinct and high-impact category worth remembering on its own: it relies on a genuinely compromised internal account rather than a spoofed one, which makes it harder to catch with standard phishing indicators.
