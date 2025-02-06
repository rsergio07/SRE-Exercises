
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
helm create my-sre-app-chart
rm -rf my-sre-app-chart/templates/*
touch Chart.yaml values.yaml templates/deployment.yaml templates/install_awx.yaml templates/configure_awx.yaml
```
Ajustar esto de arriba por los archivos ya incluidos 

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
helm install sre-app ./my-sre-app-chart
helm get manifest sre-app
```

This command will install the chart and execute the configured steps.

## Resulting Directory Structure

This process will create the following directory structure:




helm install sre-app ./my-sre-app-chart 
helm uninstall sre-app







helm package ./my-sre-app-chart

minikube service sre-abc-training-service  -n application
minikube service grafana-service  -n monitoring








# Publish a Helm Chart to a Public Repository

This guide explains how to publish a Helm chart to a public repository.

## Prerequisites

- Ensure you have Helm installed on your system.
- Confirm that Git and GitHub CLI are installed and configured with the appropriate permissions.
- A GitHub repository to host the Helm chart.

## Steps to Publish the Chart

1. **Package the Helm Chart:**
   ```bash
   helm package ./my-sre-app-chart
   ```
   This will create a `.tgz` file in the current directory.

2. **Create an `index.yaml` File:**
   Use the `helm repo index` command to generate an `index.yaml` file:
   ```bash
   helm repo index . --url https://cguillencr.github.io/sre-abc-training/
   ```
   This command scans the `.tgz` files in the directory and creates an index file required for Helm repositories.

3. **Enable GitHub Pages:**
   - Go to your repository on GitHub.
   - Navigate to **Settings > Pages**.
   - Set the source to the `main` branch and the `docs` directory.
   - Save the changes.

4. **Push the Helm Chart Files to GitHub:**
   ```bash
   helm package ./my-sre-app-chart
   mkdir -p ../../docs/
   mv my-sre-app-chart-0.1.0.tgz ../../docs/my-sre-app-chart-0.1.0.tgz
   cd ../../docs
   helm repo index ./ --url https://cguillencr.github.io/sre-abc-training
   
   git add ./index.yaml
   git add ./my-sre-app-chart-0.1.0.tgz
   cd ../exercises/exercise14
   git commit --amend -m "Helm configuration"
   git push -u origin main -f
   ```

4. **Access Your Repository:**
   After enabling GitHub Pages, your Helm repository will be available at:
   ```
   https://cguillencr.github.io/sre-abc-training/
   ```

7. **Test the Repository Locally:**
   Add the repository to your local Helm configuration:
   ```bash
   helm repo add sre-abc-lab https://cguillencr.github.io/sre-abc-training/
   #helm repo remove sre-abc-lab
   ```
   Verify the repository:
   ```bash
   helm repo update
   helm repo list
   helm search repo sre-abc-lab
   ```


8.**Install the aplication from the repository:**
helm install sre-app sre-abc-lab/my-sre-app-chart