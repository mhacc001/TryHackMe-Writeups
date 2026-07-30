# Block

## Overview

Block is a forensics challenge simulating a corporate espionage investigation: two recently fired employees still had active credentials and used them to access private files on the company file server. The only evidence available is a small network capture (traffic.pcapng) and a memory dump of the Local Security Authority Subsystem Service process (lsass.DMP). The room requires chaining together memory forensics, password cracking, and manual SMB3 traffic decryption to prove exactly what each user accessed.

## Task 1 - Server Message Block

Extracted evidence.zip to find two files: traffic.pcapng (a packet capture of two SMB sessions) and lsass.DMP (a memory dump of the LSASS process). Protocol hierarchy analysis of the pcap showed the traffic was almost entirely SMB2/SMB3, with the actual file-transfer portion encrypted via SMB 3.1.1 with AES-128-GCM.

### Identifying the users (pcap)

Filtered the pcap for NTLMSSP authentication messages and found two SMB logins from host DRAGON (10.0.2.64) to the file server (10.0.2.70):

```
frame 11: user mrealman, domain WORKGROUP, host DRAGON
frame 82: user eshellstrop, domain WORKGROUP, host DRAGON
```

### Extracting credentials (LSASS dump)

Ran pypykatz against lsass.DMP to pull NT hashes for both users:

```
pypykatz lsa minidump lsass.DMP -o pypykatz_out.json
```

**Findings:**

```
mrealman NT hash: 1f9175a516211660c7a8143b0f36ab44
eshellstrop NT hash: 3f29138a04aadc19214e9c04028bf381
```

Confirmed mrealman's hash cracks to the password Blockbuster1 by independently computing NTLM("Blockbuster1") and matching it byte-for-byte against the extracted hash (rather than trusting a wordlist hit blindly):

```python
from Crypto.Hash import MD4
def ntlm(pw):
    h = MD4.new()
    h.update(pw.encode('utf-16le'))
    return h.hexdigest()
ntlm('Blockbuster1')  # -> 1f9175a516211660c7a8143b0f36ab44
```

eshellstrop's hash did not crack against available wordlists, so the NT hash itself is the answer for that question.

### Decrypting the SMB3 traffic

The actual file access happens over SMB 3.1.1 with AES-128-GCM encryption (confirmed via the Negotiate response's SMB2_ENCRYPTION_CAPABILITIES context), so the file contents aren't visible in plaintext. Reconstructed the full decryption chain manually:

1. **Extracted NTProofStr and EncryptedSessionKey** from each user's NTLM AUTHENTICATE message in the pcap.
2. **Derived the Random Session Key** for each session using the standard NTLMv2 key exchange:
   - `ResponseNTKey = HMAC-MD5(NTHash, User.upper() + Domain.upper())`
   - `KeyExchKey = HMAC-MD5(ResponseNTKey, NTProofStr)`
   - `RandomSessionKey = RC4-decrypt(KeyExchKey, EncryptedSessionKey)`
3. **Extracted the PreauthIntegrityHashValue** (SHA-512 chain over the Negotiate and Session Setup exchange) for each session directly from Wireshark's own preauth hash calculation.
4. **Derived the SMB 3.1.1 encryption/decryption keys** via the SP800-108 KDF (HMAC-SHA256, counter mode), using labels `SMBC2SCipherKey` and `SMBS2CCipherKey` with the PreauthIntegrityHashValue as context.
5. **Manually decrypted every SMB2_TRANSFORM_HEADER packet** with AES-128-GCM (parsed via Scapy), using the Nonce field as IV, the transform header fields as AAD, and the Signature field as the GCM tag.

This revealed that mrealman opened `clients156.csv` and eshellstrop opened `clients978.csv`, both fake credential dumps with a flag embedded as one of the rows.

**Findings:**

```
Username of the first person who accessed the server: mrealman
Password of user 1: Blockbuster1
Flag the first user got access to: THM{SmB_DeCrypTing_who_Could_Have_Th0ughT}
Username of the second person who accessed the server: eshellstrop
Hash of user 4: 3f29138a04aadc19214e9c04028bf381
Flag the second user got access to: THM{No_PasSw0Rd?_No_Pr0bl3m}
```

![Task 1 answers](Screen%20Shot%202026-07-30%20at%201.42.05%20AM.png)

## Key Takeaways

- LSASS memory dumps and network captures are complementary evidence sources: the pcap proves who connected and when, while the memory dump provides the credential material needed to actually decrypt what they did once connected. Neither artefact alone would have been sufficient to prove data access.
- SMB 3.1.1's AES-GCM encryption is genuinely strong when session keys are unknown, but the entire scheme collapses once an investigator has the NT hash: the NTLM key exchange (RC4-decrypting the EncryptedSessionKey with a key exchange key derived from the hash) is fully reversible, and from there the SP800-108 KDF that derives the actual cipher keys is public and deterministic.
- The PreauthIntegrityHashValue is easy to overlook but essential for SMB 3.1.1 specifically: unlike earlier SMB3 dialects, the 3.1.1 key derivation context isn't a fixed string, it's a running SHA-512 hash over the entire negotiate and session setup exchange, so it must be pulled from the same session being decrypted.
- Cracking one password (mrealman) and being unable to crack the other (eshellstrop) reinforced that password strength directly determines how much of an investigation depends on wordlist luck versus the underlying hash itself; both paths still led to full plaintext file recovery once the SMB3 keys were derived.
- Building the decryption pipeline manually in Python (NTLM key exchange, KDF, AES-GCM) rather than relying solely on GUI tooling made the process fully scriptable and verifiable end-to-end, which matters when the goal is concrete, defensible proof rather than just visual confirmation in a packet analyzer.
