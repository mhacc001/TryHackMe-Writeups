# Monitoring AWS Logins

Explore AWS authentication, common IAM threats, and SIEM detection options.

## Task 1 - Introduction

Introductory task covering the room's learning objectives: IAM fundamentals, access keys, roles, how CloudTrail logs different login methods, real-world cloud breaches, and hands-on Splunk mini-challenges. Started the lab machine and Splunk Web Interface.

No answer required.

## Task 2 - IAM and AWS Credentials

**What type of credential is used to access AWS resources via CLI/SDK?**

```
Access Key
```

**Which IAM identity type allows you to gain AWS permissions temporarily?**

```
IAM Role
```

![Task 2 answer confirmation](./Screen%20Shot%202026-08-08%20at%206.41.09%20PM.png)

## Task 3 - Monitoring Console Logins

Investigated `ConsoleLogin` events in the `task3` Splunk index to identify failed login attempts and MFA gaps.

An initial query scoped to "Last 24 hours" returned no results, since the lab's CloudTrail data is historical rather than live.

![Initial query with wrong time range returning 0 events](./Screen%20Shot%202026-08-08%20at%206.49.18%20PM.png)

Switching to All Time and broadening the search confirmed 529 total events in the index.

![Broad index=task3 search showing 529 total events](./Screen%20Shot%202026-08-08%20at%207.02.38%20PM.png)

```
index="task3" eventName="ConsoleLogin"
```

Narrowing to just `ConsoleLogin` events brought the count down to 15.

![15 ConsoleLogin events](./Screen%20Shot%202026-08-08%20at%207.14.50%20PM.png)

Checking the field sidebar surfaced multiple username-related fields (`userName`, `user_name`, `userIdentity.userName`, etc.), which helped confirm the correct field to query on.

![Field sidebar showing username field variants](./Screen%20Shot%202026-08-08%20at%207.17.22%20PM.png)

```
index=task3 eventName=ConsoleLogin userName=thomas.bennett errorMessage=*
```

**How many times did Thomas fail to log in to the AWS console?**

```
11
```

![Thomas failed console logins query returning 11 events](./Screen%20Shot%202026-08-09%20at%203.05.01%20PM.png)

Breaking down the `userName` field across all 15 ConsoleLogin events showed three users total, with Thomas accounting for the majority.

![userName field breakdown: thomas.bennett, otake.nao, root](./Screen%20Shot%202026-08-09%20at%201.17.22%20AM.png)

```
index=task3 eventName=ConsoleLogin "additionalEventData.MFAUsed"=Yes
```

Only one event out of 15 had MFA enabled, confirming most logins in this dataset lacked MFA entirely.

![MFAUsed=Yes single event](./Screen%20Shot%202026-08-09%20at%203.07.54%20PM.png)

**Which other user logged in to the AWS console without MFA?**

```
otake.nao
```

![Task 3 answer confirmation](./Screen%20Shot%202026-08-09%20at%203.09.19%20PM.png)

## Task 4 - Monitoring Access Keys

Investigated a compromise of michael.turner's access key that led to an extortion attack on a private S3 bucket, using the `task4` Splunk index.

```
index=task4 userName=michael.turner
```

**What access key ID of Michael was used in the attack?**

```
AKIAVZZK4G6EW3NCJENS
```

![Michael's access key ID, 68 events](./Screen%20Shot%202026-08-09%20at%203.12.01%20PM.png)

```
index=task4 userIdentity.accessKeyId=AKIAVZZK4G6EW3NCJENS eventSource=s3.amazonaws.com
```

**What is the name of the S3 bucket accessed by the attackers?**

```
ocr-passport-scan
```

![S3 bucket name field](./Screen%20Shot%202026-08-09%20at%203.12.50%20PM.png)

```
index=task4 userIdentity.accessKeyId=AKIAVZZK4G6EW3NCJENS eventSource=s3.amazonaws.com requestParameters.bucketName=ocr-passport-scan eventName=DeleteObject
```

**How many files were exfiltrated and deleted by the adversary?**

```
26
```

![DeleteObject event count](./Screen%20Shot%202026-08-09%20at%203.16.31%20PM.png)

```
index=task4 userIdentity.accessKeyId=AKIAVZZK4G6EW3NCJENS eventSource=s3.amazonaws.com requestParameters.bucketName=ocr-passport-scan eventName=PutObject
```

**Which file was uploaded to the bucket at the end of the attack?**

```
WHERE-ARE-MY-FILES.README
```

![requestParameters.key ransom filename](./Screen%20Shot%202026-08-09%20at%203.17.18%20PM.png)
![requestParameters.key ransom filename confirmation](./Screen%20Shot%202026-08-09%20at%203.19.50%20PM.png)

```
index=task4 NOT userIdentity.accessKeyId=AKIA*
| stats count by eventSource
| sort -count
```

Sorting all non-access-key events by `eventSource` surfaced 14 distinct AWS services.

![Full eventSource breakdown, sorted by count](./Screen%20Shot%202026-08-09%20at%203.20.13%20PM.png)

```
index=task4 NOT userIdentity.accessKeyId=AKIA*
| stats count by eventSource
| sort -count
| head 1
```

**Which AWS service was used most by the user who did not use access keys?**

```
Amazon Bedrock
```

![Top eventSource: bedrock.amazonaws.com](./Screen%20Shot%202026-08-09%20at%203.26.59%20PM.png)

![Task 4 answer confirmation](./Screen%20Shot%202026-08-09%20at%203.27.32%20PM.png)

## Task 5 - IAM Roles for Services

Investigated how regular users and AWS services use IAM roles, including role assumption and role chaining, using the `task5` Splunk index.

```
index=task5 userIdentity.arn=*UserAvatarsProcessor*
```

**Which EC2 instance ID used the UserAvatarsProcessor role?**

```
i-0d2b8acdedc371589
```

![userIdentity.arn showing UserAvatarsProcessor role and EC2 instance ID](./Screen%20Shot%202026-08-09%20at%203.28.30%20PM.png)

```
index=task5 eventName=AssumeRole requestParameters.roleArn=*EU-RemoteSupport*
```

**Someone assumed the EU-RemoteSupport IAM role. How did they name the role session?**

```
SecretSession
```

![roleSessionName field showing SecretSession](./Screen%20Shot%202026-08-09%20at%203.50.45%20PM.png)

**Which user assumed the IAM role from the question above?**

```
sarah.braun
```

![user_arn field showing sarah.braun](./Screen%20Shot%202026-08-09%20at%203.51.19%20PM.png)

![Task 5 answer confirmation](./Screen%20Shot%202026-08-09%20at%203.51.34%20PM.png)

## Task 6 - Early Threat Detection

Audited logs of an insecure integration between Splunk and CloudTrail using the `task6` Splunk index, focused on IAM misconfigurations and over-privileged access key creation.

```
index=task6 userIdentity.arn="arn:aws:iam::398985017225:root"
```

**Under which ARN does the Splunk integration authenticate?**

```
arn:aws:iam::398985017225:root
```

![userIdentity.arn showing root, 236 events](./Screen%20Shot%202026-08-09%20at%203.52.52%20PM.png)

```
index=task6 eventName=CreateAccessKey userIdentity.arn="arn:aws:iam::398985017225:root"
```

**When was the over-privileged integration access key created?**

```
2025-12-29 19:59:23
```

![CreateAccessKey raw event showing eventTime](./Screen%20Shot%202026-08-09%20at%203.56.09%20PM.png)

![Task 6 answer confirmation](./Screen%20Shot%202026-08-09%20at%203.57.27%20PM.png)

## Key Takeaways

- Access keys grant programmatic (CLI/SDK) access and carry the same permissions as console access, while IAM roles grant temporary, short-lived STS credentials that don't require stored secrets, making roles the more secure option for services and automation.
- ConsoleLogin events are only generated for GUI logins. Access key activity never triggers a ConsoleLogin event, since programmatic access has no login stage; the credentials are simply included with each API call.
- Monitoring console logins should focus on root user activity, failed login patterns, missing MFA, and logins from unexpected locations. All three are strong indicators of compromise or misuse.
- Leaked and misused access keys remain one of the most common causes of cloud breaches. In this room's scenario, a single compromised access key led to full S3 bucket enumeration, mass exfiltration, deletion of 26 files, and a ransom note upload, all without a single console login.
- IAM roles cannot act on their own. Every action taken under an assumed role traces back to a real identity (a user or an AWS service) through the AssumeRole event, and that event is essential during triage since a custom session name can otherwise obscure who is really acting.
- Role chaining (assuming one role, then another, then another) is common in complex environments and requires walking back through AssumeRole events one at a time to find the original actor.
- Early threat detection means monitoring not just for compromise but for risky misconfigurations before they are exploited, especially CreateAccessKey events, policy modifications, and MFA deactivations, since these often precede an attack by months or years.
- Authenticating a SIEM integration directly as the AWS root user is a severe misconfiguration. It grants unrestricted, unscoped access with no way to apply least privilege, and should always be replaced with a dedicated IAM role or scoped service user.
