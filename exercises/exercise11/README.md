# **Observability with Golden Signals in Grafana**

## **Table of Contents**

- [Observability Approach](#observability-approach)
  - [What Are the Golden Signals?](#what-are-the-golden-signals)
  - [Latency](#latency)
  - [Traffic](#traffic)
  - [Errors](#errors)
  - [Saturation](#saturation)
- [Deployment](#deployment)
- [Tip for Infrastructure as Code (IaC) with Ansible](#tip-for-infrastructure-as-code-iac-with-ansible)
- [Final Objective](#final-objective)
- [Cleanup](#cleanup)

---

# Observability approach

This exercise focuses on **observability** using the **Golden Signals** framework in **Site Reliability Engineering (SRE)**. The Golden Signals—**Latency, Traffic, Errors, and Saturation**—are key indicators of system health. They enable SREs to detect performance degradation, troubleshoot issues, and optimize resource allocation.

This exercise builds on previous ones, using:
- **Grafana** for visualization
- **Prometheus** for metric collection
- **OpenTelemetry** for distributed tracing

The infrastructure remains the same as in **Exercise 10**, as we are enhancing monitoring **inside Grafana**.

![Infrastructure](../exercise10/Infra.png)

The following configurations correspond to the **blue square** in the diagram above.

---

## **Navigate to the Directory**
Before proceeding, navigate to the correct directory:

```bash
cd sre-abc-training/exercises/exercise11
```

---

## **Golden Signals for Observability**

The **Golden Signals** framework provides four key metrics that help **Site Reliability Engineers (SREs)** monitor and troubleshoot system performance issues. These signals help detect latency spikes, network congestion, high error rates, and resource saturation before they impact users.

---

### **1. Latency**  

**Definition**: The time it takes to process a request. Latency includes both **successful** and **failed** requests, but the focus is on measuring **successful response times** as a key indicator of system performance.

#### **Grafana Configuration:**
> **📌 TIP**  
> Create a **Grafana panel** with the following PromQL query:
> ```promql
> sum(rate(otel_collector_span_metrics_duration_milliseconds_bucket[5m])) by (span_name)
> ```
> using the `otel_collector_span_metrics_duration_milliseconds_bucket` metric from the **Cadvisor** service.  
> The expected output should look like this:  
>
> ![Prometheus result](images/prometheus_result1.png)

---

### **2. Traffic**  

**Definition**: The total **request volume** your system processes over time. Traffic helps identify usage patterns and potential scalability requirements.

#### **Grafana Configuration:**
> **📌 TIP**  
> Create a **Grafana panel** with:  
> ```promql
> sum(rate(container_network_receive_bytes_total[5m])) by (container_label_k8s_app)
> ```
> using the `container_network_receive_bytes_total` metric from the **Cadvisor** service.  
> The expected output should be:  
>
> ![Prometheus result](images/prometheus_result2.png)

> **📌 TIP**  
> Create another **Grafana panel** for transmitted network traffic:  
> ```promql
> sum(rate(container_network_transmit_bytes_total[5m])) by (span_name)
> ```
> using the `container_network_transmit_bytes_total` metric from the **Cadvisor** service.  
> The expected output should be:  
>
> ![Prometheus result](images/prometheus_result3.png)

> **📌 TIP**  
> Monitor **network receive errors** with this query:  
> ```promql
> sum(rate(container_network_receive_errors_total[5m])) by (span_name)
> ```
> using the `container_network_receive_errors_total` metric from **Cadvisor**.  
> The expected output should be:  
>
> ![Prometheus result](images/prometheus_result4.png)

> **📌 TIP**  
> Monitor **network transmit errors** with this query:  
> ```promql
> sum(rate(container_network_transmit_errors_total[5m])) by (span_name)
> ```
> using the `container_network_transmit_errors_total` metric from **Cadvisor**.  
> The expected output should be:  
>
> ![Prometheus result](images/prometheus_result5.png)

---

### **3. Errors**  

**Definition**: The rate of **failed requests** in the system. This includes HTTP errors (e.g., `5xx` codes) and **application-level failures**. High error rates indicate **instability** and may require immediate attention.

#### **Grafana Configuration:**
> **📌 TIP**  
> Create a **Grafana panel** with the following PromQL query:
> ```promql
> sum(rate(container_scrape_error[5m])) by (job)
> ```
> using the `container_scrape_error` metric from **Cadvisor**.  
> The expected output should be:  
>
> ![Prometheus result](images/prometheus_result6.png)

> **📌 TIP**  
> Create a **Grafana log panel** for error-level logs:  
> ```promql
> {service_name="unknown_service"} |= "err"
> ```
> This filters logs where `"err"` appears in the **log level** field.  
> The expected output should be:  
>
> ![Grafana result](images/grafana_result1.png)

---

### **4. Saturation**  

**Definition**: The **resource utilization** of the system. This includes CPU, memory, and disk usage. **High saturation levels** indicate potential performance bottlenecks.

#### **Grafana Configuration:**
> **📌 TIP**  
> Create a **Grafana panel** for **CPU saturation** using this query:
> ```promql
> sum(rate(container_cpu_system_seconds_total[5m])) by (job)
> ```
> using the `container_cpu_system_seconds_total` metric from **Cadvisor**.  
> The expected output should be:  
>
> ![Prometheus result](images/prometheus_result7.png)

> **📌 TIP**  
> Create a **Grafana panel** to track Kubernetes **container resource allocation**:
> ```promql
> sum(rate(container_label_io_kubernetes_container_name[5m])) by (job)
> ```
> using the `container_label_io_kubernetes_container_name` metric from **Cadvisor**.  
> The expected output should be:  
>
> ![Prometheus result](images/prometheus_result8.png)

---

## **Deployment**

Before applying new configurations, **clean up previous resources**:

```bash
#!/bin/bash

kubectl delete ns application
kubectl delete ns opentelemetry
kubectl delete ns monitoring
kubectl delete pv --all 
kubectl delete pvc --all 
sleep 5;

echo "-------------------------------------------------------------------------"
echo "Start creating"
echo "-------------------------------------------------------------------------"
kubectl apply -f ../exercise10/storage.yaml;
kubectl apply -f ../exercise10/deployment.yaml;
kubectl apply -f ../exercise10/otel-collector.yaml;
kubectl apply -f ../exercise8/jaeger.yaml;
kubectl apply -f ../exercise9/prometheus.yaml;
kubectl apply -f ../exercise10/grafana-loki.yaml;
kubectl apply -f ./grafana.yaml;
echo "-------------------------------------------------------------------------"
echo "wait"
echo "-------------------------------------------------------------------------"
sleep 5;
kubectl get pods -A
```

---

## **Tip for Infrastructure as Code (IaC) with Ansible**

> [!TIP]
> A more efficient **Infrastructure as Code (IaC)** approach can be implemented with Ansible to apply the new configuration and start its service in Minikube. An [example](./infra.yaml) of how to structure a YAML playbook to achieve this.

Run the playbook:

```bash
ansible-playbook -i ../exercise4.1/ansible_quickstart/inventory.ini infra.yaml
minikube service grafana-service -n monitoring
```

---
## **Final Objective**

At the end of this document, you should accomplished this:
> [!IMPORTANT]
> These signals offer a holistic view of system performance, enabling SREs to quickly address critical reliability issues. Here is a preview of the dashboard 
> 
> <img src="images/Dashboard.png" alt="Dashboard" height="150" />
> <img src="images/Dashboard1.png" alt="Dashboard" height="150" />
> 
> At [New Dashboard](grafana.yaml) is an example of all Grafana setting which include the new dashboard configuration

---

## **Cleanup**
To remove all resources:

```bash
kubectl delete ns application opentelemetry monitoring
kubectl delete pv --all
kubectl delete pvc --all
```

---