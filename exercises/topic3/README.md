# Table of Contents

1. [Introduction](#introduction)
2. [What is an ORR Checklist?](#what-is-an-orr-checklist)
3. [When Does an ORR Checklist Occur?](#when-does-an-orr-checklist-occur)
4. [ORR Checklist Items](#orr-checklist-items)
   - [Logging Format & Catalog](#logging-format--catalog)
   - [Distributed Tracing](#distributed-tracing)
   - [RunBooks](#runbooks)
   - [Monitoring](#monitoring)
   - [Disaster Recovery](#disaster-recovery)
5. [What to Do After Creating the ORR Checklist](#what-to-do-after-creating-the-orr-checklist)

# Introduction

In Site Reliability Engineering (SRE), an Operational Readiness Review (ORR) checklist is a critical process that ensures applications and systems are production-ready. It evaluates various aspects of reliability, performance, and operational readiness, helping teams identify and address gaps before deployment.

# What is an ORR Checklist?

An ORR checklist is a systematic evaluation used to verify that a system meets operational requirements and is prepared for production deployment. It involves assessing key areas such as logging, monitoring, disaster recovery, and documentation.

# When Does an ORR Checklist Occur?

The ORR checklist is typically conducted:
- Before a new service or feature is deployed to production.
- After significant architectural changes or migrations.
- During routine reviews as part of a continuous reliability improvement process.

# ORR Checklist Items

### Logging Format & Catalog
- **Check**: Do the application microservices follow a standard logging format to capture consistent information at runtime?
- **Importance**: Consistent logging helps with debugging, monitoring, and analyzing application behavior across distributed systems.

### Distributed Tracing
- **Check**: Are the user requests traced end-to-end using unique IDs?
- **Importance**: Distributed tracing enables visibility into user flows and identifies bottlenecks in a microservices architecture.

### RunBooks
- **Check**: Are there manual and automated runbooks available that provide step-by-step instructions to administer the solution?
- **Importance**: Runbooks ensure that operational tasks are executed consistently and efficiently, reducing mean time to recovery (MTTR).

### Monitoring
- **Check**: Is the necessary monitoring established and alerts configured?
- **Importance**: Proper monitoring ensures issues are detected and addressed promptly, minimizing downtime and impact.

### Disaster Recovery
- **Check**: Are you able to successfully perform a disaster recovery test?
- **Importance**: Disaster recovery testing verifies the ability to restore services and data in case of catastrophic failures.

# What to Do After Creating the ORR Checklist

After completing the ORR checklist:
1. **Analyze Results**: Identify gaps and areas for improvement.
2. **Prioritize Improvements**: Categorize issues by their impact and urgency.
3. **Implement Solutions**: Address critical gaps first, such as missing monitoring or inadequate disaster recovery plans.
4. **Schedule Follow-Ups**: Regularly revisit the checklist to ensure continuous improvement and alignment with evolving requirements.
