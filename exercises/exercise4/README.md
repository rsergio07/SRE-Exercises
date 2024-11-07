# Table of Contents
- [Kubernetes, Minikube, kubectl, YAML, and Podman Desktop: A Quick Start Guide](#kubernetes-minikube-kubectl-yaml-and-podman-desktop-a-quick-start-guide)
  - [What is Kubernetes?](#what-is-kubernetes)
  - [What is Minikube?](#what-is-minikube)
  - [What is kubectl?](#what-is-kubectl)
  - [What is YAML?](#what-is-yaml)
  - [How to Enable Local Minikube in Podman Desktop](#how-to-enable-local-minikube-in-podman-desktop)
- [Deploying the SRE ABC Training Python App on Kubernetes](#deploying-the-sre-abc-training-python-app-on-kubernetes)
  - [Deployment YAML](#deployment-yaml)
  - [Service YAML](#service-yaml)
  - [Deployment Steps](#deployment-steps)
  - [Access the Application](#access-the-application)
- [Final Objective](#final-objective)

## What is Kubernetes?

Kubernetes (often abbreviated as K8s) is an open-source platform designed to automate the deployment, scaling, and operation of containerized applications. It provides a robust framework to run distributed systems resiliently. Kubernetes handles the work of scheduling containers onto a compute cluster and manages the workloads to ensure they run as intended.

### Key Features of Kubernetes:
- **Automatic bin packing**: Automatically places containers based on their resource requirements and other constraints.
- **Self-healing**: Restarts containers that fail, replaces and reschedules containers when nodes die, and kills containers that don't respond to user-defined health checks.
- **Horizontal scaling**: Scales applications up and down with a simple command, based on CPU usage, or automatically based on custom metrics.
- **Service discovery and load balancing**: Exposes a container using the DNS name or their own IP address and balances the load across containers.
- **Automated rollouts and rollbacks**: Rolls out changes to applications or configuration, and rolls back to the previous state if something goes wrong.

## What is Minikube?

Minikube is a lightweight Kubernetes implementation that creates a virtualized environment on your local machine to run Kubernetes clusters. It’s an excellent tool for developers and system administrators to experiment, develop, and learn Kubernetes on a smaller scale before deploying to a full-scale production environment.

### Why Use Minikube?
- **Easy Setup**: Minikube provides a simple way to set up a single-node Kubernetes cluster on your local machine.
- **Supports Kubernetes Features**: Despite being lightweight, Minikube supports most Kubernetes features like DNS, dashboards, and container runtime.
- **Extensible**: Minikube can run multiple Kubernetes versions and provides addons for additional functionality.

## What is kubectl?

`kubectl` is a command-line tool that allows you to run commands against Kubernetes clusters. You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs, among other tasks. It's the primary way to interact with Kubernetes clusters.

### Common kubectl Commands:
- **kubectl get pods**: Lists all pods running in the cluster.
- **kubectl create -f <file.yaml>**: Creates resources defined in a YAML file.
- **kubectl apply -f <file.yaml>**: Applies changes to resources defined in a YAML file.
- **kubectl delete -f <file.yaml>**: Deletes resources defined in a YAML file.

## What is YAML?

YAML (YAML Ain't Markup Language) is a human-readable data serialization standard that is commonly used for configuration files and data exchange between languages with different data structures. In Kubernetes, YAML files are used to define the desired state of resources like deployments, services, and more.

### Key Concepts in a Kubernetes YAML File:
- **apiVersion**: Specifies the Kubernetes API version.
- **kind**: The type of Kubernetes resource (e.g., Deployment, Service).
- **metadata**: Provides information like the name and labels of the resource.
- **spec**: Defines the desired state of the resource, including the number of replicas, the container image, ports, and more.

## How to Enable Local Minikube in Podman Desktop

Podman Desktop is an open-source tool that allows you to manage containers and Kubernetes clusters from a single UI. If you want to run a Kubernetes cluster using Minikube within Podman Desktop, follow these steps:

### Prerequisites:
- **Podman Desktop**: Ensure Podman Desktop is installed on your system.
- **Minikube**: Make sure Minikube is installed. You can follow the official installation guide [here](https://minikube.sigs.k8s.io/docs/start/).
- **Hypervisor**: Minikube requires a hypervisor like VirtualBox, HyperKit, or KVM to run the virtual machine.

### Steps to Enable Minikube in Podman Desktop:

1. **Start Minikube**:
   - Open your terminal and start Minikube with the following command:
     ```sh
     minikube start --driver=<driver_name>
     ```
     Replace `<driver_name>` with the appropriate driver for your system (e.g., `virtualbox`, `hyperkit`, `kvm`).

   - Let´s use to following:
     ```sh
     minikube start --container-runtime=containerd
     ```
2. **Verify Minikube**:
   - After starting Minikube, verify that it is running:
     ```sh
     minikube status
     ```

### Dashboard:
- **Accessing the Kubernetes Dashboard**: Minikube comes with a built-in dashboard that you can access by running:
  ```sh
  minikube dashboard
  ```


# Deploying the SRE ABC Training Python App on Kubernetes

This guide will help you deploy the `cguillenmendez/sre-abc-training-python-app` container on Kubernetes using a Deployment with 3 replicas and a Service with a NodePort.

## Deployment YAML

In Kubernetes, a **Deployment** is a resource object that provides declarative updates to applications. It manages a set of Pods and ensures that the specified number of Pods are running at any given time. Deployments are useful for scaling applications, rolling out updates, and rolling back to previous versions.

Create a file named `deployment.yaml` with the following content:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sre-abc-training-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sre-abc-training-app
  template:
    metadata:
      labels:
        app: sre-abc-training-app
    spec:
      containers:
      - name: sre-abc-training-app
        image: cguillenmendez/sre-abc-training-python-app:latest
        ports:
        - containerPort: 5000
```
This YAML file defines a Kubernetes Deployment named sre-abc-training-app that manages 3 replicas of a Pod. Each Pod runs a container from the image cguillenmendez/sre-abc-training-python-app:latest, and the container listens on port 5000. The Deployment ensures that the specified number of Pods are always running and manages updates to them.

### YAML File Breakdown
- **apiVersion**: Specifies the API version of the Kubernetes object being defined. In this case, apps/v1 indicates that the Deployment API is being used.

- **kind**: Defines the type of Kubernetes resource. Deployment indicates that this configuration is for a Deployment resource.

- **metadata**: Provides metadata about the resource.
name: The name of the Deployment resource. This name must be unique within the namespace and is used to identify the Deployment.

- **spec**: Describes the desired state of the Deployment.
replicas: Specifies the number of Pod replicas to run. In this case, 3 replicas are requested, meaning Kubernetes will maintain 3 copies of the application Pod running at all times.

- **selector**: Defines how to identify which Pods are managed by this Deployment.
matchLabels: A set of labels used to select Pods. Here, it selects Pods with the label app: sre-abc-training-app.

- **template**: Specifies the Pod template used by the Deployment.
   - **metadata**: Metadata for the Pods created by this Deployment.
   - **labels**: Labels applied to the Pods. The label app: sre-abc-training-app ensures that the Pods created by this Deployment match the selector.

- **spec**: Describes the desired state of the Pods.
   - **containers**: Lists the containers to run in each Pod.
   - **name**: The name of the container within the Pod.
   - **image**: The Docker image used for the container. cguillenmendez/sre-abc-training-python-app:latest is the image being used.
   - **ports**: Specifies which ports are exposed by the container.
   - **containerPort**:: The port number that the container exposes, which is 5000 in this case.

## Service YAML
A **Kubernetes Service** is a crucial resource in Kubernetes that provides a stable endpoint for accessing a set of Pods. Services enable communication between different parts of an application and between applications and external clients.

Next, create a file named `service.yaml` with the following content:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sre-abc-training-service
spec:
  type: NodePort
  selector:
    app: sre-abc-training-app
  ports:
  - port: 5000
    targetPort: 5000
    nodePort: 30007 # You can specify a different NodePort if desired

```
This YAML configuration sets up a Kubernetes Service named sre-abc-training-service that exposes an application running on Pods labeled with app: sre-abc-training-app. The Service is of type NodePort, making it accessible externally through port 30007 on each Node in the cluster. Inside the cluster, the Service listens on port 5000 and forwards traffic to port 5000 on the selected Pods.

### Breakdown of the YAML File
- **apiVersion**: v1
   - **apiVersion***: Specifies the API version for the Service resource. v1 is the version used for core Kubernetes resources like Services.
- **kind**: Service
    - **kind**: Indicates that this configuration is for a Kubernetes Service resource.
- **metadata**
   - **metadata**: Provides metadata about the Service.
       - **name**: The name of the Service resource. In this case, it is sre-abc-training-service.
- **spec**
   - **spec**: Defines the desired state of the Service.
      - **type**: Specifies the type of Service. NodePort means that the Service will be exposed on a port on each Node in the cluster.
      - **selector**: Determines which Pods are targeted by the Service.
        - **app**: The label selector used to match Pods. This Service will route traffic to Pods with the label app: sre-abc-training-app.
      - **ports**: Configures the ports for the Service.
        - **port**: The port that the Service exposes inside the cluster. In this case, it is 5000.
        - **targetPort**: The port on the Pods that the Service should forward traffic to. Here, it is 5000, matching the port that the container exposes.
       - **nodePort**: The port on each Node that the Service is exposed on. 30007 is used here, but it can be changed to any port in the allowed range (30000-32767).



## Deployment Steps
Apply the Deployment:

```sh
kubectl apply -f deployment.yaml
```

## Apply the Service:
```sh
kubectl apply -f service.yaml
```

## Verify the Deployment:
Check that the pods are running:
```sh
kubectl get pods
```
You should see 3 pods running for the sre-abc-training-app. Wait until the output display the pods running in this 
```sh
cristianguillenmendez@Cristians-MacBook-Pro exercise4 % kubectl get pods                                          
NAME                                    READY   STATUS    RESTARTS   AGE
sre-abc-training-app-5f67f997cb-76rds   1/1     Running   0          68s
sre-abc-training-app-5f67f997cb-94bjj   1/1     Running   0          68s
sre-abc-training-app-5f67f997cb-d7pmc   1/1     Running   0          68s
```
If you get the **ContainerCreating** status means that minikube is downloading the image from dockerhub
## Access the Application:

You can access the application via any node's IP address on the NodePort specified (default: 30007):
```sh
http://<node-ip>:30007
```
Minikube offers a convenient way to expose services directly in your host machine using the minikube service command, which automatically sets up a tunnel.
```sh
minikube service sre-abc-training-service
``` 
Notice how the service is mapping the host port 30007 to the pod port 5000 where the python applicatin is running

---
# Final Objective
At the end of this document, you should accomplished this:
> [!IMPORTANT]
> ##  Reviewing the Deployment and Services in Minikube Dashboard
> To visually inspect the deployment and services:
> minikube dashboard
> 
> - **Start the Minikube Dashboard**:
> ```sh
> minikube dashboard
> ```
> ![k8s_dashboard](k8s_dashboard.png)
> - **Review the Deployment**: In the Minikube dashboard, navigate to Workloads > Deployments. Here you can see the sre-abc-training-app deployment and monitor its status, including the number of replicas and their health.
> 
> - **Review the Services**: In the Minikube dashboard, navigate to Services under the Network section. You can view the sre-abc-training-service and check its configuration, including the NodePort assigned and the pods it is routing traffic to.

