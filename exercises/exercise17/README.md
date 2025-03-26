# **Automating Kubernetes Deployments with ArgoCD**

## **Table of Contents**

- [Introduction](#introduction)
- [What is ArgoCD?](#what-is-argocd)
- [Why Use ArgoCD in SRE?](#why-use-argocd-in-sre)
- [Preconditions](#preconditions)
- [Navigate to the Directory](#navigate-to-the-directory)
- [Step 1 – Install ArgoCD on Minikube](#step-1--install-argocd-on-minikube)
- [Step 2 – Port Forward the ArgoCD UI](#step-2--port-forward-the-argocd-ui)
- [Step 3 – Login via the ArgoCD CLI](#step-3--login-via-the-argocd-cli)
- [Step 4 – Create ArgoCD App and Project](#step-4--create-argocd-app-and-project)
- [Step 5 – Sync Application](#step-5--sync-application)
- [Expected Outcome](#expected-outcome)
- [Cleanup](#cleanup)

---

## **Introduction**

This exercise introduces **ArgoCD**, a Kubernetes-native continuous delivery tool built on GitOps principles. In this exercise, we will continue working with the sample application used throughout previous practices, this time managing its deployment declaratively with ArgoCD.

You will learn how to deploy ArgoCD in Minikube, connect it to your Git repository, and use it to automatically deploy your application based on changes to your Git manifests.

---

## **What is ArgoCD?**

**ArgoCD** is a declarative GitOps continuous delivery tool for Kubernetes. It:

- Monitors Git repositories for changes to Kubernetes manifests.
- Automatically applies changes to your cluster based on the declared state.
- Provides both a web UI and a command-line interface (CLI) for managing your deployments.

---

## **Why Use ArgoCD in SRE?**

SRE teams can leverage ArgoCD to:

- Eliminate manual deployment steps.
- Enforce version-controlled configuration for applications and infrastructure.
- Quickly roll back to a previous stable state.
- Enhance auditability and reliability of production deployments.

---

## **Preconditions**

- A running **Minikube** cluster.
- Basic familiarity with Kubernetes and `kubectl` commands.
- An application image already available in a public registry (e.g., DockerHub).
- (Optional) ArgoCD CLI installed. You can install it using:
  ```bash
  brew install argocd
  ```

---

## **Navigate to the Directory**

Before starting, change your working directory to the exercise folder:

```bash
cd sre-abc-training/exercises/exercise17
```

> ⚠️ **Note:** All necessary files for this exercise already exist in the `argocd/` folder. You only need to edit them with the correct repository and path information.

---

## **Step 1 – Install ArgoCD on Minikube**

1. Create the `argocd` namespace:
   ```bash
   kubectl create namespace argocd
   ```

2. Deploy ArgoCD using the official installation manifest:
   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. Wait until all pods in the `argocd` namespace are in the `Running` state:
   ```bash
   kubectl get pods -n argocd
   ```

---

## **Step 2 – Port Forward the ArgoCD UI**

Forward the ArgoCD UI server to your local machine:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open your browser and go to: [http://localhost:8080](http://localhost:8080)

**Default Credentials:**
- **Username:** `admin`
- **Password:** Retrieve using:
  ```bash
  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
  ```

---

## **Step 3 – Login via the ArgoCD CLI**

Use the CLI to log in to your ArgoCD instance:

```bash
argocd login localhost:8080 --insecure
```

Enter the same password retrieved in the previous step when prompted.

---

## **Step 4 – Create ArgoCD App and Project**

1. Edit the files in the `argocd/` folder:
   - `project.yaml`: Defines the boundaries (namespaces, clusters, etc.) for your app.
   - `app.yaml`: Specifies the Git repo, path, and sync settings to deploy the app.

> 💡 Be sure to update the following fields:
> - `repoURL`: The HTTPS link to your GitHub repo (e.g., `https://github.com/<your-username>/sre-abc-training`)
> - `targetRevision`: Typically `main`
> - `path`: The path to your app (e.g., `exercises/exercise10` or another folder containing Kubernetes manifests)

2. Apply the configuration:

```bash
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/app.yaml
```

> 🔍 **Troubleshooting Tip:** If the sync fails, ensure the `repoURL`, `targetRevision`, and `path` values in `app.yaml` are correct and accessible from ArgoCD.

---

## **Step 5 – Sync Application**

Synchronize your application using either of the following methods:

### Option 1: Via the UI
- Open the ArgoCD UI.
- Navigate to the **Applications** view.
- Select your application (e.g., `sre-app`) and click **SYNC**.

### Option 2: Via the CLI

```bash
argocd app sync sre-app
```

---

## **Expected Outcome**

- The application is deployed to the designated namespace (e.g., `application`).
- The ArgoCD UI shows the application as `Healthy` and `Synced`.
- You can verify the deployment by running:

```bash
kubectl get all -n application
```

---

## **Cleanup**

To clean up the resources deployed by this exercise, run:

```bash
argocd app delete sre-app --yes
kubectl delete namespace application
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

---