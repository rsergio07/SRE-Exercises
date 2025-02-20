# **Automating a Runbook for Incident Reporting with AWX and Grafana**

## **Table of Contents**

- [Introduction](#introduction)
- [Navigate to Directory](#navigate-to-directory)
- [Understanding Ansible, AWX, and Operators](#understanding-ansible-awx-and-operators)
- [Installing AWX Operator Using Helm](#installing-awx-operator-using-helm)  
- [Setting Up a Project and Runbook in Ansible AWX](#setting-up-a-project-and-runbook-in-ansible-awx)  
- [Executing Ansible Scripts in AWX via REST API](#executing-ansible-scripts-in-awx-via-rest-api)  
- [Configure Grafana to Trigger the AWX Job](#configure-grafana-to-trigger-the-awx-job)  
- [Deployment](#deployment)  
- [Tip for Infrastructure as Code (IaC) with Ansible](#tip-for-infrastructure-as-code-iac-with-ansible)  
- [Final Objective](#final-objective)
- [Cleanup](#cleanup)

---

## **Introduction**
In this exercise, we automate an **incident response runbook** using **AWX** and **Grafana alerts**.  
Whenever an alert is triggered in **Grafana**, it will execute an **AWX job** to collect system status.  

This setup improves **incident resolution** by:
- Automatically gathering **diagnostics**.
- Reducing **manual intervention**.
- Shortening **Time to Resolution (TTR)**.

### **Infrastructure Overview**
![Infrastructure Diagram](./Infra.png)

---

## **Navigate to Directory**
Before proceeding, navigate to the correct directory:

```bash
cd sre-abc-training/exercises/exercise13
```

---

# What is a Runbook?
A runbook is a structured document or automated script that provides step-by-step instructions to resolve specific operational tasks or incidents. In the context of Site Reliability Engineering (SRE), runbooks are invaluable for documenting:

- Common incident resolution steps.
- Operational workflows.
- Routine maintenance procedures.

Runbooks are designed to ensure consistency and reduce human error, enabling teams to respond more effectively to issues and perform repetitive tasks with greater reliability.

## Automating Runbooks
Automating runbooks transforms static instructions into dynamic, executable processes. Instead of relying on manual intervention, automated runbooks leverage tools and scripts to perform tasks with minimal human input. Automation can be achieved through scripting languages, orchestration tools, or platforms like Ansible.

### Benefits of Automating Runbooks
1. **Time to Detect (TTD):** Automated monitoring integrated with runbooks can identify issues and trigger actions immediately, reducing the delay between an issue occurring and it being detected.

2. **Time to Acknowledge (TTA):** Automating notifications and initial responses can ensure that incidents are acknowledged faster, either by alerting the right team or initiating predefined actions.

3. **Time to Resolve (TTR):** Automated steps within runbooks can:
   - Execute diagnostic commands to gather relevant data.
   - Perform common remediation actions (e.g., restarting services, clearing caches).
   - Escalate unresolved issues with detailed logs and context.

By automating runbooks, organizations can reduce downtime, improve incident response, and enhance overall system reliability.

### Example Use Cases
- **Incident Resolution:** Automatically restart a failing service or scale up resources during high traffic.
- **Diagnostics:** Collect system logs and metrics when an alert is triggered.
- **Routine Maintenance:** Automate tasks like database backups or clearing temporary files.

### Sample Workflow
1. **Monitoring System:** Detects an issue (e.g., high CPU usage).
2. **Trigger:** The monitoring system triggers an alert and invokes an Ansible playbook.
3. **Automated Runbook Execution:**
   - Diagnoses the issue (e.g., collects logs).
   - Applies a resolution (e.g., restarts the service).
4. **Notification:** Sends a summary of actions taken to the on-call engineer.

---

# Understanding Ansible, AWX, and Operators

## What is Ansible?

Ansible is an open-source automation tool designed for IT tasks like configuration management, application deployment, and orchestration. It uses a simple YAML-based language called Playbooks to define the desired state of your systems. Ansible is agentless, meaning it does not require any software installation on the target systems. Instead, it uses SSH or APIs for communication.

## What are Kubernetes Operators vs Ansible Operators?

### Kubernetes Operators
Kubernetes Operators extend the Kubernetes API to manage complex, stateful applications. They encapsulate the operational knowledge of running an application in code, enabling automation of tasks like scaling, upgrading, and maintaining applications.

Key features of Kubernetes Operators:
- Written in languages like Go.
- Deeply integrated with Kubernetes.
- Provide domain-specific logic for managing Kubernetes resources.

### Ansible Operators
Ansible Operators are a type of Kubernetes Operator that use Ansible Playbooks and Roles to manage the lifecycle of Kubernetes applications. They leverage Ansible's simplicity and do not require custom Go code for implementation.

Key features of Ansible Operators:
- Use existing Ansible Playbooks for Kubernetes resource management.
- Easier to write and maintain compared to traditional Kubernetes Operators.
- Built using the Operator Framework, making it simpler to create operators for complex applications.

## What is Ansible AWX?

Ansible AWX is the open-source upstream project for **Red Hat Ansible Automation Platform**. It provides a web-based user interface, REST API, and task engine to manage and execute Ansible Playbooks at scale.

Key features of AWX:
- Centralized management for Ansible Playbooks, inventories, and credentials.
- Role-based access control (RBAC) to define user permissions.
- Visual job templates for managing automation tasks.
- Integration with source control (e.g., Git) for Playbooks.

AWX allows you to build, manage, and track automation tasks more effectively, and it serves as a foundation for enterprises looking to scale their automation efforts.

---

## Summary

| Concept              | Description                                                                                   |
|----------------------|-----------------------------------------------------------------------------------------------|
| **Ansible**          | Automation tool for managing IT tasks using YAML-based Playbooks.                            |
| **Kubernetes Operator** | A Kubernetes-native way to automate application management, often written in Go.           |
| **Ansible Operator** | A Kubernetes Operator that uses Ansible Playbooks instead of Go for application automation.   |
| **Ansible AWX**      | Open-source UI and API for managing and scaling Ansible automation.                          |

Ansible and its ecosystem provide versatile tools for both traditional IT environments and Kubernetes-based cloud-native applications.

---

## Installing AWX Operator Using Helm

Ansible can now be installed using the following commands:

```bash
brew install helm
helm repo add awx-operator https://ansible-community.github.io/awx-operator-helm/
helm install my-awx-operator awx-operator/awx-operator -n awx --create-namespace
```
Source: AWX Operator Helm Chart from https://ansible-community.github.io/awx-operator-helm/

### Steps to Deploy AWX:

1. Wait until the pod awx-operator-controller-manager-*** is in a running state.
```bash
kubectl get pods -n awx
```

2. Apply the AWX Demo deployment:
```bash
kubectl apply -f awx-demo.yml
```

3. Wait for the awx-demo-service to become available:
```bash
kubectl get service awx-demo-service -n awx
```

4. Access the AWX service:
```bash
minikube service awx-demo-service -n awx
```

5. Retrieve the admin password:
```bash
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo
```

---

# Setting Up a Project and Runbook in Ansible AWX

This guide outlines the steps to create a project and an Ansible runbook (job template) in **Ansible AWX**, including how to integrate your project with a Git repository for automation.

## Prerequisites

- Ansible AWX is installed and running.
- You have access to the AWX Web UI and API.
- A Git repository (optional) to store your Ansible playbooks.

## Step 1: Login to Ansible AWX

1. Open your browser and navigate to the AWX web interface, typically at:
``` bash
minikube service awx-demo-service -n awx
```

2. Log in using your admin credentials:
- **Username:** `admin`
- **Password:** You can get the password from the Kubernetes secret (see previous step).
```bash
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo
```

## Step 2: Create a New Project in AWX

1. In the **AWX Web UI**, go to the **Projects** tab in the left-hand menu.

2. Click the **+** button (or **Add** button) to create a new project.

3. Fill out the required fields:
- **Name:** `sre_project` (or any name of your choice)
- **Organization:** Select an existing organization or create a new one.
- **Source Control Type:** Select `Git` 
- **Source Control URL:**  If using a Git repository, provide the URL to your Git repository containing your playbooks. For example:
  ```
  https://github.com/cguillencr/sre-abc-training
  ```
4. After filling out the fields, click **Save** to create the project.

## Step 3: Create a New Runbook (Job Template)

Step 3: Create a New Runbook (Job Template)
A runbook, also known as a job template, defines the execution of a particular playbook. Here's how to create one:

1. Go to the Job Templates tab in the left-hand menu of AWX.

2. Click the + button (or Add button) to create a new job template.

3. Fill out the required fields:

- Name: `Restart application`
- Job Type: Select `Run` (this indicates a job that will execute a playbook).
- Inventory: Choose an inventory from the list (or create a new one if needed).
- Project: Select the project you created in Step 2.
- Playbook: Choose a playbook from the list of available playbooks in your project. If you linked a Git repository, it will list the playbooks from that repository. Use this one `exercises/exercise13/collect-status-application.yaml`
- Credential: Select the credentials required for running the playbook (e.g., SSH key for remote hosts).
4. Optionally, you can enable Limit (to specify which hosts to run the playbook on) and Extra Variables (to pass additional variables to your playbook).

5. After filling out the fields, click Save to create the job template.

![runbook](./images/runbook.png)

## Step 4: Launch the Runbook (Job)

Once the runbook is created, you can run it manually from the AWX Web UI.

1. Go to the Job Templates tab.
2. Find the job template you created in Step 3.
3. Click the Launch button (a green triangle) to execute the playbook.
The job will begin running, and you can monitor its progress on the Jobs page. The job logs will be displayed in real-time, showing the output from the playbook execution.

## Step 5: Monitor and Review Job Status

You can view the status of your job by going to the Jobs tab in AWX. It will display:

The job status (e.g., successful, failed).
The logs for the job execution.
The duration of the job.
If the job fails, you can view the logs for troubleshooting and error resolution.

---

# Executing Ansible Scripts in AWX via REST API

## Prerequisites

### 1. Create an Application in AWX
Before executing scripts, create an application to enable API access:

1. Log in to the AWX web interface.
2. Navigate to **Applications** under **Authentication**.
3. Click **Add** to create a new application.
4. Fill in the fields:
   - **Name**: e.g., `API Access`
   - **Organization**: Select your organization.  e.g., `Default`
   - Enable **Client Type** as "Confidential" and **Authorization Grant Type** as "Resource owner password-based".
5. Save the application to generate the Client ID and Secret.

#### Example:
In my case
```bash
Resource owner password-based
Client ID SXGiXHj4KKFFwrm1lP4YwsGaMV2vP3lFly5hfSjZ

Client Secret
5UiVeTxwJw5ioStaGQxrWgCbQagHOFTBIYkBOWbi7MI3pyyWwFSLnWbowYwtVu5jc79DA0HqdCRM5QgHt6KgCojI5EWj5c7KUPje6T5pixOioSmV79vMtFV0BKewXfLg
```
### 2. Generate an Access Token

1. Go to **Your Profile > Tokens > Create Token**.
1.1 Use the application created above
1.2 Use the writer permission
2. Copy the generated token for API authentication.

#### Example:
In my case
```bash
Token
wpSCyIlK1j8Dy8zM7wTmZ7bbkdgQVE

Refresh Token
Gfr2gKg5NC1QifTZqgA49fBAyuSCZx
```

### 3. Verify API Access
Test connectivity with the AWX API using the token:
```bash
curl -H "Authorization: Bearer <your_token>" http://<awx_host>/api/v2/me/
```

#### Example:
In my case
```bash
cristianguillenmendez@Cristians-MacBook-Pro exercise13 % curl -H "Authorization: Bearer wpSCyIlK1j8Dy8zM7wTmZ7bbkdgQVE" http://192.168.105.19:32728/api/v2/me/
{"count":1,"next":null,"previous":null,"results":[{"id":1,"type":"user","url":"/api/v2/users/1/","related":{"teams":"/api/v2/users/1/teams/","organizations":"/api/v2/users/1/organizations/","admin_of_organizations":"/api/v2/users/1/admin_of_organizations/","projects":"/api/v2/users/1/projects/","credentials":"/api/v2/users/1/credentials/","roles":"/api/v2/users/1/roles/","activity_stream":"/api/v2/users/1/activity_stream/","access_list":"/api/v2/users/1/access_list/","tokens":"/api/v2/users/1/tokens/","authorized_tokens":"/api/v2/users/1/authorized_tokens/","personal_tokens":"/api/v2/users/1/personal_tokens/"},"summary_fields":{"resource":{"ansible_id":"90f9076d-8490-4f34-be5d-423ed3d706c2","resource_type":"shared.user"},"user_capabilities":{"edit":true,"delete":false}},"created":"2024-11-21T17:47:33.840697Z","modified":"2024-11-25T17:19:32.277001Z","username":"admin","first_name":"","last_name":"","email":"test@example.com","is_superuser":true,"is_system_auditor":false,"password":"$encrypted$","ldap_dn":"","last_login":"2024-11-25T17:19:32.277001Z","external_account":null,"auth":[]}]}
```

---

## Steps to Execute an Ansible Script via REST API

### 1. Identify the Job Template
List all Job Templates available in your AWX instance:
```bash
curl -H "Authorization: Bearer <your_token>" http://<awx_host>/api/v2/job_templates/
```
Find the `id` of the Job Template you want to execute.

#### Example:
```bash
cristianguillenmendez@Cristians-MacBook-Pro exercise13 % curl -H "Authorization: Bearer wpSCyIlK1j8Dy8zM7wTmZ7bbkdgQVE" http://192.168.105.19:32728/api/v2/job_templates/
{"count":5,"next":null,"previous":null,"results":[{"id":16,"type":"job_template","url":"/api/v2/job_templates/16/","related":{"created_by":"/api/v2/users/1/","modified_by":"/api/v2/users/1/","labels":"/api/v2/job_templates/16/labels/","project":"/api/v2/projects/12/","organization":"/api/v2/organizations/1/","credentials":"/api/v2/job_templates/16/credentials/","last_job":"/api/v2/jobs/52/","jobs":"/api/v2/job_templates/16/jobs/","schedules":"/api/v2/job_templates/16/schedules/","activity_stream":"/api/v2/job_templates/16/activity_stream/","launch":"/api/v2/job_templates/16/launch/","webhook_key":"/api/v2/job_templates/16/webhook_key/","webhook_receiver":"","notification_templates_started":"/api/v2/job_templates/16/notification_templates_started/","notification_templates_success":"/api/v2/job_templates/16/notification_templates_success/","notification_templates_error":"/api/v2/job_templates/16/notification_templates_error/","access_list":"/api/v2/job_templates/16/access_list/","survey_spec":"/api/v2/job_templates/16/survey_spec/","object_roles":"/api/v2/job_templates/16/object_roles/","instance_groups":"/api/v2/job_templates/16/instance_groups/","slice_workflow_jobs":"/api/v2/job_templates/16/slice_workflow_jobs/","copy":"/api/v2/job_templates/16/copy/"},"summary_fields":{"organization":{"id":1,"name":"Default","description":""},"project":{"id":12,"name":"sre_project","description":"","status":"successful","scm_type":"git","allow_override":false},"last_job":{"id":52,"name":"demo","description":"","finished":"2024-11-22T21:00:39.369618Z","status":"failed","failed":true},"last_update":{"id":52,"name":"demo","description":"","status":"failed","failed":true},"created_by":{"id":1,"username":"admin","first_name":"","last_name":""},"modified_by":{"id":1,"username":"admin","first_name":"","last_name":""},"object_roles":{"admin_role":{"description":"Can manage all aspects of the job template","name":"Admin","id":83},"execute_role":{"description":"May run the job template","name":"Execute","id":84},"read_role":{"description":"May view settings for the job template","name":"Read","id":85}},"user_capabilities":{"edit":true,"delete":true,"start":false,"schedule":false,"copy":false},"labels":{"count":0,"results":[]},"recent_jobs":[{"id":52,"status":"failed","finished":"2024-11-22T21:00:39.369618Z","canceled_on":null,"type":"job"}],"credentials":[{"id":4,"name":"Machine Host","description":"","kind":"ssh","cloud":false}]},"created":"2024-11-22T21:00:30.634466Z","modified":"2024-11-22T21:00:30.634473Z","name":"demo","description":"","job_type":"run","inventory":null,"project":12,"playbook":"exercises/exercise13/restart-application.yaml","scm_branch":"","forks":0,"limit":"","verbosity":0,"extra_vars":"---","job_tags":"","force_handlers":false,"skip_tags":"","start_at_task":"","timeout":0,"use_fact_cache":false,"organization":1,"last_job_run":"2024-11-22T21:00:39.369618Z","last_job_failed":true,"next_job_run":null,"status":"failed","execution_environment":null,"host_config_key":"","ask_scm_branch_on_launch":false,"ask_diff_mode_on_launch":false,"ask_variables_on_launch":false,"ask_limit_on_launch":false,"ask_tags_on_launch":false,"ask_skip_tags_on_launch":false,"ask_job_type_on_launch":false,"ask_verbosity_on_launch":false,"ask_inventory_on_launch":false,"ask_credential_on_launch":false,"ask_execution_environment_on_launch":false,"ask_labels_on_launch":false,"ask_forks_on_launch":false,"ask_job_slice_count_on_launch":false,"ask_timeout_on_launch":false,"ask_instance_groups_on_launch":false,"survey_enabled":false,"become_enabled":false,"diff_mode":false,"allow_simultaneous":false,"custom_virtualenv":null,"job_slice_count":1,"webhook_service":"","webhook_credential":null,"prevent_instance_group_fallback":false},{"id":7,"type":"job_template","url":"/api/v2/job_templates/7/","related":{"created_by":"/api/v2/users/1/","modified_by":"/api/v2/users/1/","labels":"/api/v2/job_templates/7/labels/","inventory":"/api/v2/inventories/1/","project":"/api/v2/projects/6/","organization":"/api/v2/organizations/1/","credentials":"/api/v2/job_templates/7/credentials/","last_job":"/api/v2/jobs/33/","jobs":"/api/v2/job_templates/7/jobs/","schedules":"/api/v2/job_templates/7/schedules/","activity_stream":"/api/v2/job_templates/7/activity_stream/","launch":"/api/v2/job_templates/7/launch/","webhook_key":"/api/v2/job_templates/7/webhook_key/","webhook_receiver":"","notification_templates_started":"/api/v2/job_templates/7/notification_templates_started/","notification_templates_success":"/api/v2/job_templates/7/notification_templates_success/","notification_templates_error":"/api/v2/job_templates/7/notification_templates_error/","access_list":"/api/v2/job_templates/7/access_list/","survey_spec":"/api/v2/job_templates/7/survey_spec/","object_roles":"/api/v2/job_templates/7/object_roles/","instance_groups":"/api/v2/job_templates/7/instance_groups/","slice_workflow_jobs":"/api/v2/job_templates/7/slice_workflow_jobs/","copy":"/api/v2/job_templates/7/copy/"},"summary_fields":{"organization":{"id":1,"name":"Default","description":""},"inventory":{"id":1,"name":"Demo Inventory","description":"","has_active_failures":true,"total_hosts":1,"hosts_with_active_failures":1,"total_groups":0,"has_inventory_sources":false,"total_inventory_sources":0,"inventory_sources_with_failures":0,"organization_id":1,"kind":""},"project":{"id":6,"name":"Demo Project","description":"","status":"successful","scm_type":"git","allow_override":false},"last_job":{"id":33,"name":"Demo Job Template","description":"","finished":"2024-11-22T17:10:12.222014Z","status":"successful","failed":false},"last_update":{"id":33,"name":"Demo Job Template","description":"","status":"successful","failed":false},"created_by":{"id":1,"username":"admin","first_name":"","last_name":""},"modified_by":{"id":1,"username":"admin","first_name":"","last_name":""},"object_roles":{"admin_role":{"description":"Can manage all aspects of the job template","name":"Admin","id":31},"execute_role":{"description":"May run the job template","name":"Execute","id":32},"read_role":{"description":"May view settings for the job template","name":"Read","id":33}},"user_capabilities":{"edit":true,"delete":true,"start":true,"schedule":true,"copy":true},"labels":{"count":0,"results":[]},"recent_jobs":[{"id":33,"status":"successful","finished":"2024-11-22T17:10:12.222014Z","canceled_on":null,"type":"job"}],"credentials":[]},"created":"2024-11-21T17:47:40.085884Z","modified":"2024-11-21T17:47:40.085890Z","name":"Demo Job Template","description":"","job_type":"run","inventory":1,"project":6,"playbook":"hello_world.yml","scm_branch":"","forks":0,"limit":"","verbosity":0,"extra_vars":"","job_tags":"","force_handlers":false,"skip_tags":"","start_at_task":"","timeout":0,"use_fact_cache":false,"organization":1,"last_job_run":"2024-11-22T17:10:12.222014Z","last_job_failed":false,"next_job_run":null,"status":"successful","execution_environment":null,"host_config_key":"","ask_scm_branch_on_launch":false,"ask_diff_mode_on_launch":false,"ask_variables_on_launch":false,"ask_limit_on_launch":false,"ask_tags_on_launch":false,"ask_skip_tags_on_launch":false,"ask_job_type_on_launch":false,"ask_verbosity_on_launch":false,"ask_inventory_on_launch":false,"ask_credential_on_launch":false,"ask_execution_environment_on_launch":false,"ask_labels_on_launch":false,"ask_forks_on_launch":false,"ask_job_slice_count_on_launch":false,"ask_timeout_on_launch":false,"ask_instance_groups_on_launch":false,"survey_enabled":false,"become_enabled":false,"diff_mode":false,"allow_simultaneous":false,"custom_virtualenv":null,"job_slice_count":1,"webhook_service":"","webhook_credential":null,"prevent_instance_group_fallback":false},{"id":15,"type":"job_template","url":"/api/v2/job_templates/15/","related":{"created_by":"/api/v2/users/1/","modified_by":"/api/v2/users/1/","labels":"/api/v2/job_templates/15/labels/","project":"/api/v2/projects/12/","organization":"/api/v2/organizations/1/","credentials":"/api/v2/job_templates/15/credentials/","last_job":"/api/v2/jobs/50/","jobs":"/api/v2/job_templates/15/jobs/","schedules":"/api/v2/job_templates/15/schedules/","activity_stream":"/api/v2/job_templates/15/activity_stream/","launch":"/api/v2/job_templates/15/launch/","webhook_key":"/api/v2/job_templates/15/webhook_key/","webhook_receiver":"","notification_templates_started":"/api/v2/job_templates/15/notification_templates_started/","notification_templates_success":"/api/v2/job_templates/15/notification_templates_success/","notification_templates_error":"/api/v2/job_templates/15/notification_templates_error/","access_list":"/api/v2/job_templates/15/access_list/","survey_spec":"/api/v2/job_templates/15/survey_spec/","object_roles":"/api/v2/job_templates/15/object_roles/","instance_groups":"/api/v2/job_templates/15/instance_groups/","slice_workflow_jobs":"/api/v2/job_templates/15/slice_workflow_jobs/","copy":"/api/v2/job_templates/15/copy/"},"summary_fields":{"organization":{"id":1,"name":"Default","description":""},"project":{"id":12,"name":"sre_project","description":"","status":"successful","scm_type":"git","allow_override":false},"last_job":{"id":50,"name":"restart","description":"","finished":"2024-11-22T20:48:13.657837Z","status":"failed","failed":true},"last_update":{"id":50,"name":"restart","description":"","status":"failed","failed":true},"created_by":{"id":1,"username":"admin","first_name":"","last_name":""},"modified_by":{"id":1,"username":"admin","first_name":"","last_name":""},"object_roles":{"admin_role":{"description":"Can manage all aspects of the job template","name":"Admin","id":77},"execute_role":{"description":"May run the job template","name":"Execute","id":78},"read_role":{"description":"May view settings for the job template","name":"Read","id":79}},"user_capabilities":{"edit":true,"delete":true,"start":false,"schedule":false,"copy":false},"labels":{"count":0,"results":[]},"recent_jobs":[{"id":50,"status":"failed","finished":"2024-11-22T20:48:13.657837Z","canceled_on":null,"type":"job"}],"credentials":[]},"created":"2024-11-22T20:48:07.456089Z","modified":"2024-11-22T20:48:07.456095Z","name":"restart","description":"","job_type":"run","inventory":null,"project":12,"playbook":"exercises/exercise13/restart-application.yaml","scm_branch":"","forks":0,"limit":"","verbosity":0,"extra_vars":"---","job_tags":"","force_handlers":false,"skip_tags":"","start_at_task":"","timeout":0,"use_fact_cache":false,"organization":1,"last_job_run":"2024-11-22T20:48:13.657837Z","last_job_failed":true,"next_job_run":null,"status":"failed","execution_environment":null,"host_config_key":"","ask_scm_branch_on_launch":false,"ask_diff_mode_on_launch":false,"ask_variables_on_launch":false,"ask_limit_on_launch":false,"ask_tags_on_launch":false,"ask_skip_tags_on_launch":false,"ask_job_type_on_launch":false,"ask_verbosity_on_launch":false,"ask_inventory_on_launch":false,"ask_credential_on_launch":false,"ask_execution_environment_on_launch":false,"ask_labels_on_launch":false,"ask_forks_on_launch":false,"ask_job_slice_count_on_launch":false,"ask_timeout_on_launch":false,"ask_instance_groups_on_launch":false,"survey_enabled":false,"become_enabled":false,"diff_mode":false,"allow_simultaneous":false,"custom_virtualenv":null,"job_slice_count":1,"webhook_service":"","webhook_credential":null,"prevent_instance_group_fallback":false},{"id":11,"type":"job_template","url":"/api/v2/job_templates/11/","related":{"created_by":"/api/v2/users/1/","modified_by":"/api/v2/users/1/","labels":"/api/v2/job_templates/11/labels/","inventory":"/api/v2/inventories/1/","organization":"/api/v2/organizations/1/","credentials":"/api/v2/job_templates/11/credentials/","jobs":"/api/v2/job_templates/11/jobs/","schedules":"/api/v2/job_templates/11/schedules/","activity_stream":"/api/v2/job_templates/11/activity_stream/","launch":"/api/v2/job_templates/11/launch/","webhook_key":"/api/v2/job_templates/11/webhook_key/","webhook_receiver":"","notification_templates_started":"/api/v2/job_templates/11/notification_templates_started/","notification_templates_success":"/api/v2/job_templates/11/notification_templates_success/","notification_templates_error":"/api/v2/job_templates/11/notification_templates_error/","access_list":"/api/v2/job_templates/11/access_list/","survey_spec":"/api/v2/job_templates/11/survey_spec/","object_roles":"/api/v2/job_templates/11/object_roles/","instance_groups":"/api/v2/job_templates/11/instance_groups/","slice_workflow_jobs":"/api/v2/job_templates/11/slice_workflow_jobs/","copy":"/api/v2/job_templates/11/copy/"},"summary_fields":{"organization":{"id":1,"name":"Default","description":""},"inventory":{"id":1,"name":"Demo Inventory","description":"","has_active_failures":true,"total_hosts":1,"hosts_with_active_failures":1,"total_groups":0,"has_inventory_sources":false,"total_inventory_sources":0,"inventory_sources_with_failures":0,"organization_id":1,"kind":""},"created_by":{"id":1,"username":"admin","first_name":"","last_name":""},"modified_by":{"id":1,"username":"admin","first_name":"","last_name":""},"object_roles":{"admin_role":{"description":"Can manage all aspects of the job template","name":"Admin","id":51},"execute_role":{"description":"May run the job template","name":"Execute","id":52},"read_role":{"description":"May view settings for the job template","name":"Read","id":53}},"user_capabilities":{"edit":true,"delete":true,"start":false,"schedule":false,"copy":false},"labels":{"count":0,"results":[]},"recent_jobs":[],"credentials":[]},"created":"2024-11-21T21:57:09.835951Z","modified":"2024-11-21T21:57:09.835970Z","name":"Restart application","description":"","job_type":"run","inventory":1,"project":null,"playbook":"","scm_branch":"","forks":0,"limit":"","verbosity":0,"extra_vars":"---","job_tags":"","force_handlers":false,"skip_tags":"","start_at_task":"","timeout":0,"use_fact_cache":false,"organization":1,"last_job_run":"2024-11-21T21:57:21.522360Z","last_job_failed":true,"next_job_run":null,"status":"failed","execution_environment":null,"host_config_key":"","ask_scm_branch_on_launch":false,"ask_diff_mode_on_launch":false,"ask_variables_on_launch":false,"ask_limit_on_launch":false,"ask_tags_on_launch":false,"ask_skip_tags_on_launch":false,"ask_job_type_on_launch":false,"ask_verbosity_on_launch":false,"ask_inventory_on_launch":false,"ask_credential_on_launch":false,"ask_execution_environment_on_launch":false,"ask_labels_on_launch":false,"ask_forks_on_launch":false,"ask_job_slice_count_on_launch":false,"ask_timeout_on_launch":false,"ask_instance_groups_on_launch":false,"survey_enabled":false,"become_enabled":false,"diff_mode":false,"allow_simultaneous":false,"custom_virtualenv":null,"job_slice_count":1,"webhook_service":"","webhook_credential":null,"prevent_instance_group_fallback":false},{"id":13,"type":"job_template","url":"/api/v2/job_templates/13/","related":{"created_by":"/api/v2/users/1/","modified_by":"/api/v2/users/1/","labels":"/api/v2/job_templates/13/labels/","inventory":"/api/v2/inventories/1/","project":"/api/v2/projects/12/","organization":"/api/v2/organizations/1/","credentials":"/api/v2/job_templates/13/credentials/","last_job":"/api/v2/jobs/60/","execution_environment":"/api/v2/execution_environments/3/","jobs":"/api/v2/job_templates/13/jobs/","schedules":"/api/v2/job_templates/13/schedules/","activity_stream":"/api/v2/job_templates/13/activity_stream/","launch":"/api/v2/job_templates/13/launch/","webhook_key":"/api/v2/job_templates/13/webhook_key/","webhook_receiver":"","notification_templates_started":"/api/v2/job_templates/13/notification_templates_started/","notification_templates_success":"/api/v2/job_templates/13/notification_templates_success/","notification_templates_error":"/api/v2/job_templates/13/notification_templates_error/","access_list":"/api/v2/job_templates/13/access_list/","survey_spec":"/api/v2/job_templates/13/survey_spec/","object_roles":"/api/v2/job_templates/13/object_roles/","instance_groups":"/api/v2/job_templates/13/instance_groups/","slice_workflow_jobs":"/api/v2/job_templates/13/slice_workflow_jobs/","copy":"/api/v2/job_templates/13/copy/"},"summary_fields":{"organization":{"id":1,"name":"Default","description":""},"inventory":{"id":1,"name":"Demo Inventory","description":"","has_active_failures":true,"total_hosts":1,"hosts_with_active_failures":1,"total_groups":0,"has_inventory_sources":false,"total_inventory_sources":0,"inventory_sources_with_failures":0,"organization_id":1,"kind":""},"execution_environment":{"id":3,"name":"Control Plane Execution Environment","description":"","image":"quay.io/ansible/awx-ee:24.6.1"},"project":{"id":12,"name":"sre_project","description":"","status":"successful","scm_type":"git","allow_override":false},"last_job":{"id":60,"name":"Restart application1","description":"","finished":"2024-11-25T15:34:00.247059Z","status":"failed","failed":true},"last_update":{"id":60,"name":"Restart application1","description":"","status":"failed","failed":true},"created_by":{"id":1,"username":"admin","first_name":"","last_name":""},"modified_by":{"id":1,"username":"admin","first_name":"","last_name":""},"object_roles":{"admin_role":{"description":"Can manage all aspects of the job template","name":"Admin","id":58},"execute_role":{"description":"May run the job template","name":"Execute","id":59},"read_role":{"description":"May view settings for the job template","name":"Read","id":60}},"user_capabilities":{"edit":true,"delete":true,"start":true,"schedule":true,"copy":true},"labels":{"count":0,"results":[]},"recent_jobs":[{"id":60,"status":"failed","finished":"2024-11-25T15:34:00.247059Z","canceled_on":null,"type":"job"},{"id":54,"status":"failed","finished":"2024-11-22T21:03:59.374605Z","canceled_on":null,"type":"job"},{"id":47,"status":"failed","finished":"2024-11-22T17:38:16.785048Z","canceled_on":null,"type":"job"},{"id":44,"status":"failed","finished":"2024-11-22T17:28:20.320449Z","canceled_on":null,"type":"job"},{"id":42,"status":"failed","finished":"2024-11-22T17:22:34.971288Z","canceled_on":null,"type":"job"},{"id":40,"status":"failed","finished":"2024-11-22T17:20:31.417373Z","canceled_on":null,"type":"job"},{"id":38,"status":"failed","finished":"2024-11-22T17:16:25.153333Z","canceled_on":null,"type":"job"},{"id":36,"status":"failed","finished":"2024-11-22T17:12:54.281207Z","canceled_on":null,"type":"job"},{"id":32,"status":"failed","finished":"2024-11-22T16:26:53.670980Z","canceled_on":null,"type":"job"},{"id":31,"status":"failed","finished":"2024-11-22T16:25:37.016297Z","canceled_on":null,"type":"job"}],"credentials":[{"id":4,"name":"Machine Host","description":"","kind":"ssh","cloud":false}]},"created":"2024-11-21T22:00:35.517625Z","modified":"2024-11-22T21:03:52.375950Z","name":"Restart application1","description":"","job_type":"run","inventory":1,"project":12,"playbook":"exercises/exercise13/restart-application.yaml","scm_branch":"","forks":0,"limit":"","verbosity":1,"extra_vars":"---","job_tags":"","force_handlers":false,"skip_tags":"","start_at_task":"","timeout":0,"use_fact_cache":false,"organization":1,"last_job_run":"2024-11-25T15:34:00.247059Z","last_job_failed":true,"next_job_run":null,"status":"failed","execution_environment":3,"host_config_key":"","ask_scm_branch_on_launch":false,"ask_diff_mode_on_launch":false,"ask_variables_on_launch":false,"ask_limit_on_launch":false,"ask_tags_on_launch":false,"ask_skip_tags_on_launch":false,"ask_job_type_on_launch":false,"ask_verbosity_on_launch":false,"ask_inventory_on_launch":false,"ask_credential_on_launch":false,"ask_execution_environment_on_launch":false,"ask_labels_on_launch":false,"ask_forks_on_launch":false,"ask_job_slice_count_on_launch":false,"ask_timeout_on_launch":false,"ask_instance_groups_on_launch":false,"survey_enabled":false,"become_enabled":false,"diff_mode":false,"allow_simultaneous":false,"custom_virtualenv":null,"job_slice_count":1,"webhook_service":"","webhook_credential":null,"prevent_instance_group_fallback":false}]}
```

### 2. Launch the Job Template
Use the Job Template ID to launch the job:
```bash
curl -X POST -H "Authorization: Bearer <your_token>" \
     -H "Content-Type: application/json" \
     -d '{}' \
     http://<awx_host>/api/v2/job_templates/<job_template_id>/launch/
```
#### Example:
```bash
cristianguillenmendez@Cristians-MacBook-Pro exercise13 % curl -X POST -H "Authorization: Bearer wpSCyIlK1j8Dy8zM7wTmZ7bbkdgQVE" \
     -H "Content-Type: application/json" \
     -d '{}' \
     http://192.168.105.19:32728/api/v2/job_templates/13/launch/
{"job":61,"ignored_fields":{},"id":61,"type":"job","url":"/api/v2/jobs/61/","related":{"created_by":"/api/v2/users/1/","modified_by":"/api/v2/users/1/","labels":"/api/v2/jobs/61/labels/","inventory":"/api/v2/inventories/1/","project":"/api/v2/projects/12/","organization":"/api/v2/organizations/1/","credentials":"/api/v2/jobs/61/credentials/","unified_job_template":"/api/v2/job_templates/13/","stdout":"/api/v2/jobs/61/stdout/","execution_environment":"/api/v2/execution_environments/3/","job_events":"/api/v2/jobs/61/job_events/","job_host_summaries":"/api/v2/jobs/61/job_host_summaries/","activity_stream":"/api/v2/jobs/61/activity_stream/","notifications":"/api/v2/jobs/61/notifications/","create_schedule":"/api/v2/jobs/61/create_schedule/","job_template":"/api/v2/job_templates/13/","cancel":"/api/v2/jobs/61/cancel/","relaunch":"/api/v2/jobs/61/relaunch/"},"summary_fields":{"organization":{"id":1,"name":"Default","description":""},"inventory":{"id":1,"name":"Demo Inventory","description":"","has_active_failures":true,"total_hosts":1,"hosts_with_active_failures":1,"total_groups":0,"has_inventory_sources":false,"total_inventory_sources":0,"inventory_sources_with_failures":0,"organization_id":1,"kind":""},"execution_environment":{"id":3,"name":"Control Plane Execution Environment","description":"","image":"quay.io/ansible/awx-ee:24.6.1"},"project":{"id":12,"name":"sre_project","description":"","status":"successful","scm_type":"git","allow_override":false},"job_template":{"id":13,"name":"Restart application1","description":""},"unified_job_template":{"id":13,"name":"Restart application1","description":"","unified_job_type":"job"},"created_by":{"id":1,"username":"admin","first_name":"","last_name":""},"modified_by":{"id":1,"username":"admin","first_name":"","last_name":""},"user_capabilities":{"delete":true,"start":true},"labels":{"count":0,"results":[]},"credentials":[{"id":4,"name":"Machine Host","description":"","kind":"ssh","cloud":false}]},"created":"2024-11-25T17:48:34.130168Z","modified":"2024-11-25T17:48:34.152865Z","name":"Restart application1","description":"","job_type":"run","inventory":1,"project":12,"playbook":"exercises/exercise13/restart-application.yaml","scm_branch":"","forks":0,"limit":"","verbosity":1,"extra_vars":"{}","job_tags":"","force_handlers":false,"skip_tags":"","start_at_task":"","timeout":0,"use_fact_cache":false,"organization":1,"unified_job_template":13,"launch_type":"manual","status":"pending","execution_environment":3,"failed":false,"started":null,"finished":null,"canceled_on":null,"elapsed":0.0,"job_args":"","job_cwd":"","job_env":{},"job_explanation":"","execution_node":"","controller_node":"","result_traceback":"","event_processing_finished":false,"launched_by":{"id":1,"name":"admin","type":"user","url":"/api/v2/users/1/"},"work_unit_id":null,"job_template":13,"passwords_needed_to_start":[],"allow_simultaneous":false,"artifacts":{},"scm_revision":"","instance_group":null,"diff_mode":false,"job_slice_number":0,"job_slice_count":1,"webhook_service":"","webhook_credential":null,"webhook_guid":""}
```

### 3. Monitor Job Status
After launching a job, get the job ID from the launch response. Use it to monitor the job status:
```bash
curl -H "Authorization: Bearer <your_token>" http://<awx_host>/api/v2/jobs/<job_id>/
```

The `status` field will indicate the job’s progress (`pending`, `running`, `successful`, `failed`, etc.).

#### Example:
```bash
cristianguillenmendez@Cristians-MacBook-Pro exercise13 % curl -H "Authorization: Bearer wpSCyIlK1j8Dy8zM7wTmZ7bbkdgQVE" \
     http://192.168.105.19:32728/api/v2/jobs/61/
{"id":61,"type":"job","url":"/api/v2/jobs/61/","related":{"created_by":"/api/v2/users/1/","labels":"/api/v2/jobs/61/labels/","inventory":"/api/v2/inventories/1/","project":"/api/v2/projects/12/","organization":"/api/v2/organizations/1/","credentials":"/api/v2/jobs/61/credentials/","unified_job_template":"/api/v2/job_templates/13/","stdout":"/api/v2/jobs/61/stdout/","execution_environment":"/api/v2/execution_environments/3/","job_events":"/api/v2/jobs/61/job_events/","job_host_summaries":"/api/v2/jobs/61/job_host_summaries/","activity_stream":"/api/v2/jobs/61/activity_stream/","notifications":"/api/v2/jobs/61/notifications/","create_schedule":"/api/v2/jobs/61/create_schedule/","job_template":"/api/v2/job_templates/13/","cancel":"/api/v2/jobs/61/cancel/","relaunch":"/api/v2/jobs/61/relaunch/"},"summary_fields":{"organization":{"id":1,"name":"Default","description":""},"inventory":{"id":1,"name":"Demo Inventory","description":"","has_active_failures":true,"total_hosts":1,"hosts_with_active_failures":1,"total_groups":0,"has_inventory_sources":false,"total_inventory_sources":0,"inventory_sources_with_failures":0,"organization_id":1,"kind":""},"execution_environment":{"id":3,"name":"Control Plane Execution Environment","description":"","image":"quay.io/ansible/awx-ee:24.6.1"},"project":{"id":12,"name":"sre_project","description":"","status":"successful","scm_type":"git","allow_override":false},"job_template":{"id":13,"name":"Restart application1","description":""},"unified_job_template":{"id":13,"name":"Restart application1","description":"","unified_job_type":"job"},"instance_group":{"id":2,"name":"default","is_container_group":true},"created_by":{"id":1,"username":"admin","first_name":"","last_name":""},"user_capabilities":{"delete":true,"start":true},"labels":{"count":0,"results":[]},"credentials":[{"id":4,"name":"Machine Host","description":"","kind":"ssh","cloud":false}]},"created":"2024-11-25T17:48:34.130168Z","modified":"2024-11-25T17:48:34.250619Z","name":"Restart application1","description":"","job_type":"run","inventory":1,"project":12,"playbook":"exercises/exercise13/restart-application.yaml","scm_branch":"","forks":0,"limit":"","verbosity":1,"extra_vars":"{}","job_tags":"","force_handlers":false,"skip_tags":"","start_at_task":"","timeout":0,"use_fact_cache":false,"organization":1,"unified_job_template":13,"launch_type":"manual","status":"failed","execution_environment":3,"failed":true,"started":"2024-11-25T17:48:34.269855Z","finished":"2024-11-25T17:48:39.248861Z","canceled_on":null,"elapsed":4.979,"job_args":"[\"ssh-agent\", \"sh\", \"-c\", \"trap 'rm -f /runner/artifacts/61/ssh_key_data' EXIT && ssh-add /runner/artifacts/61/ssh_key_data && rm -f /runner/artifacts/61/ssh_key_data && ansible-playbook -u cristianguillenmendez -v -i /runner/inventory/hosts -e @/runner/env/extravars exercises/exercise13/restart-application.yaml\"]","job_cwd":"/runner/project","job_env":{"PWD":"/runner","HOME":"/runner","PATH":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","SHLVL":"0","JOB_ID":"61","AWX_HOST":"https://towerhost","HOSTNAME":"automation-job-61-ttz44","LC_CTYPE":"C.UTF-8","INVENTORY_ID":"1","MAX_EVENT_RES":"700000","KUBERNETES_PORT":"tcp://10.96.0.1:443","PROJECT_REVISION":"5fc4870cccbd9be01b9560463ef2171b62b8b9b4","ANSIBLE_ROLES_PATH":"/runner/requirements_roles:~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles","RUNNER_OMIT_EVENTS":"False","ANSIBLE_FORCE_COLOR":"True","AWX_PRIVATE_DATA_DIR":"/tmp/awx_61_ifxztvul","AWX_DEMO_SERVICE_PORT":"tcp://10.103.35.163:80","AWX_ISOLATED_DATA_DIR":"/runner/artifacts/61","ANSIBLE_BASE_TEAM_MODEL":"main.Team","ANSIBLE_STDOUT_CALLBACK":"awx_display","KUBERNETES_PORT_443_TCP":"tcp://10.96.0.1:443","KUBERNETES_SERVICE_HOST":"10.96.0.1","KUBERNETES_SERVICE_PORT":"443","ANSIBLE_CALLBACK_PLUGINS":"/usr/local/lib/python3.9/site-packages/ansible_runner/display_callback/callback","ANSIBLE_COLLECTIONS_PATH":"/runner/requirements_collections:~/.ansible/collections:/usr/share/ansible/collections","ANSIBLE_COLLECTIONS_PATHS":"/runner/requirements_collections:~/.ansible/collections:/usr/share/ansible/collections","ANSIBLE_HOST_KEY_CHECKING":"False","PIP_BREAK_SYSTEM_PACKAGES":"1","RUNNER_ONLY_FAILED_EVENTS":"False","ANSIBLE_BASE_ROLE_PRECREATE":"{}","ANSIBLE_RETRY_FILES_ENABLED":"False","ANSIBLE_SSH_CONTROL_PATH_DIR":"/runner/cp","AWX_DEMO_SERVICE_PORT_80_TCP":"tcp://10.103.35.163:80","KUBERNETES_PORT_443_TCP_ADDR":"10.96.0.1","KUBERNETES_PORT_443_TCP_PORT":"443","ANSIBLE_BASE_ALL_REST_FILTERS":"('ansible_base.rest_filters.rest_framework.type_filter_backend.TypeFilterBackend', 'ansible_base.rest_filters.rest_framework.field_lookup_backend.FieldLookupBackend', 'rest_framework.filters.SearchFilter', 'ansible_base.rest_filters.rest_framework.order_backend.OrderByBackend')","ANSIBLE_BASE_CREATOR_DEFAULTS":"['change', 'delete', 'execute', 'use', 'adhoc', 'approve', 'update', 'view']","ANSIBLE_BASE_PERMISSION_MODEL":"main.Permission","AWX_DEMO_SERVICE_SERVICE_HOST":"10.103.35.163","AWX_DEMO_SERVICE_SERVICE_PORT":"80","KUBERNETES_PORT_443_TCP_PROTO":"tcp","KUBERNETES_SERVICE_PORT_HTTPS":"443","ANSIBLE_BASE_ROLE_CREATOR_NAME":"{cls.__name__} Creator","ANSIBLE_BASE_ALLOW_CUSTOM_ROLES":"True","ANSIBLE_BASE_ALLOW_TEAM_PARENTS":"True","ANSIBLE_BASE_CUSTOM_VIEW_PARENT":"awx.api.generics.APIView","ANSIBLE_BASE_ORGANIZATION_MODEL":"main.Organization","ANSIBLE_BASE_BYPASS_ACTION_FLAGS":"{}","ANSIBLE_BASE_ALLOW_TEAM_ORG_ADMIN":"False","ANSIBLE_BASE_ALLOW_TEAM_ORG_PERMS":"True","ANSIBLE_INVENTORY_UNPARSED_FAILED":"True","ANSIBLE_PARAMIKO_RECORD_HOST_KEYS":"False","AWX_DEMO_SERVICE_PORT_80_TCP_ADDR":"10.103.35.163","AWX_DEMO_SERVICE_PORT_80_TCP_PORT":"80","ANSIBLE_BASE_ALLOW_TEAM_ORG_MEMBER":"False","ANSIBLE_BASE_MANAGED_ROLE_REGISTRY":"{}","ANSIBLE_BASE_ROLE_SYSTEM_ACTIVATED":"True","AWX_DEMO_SERVICE_PORT_80_TCP_PROTO":"tcp","AWX_DEMO_SERVICE_SERVICE_PORT_HTTP":"80","ANSIBLE_BASE_BYPASS_SUPERUSER_FLAGS":"['is_superuser']","ANSIBLE_BASE_RESOURCE_CONFIG_MODULE":"awx.resource_api","ANSIBLE_BASE_ALLOW_CUSTOM_TEAM_ROLES":"False","ANSIBLE_BASE_CACHE_PARENT_PERMISSIONS":"True","ANSIBLE_BASE_ALLOW_SINGLETON_ROLES_API":"False","ANSIBLE_BASE_CHECK_RELATED_PERMISSIONS":"['use', 'change', 'view']","ANSIBLE_BASE_ALLOW_SINGLETON_TEAM_ROLES":"False","ANSIBLE_BASE_ALLOW_SINGLETON_USER_ROLES":"True","ANSIBLE_BASE_REST_FILTERS_RESERVED_NAMES":"('page', 'page_size', 'format', 'order', 'order_by', 'search', 'type', 'host_filter', 'count_disabled', 'no_truncate', 'limit', 'validate')","ANSIBLE_BASE_EVALUATIONS_IGNORE_CONFLICTS":"True","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_PORT":"tcp://10.110.254.131:8443","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_SERVICE_HOST":"10.110.254.131","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_SERVICE_PORT":"8443","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_PORT_8443_TCP":"tcp://10.110.254.131:8443","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_PORT_8443_TCP_ADDR":"10.110.254.131","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_PORT_8443_TCP_PORT":"8443","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_SERVICE_PORT_HTTPS":"8443","AWX_OPERATOR_CONTROLLER_MANAGER_METRICS_SERVICE_PORT_8443_TCP_PROTO":"tcp"},"job_explanation":"","execution_node":"","controller_node":"awx-demo-task-76ffcd58c-crjzm","result_traceback":"","event_processing_finished":true,"launched_by":{"id":1,"name":"admin","type":"user","url":"/api/v2/users/1/"},"work_unit_id":"VMSY697c","job_template":13,"passwords_needed_to_start":[],"allow_simultaneous":false,"artifacts":{},"scm_revision":"5fc4870cccbd9be01b9560463ef2171b62b8b9b4","instance_group":2,"diff_mode":false,"job_slice_number":0,"job_slice_count":1,"webhook_service":"","webhook_credential":null,"webhook_guid":"","host_status_counts":{"failures":1},"playbook_counts":{"play_count":1,"task_count":2},"custom_virtualenv":null}
```

---

## **Configure Grafana to Trigger the AWX Job**

### Step 1: Add a Contact Point in Grafana
1. Open **Grafana** and go to **Alerting → + New alert rule**.
1.1 Name: **Endpoint's latency lower than 1400 miliseconds**
1.2 A: **sum(rate(otel_collector_span_metrics_duration_milliseconds_bucket[5m])) by (span_name)**
1.3 C: Input: **A** IS BOVE **1**
1.4 Click preview
![grafana alert preview](./images/grafana-alert-preview.png)
2. Click Contact point and select **Job to collect information**.
3. Save rule and exit
![grafana alert preview contact point](./images/grafana-alert-preview-contact-point.png)

---

# Deployment
Before deploy all the new staff it's important to clean the changes from the previous exercises and then apply the new settings wih short program like this one:
```bash
#!/bin/bash
#!/bin/bash

kubectl delete ns awx
kubectl delete ns application
kubectl delete ns opentelemetry
kubectl delete ns monitoring
kubectl delete pv --all 
kubectl delete pvc --all 
sleep 5;

echo "-------------------------------------------------------------------------"
echo "Install AWX"
echo "-------------------------------------------------------------------------"

brew install helm
helm repo add awx-operator https://ansible-community.github.io/awx-operator-helm/
helm install my-awx-operator awx-operator/awx-operator -n awx --create-namespace


echo "-------------------------------------------------------------------------"
echo "Configure AWX"
echo "-------------------------------------------------------------------------"


kubectl get pods -n awx #  awx-operator-controller-manager-*** is in a running state.
kubectl apply -f awx-demo.yaml
kubectl get service awx-demo-service -n awx #Wait for the awx-demo-service to become available: It could take someminutes
sleep 2;
kubectl get pods -A
minikube service awx-demo-service -n awx
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo
ansible-playbook -i ../exercise4.1/ansible_quickstart/inventory.ini job-template.yaml

echo "-------------------------------------------------------------------------"
echo "Install the rest of the Infra"
echo "-------------------------------------------------------------------------"

kubectl apply -f ../exercise10/storage.yaml;
kubectl apply -f ../exercise10/deployment.yaml;
kubectl apply -f ../exercise10/otel-collector.yaml;
kubectl apply -f ../exercise8/jaeger.yaml;
kubectl apply -f ../exercise9/prometheus.yaml;
kubectl apply -f ../exercise12/grafana-loki.yaml;
kubectl apply -f ./grafana.yaml;
echo "-------------------------------------------------------------------------"
echo "wait"
echo "-------------------------------------------------------------------------"
sleep 10;
kubectl get pods -A
```

---

# Tip for Infrastructure as Code (IaC) with Ansible

> [!TIP]
> A more efficient **Infrastructure as Code (IaC)** approach can be implemented with Ansible to apply the new configuration and start its service in Minikube. An [example](./infra.yaml) of how to structure a YAML playbook to achieve this.
> 1. **Configure AWX**
> At [awx-configuration.yaml](./awx-configuration.yaml), you will find an Ansible script that uses the AWX REST API to create the following resources in AWX: organization, inventory, project, job template, application, client, and token. Additionally, the script generates a `./grafana_updated.yaml` file with the configuration for the Grafana contact point. This contact point enables Grafana to send a message whenever an alert is triggered. 
> 2. **Diagnostic script**
> At [collect-status-application.yaml](./collect-status-application.yaml), you will find an Ansible script that collects information about the node where it is executed. The purpose of this script is to 
> 3. **Run the Playbook**
>```bash
> playbook -i ../exercise4.1/ansible_quickstart/inventory.ini infra.yaml
> minikube service awx-demo-service -n awx
> minikube service grafana-service -n monitoring
> kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo
> ```

---

# Final Objective
At the end of this document, you should accomplished this:
> [!IMPORTANT]
> The goal is to trigger a runbook each time alerts are fired in Grafana. This will collect additional information about the system's status and help reduce the time needed to resolve incidents.
> Alerts in Grafana should include this new Contact Point:
> ![grafana-alerts-contact-point](./images/grafana-alerts-contact-point.png)
> As you know, the degradation conditions implemented in our program will eventually generate an error:
> ![grafana error triggering.png](./images/grafana-error-triggering.png)
> After a while, each alert in Grafana will trigger the execution of the runbook:
> ![awx template job executions](./images/awx-template-job-executions.png)

---

## **Cleanup**
To remove **all** deployed resources:

```bash
kubectl delete ns awx application opentelemetry monitoring
kubectl delete pv --all
kubectl delete pvc --all
```

---

