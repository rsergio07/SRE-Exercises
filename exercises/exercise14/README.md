
# Installation and Configuration Using Helm Charts

Currently, we have built our entire application using the commands present in `../exercise13/cluster.sh`, which are used to review the installation order of each application and their respective configurations. As seen, the script installs numerous Kubernetes manifests, and while this is a valid approach, it entails a considerable amount of work for the SRE team due to the following reasons:

1. **Rigid installation order:** The team must follow a strict installation sequence, with no version number to reference, making it difficult to roll back the installation in case of failure.
2. **Code duplication:** Each manifest may contain similar values across different files, which introduces redundancy and complicates maintenance.

In this context, changing the installation process to use **Helm charts** can help reduce code duplication and manage all the manifests in a centralized manner, with a specific version number, allowing for better control and order.

## Step 1: Installing Helm

The first step is to install Helm, which can be done with the following command:

```bash
brew install helm
```

## Step 2: Creating the First Helm Chart

Once Helm is installed, we can proceed to create our first chart with the following commands:

```bash
mkdir my-sre-app-chart
cd my-sre-app-chart
mkdir charts templates
touch Chart.yaml values.yaml templates/deployment.yaml templates/install_awx.yaml templates/configure_awx.yaml
```

### Description of the Files:

1. **`Chart.yaml`:** This file contains the description of our new chart. It defines the name, version, and other relevant details.
2. **`values.yaml`:** This file defines the default values to be used in the chart. Here, we will add values such as the namespace name and file paths.

Example of `values.yaml`:

```yaml
namespace: awx
awx_chart_repo: "https://ansible-community.github.io/awx-operator-helm/"
awx_chart_name: "my-awx-operator"
storage_yaml_path: "../exercise10/storage.yaml"
deployment_yaml_path: "../exercise10/deployment.yaml"
otel_collector_yaml_path: "../exercise10/otel-collector.yaml"
jaeger_yaml_path: "../exercise8/jaeger.yaml"
prometheus_yaml_path: "../exercise9/prometheus.yaml"
grafana_loki_yaml_path: "../exercise12/grafana-loki.yaml"
grafana_yaml_path: "./grafana.yaml"
```

3. **`templates/deployment.yaml`:** This file defines Kubernetes resources, such as `Namespace`, `PersistentVolume` (PV), `PersistentVolumeClaim` (PVC), and others, using Helm syntax.

Example of a `Namespace` resource for AWX:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.namespace }}
```

4. **`templates/install_awx.yaml`:** This file describes the installation of the AWX operator using Helm.

```yaml
apiVersion: helm.sh/v3
kind: HelmRelease
metadata:
  name: awx-operator
  namespace: {{ .Values.namespace }}
spec:
  chart:
    repository: {{ .Values.awx_chart_repo }}
    name: awx-operator
    version: "latest"
```

5. **`templates/configure_awx.yaml`:** To configure AWX after installation, we can use a Kubernetes `Job`, where the `kubectl` commands to apply the necessary configuration are executed.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: configure-awx
  namespace: {{ .Values.namespace }}
spec:
  template:
    spec:
      containers:
        - name: configure-awx
          image: "your-image"
          command: ["/bin/bash", "-c", "kubectl apply -f awx-demo.yaml && kubectl get service awx-demo-service -n {{ .Values.namespace }}"]
      restartPolicy: Never
```

6. **`templates/apply_infra.yaml`:** This file can include additional resources required for infrastructure setup.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: apply-infra
  namespace: {{ .Values.namespace }}
spec:
  template:
    spec:
      containers:
        - name: apply-infra
          image: "your-image"
          command: ["/bin/bash", "-c", "kubectl apply -f {{ .Values.storage_yaml_path }} && kubectl apply -f {{ .Values.deployment_yaml_path }}"]
      restartPolicy: Never
```

## Step 3: Installing and Running the Chart

Once the above configurations are in place, you can proceed to install the chart using the following Helm command:

```bash
helm install my-setup ./my-setup-chart
```

This command will install the chart and execute the configured steps.

## Resulting Directory Structure

This process will create the following directory structure:

