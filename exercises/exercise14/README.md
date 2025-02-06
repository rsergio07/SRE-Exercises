
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
```

Now let now the most recentr yaml files in to our new chart
```bash
mv ../exercise10/storage.yaml ../exercise10/deployment.yaml ../exercise10/otel-collector.yaml ../exercise8/jaeger.yaml ../exercise9/prometheus.yaml ../exercise12/grafana-loki.yaml ./grafana.yaml my-sre-app-chart/templates/
```
### Description of the Files:

1. **`Chart.yaml`:** This file contains the description of our new chart. It defines the name, version, and other relevant details.
2. **`values.yaml`:** This file defines the default values to be used in the chart. Here, we will add values such as the namespace name and file paths.
2. **`/templates/*`:** All the MANIFEST files you want to include in your new chart.

## Step 3: Installing and Running the Chart

Once the above configurations are in place, you can proceed to install the chart using the following Helm command:

```bash
helm install sre-app ./my-sre-app-chart
helm get manifest sre-app
kugbectl get pods -A
```

This is the expected output 
```
application     sre-abc-training-app-766c47bdfc-4bmf2              0/1     ContainerCreating   0          18s
application     sre-abc-training-app-766c47bdfc-g99cn              0/1     ContainerCreating   0          18s
application     sre-abc-training-app-766c47bdfc-xfjxs              0/1     ContainerCreating   0          18s
awx             awx-demo-migration-24.6.1-js69h                    0/1     Completed           0          11m
awx             awx-demo-postgres-15-0                             1/1     Running             0          12m
awx             awx-demo-task-676f8784d6-j6b55                     4/4     Running             0          12m
awx             awx-demo-web-6cc8c7cbf6-zk9md                      3/3     Running             0          12m
awx             awx-operator-controller-manager-748c67f659-kf6jh   2/2     Running             0          14m
kube-system     coredns-6f6b679f8f-6h486                           1/1     Running             0          14m
kube-system     etcd-minikube                                      1/1     Running             0          15m
kube-system     kube-apiserver-minikube                            1/1     Running             0          15m
kube-system     kube-controller-manager-minikube                   1/1     Running             0          14m
kube-system     kube-proxy-cfcg5                                   1/1     Running             0          14m
kube-system     kube-scheduler-minikube                            1/1     Running             0          14m
kube-system     storage-provisioner                                1/1     Running             0          14m
monitoring      grafana-deployment-574d97df54-qfr65                0/1     ContainerCreating   0          18s
monitoring      prometheus-deployment-5798446c77-vwsbh             0/1     ContainerCreating   0          18s
opentelemetry   jaeger-67756bcc5b-twpv5                            1/1     Running             0          18s
opentelemetry   loki-844db6f8c7-q5r8q                              1/1     Running             0          18s
opentelemetry   otel-collector-7f64d77765-2b52r                    1/1     Running             0          18s
```

Same than last time could use, to expose the services
```
minikube service sre-abc-training-service  -n application
minikube service grafana-service  -n monitoring
```


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