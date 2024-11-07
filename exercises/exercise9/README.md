# Table of Contents

- [Configuring OpenTelemetry Collector for Trace-Based Metrics](#configuring-opentelemetry-collector-for-trace-based-metrics)
   - [Steps Overview](#steps-overview)
   - [SpanMetrics Connector](#spanmetrics-connector)
   - [Example Configuration for OpenTelemetry Collector](#example-configuration-for-opentelemetry-collector)
     - [Key Configuration Components](#key-configuration-components)
   - [Exporting Metrics to Prometheus](#exporting-metrics-to-prometheus)
   - [Build a Dashboard at Grafana using the new metrics](#build-a-dashboard-at-grafana-using-the-new-metrics)
-  [Deployment](#deployment)
-  [Tip for Infrastructure as Code (IaC) with Ansible](#tip-for-infrastructure-as-code-iac-with-ansible)
-  [Final Objective](#final-objective)


# Configuring OpenTelemetry Collector for Trace-Based Metrics

In this section, we will configure the OpenTelemetry Collector to generate metrics based on the traces received from the Python application. To achieve this, we will use the `spanmetricsconnector`, a component available in the [OpenTelemetry Collector Contrib repository](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/connector/spanmetricsconnector). This connector will act as a processor that creates metrics from the incoming traces, and we will configure an exporter to send these metrics to Prometheus.


![python otelcollector jaeger](<python-otelcollector-jaeger.png>)

All the following configurations are going to create the line in red for the draw above

## Steps Overview

1. **Install and Configure the SpanMetrics Connector**: This connector will convert spans (trace data) into metrics.
2. **Create a Processor and Connector**: These will generate the metrics from the trace data.
3. **Configure a Prometheus Exporter**: This will send the generated metrics to Prometheus for monitoring and visualization.

### SpanMetrics Connector

The `spanmetricsconnector` is designed to aggregate span data and generate corresponding metrics. It tracks key metrics like request count, error count, and request duration, which are useful for monitoring application performance.

### Example Configuration for OpenTelemetry Collector

Here is an example configuration for the OpenTelemetry Collector using the `spanmetricsconnector` and setting up the Prometheus exporter.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-config
  namespace: opentelemetry
data:
  config.yaml: |
    ....
    exporters:
      ...
      debug: {}  # Use debug exporter instead of logging
      prometheus:
        endpoint: "0.0.0.0:9464"  # Prometheus exporter for metrics
        namespace: "otel_collector"  # Optional: Adds prefix to metric names
    ...
    connectors:
      spanmetrics:  # Connect the spanmetrics connector to process traces
          namespace: span.metrics

    ...
    service:
    ...
            traces: 
                ...
                exporters: [debug, otlp/jaeger, spanmetrics]
            metrics:
              receivers: [otlp, spanmetrics]
              ...

---
apiVersion: v1
kind: Service
...
  type: ClusterIP
  ports:
    - name: metrics
      port: 9464
      targetPort: 9464
      protocol: TCP
...
    app: otel-collector
```

### Key Configuration Components

- **Receivers**: The OTLP receiver listens for trace data from the Python application.
- **Processors**: 
  - `batch`: Batches spans for more efficient processing and exporting.
  - `spanmetrics`: Converts spans into metrics, including request duration and error counts.
- **Exporters**: The `prometheus` exporter exposes a `/metrics` endpoint that Prometheus can scrape for metrics data.
- **Service Pipelines**: The pipeline defines how the traces are processed and which exporters are used. In this case, the traces are received, processed with `spanmetrics` to generate metrics, and then exported to Prometheus.

### Exporting Metrics to Prometheus

Once the OpenTelemetry Collector is running with the above configuration, Prometheus can scrape the metrics at the configured endpoint. This setup ensures that you can monitor trace-based metrics, such as:
- **Request Count**: Total number of requests received.
- **Error Count**: Total number of errors encountered.
- **Request Duration**: Latency of requests, provided in histogram buckets.


### Example Configuration to integrate Prometheus with the OtelCollector

Here is an example  of the job required to let's Prometheus scrape the information from Otel exporter.
```yaml
      - job_name: 'otel-collector'
        scrape_interval: 15s
        static_configs:
          - targets: ['otel-collector.opentelemetry.svc.cluster.local:9464']  # Address of the OpenTelemetry Collector
```

## Checkout the metric at Prometheus

Open Prometheus page and look for all the new metrics with this preffix **otel_collector_span**
```bash
minikube service prometheus-service  -n monitoring
```
![metrics-at-prometheus](metrics-at-prometheus.png)

## Build a Dashboard at Grafana using the new metrics

Let's use the new `otel_collector_span_metrics_calls_total` to create a report, but let's filter the results to only display when the goo function fails with the statement `{span_name="goo", status_code="STATUS_CODE_ERROR"}`. The result should looks domethin like 

At the [grafana](./grafana.yaml) configuration file:
```yaml
       {
          "datasource": "Prometheus",
          ...
          "targets": [
            {
              "expr": "rate(otel_collector_span_metrics_calls_total{span_name=\"goo\", status_code=\"STATUS_CODE_ERROR\"}[5m])",
              "refId": "C"
            }
          ],
          "title": "goo application errors",
          ...
    }
```

# Deployment
Before deploy all the new staff it's important to clean the changes from the previous exercises and then apply the new settings wih short program like this one:
```bash
#!/bin/bash
kubectl delete ns application
kubectl delete ns opentelemetry
kubectl delete ns monitoring
sleep 5;
kubectl apply -f ../exercise8/deployment.yaml;
kubectl apply -f ./otel-collector.yaml;
kubectl apply -f ../exercise8/jaeger.yaml;
kubectl apply -f ./prometheus.yaml;
kubectl apply -f ./grafana.yaml;
```

# Tip for Infrastructure as Code (IaC) with Ansible

> [!TIP]
> A more efficient **Infrastructure as Code (IaC)** approach can be implemented with Ansible to apply the new configuration and start its service in Minikube. Below is an example of how to structure a YAML playbook to achieve this:
> 1. **Create a YAML Playbook**
> ```yaml
> ---
> - name: Automate Kubernetes Cleanup and Deployment
>   hosts: all
>   gather_facts: no
>
>   tasks:
>     - name: Delete 'application' namespace
>       command:
>         cmd: kubectl delete ns application
>       ignore_errors: yes
> 
>     - name: Delete 'opentelemetry' namespace
>       command:
>         cmd: kubectl delete ns opentelemetry
>       ignore_errors: yes
> 
>     - name: Delete 'monitoring' namespace
>       command:
>         cmd: kubectl delete ns monitoring
>       ignore_errors: yes
> 
>     - name: Wait for 5 seconds
>       wait_for:
>         timeout: 5
> 
>     - name: Apply deployment.yaml
>       command:
>         cmd: kubectl apply -f ../exercise8/deployment.yaml
> 
>     - name: Apply otel-collector.yaml
>       command:
>         cmd: kubectl apply -f ./otel-collector.yaml
> 
>     - name: Apply jaeger.yaml
>       command:
>         cmd: kubectl apply -f ../exercise8/jaeger.yaml
> 
>     - name: Apply prometheus.yaml
>       command:
>         cmd: kubectl apply -f ./prometheus.yaml
> 
>     - name: Apply grafana.yaml
>       command:
>         cmd: kubectl apply -f ./grafana.yaml
> 
>     - name: Get all pods across all namespaces
>       command:
>         cmd: kubectl get pods -A
> 
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
> ![Granafa-dashboard](Granafa-dashboard.png)