# Phishing Emails in Action — TryHackMe SOC Level 1

Room: Phishing Analysis module (second room)
Path: SOC Level 1

## Overview

This room builds on Phishing Analysis Fundamentals by walking through real-world phishing email samples pulled from actual spam and phishing traffic. Each sample highlights a different combination of techniques: spoofed addresses, URL shortening, tracking pixels, brand impersonation, credential harvesting, BCC abuse, and malicious attachments.

## Please Cancel Your Order (PayPal)

This sample spoofs a PayPal transaction receipt. The From address doesn't match the real sender domain, and the "Cancel the order" button routes through a shortened URL to obscure its real destination. Tools like WhereGoes can expand shortened links without visiting them directly.

| Question | Answer |
|---|---|
| Who is listed as the Merchant in the email body? | `Amazing Stuff` |

![PayPal sample analysis](Screen%20Shot%202026-07-18%20at%208.29.35%20PM.png)

## Track Your Package (DHL Tracking)

This sample impersonates a shipping notification. The display name "Distribution Center" doesn't match the real sender address, and the tracking link doesn't lead where it claims. A tracking pixel embedded in the message (`Tracking.png`) explains why Yahoo automatically blocked the images.

| Question | Answer |
|---|---|
| What root domain does the hyperlink point to (defanged)? | `devret[.]xyz` |

## Download Document Here (OneDrive / Credential Harvesting)

This sample impersonates a fax/document notification and funnels the victim through fake OneDrive and Adobe pages toward a credential harvesting form. Even entering fake credentials returns a generic error, since the page's only real function is forwarding whatever is typed to the attacker's server. Modern phishing kits built with AI assistance often lack the grammar issues that used to be a reliable red flag.

| Question | Answer |
|---|---|
| What other company name was used in this phishing email? | `Citrix` |
| What is this type of attack called (fake portal to capture and exfiltrate credentials)? | `Credential Harvesting` |

![Credential harvesting login page](Screen%20Shot%202026-07-18%20at%208.32.38%20PM.png)

## Your Account Is on Hold (Netflix)

This sample impersonates Netflix billing using the display name "Netllx billing" to sneak past a quick glance. The real sender address is unrelated to Netflix, and the email pushes urgency (account suspension) alongside an atypical support phone number.

| Question | Answer |
|---|---|
| What is the actual sender email address hidden behind the "Netllx billing" display name? | `z99@musacombi.online` |

![Netflix billing sample](Screen%20Shot%202026-07-18%20at%208.33.31%20PM.png)

## Your Recent Purchase (Apple Support / BCC)

This sample has a completely blank email body and relies entirely on a `.dot` (Microsoft Word Template) attachment, an unusual format for a receipt. The recipient was BCCed rather than directly addressed, hiding the true distribution list. Clicking the embedded image in the document redirects through a long, complex URL designed to look legitimate at a glance.

| Question | Answer |
|---|---|
| What does the acronym BCC stand for? | `Blind Carbon Copy` |
| What is the file extension of the attachment? | `.dot` |

![Apple Support BCC sample](Screen%20Shot%202026-07-18%20at%208.35.30%20PM.png)

## Scheduled Shipment (DHL Excel Payload)

This sample impersonates DHL Express and centers on a malicious `.xlsx` attachment rather than the email body itself. The document contains conflicting geographical markers (German sender domain, an Indian delivery address, Mandarin content) and a single link that attempts to download and execute a payload. In this sandboxed environment the payload throws a system error, but the intent (persistence, data exfiltration, or ransomware deployment) is clear from the attempted execution.

| Question | Answer |
|---|---|
| What is the name of the executable that the Excel attachment attempts to run? | `regasms.exe` |

![DHL Excel payload execution](Screen%20Shot%202026-07-18%20at%208.42.57%20PM.png)

## Conclusion

No answer needed. Wraps up the room with a summary of the phishing indicators covered across all six samples.

## Key Takeaways

- Across every sample, the same handful of tells kept reappearing: a mismatched From address, manufactured urgency, and a link or attachment designed to obscure its real destination or payload.
- URL shorteners and tracking pixels are two sides of the same coin: one hides the destination, the other silently confirms to the attacker that the email was opened.
- Credential harvesting pages don't need to actually authenticate anything, they just need to look like they do long enough to capture what's typed, which is why even a fake login attempt returns a generic error either way.
- Attachment format itself can be a red flag: a `.dot` file standing in for a receipt, or an `.xlsx` file carrying an embedded executable, is often more telling than the email body.
- As AI-generated phishing content becomes more polished, grammar and spelling errors are a shrinking signal. Verifying sender addresses, link destinations, and attachment behavior matters more than ever.
