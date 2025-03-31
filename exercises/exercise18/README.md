# **Rolling Updates and Rollbacks in Kubernetes**

## **Table of Contents**
- [Introduction](#introduction)
- [Navigate to the Directory](#navigate-to-the-directory)
- [Why Practice Rollbacks?](#why-practice-rollbacks)
- [What You Will Learn](#what-you-will-learn)
- [Versioned Deployments](#versioned-deployments)
  - [Step 1: Apply Version 1](#step-1-apply-version-1)
  - [Step 2: Apply Version 2 (Simulate a Faulty Deployment)](#step-2-apply-version-2-simulate-a-faulty-deployment)
  - [Step 3: Roll Back to Version 1](#step-3-roll-back-to-version-1)
- [Verify Rollback](#verify-rollback)
- [Expected Outcome](#expected-outcome)
- [Troubleshooting Tips](#troubleshooting-tips)
- [Cleanup](#cleanup)

---

## **Introduction**

In this exercise, you will simulate a faulty deployment of an application and perform a rollback using Kubernetes’ native deployment strategies. This exercise reflects a real-world scenario where a new release introduces issues, necessitating an immediate rollback to restore service availability.

---

## **Navigate to the Directory**

Before proceeding, ensure you are in the correct working directory:

```bash
cd sre-abc-training/exercises/exercise18
```

---

## **Why Practice Rollbacks?**

In Production, achieving high availability is critical. While rolling updates aim to minimize downtime, issues can still occur. Learning how to:
- Quickly detect deployment issues
- Roll back to a known-good version  
is essential to protect service level agreements (SLAs) and reduce user impact.

---

## **What You Will Learn**

- How to apply versioned deployments using Kubernetes manifests.
- How to simulate a faulty deployment.
- How to use `kubectl rollout undo` to perform a rollback.
- How Kubernetes maintains deployment history for traceability.

---

## **Versioned Deployments**

This exercise uses two preconfigured Kubernetes manifests:
- `v1/deployment.yaml`: A stable, working version of the application.
- `v2/deployment.yaml`: A faulty or misconfigured version to simulate a deployment issue.

> **Note:** These files are pre-created for this lab. Do not create them manually.

---

### **Step 1: Apply Version 1**

Apply the stable version of the application:

```bash
kubectl apply -f v1/deployment.yaml
```

Then check the deployment status and list pods:

```bash
kubectl rollout status deployment sre-rollback-app
kubectl get pods
```

Open the application in your browser:

```bash
minikube service sre-rollback-service
```

*Expected output:*  
"Version 1 - Stable release"

---

### **Step 2: Apply Version 2 (Simulate a Faulty Deployment)**

Simulate a problematic update by applying the faulty version:

```bash
kubectl apply -f v2/deployment.yaml
```

Monitor the rollout and inspect pods:

```bash
kubectl rollout status deployment sre-rollback-app
kubectl get pods
```

Access the application again:

```bash
minikube service sre-rollback-service
```

*Expected output:*  
"Version 2 - Broken build"

---

### **Step 3: Roll Back to Version 1**

Restore the last known-good version using the rollback command:

```bash
kubectl rollout undo deployment sre-rollback-app
```

Verify that the rollback has been successful:

```bash
kubectl rollout status deployment sre-rollback-app
kubectl get pods
```

Open the service one more time:

```bash
minikube service sre-rollback-service
```

*Expected output:*  
"Version 1 - Stable release"

---

## **Verify Rollback**

Review the deployment history by running:

```bash
kubectl rollout history deployment sre-rollback-app
```

This command helps you confirm that the rollback restored the previous revision and provides traceability of past deployments.

---

## **Expected Outcome**

At the end of this exercise, you should have:
- Simulated a faulty deployment with Version 2.
- Rolled back to a stable Version 1.
- Validated the changes using both `kubectl` and accessing the application via Minikube.
- Gained an understanding of Kubernetes deployment history.

---

## **Troubleshooting Tips**

- **Deployment Issues:**  
  If `kubectl rollout status` hangs or shows errors, ensure that your cluster has sufficient resources and that all pods are scheduled properly.
  
- **Service Unavailability:**  
  If the application does not respond via `minikube service sre-rollback-service`, check pod logs using:
  ```bash
  kubectl logs <pod-name>
  ```

- **Rollback Failure:**  
  If the rollback does not occur as expected, inspect the deployment history for errors and confirm that the deployment manifests are correctly configured.

---

## **Cleanup**

Remove all deployed resources to clean up your cluster:

```bash
kubectl delete deployment sre-rollback-app
kubectl delete service sre-rollback-service
```

---