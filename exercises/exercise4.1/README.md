# Table of Contents
- [Infrastructure as Code (IaC) with Ansible and Kubernetes](#infrastructure-as-code-iac-with-ansible-and-kubernetes)
- [What is Ansible?](#what-is-ansible)
- [Using Ansible with Kubernetes](#using-ansible-with-kubernetes)
- [Setting Up Ansible with pipx and Creating a Basic Inventory](#setting-up-ansible-with-pipx-and-creating-a-basic-inventory)
- [Running an Ansible Playbook](#running-an-ansible-playbook)
- [Final Objective](#final-objective)

## What is Infrastructure as Code (IaC)?

Infrastructure as Code (IaC) is a modern approach to managing and provisioning computing infrastructure through code, rather than manual processes. With IaC, infrastructure configuration and deployment are defined in machine-readable scripts, allowing infrastructure to be versioned, tested, and reproduced just like software code.

### Why is IaC Important?

- **Consistency**: IaC helps eliminate configuration drift and ensures that environments are consistent across development, testing, and production.
- **Efficiency**: Manual infrastructure management is time-consuming. IaC automates repetitive tasks, making setup faster and reducing human error.
- **Scalability**: With IaC, scaling infrastructure up or down is much easier, especially in environments like cloud computing where resources can be dynamically adjusted.
- **Version Control**: Since infrastructure is managed as code, all changes can be tracked through version control, enabling rollback if an issue arises.

---

## What is Ansible?

Ansible is an open-source automation tool primarily used for configuration management, application deployment, and task automation. With its simple YAML syntax, Ansible allows developers and operators to describe the desired state of systems without needing to write complex code. 

Ansible operates in a "push" model, where it connects to remote systems over SSH and executes commands to bring the systems to the desired state. This agentless approach makes Ansible easy to set up and widely compatible with different platforms.

### Key Features of Ansible

- **Agentless**: No need to install additional software on the target machines.
- **Idempotency**: Ensures that applying the same configuration multiple times yields the same result.
- **Flexibility**: Supports a wide range of modules for different environments, including cloud providers, virtual machines, and containers.

---

## Using Ansible with Kubernetes

Ansible can be used in conjunction with Kubernetes to manage cluster resources, deploy applications, and handle configurations in a Kubernetes environment. While Kubernetes itself provides configuration as code through YAML manifests and Helm charts, Ansible offers additional control, allowing for cross-environment orchestration and integration with other parts of the infrastructure.

### When to Use Ansible with Kubernetes

1. **Multi-Cloud or Hybrid Environments**: Ansible can help manage infrastructure spanning multiple clouds or on-premises systems in addition to Kubernetes resources.
2. **Infrastructure Setup**: Ansible can automate the installation and configuration of Kubernetes clusters (e.g., provisioning Minikube or full clusters on cloud providers).
3. **Application Deployment**: Although Kubernetes has tools like `kubectl` and Helm, Ansible can orchestrate complex deployments involving non-Kubernetes resources alongside Kubernetes resources.
4. **Configuration Management**: Ansible can be used to configure the applications running within Kubernetes, particularly when the configurations are external to the cluster.

---

#### Setting Up Ansible with pipx and Creating a Basic Inventory

This guide will walk you through installing `pipx` and `ansible`, as well as setting up a quick Ansible project with an inventory file.

---

##### Step 1: Install pipx
`pipx` is a tool to install and run Python applications in isolated environments, which is particularly useful for managing tools like Ansible.

To install `pipx` on macOS:

From the [pipx documentation](https://pipx.pypa.io/stable/):
``` bash
brew install pipx
pipx ensurepath
sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
```

(Optional) To allow pipx to manage global installations (useful for applications like Ansible that may need system-wide access):
``` bash
sudo pipx ensurepath --global
```

##### Step 2:Install Ansible with pipx
Once pipx is installed, you can use it to install Ansible. This approach ensures that Ansible and its dependencies are managed in a virtual environment.

From the Ansible [installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html):

``` bash
pipx install --include-deps ansible
pipx upgrade --include-injected ansible
pipx inject --include-apps ansible argcomplete
```
##### Step 3: Getting Started with Ansible
After installing Ansible, you can verify the installation by running:
``` bash
ansible --version
```
From the Ansible [Quickstart Guide](https://docs.ansible.com/ansible/latest/getting_started/get_started_ansible.html), create a new directory for your Ansible project and navigate to it:

``` bash
pip install ansible
mkdir ansible_quickstart && cd ansible_quickstart
```

##### Step 4: Setting Up an Inventory File
An inventory file is used to define the systems Ansible will manage. To create an inventory file in the ansible_quickstart directory:

From the [Ansible Inventory Guide](https://docs.ansible.com/ansible/latest/getting_started/get_started_inventory.html):

1. Create a file named inventory.ini in the ansible_quickstart directory.
2. Add a new [allhosts] group to the inventory.ini file, listing each host's IP address or fully qualified domain name (FQDN).

``` bash
[allhosts]
127.0.0.1 ansible_connection=local
```
This file tells Ansible to connect to 127.0.0.1 (localhost) using the local connection method, which is useful for testing and development.

``` bash
Cristians-MacBook-Pro:ansible_quickstart cristianguillenmendez$ ansible-inventory -i inventory.ini --list
{
    "_meta": {
        "hostvars": {}
    },
    "all": {
        "children": [
            "ungrouped",
            "myhosts"
        ]
    },
    "myhosts": {
        "hosts": [
            "127.0.0.1"
        ]
    }
}
```
Then try the connection
``` bash
Cristians-MacBook-Pro:ansible_quickstart cristianguillenmendez$ ansible myhosts -m ping -i inventory.ini
[WARNING]: Platform darwin on host 127.0.0.1 is using the discovered Python interpreter at /usr/local/bin/python3.12, but future installation of
another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
127.0.0.1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/local/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}
```

3. Create a file named playbook.yaml in your ansible_quickstart directory, that you created earlier, with the following content:

``` yaml
- name: My first play
  hosts: myhosts
  tasks:
   - name: Ping my hosts
     ansible.builtin.ping:

   - name: Print message
     ansible.builtin.debug:
       msg: Hello world
```
Run your playbook.
``` yaml
ansible-playbook -i inventory.ini playbook.yaml
```
``` bash
Cristians-MacBook-Pro:ansible_quickstart cristianguillenmendez$ ansible-playbook -i inventory.ini playbook.yaml

PLAY [My first play] *******************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************
[WARNING]: Platform darwin on host 127.0.0.1 is using the discovered Python interpreter at /usr/local/bin/python3.12, but future installation of
another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [127.0.0.1]

TASK [Ping my hosts] *******************************************************************************************************************************
ok: [127.0.0.1]

TASK [Print message] *******************************************************************************************************************************
ok: [127.0.0.1] => {
    "msg": "Hello world"
}

PLAY RECAP *****************************************************************************************************************************************
127.0.0.1                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
In this output you can see:

The names that you give the play and each task. You should always use descriptive names that make it easy to verify and troubleshoot playbooks.

The “Gathering Facts” task runs implicitly. By default, Ansible gathers information about your inventory that it can use in the playbook.

The status of each task. Each task has a status of ok which means it ran successfully.

The play recap that summarizes results of all tasks in the playbook per host. In this example, there are three tasks so ok=3 indicates that each task ran successfully.

Congratulations, you have started using Ansible!

---
# Final Objective
At the end of this document, you should accomplished this:
> [!IMPORTANT]
> Change all the steps from the at [4. Practice](../exercise4/) to setup the node using ansible with a yaml file to should looks like this [yaml file](./ansible_quickstart/iac_paybook.yaml) with this command:
> ``` yaml
> Cristians-MacBook-Pro:ansible_quickstart cristianguillenmendez$ ansible-playbook -i inventory.ini iac_paybook.yaml --ask-become-pass
> BECOME password: 
> 
> PLAY [Install Minikube with Podman on macOS and Linux] *********************************************************************************************
> 
> TASK [Gathering Facts] *****************************************************************************************************************************
> [WARNING]: Platform darwin on host 127.0.0.1 is using the discovered Python interpreter at /usr/local/bin/python3.12, but future installation of
> another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
> core/2.17/reference_appendices/interpreter_discovery.html for more information.
> ok: [127.0.0.1]
> 
> TASK [Install dependencies on Debian/Ubuntu] *******************************************************************************************************
> skipping: [127.0.0.1]
> 
> TASK [Install dependencies on macOS] ***************************************************************************************************************
> ok: [127.0.0.1]
> 
> TASK [Install Podman on Debian/Ubuntu] *************************************************************************************************************
> skipping: [127.0.0.1]
> 
> TASK [Install Podman on macOS] *********************************************************************************************************************
> ok: [127.0.0.1]
> 
> TASK [Download Minikube binary for macOS] **********************************************************************************************************
> ok: [127.0.0.1]
> 
> TASK [Download Minikube binary for Linux] **********************************************************************************************************
> skipping: [127.0.0.1]
> 
> TASK [Start Minikube with Podman] ******************************************************************************************************************
> changed: [127.0.0.1]
> 
> TASK [Display Minikube start status] ***************************************************************************************************************
> ok: [127.0.0.1] => {
>     "minikube_start.stdout": "╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮\n│                                                                                                          │\n│    You are trying to run the amd64 binary on an M1 system.                                               │\n│    Please consider running the darwin/arm64 binary instead.                                              │\n│    Download at https://github.com/kubernetes/minikube/releases/download/v1.34.0/minikube-darwin-arm64    │\n│                                                                                                          │\n╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯\n* minikube v1.34.0 on Darwin 14.3.1\n* Kubernetes 1.31.0 is now available. If you would like to upgrade, specify: --kubernetes-version=v1.31.0\n* Using the podman (experimental) driver based on existing profile\n* Starting \"minikube\" primary control-plane node in \"minikube\" cluster\n* Pulling base image v0.0.45 ...\n* Updating the running podman \"minikube\" container ...\n* Preparing Kubernetes v1.28.3 on containerd 1.6.24 ...\n* Verifying Kubernetes components...\n  - Using image docker.io/kubernetesui/dashboard:v2.7.0\n  - Using image gcr.io/k8s-minikube/storage-provisioner:v5\n  - Using image docker.io/kubernetesui/metrics-scraper:v1.0.8\n* Some dashboard features require the metrics-server addon. To enable all features please run:\n\n\tminikube addons enable metrics-server\n\n* Enabled addons: storage-provisioner, default-storageclass, dashboard\n* Done! kubectl is now configured to use \"minikube\" cluster and \"default\" namespace by default"
> }
> 
> PLAY RECAP *****************************************************************************************************************************************
> 127.0.0.1                  : ok=6    changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
> 
> ```