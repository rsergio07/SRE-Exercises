# Table of Contents
- [Introduction to Grafana](#introduction-to-grafana)
- [Key Features](#key-features)
- [Getting Started](#getting-started)
- [Install Grafana in the Cluster](#install-grafana-in-the-cluster)
- [Tip for Infrastructure as Code (IaC) with Ansible](#tip-for-infrastructure-as-code-iac-with-ansible)
- [Final Objective](#final-objective)

# Introduction to Grafana
Grafana is an open-source platform for monitoring and observability that provides powerful visualization and analysis capabilities for your metrics and logs. It is widely used for creating interactive and customizable dashboards to gain insights into your system's performance and health.

## Key Features

### 1. **Customizable Dashboards**

Grafana allows you to create and customize dashboards with a wide range of visualization options, including graphs, tables, heatmaps, and more. You can arrange and configure panels to display data in a way that suits your needs.

### 2. **Rich Data Sources Integration**

Grafana supports integration with various data sources, including:
- **Prometheus**: A powerful metrics collection and querying system.
- **InfluxDB**: A time-series database.
- **Elasticsearch**: A search and analytics engine.
- **MySQL, PostgreSQL**: Relational databases.
- **CloudWatch, Graphite**, and many others.

You can connect multiple data sources and query them simultaneously within a single dashboard.

### 3. **Advanced Query Capabilities**

Grafana provides advanced querying capabilities to extract and aggregate data from connected data sources. You can write complex queries to filter, transform, and analyze your metrics and logs.

### 4. **Alerting**

Grafana supports alerting based on defined thresholds and conditions. Alerts can be configured to notify you through various channels such as email, Slack, or webhook when specific conditions are met.

### 5. **Plugins and Extensions**

Grafana has a rich ecosystem of plugins and extensions that add additional functionality and integrations. These plugins include new visualization options, data source integrations, and application features.

### 6. **User Management and Access Control**

Grafana provides robust user management and access control features. You can define roles and permissions to control who can view, edit, or manage dashboards and data sources.

### 7. **Data Annotations and Time Ranges**

Grafana allows you to annotate your data with events or notes to provide context for specific metrics. You can also adjust the time range for your visualizations to focus on different periods of data.

### 8. **Community and Support**

Grafana has a large and active community of users and contributors. The official Grafana documentation, forums, and GitHub repository provide extensive resources and support for getting started and troubleshooting issues.

## Getting Started

To get started with Grafana:
1. **Install Grafana**: Follow the [installation instructions](https://grafana.com/docs/grafana/latest/installation/) for your platform.
2. **Add Data Sources**: Configure your data sources within the Grafana UI.
3. **Create Dashboards**: Use the Grafana UI to create and customize dashboards.
4. **Set Up Alerts**: Configure alerts based on your metrics and thresholds.

For detailed documentation and tutorials, visit the [Grafana Documentation](https://grafana.com/docs/grafana/latest/).


## Install granafa in the cluster

Let's review the [Grafana Setup yaml file](./grafana.yaml) to install the grafana server.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana-deployment
  namespace: monitoring
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: grafana/grafana:latest #Docker image to use (grafana/grafana:latest).
          ports:
            - containerPort: 3000
          volumeMounts:
            - name: grafana-config #The name of the volume (grafana-config).
              mountPath: /etc/grafana/provisioning #Path inside the container where the volume is mounted (/etc/grafana/provisioning).
              readOnly: true #Specifies if the volume is read-only (true).
      volumes:
        - name: grafana-config #The name of the volume (grafana-config).
          configMap:
            name: grafana-config#The ConfigMap providing the volume (grafana-config).
```
Then a service will be created to access the grafana server installed above 
```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana-service #The name of the service (grafana-service).
  namespace: monitoring
  labels:
    app: grafana
spec:
  selector:
    app: grafana
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: NodePort

```
Then include a section like this one to create a datasource with the Promotheus installed previously and start query the information inside Promotheus. 

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-config
  namespace: monitoring
  labels:
    app: grafana
data:
  datasources.yaml: | #Configures Grafana to use Prometheus as a data source
    apiVersion: 1
    deleteDatasources:
      - name: Prometheus #Deletes existing Prometheus data source if it exists
    datasources:
      - name: Prometheus #Defines the Prometheus data source with its URL and settings.
        type: prometheus
        access: proxy
        url: http://prometheus-service.monitoring.svc.cluster.local:9090
        isDefault: true
        version: 1
        editable: true
```
Now let´s configure Grafana to define a internal path for the provider where the dashboard are going to be stored.
```yaml
  dashboards.yaml: |
    apiVersion: 1
    providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        options:
          path: /etc/grafana/provisioning/dashboards
  example-dashboard.json: |
    {
      "id": null,
      "uid": "example-dashboard",
      "title": "Example Dashboard",
      "tags": [],
      "style": "dark",
      "timezone": "browser",
      "editable": true,
      "panels": [
        {
          "datasource": "Prometheus",
          "id": 1,
          "targets": [
            {
              "expr": "sum by(job) (rate(process_cpu_seconds_total[1m]))",
              "refId": "A"
            }
          ],
          "title": "CPU Usage",
          "type": "graph"
        }
      ],
      "schemaVersion": 16,
      "version": 1
    }
```
- **Run it together**:
Let´s run all together using these commands
```yaml
kubectl apply -f grafana.yaml
minikube service grafana-service -n monitoring
```

# Tip for Infrastructure as Code (IaC) with Ansible

> [!TIP]
> A more efficient **Infrastructure as Code (IaC)** approach can be implemented with Ansible to apply the Grafana configuration and start its service in Minikube. Below is an example of how to structure a YAML playbook to achieve this:
> 1. **Create a YAML Playbook**
> ```yaml
> ---
> - name: Apply Grafana configuration and start service in Minikube
>   hosts: all
>   become: yes  # Optional, if sudo permissions are required
>   tasks:
>     - name: Apply Grafana configuration
>       command: kubectl apply -f grafana.yaml
>       args:
>         chdir: ./  #  directory where the command should be executed
> ```
> 2. **Run the Playbook**
> ```bash
> ansible-playbook -i ../exercise4.1/ansible_quickstart/inventory.ini infra.yaml
> minikube service grafana-service -n monitoring
> ```
---
# Final Objective
At the end of this document, you should accomplished this:
> [!IMPORTANT]
> These are the credencials **admin/amin** to access Grafana and see the datasource and the dashboard that should look something like this
> ![alt text](image.png). 
