# Offensive Security Intro
**Platform:** TryHackMe  
**Path:** SOC Level 1 / Pre-Security  
**Difficulty:** Easy  
---

## Objective

Hack your first website (legally, in a safe environment) and experience what an ethical hacker does. This room introduces offensive security by simulating a real-world bank application attack using directory enumeration.

---

## Tools Used

- `dirb` (web content scanner / directory brute-forcer)
- Firefox browser (in-lab virtual desktop)

---

## Methodology

### Task 1 -- Think Like a Hacker

Before touching any tools, the room introduced the offensive security mindset: to beat attackers, you need to think like one. Ethical hackers legally probe systems to find vulnerabilities before malicious actors do.

### Task 2 -- Starting the Lab

Launched the virtual lab environment. The FakeBank web application loaded in the browser, showing a banking dashboard for account **8881** belonging to Mrs. G. Benjamin, with a current balance of **-$1,232.32**.

![FakeBank application loaded in the virtual desktop](Screen%20Shot%202026-05-31%20at%208.47.46%20PM.png)

### Task 3 -- Hack the Bank (Directory Enumeration with dirb)

Opened the terminal in the virtual desktop and ran `dirb` against the FakeBank URL to discover hidden pages:

```bash
dirb http://fakebank.thm
```

`dirb` scanned 4,610 entries and found **2 URLs**:
- `http://fakebank.thm/bank-transfer` (CODE:200 | SIZE:4663)
- `http://fakebank.thm/images` (CODE:301 | SIZE:179)

The `/bank-transfer` endpoint was not linked anywhere on the site -- a classic case of security through obscurity failing.

![dirb output showing hidden /bank-transfer URL discovered](Screen%20Shot%202026-05-31%20at%208.50.33%20PM.png)

### Task 4 -- Attack the Admin Page

Navigated directly to `http://fakebank.thm/bank-transfer` in the browser. This revealed a hidden admin panel. Selected account **8881** and deposited **$2000**, which flipped the account balance from negative to positive.

A popup appeared with the flag in green text.

![Hidden /bank-transfer admin panel with deposit form](Screen%20Shot%202026-05-31%20at%208.53.39%20PM.png)

![Flag popup confirming successful bank transfer -- BANK-HACKED](Screen%20Shot%202026-05-31%20at%209.18.45%20PM.png)

---

## Flag

```
BANK-HACKED
```

---

## Key Takeaways

- **Directory enumeration** with tools like `dirb` can expose hidden endpoints that developers forgot to protect or remove.
- A page that isn't linked in the UI is not a page that's secure -- attackers can brute-force paths just as easily.
- Offensive security techniques like this are used by ethical hackers and penetration testers to find vulnerabilities before real attackers do.
- Every organization should audit their web applications for unprotected admin endpoints.
