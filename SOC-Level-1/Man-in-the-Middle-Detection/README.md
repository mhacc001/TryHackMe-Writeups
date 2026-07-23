# Man-in-the-Middle Detection

## Overview

A routine network monitoring alert at Acme Corp revealed unusual traffic patterns suggesting a possible Man-in-the-Middle (MITM) attack inside the corporate LAN. Over several days, an attacker quietly intercepted communications, redirected connections, and captured user credentials. This room walks through a SOC Analyst investigation of a chained MITM attack made up of three techniques:

- ARP Spoofing (network interception)
- DNS Spoofing (redirection)
- SSL Stripping (credential capture)

All analysis was performed on `network-traffic.pcap` using Wireshark, with logs also available via `mitm_attack.log` and Splunk (`index=network_logs`).

## Task 4 - Detecting ARP Spoofing

ARP has no authentication, so any device on the network can send unsolicited "is-at" replies. The attacker exploited this by sending fake ARP replies claiming to own the gateway's IP address (192.168.10.1), poisoning the ARP caches of hosts on the LAN and positioning themselves as a man-in-the-middle.

Key filters used:

```
arp
arp.opcode == 1
arp.opcode == 2
arp.isgratuitous
arp && arp.src.proto_ipv4 == 192.168.10.1 && eth.src == 02:aa:bb:cc:00:01
arp.opcode == 2 && arp.src.proto_ipv4 == 192.168.10.1
arp.duplicate-address-detected || arp.duplicate-address-frame
```

**Findings:**

- ARP packets from the legitimate gateway MAC address: 10
- Attacker MAC address impersonating the gateway: 02:fe:fe:fe:55:55
- Gratuitous ARP replies observed for 192.168.10.1: 2
- Unique MAC addresses claiming 192.168.10.1: 2 (legitimate gateway and attacker)
- Total ARP spoofing packets from the attacker: 14

## Task 5 - Unmasking DNS Spoofing

With ARP spoofing established, the attacker used their MITM position to intercept and respond to DNS queries before the legitimate resolver could. The domain of interest, `corp-login.acme-corp.local`, received forged DNS responses pointing victims to an attacker-controlled IP instead of the real server.

Key filters used:

```
dns
dns.flags.response == 1 && ip.src == 8.8.8.8
dns.flags.response == 1
dns && dns.qry.name == "corp-login.acme-corp.local"
dns.flags.response == 1 && ip.src == 8.8.8.8 && dns.qry.name == "corp-login.acme-corp.local"
dns.flags.response == 1 && ip.src != 8.8.8.8 && dns.qry.name == "corp-login.acme-corp.local"
```

**Findings:**

- DNS responses observed for corp-login.acme-corp.local: 211
- DNS requests from IPs other than 8.8.8.8: 2
- IP returned in the attacker's forged DNS response: 192.168.10.55

## Task 6 - Spotting SSL Stripping in Action

Once the victim was redirected to the attacker's IP via DNS spoofing, the attacker downgraded the connection from HTTPS to HTTP, relaying plaintext traffic to the victim while keeping a secure session with the real server. This let the attacker capture the victim's login credentials in cleartext.

Key filters used:

```
tls || ssl
tls.handshake.type == 1 && tls.handshake.extensions_server_name == "corp-login.acme-corp.local"
dns.flags.response == 1 && ip.src == 192.168.10.55 && dns.qry.name == "corp-login.acme-corp.local"
http && ip.src == 192.168.10.10 && ip.dst == 192.168.10.55
```

**Findings:**

- POST requests observed for corp-login.acme-corp.local: 1
- Victim's password recovered in plaintext:

```
Secret123!
```

## Attack Timeline

1. **ARP Spoofing** - attacker sends unsolicited ARP "is-at" replies claiming to be the gateway (192.168.10.1), poisoning ARP caches on the LAN.
2. **DNS Spoofing** - attacker intercepts the victim's DNS query for corp-login.acme-corp.local and returns a forged response pointing to their own IP (192.168.10.55).
3. **SSL Stripping** - victim connects to the resolved IP over HTTP instead of HTTPS, and submits login credentials that are captured in cleartext via a POST request.

## Key Takeaways

- ARP has no built-in authentication, which makes gratuitous and unsolicited replies a strong red flag when investigating LAN-based interception.
- DNS spoofing is easiest to catch by comparing responses for the same query name against the known legitimate resolver; conflicting answers from an unexpected source are the clearest signal.
- SSL stripping relies on the victim never establishing a TLS handshake with the real server after redirection, so the absence of expected TLS traffic combined with plaintext HTTP POSTs is the tell.
- These three techniques chain together into a full MITM kill chain: interception (ARP) leads to redirection (DNS) leads to credential capture (SSL stripping), and correlating all three across the same pcap is what confirms the full attack path rather than isolated anomalies.
