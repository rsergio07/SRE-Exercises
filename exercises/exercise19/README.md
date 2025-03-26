# **Performing Chaos Engineering in Kubernetes**

## **Table of Contents**
- [Introduction](#introduction)
- [What is Chaos Engineering?](#what-is-chaos-engineering)
- [Why Use Chaos Engineering in SRE?](#why-use-chaos-engineering-in-sre)
- [Preconditions](#preconditions)
- [Navigate to the Directory](#navigate-to-the-directory)
- [Step 1 – Install LitmusChaos](#step-1--install-litmuschaos)
- [Step 2 – Deploy a Sample Application](#step-2--deploy-a-sample-application)
- [Step 3 – Apply Chaos Experiments](#step-3--apply-chaos-experiments)
  - [Pod Delete Experiment](#pod-delete-experiment)
  - [Network Latency Experiment](#network-latency-experiment)
- [Step 4 – Observe and Analyze](#step-4--observe-and-analyze)
- [Final Objective](#final-objective)
- [Cleanup](#cleanup)

---

## **Introduction**

In this exercise, you will explore the fundamentals of Chaos Engineering by simulating failures in a Kubernetes cluster. Using LitmusChaos, a popular chaos engineering tool, you will inject failures such as pod deletion and network latency, which helps test the resilience of your system. This lab is designed to demonstrate how SREs can improve fault tolerance and recovery strategies in production systems.

---

## **What is Chaos Engineering?**

Chaos Engineering involves intentionally injecting failures into a system to build confidence in its resilience. The process includes:
- Injecting controlled failures into the system.
- Observing how the system responds.
- Identifying weaknesses before they escalate into real outages.

For more details, refer to the [LitmusChaos documentation](https://litmuschaos.github.io/).

---

## **Why Use Chaos Engineering in SRE?**

Chaos Engineering helps SRE teams:
- Validate the resiliency of microservices under failure conditions.
- Uncover blind spots in monitoring and alerting.
- Test auto-healing, rollback strategies, and failover mechanisms.
- Proactively reduce Mean Time To Recovery (MTTR) during incidents.

---

## **Preconditions**

Ensure you have the following before beginning this exercise:
- A running Kubernetes cluster (e.g., Minikube).
- `kubectl` installed and configured.
- Internet connectivity to download LitmusChaos manifests.

---

## **Navigate to the Directory**

Change your working directory to the exercise folder:
```bash
cd sre-abc-training/exercises/exercise19
```

---

## **Step 1 – Install LitmusChaos**

Install LitmusChaos to perform chaos experiments.

1. **Create a namespace for LitmusChaos:**
   ```bash
   kubectl create ns litmus
   ```

2. **Install LitmusChaos using the official manifest:**
   ```bash
   kubectl apply -f https://litmuschaos.github.io/litmus/litmus-operator-v3.0.0.yaml -n litmus
   ```

3. **Wait until all pods in the `litmus` namespace are running:**
   ```bash
   kubectl get pods -n litmus
   ```

---

## **Step 2 – Deploy a Sample Application**

Deploy a simple NGINX application to simulate chaos experiments.

1. **Create a namespace for the demo:**
   ```bash
   kubectl create ns chaos-demo
   ```

2. **Deploy the NGINX application:**
   ```bash
   kubectl create deployment nginx --image=nginx -n chaos-demo
   ```

3. **Expose the deployment:**
   ```bash
   kubectl expose deployment nginx --port=80 --target-port=80 -n chaos-demo
   ```

4. **Verify the deployment is running:**
   ```bash
   kubectl get all -n chaos-demo
   ```

---

## **Step 3 – Apply Chaos Experiments**

We will apply two predefined chaos experiments stored under the `chaos/` directory. These experiments are designed safely to target the NGINX pod in the `chaos-demo` namespace.

### **Pod Delete Experiment**

This experiment simulates unexpected deletion of a pod to test system resiliency.

- **Apply the experiment:**
  ```bash
  kubectl apply -f chaos/pod-delete.yaml
  ```

### **Network Latency Experiment**

This experiment introduces artificial network delay to assess application responsiveness under suboptimal network conditions.

- **Apply the experiment:**
  ```bash
  kubectl apply -f chaos/network-latency.yaml
  ```

---

## **Step 4 – Observe and Analyze**

Monitor your system's behavior during chaos injection:

1. **Watch the status of the pods:**
   ```bash
   kubectl get pods -n chaos-demo -w
   ```
   
2. **Describe chaos engine events:**
   ```bash
   kubectl describe chaosengines -n chaos-demo
   ```

If you have monitoring tools like Prometheus or Grafana set up, observe key metrics such as CPU, memory usage, and response times. Additionally, verify:
- The deployment controller restarts any deleted pods.
- Traffic recovers after recovery from induced latency.

---

## **Final Objective**

By the end of this practice, you should be able to:
- Understand the role of chaos experiments in enhancing system resilience.
- Deploy and execute LitmusChaos experiments (e.g., pod deletion and network latency).
- Monitor system reactions and validate the effectiveness of self-healing mechanisms.
- Integrate chaos testing into your overall reliability and SRE strategy.

---

## **Cleanup**

Remove all the resources created during this exercise:

1. **Delete the demo namespace:**
   ```bash
   kubectl delete ns chaos-demo
   ```

2. **Delete the LitmusChaos namespace:**
   ```bash
   kubectl delete ns litmus
   ```

---