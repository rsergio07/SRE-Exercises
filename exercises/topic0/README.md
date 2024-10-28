# Understanding SLO, SLI, SLA, and Error Budgets in SRE

## Table of Contents
- [Overview](#overview)
- [Definitions and Proper Order](#definitions-and-proper-order)
  - [Service Level Indicator (SLI)](#service-level-indicator-sli)
  - [Service Level Objective (SLO)](#service-level-objective-slo)
  - [Service Level Agreement (SLA)](#service-level-agreement-sla)
  - [Error Budget](#error-budget)
- [Applying SLIs, SLOs, SLAs, and Error Budgets](#applying-slis-slos-slas-and-error-budgets)
  - [Greenfield Project Example](#greenfield-project-example)
  - [Mature Product Example](#mature-product-example)
- [Error Budget and SLO Miss Policy](#error-budget-and-slo-miss-policy)
- [Continuous Improvement of SLO Targets](#continuous-improvement-of-slo-targets)
- [Why 100% SLO Is Unrealistic](#why-100-slo-is-unrealistic)

---

## Overview

In Site Reliability Engineering (SRE), **Service Level Indicators (SLIs)**, **Service Level Objectives (SLOs)**, **Service Level Agreements (SLAs)**, and **Error Budgets** are essential for defining, measuring, and maintaining system reliability. Using these concepts strategically helps teams balance reliability and innovation, manage user expectations, and handle incidents effectively.

---

## Definitions and Proper Order

To effectively set up reliability metrics, it’s crucial to define SLIs, SLOs, SLAs, and Error Budgets in the correct sequence. 

### Service Level Indicator (SLI)

- **Definition**: An SLI is a specific metric that measures a system's behavior. Examples include request latency, availability percentage, and error rates.
- **Example**: Measuring the **request latency** over a given period.

### Service Level Objective (SLO)

- **Definition**: An SLO is the target for an SLI that defines acceptable performance levels. SLOs are typically set below perfect (e.g., 99.9% availability) to balance reliability and development velocity.
- **Example**: Setting a **latency SLO** for 95% of requests to respond within 200 ms.

### Service Level Agreement (SLA)

- **Definition**: An SLA is a formal contract with customers that outlines the expected performance and the penalties for breaches. SLAs should align with SLOs but are legally binding.
- **Example**: An SLA might stipulate that **99.9% availability** must be met monthly, or else credits/refunds are issued.

### Error Budget

- **Definition**: An Error Budget is the allowable amount of time a service can fail or operate below its SLO. It provides a controlled way to manage risk and balance reliability with development speed.
- **Example**: If your SLO is 99.9% availability, the error budget allows for 0.1% downtime (about 43.2 minutes per month).

### Proper Order for Implementation

1. **Define SLIs** to decide what will be measured.
2. **Set SLOs** to target desired performance.
3. **Establish SLAs** for contractual obligations with external customers.
4. **Allocate an Error Budget** based on the SLO to manage development and reliability trade-offs.

---

# Applying SLIs, SLOs, SLAs, and Error Budgets

| Criteria                  | Greenfield Project                        | Mature Product                        |
|---------------------------|-------------------------------------------|---------------------------------------|
| **Define SLIs**           | Track basic SLIs like availability, latency, and error rate. | Use detailed SLIs (e.g., latency percentiles, geographic availability). |
| **Set SLOs**              | Set an initial SLO target, e.g., 99.9% availability. | Fine-tune SLOs, e.g., 99.95% availability, aligned with business goals. |
| **Establish SLAs**        | Delay setting SLAs until stable, after SLOs are consistently met. | Commit to SLAs based on customer needs with possible penalties for breaches. |
| **Allocate Error Budget** | Allow a 0.1% error budget for development flexibility. | Limit risk with a smaller error budget, e.g., 0.05%, to ensure reliability. |
| **SLO Miss Policy**       | Restrict deployments if the error budget is exceeded, prioritize bug fixes. | Freeze new features, require incident review, and implement reliability improvements if error budget is exhausted. |
| **Continuous Improvement** | Quarterly review of SLOs; adjust if system performance exceeds expectations. | Quarterly review; if SLOs are exceeded, consider raising SLOs to enhance reliability further. |

## Error Budget and SLO Miss Policy

When an SLO is missed, the **Error Budget** acts as a buffer to manage trade-offs between reliability and feature deployment. Here are examples of Error Budget policies for missed SLOs:

### Greenfield Project
- **Policy**: Limit deployments or require approvals if the error budget is exceeded.
- **Action**: If the error budget is exhausted, restrict deployments for one week and prioritize bug fixes.

### Mature Product
- **Policy**: Immediate response required when SLO is breached, with more restrictive measures.
- **Action**: Freeze all new feature deployments, require an incident review, and implement reliability improvements.

The policy helps maintain reliability by pausing new development until system health is restored.

## Continuous Improvement of SLO Targets

**SLO targets** should not remain static. Periodic reviews, ideally every quarter, help align SLOs with evolving system performance and user expectations. For example:

- If SLOs are consistently met, consider tightening targets to improve reliability.
- Conversely, if targets are frequently missed without clear impacts, re-evaluate whether they are set too high.

### Example

For a mature product:
1. **Current SLO**: 99.9% availability.
2. **Review Findings**: SLO is consistently exceeded at 99.95%.
3. **Action**: Raise the SLO to 99.95% to match current performance and increase reliability.

## Why 100% SLO Is Unrealistic

Striving for 100% reliability is impractical because:
- **Resource Constraints**: Maintaining perfect uptime requires exponentially increasing resources, which can be cost-prohibitive.
- **Human Error**: Systems depend on people, who may make mistakes that affect uptime.
- **External Dependencies**: Reliance on third-party services or hardware can introduce failures beyond your control.

### Example

Instead of aiming for 100% availability, a **99.99% availability** SLO allows for minor, non-disruptive downtimes, balancing reliability with resource efficiency.



# Service Level Objectives (SLOs)
At the end of this file a list like this one should be created 
| **SLO Category** | **Objective**                                                | **Target**                                  | **SLI (Service Level Indicator)**                                                                           | **Error Budget**                                                 |
|------------------|--------------------------------------------------------------|---------------------------------------------|-------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| **Latency**      | REST API should respond within 100 milliseconds.             | 95% of requests should complete within 100 ms. | Percentage of requests completing under 100 ms (measured via Prometheus latency metrics).                    | 5% of requests may exceed the 100 ms latency threshold.          |
| **Availability** | Maintain low error rates to ensure high service availability. | Less than 10% of requests result in errors. | Percentage of requests without errors (measured via HTTP response codes and error logs).                     | 10% of requests may result in errors before intervention.        |
| **Traffic**      | Ensure network stability by monitoring transmitted bytes.     | Total bytes transmitted per container stays within expected thresholds. | Rate of bytes transmitted per container (measured via network metrics in Prometheus).                        | Up to 5% above expected transmission rate before scaling.        |
