# SRE (Site Reliability Engineering) Process

---

## Introduction

Site Reliability Engineering (SRE) applies software engineering principles to operations to build scalable and highly reliable systems. SRE ensures system availability, reduces toil, and drives continuous improvement—striking a balance between innovation velocity and risk management.

This repository offers a step-by-step learning path with hands-on exercises and supporting topics that introduce core SRE concepts, practices, and tooling. Each section contains clear objectives along with real-world examples for both aspiring and experienced SRE professionals.

---

## Getting Started

Before beginning any exercise or topic, clone the repository to your local machine:

```bash
git clone https://github.com/cguilencr/sre-abc-training.git
cd sre-abc-training
```

This will give you access to all the exercises (located in the `exercises/` folder) and topics (located in the `topicX/` folders).

---

## Table of Contents

- [Topics](#topics)
- [Exercises](#exercises)
- [Learning Path](#learning-path)
- [Final Objectives](#final-objectives)
- [Notes](#notes)

---

## Topics

- [Topic 0 – SLIs, SLOs, SLAs, and Error Budgets](./exercises/topic0/)
- [Topic 1 – Time to Detect, Acknowledge, and Resolve](./exercises/topic1/)
- [Topic 2 – Synthetic Monitoring](./exercises/topic2/)
- [Topic 3 – Operational Readiness Review (ORR)](./exercises/topic3/)
- [Topic 4 – Managing Tasks with GitHub Projects](./exercises/topic4/)

---

## Exercises

| Exercise # | Title                                  | Link                                          | Description                                      |
|------------|----------------------------------------|-----------------------------------------------|--------------------------------------------------|
| 1          | Python app                             | [Exercise #1](./exercises/exercise1/)         | Build and run a simple Python Flask application. |
| 2          | App packaged as image                  | [Exercise #2](./exercises/exercise2/)         | Package the Python app as a Docker image.        |
| 3          | App image pushed to a registry         | [Exercise #3](./exercises/exercise3/)         | Push the Docker image to a container registry.   |
| 4          | Running the app as a service           | [Exercise #4](./exercises/exercise4/)         | Deploy the Docker image as a service.            |
| 4.1        | IaC with Ansible                       | [Exercise #4.1](./exercises/exercise4.1/)     | Use Ansible for Infrastructure as Code (IaC).    |
| 5          | Include Prometheus                     | [Exercise #5](./exercises/exercise5/)         | Integrate Prometheus for monitoring.             |
| 6          | Include Grafana                        | [Exercise #6](./exercises/exercise6/)         | Integrate Grafana for visualization.             |
| 7          | Share node metrics                     | [Exercise #7](./exercises/exercise7/)         | Collect and share node metrics.                  |
| 8          | Share app traces                       | [Exercise #8](./exercises/exercise8/)         | Collect and share application traces.            |
| 9          | Create metrics from traces             | [Exercise #9](./exercises/exercise9/)         | Create metrics based on application traces.      |
| 10         | Share app logs                         | [Exercise #10](./exercises/exercise10/)       | Set up log sharing and observability.            |
| 11         | Golden Signals Dashboard               | [Exercise #11](./exercises/exercise11/)       | Create a dashboard for golden signals monitoring.|
| 12         | Define alerts                          | [Exercise #12](./exercises/exercise12/)       | Define and configure alerts.                     |
| 13         | Automate runbooks with Ansible + AWX   | [Exercise #13](./exercises/exercise13/)       | Automate runbooks using Ansible and AWX.         |
| 14         | Helm Charts                            | [Exercise #14](./exercises/exercise14/)       | Use Helm charts for application deployment.      |
| 15         | Terraform                              | [Exercise #15](./exercises/exercise15/)       | Manage infrastructure with Terraform.            |
| 16         | CI/CD with GitHub Actions              | [Exercise #16](./exercises/exercise16/)       | Implement CI/CD pipelines with GitHub Actions.   |
| 17         | GitOps with ArgoCD                     | [Exercise #17](./exercises/exercise17/)       | Practice GitOps using ArgoCD.                    |
| 18         | Kubernetes Rollback                    | [Exercise #18](./exercises/exercise18/)       | Perform rollbacks in Kubernetes.                 |
| 19         | Chaos Engineering                      | [Exercise #19](./exercises/exercise19/)       | Conduct chaos engineering experiments.           |

---

## Learning Path

1. **Start with the Topics (Topic 0 to Topic 4):**  
   These foundational concepts are essential for understanding SRE principles before diving into practical labs.

2. **Proceed Through the Exercises Sequentially (Exercise 1 to Exercise 19):**  
   The exercises build upon each other, guiding you from application creation and packaging to comprehensive monitoring, automation, and resilience engineering.

---

## Final Objectives

By completing all topics and exercises, you will:
- Learn and apply key SRE concepts in real-world labs.
- Deploy a containerized application and set up monitoring and alerting.
- Automate infrastructure management using tools like Ansible, Helm, and Terraform.
- Practice GitOps with ArgoCD and CI/CD with GitHub Actions.
- Run chaos experiments to enhance system resilience.
- Manage tasks using GitHub Projects with a production-oriented mindset.

---

## Notes

- This repository is part of a practical training series developed for SRE bootcamps and team onboarding.
- It is optimized for environments like Minikube but can be adapted to other Kubernetes setups.
- Contributions and improvements are welcome. If you encounter issues or have suggestions, please open a pull request or GitHub issue.

Happy learning and implementing SRE best practices!

![SRE Bootcamp](https://img.shields.io/badge/SRE-Bootcamp-blue)