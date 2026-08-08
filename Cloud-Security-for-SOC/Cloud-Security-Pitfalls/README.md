# Cloud Security Pitfalls

Explore the risks companies face when migrating to the cloud, and learn how to address them in a SOC.

## Task 1 - Introduction

Introductory task covering the room's learning objectives: cloud service models (IaaS, PaaS, SaaS), risks from cloud providers, core cloud security concepts, and the challenges of monitoring clouds as a SOC analyst.

No answer required.

## Task 2 - What Is Cloud

**Which cloud model allows you to migrate a big on-premises network to the cloud?**

```
IaaS
```

**Which cloud model do Elastic Cloud and CrowdStrike Falcon fit into?**

```
SaaS
```

![Task 2 answers](./Screen%20Shot%202026-08-08%20at%205.20.36%20PM.png)

## Task 3 - Security of the Cloud

**Is the cloud provider responsible for securing and monitoring its own infrastructure (Yea/Nay)?**

```
Yea
```

**But should you trust the cloud provider without watching for supply chain threats? (Yea/Nay)**

```
Nay
```

![Task 3 answers](./Screen%20Shot%202026-08-08%20at%205.28.26%20PM.png)

## Task 4 - Security in the Cloud

**Does moving an unpatched server to the cloud make it secure again? (Yea/Nay)**

```
Nay
```

**What is the first major obstacle to integrating most cloud products with a SIEM?**

```
Paid Logs
```

![Task 4 answers](./Screen%20Shot%202026-08-08%20at%205.28.58%20PM.png)

## Task 5 - What to Protect and Monitor

**What term describes cloud compute resources like VMs or containers?**

```
Workloads
```

**Which of the mentioned cloud security tools do Falco and Tetragon fit into?**

```
CWPP
```

![Task 5 answers](./Screen%20Shot%202026-08-08%20at%205.29.35%20PM.png)

## Exercise 1 - Choose the Correct Cloud Service Model

Sorted the nine card descriptions into IaaS, PaaS, and SaaS.

**IaaS**
- Provides an ability to launch and use Linux or Windows VMs in the cloud
- Requires the most effort to learn, configure, harden, secure, and monitor
- Amazon AWS, Google Cloud, and Microsoft Azure are some of the examples

**PaaS**
- Allows you to quickly build applications without maintaining servers
- Popular examples include Azure App Service and Google App Engine
- Is a balance between maintaining VMs and simply using software in the cloud

**SaaS**
- Asana, Confluence, Salesforce, and DrawIO are some of the examples
- Can be used by non-technical departments, such as Sales, Marketing or Design
- Ready to use right after you sign up, doesn't require much configuration

```
THM{flag_as_a_service!}
```

![Exercise 1 completed](./Screen%20Shot%202026-08-08%20at%205.36.32%20PM.png)

## Exercise 2 - Choose the Responsible Person in IaaS

Sorted the seven responsibility statements into You vs IaaS Provider, based on the shared responsibility model.

**You**
- Detect suspicious logins of cloud users within your IaaS tenant
- Collect VM logs and monitor the launched workloads for cyber threats
- Control access to data in cloud-managed services, such as AWS S3
- Manage software dependencies in the virtual machines you launch

**IaaS Provider**
- Secure the cloud datacenters from unauthorized physical access
- Protect against supply chain attacks on cloud admin panel
- Patch vulnerabilities in cloud-managed services, such as AWS S3

```
THM{ready_for_cloud_migration!}
```

![Exercise 2 completed](./Screen%20Shot%202026-08-08%20at%205.39.54%20PM.png)

## Key Takeaways

- The three cloud service models (IaaS, PaaS, SaaS) trade off control for convenience: IaaS gives the most control and requires the most security effort, SaaS gives the least control and requires the least.
- Security of the cloud (the provider's infrastructure) and security in the cloud (your workloads, data, and configurations) are separate responsibilities. Trusting the provider's infrastructure security does not mean ignoring supply chain risk.
- Migrating an unpatched or poorly secured system to the cloud does not make it secure. Cloud-specific hardening is still required.
- Cloud logging is harder to integrate with a SIEM than on-premises logging, often due to paid logging tiers, inconsistent log formats, and limited SIEM integration support, especially in SaaS.
- The shared responsibility model in IaaS splits cleanly along managed vs unmanaged: for self-launched VMs and workloads, you own patching, monitoring, and access control; for fully managed services like AWS S3, the provider owns patching the underlying service while you still control data access.
- CWPP (Cloud Workload Protection Platform) tools like Falco and Tetragon focus on runtime protection for containerized workloads, filling a gap that traditional EDR often cannot cover in cloud environments.
