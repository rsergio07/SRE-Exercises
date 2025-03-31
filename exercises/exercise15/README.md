# **Infrastructure Automation with Terraform**

## **Table of Contents**
- [Introduction](#introduction)
- [Why Use Terraform in SRE?](#why-use-terraform-in-sre)
- [Terraform Workflow](#terraform-workflow)
- [Files Provided](#files-provided)
- [Navigate to the Directory](#navigate-to-the-directory)
- [Prerequisites](#prerequisites)
- [Step-by-Step Instructions](#step-by-step-instructions)
- [Expected Outcome](#expected-outcome)
- [Verify Deployment](#verify-deployment)
- [Cleanup](#cleanup)
- [Important Notes](#important-notes)
- [Final Objective](#final-objective)

---

## **Introduction**

In previous exercises, we used Helm Charts, YAML manifests, and Ansible to manage Kubernetes resources. In this practice, we will explore another **Infrastructure as Code (IaC)** tool widely used in the SRE world — **Terraform**.

Terraform allows us to declaratively provision cloud and Kubernetes infrastructure in a consistent and reproducible way using code.

---

## **Why Use Terraform in SRE?**

Terraform brings several benefits for Site Reliability Engineers:
- **Declarative Configuration**: Define the desired state of infrastructure and let Terraform handle the rest.
- **Version Control**: Infrastructure code can be committed, reviewed, and audited like application code.
- **State Management**: Maintains a state file to track deployed infrastructure.
- **Platform Agnostic**: Supports multiple providers (AWS, GCP, Azure, Kubernetes, etc.).
- **Repeatability**: Avoids manual drift by always applying the latest infrastructure state.

---

## **Terraform Workflow**

Here’s how a typical Terraform workflow looks for deploying resources in Kubernetes:

1. **Write Code**: Define resources in `.tf` files (main.tf, variables.tf, etc.).
2. **Initialize**: Run `terraform init` to prepare Terraform for use.
3. **Preview Changes**: Run `terraform plan` to review what will be created.
4. **Apply**: Run `terraform apply` to deploy the infrastructure.
5. **Track State**: Terraform keeps a `.tfstate` file to manage resource changes over time.

> 🧪 We include a `terraform.tfstate.example` file in this repo for **educational purposes only**. This file is NOT used during the live deployment but illustrates what Terraform’s state tracking file looks like.

---

## **Files Provided**

- **main.tf** – Defines Kubernetes Namespace, Deployment, and Service.
- **variables.tf** – Contains configurable values like namespace, image, ports, etc.
- **outputs.tf** – Displays output after a successful deployment.
- **terraform.tfstate.example** – Shows what a Terraform state file looks like (not functional).

---

## **Navigate to the Directory**

Before proceeding, navigate to the correct directory:

```bash
cd sre-abc-training/exercises/exercise15
```

---

## **Prerequisites**

Make sure the following tools are installed and configured:
- **Terraform CLI v1.3+**
- **Kubernetes cluster (via Minikube or Docker Desktop)**
- **kubectl is configured and connected to your running cluster**
- **Terraform Kubernetes provider plugins installed (`terraform init` does this automatically)**

---

## **Step-by-Step Instructions**

1. **Initialize the Terraform working directory**:

    ```bash
    terraform init
    ```

2. **Preview the changes Terraform will make**:

    ```bash
    terraform plan
    ```

3. **Apply the configuration to deploy your app**:

    ```bash
    terraform apply
    ```

    You will be prompted to confirm:

    ```plaintext
    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes
    ```

---

## **Expected Outcome**

After applying the configuration:
- A new namespace named `application` is created
- A deployment named `sre-abc-training-app` with 3 replicas is created
- A service named `sre-abc-training-app-service` is created as a NodePort
- Output will confirm the names of the created resources

---

## **Verify Deployment**

1. **Check deployed resources**:

    ```bash
    kubectl get all -n application
    ```

2. **Access the application using Minikube**:

    ```bash
    minikube service sre-abc-training-app-service -n application
    ```

    This should open your default browser and display the “Hello, World!” message from the Python app.

---

## **Cleanup**

To destroy all resources created by Terraform:

```bash
terraform destroy
```

Confirm when prompted:

```plaintext
Do you really want to destroy all resources?
Terraform will destroy all your managed infrastructure, as shown above.
Only 'yes' will be accepted to confirm.

Enter a value: yes
```

---

## **Important Notes**

- The `terraform.tfstate` file is auto-generated. Do not edit it manually.
- You can version control it in learning projects but consider using remote state (e.g., AWS S3) in production.
- Terraform does not detect changes made outside of its control unless you run `terraform refresh`.

---

## **Final Objective**

By the end of this exercise, you should be able to:
- Understand how to use Terraform to deploy Kubernetes resources
- Apply the IaC approach to manage application deployments
- Track and destroy infrastructure cleanly
- Appreciate the advantages of Terraform in cloud-native SRE workflows

---