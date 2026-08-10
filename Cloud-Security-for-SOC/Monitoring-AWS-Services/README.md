# Monitoring AWS Services

Discover common attacks on AWS services and learn how to protect against them.

## Task 1 - Introduction

Introductory task covering the room's learning objectives: risks of exposed S3, EC2, and RDS, insecure security group workflows, Denial of Wallet (DoW) attacks, and CloudTrail/GuardDuty-based detection. Started the lab machine.

No answer required.

## Task 2 - Attacks on S3

Investigated how Alex exposed an S3 bucket and the breach that followed, using the `task2` Splunk index.

```
index=task2 eventName=PutBucketPublicAccessBlock userName=alex.morgan
```

**When did Alex disable the "S3 Public Access Block" feature?**

```
2025-12-31 17:48:12
```

![eventTime field showing 2025-12-31T17:48:12Z](./Screen%20Shot%202026-08-09%20at%204.26.33%20PM.png)

```
index=task2 eventName=PutBucketPolicy userName=alex.morgan
```

The applied bucket policy targeted the `thm-internal-backups` bucket.

![bucketName field showing thm-internal-backups](./Screen%20Shot%202026-08-09%20at%204.27.11%20PM.png)

**What is the SID of the applied policy that made the bucket public?**

```
TempAccessDeniedDebug
```

The policy contained two statements. `AllowAccessOnlyFromTorontoOffice` was IP-restricted and not the public-access statement; `TempAccessDeniedDebug` was the one that granted anonymous public access.

![bucketPolicy.Statement.Sid field showing two SIDs](./Screen%20Shot%202026-08-09%20at%204.28.53%20PM.png)

```
index=task2 eventSource=s3.amazonaws.com (eventName=GetObject OR eventName=HeadObject)
```

**Which IP address started the bucket scan soon after it was exposed?**

```
212.8.250.220
```

![src_ip field showing 212.8.250.220, 53 events](./Screen%20Shot%202026-08-09%20at%204.30.57%20PM.png)

```
index=task2 eventSource=s3.amazonaws.com sourceIPAddress=212.8.250.220 errorCode=AccessDenied
```

53 filenames were brute-forced against the bucket, all resulting in Access Denied.

![errorCode=AccessDenied query, 53 events](./Screen%20Shot%202026-08-09%20at%204.32.51%20PM.png)

![Raw AccessDenied event example](./Screen%20Shot%202026-08-09%20at%204.39.59%20PM.png)

```
index=task2 eventSource=s3.amazonaws.com sourceIPAddress=212.8.250.220
| stats count by eventName
```

Breaking activity down by eventName showed both GetObject and ListObjects calls from the scanning IP.

![eventName breakdown: GetObject, ListObjects](./Screen%20Shot%202026-08-09%20at%204.35.18%20PM.png)

```
index=task2 eventSource=s3.amazonaws.com sourceIPAddress=212.8.250.220 eventName=GetObject NOT errorCode=AccessDenied
```

Out of 54 total GetObject attempts, 52 failed with AccessDenied and 1 succeeded, confirming a single successful exfiltration.

![Successful GetObject event, no error](./Screen%20Shot%202026-08-09%20at%204.41.43%20PM.png)

**How many filenames were attempted, and which file was exfiltrated?**

```
53, repo.zip
```

![requestParameters.key field showing repo.zip](./Screen%20Shot%202026-08-09%20at%204.43.23%20PM.png)

![Task 2 answer confirmation](./Screen%20Shot%202026-08-09%20at%204.43.54%20PM.png)

## Task 3 - EC2 Internet Exposure

Investigated a typical EC2 exposure scenario involving Emma, using the `task3` Splunk index.

```
index=task3 eventName=CreateSecurityGroup userName=emma*
```

**Which security group did Emma create, and which risky service did it expose?**

```
website-access-sg, SSH
```

![groupName field showing website-access-sg](./Screen%20Shot%202026-08-09%20at%204.48.10%20PM.png)

![vpcId field for the created security group](./Screen%20Shot%202026-08-09%20at%204.49.48%20PM.png)

![Field list from the CreateSecurityGroup event](./Screen%20Shot%202026-08-09%20at%204.50.36%20PM.png)

```
index=task3 eventName=AuthorizeSecurityGroupIngress sg-088dacb4d53945be6
```

The ingress rule opened TCP port 22 (SSH) to the security group `sg-088dacb4d53945be6`.

```
index=task3 (eventName=RunInstances OR eventName=ModifyInstanceAttribute) *sg-088dacb4d53945be6*
```

**Which EC2 instance ID was created shortly after and uses that security group?**

```
i-082579354380296e6
```

```
index=task3 sourcetype=*guardduty*
```

A GuardDuty finding (`Recon:EC2/PortProbeUnprotectedPort`) confirmed the instance's exposed port was being actively probed.

**According to the GuardDuty alert, which IP soon attacked the instance?**

```
45.78.205.134
```

```
index=task3 eventName=RevokeSecurityGroupIngress
```

**When did Emma revoke the insecure rule from the security group?**

```
2025-12-31 21:58:34
```

## Task 4 - Exposed Database

Analyzed an RDS database exposure scenario using the `task4` Splunk index, focused on write events (`readOnly=false`).

```
index=task4 eventName=CreateDBInstance readOnly=false
```

**What is the name (instance identifier) of the created RDS instance?**

```
db-thm-preprod-qa
```

```
index=task4 readOnly=false (eventName=CreateDBInstance OR eventName=ModifyDBInstance OR eventName=AuthorizeSecurityGroupIngress)
```

The database was not made public at creation. A later `ModifyDBInstance` event set `publiclyAccessible: true`, and a separate event opened the port to the internet.

**Which two events indicate the database is Internet-exposed? Provide the first part of their eventID in chronological order.**

```
dcb54877, 0a3b23c1
```

## Task 5 - Cloud Discovery Intro

Analyzed a simple Discovery sequence from a breached IAM user using the `task5` Splunk index.

```
index=task5
| table eventTime eventName sourceIPAddress
| sort eventTime
```

The adversary's full command sequence, in order: GetCallerIdentity, ListAttachedUserPolicies, GetAccountSummary, ListUsers, DescribeTrails, ListFunctions20150331, DescribeDBInstances, DescribeInstances, ListBuckets, ListAttachedUserPolicies (again, targeting a specific user), CreateAccessKey, ListAccessKeys.

**What was the second Discovery command the adversary ran?**

```
ListAttachedUserPolicies
```

```
index=task5 eventName=CreateAccessKey
```

The second `ListAttachedUserPolicies` call, followed immediately by `CreateAccessKey`, indicated the adversary checked a specific user's permissions before backdooring their account with a new access key.

**Which other IAM user did the adversary discover and backdoor?**

```
lars.andersen
```

## Task 6 - Denial of Wallet Attacks

Conceptual task on Denial of Wallet (DoW) attacks, where adversaries drive up cloud costs instead of causing downtime.

**What does the acronym DoW stand for?**

```
Denial of Wallet
```

**Should you monitor DoW with the same effort as DoS?**

```
Yea
```

## Key Takeaways

- S3 exposure typically happens through two combined misconfigurations: disabling the "S3 Public Access Block" feature and applying a bucket policy with `Effect: Allow` and `Principal: *`. Not every public-looking policy is actually insecure, since Condition blocks (like IP restrictions) can limit real exposure, so each policy needs to be reviewed in full rather than flagged on Principal alone.
- Once a bucket is exposed, botnets and scanners will reliably find it. A spike of `AccessDenied` responses on `GetObject`/`HeadObject` from an anonymous or external IP is a strong signal of active brute-forcing against object names, and a lone successful `GetObject` in that same pattern usually marks the actual exfiltrated file.
- EC2 exposure follows a similar two-part pattern: an insecure security group rule (like SSH open to 0.0.0.0/0) combined with an EC2 instance actually using that security group. Correlating `CreateSecurityGroup`/`AuthorizeSecurityGroupIngress` events with `RunInstances`/`ModifyInstanceAttribute` events is necessary because security groups and the resources using them aren't always obviously linked in isolated log entries.
- GuardDuty findings like `Recon:EC2/PortProbeUnprotectedPort` provide automated confirmation of real-world exploitation attempts against exposed ports, cutting down the manual correlation work a SOC analyst would otherwise need to do across raw CloudTrail logs.
- RDS and other managed database services can be exposed either at creation (`CreateDBInstance` with `publiclyAccessible: true`) or later through a `ModifyDBInstance` change, so a database that was private for months can still become an exposure incident well after deployment. Detecting exposure typically requires correlating the publicly-accessible flag with a permissive security group rule opening the database port.
- Adversary Discovery activity in AWS follows a predictable pattern: identity check (GetCallerIdentity), permission enumeration (List*Policies), account-level context (GetAccountSummary), then broad service enumeration (ListUsers, ListBuckets, DescribeInstances, etc.). A second, more targeted enumeration call aimed at a specific user immediately followed by `CreateAccessKey` is a strong indicator of backdooring for persistence.
- Denial of Wallet (DoW) attacks exploit the pay-per-use nature of cloud services, driving up costs through high-volume requests or triggering autoscaling, rather than causing outright downtime. SOC teams should treat DoW monitoring with the same priority as traditional DoS monitoring, since a "successful" attack may never take a service offline while still causing significant financial damage.
