#!/bin/bash

# Enhanced logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to wait for pods with timeout
wait_for_pods() {
    local namespace=$1
    local label_selector=$2
    local timeout=${3:-300}  # 5 minutes default
    local counter=0
    
    log "Waiting for pods with selector '$label_selector' in namespace '$namespace'..."
    
    while [ $counter -lt $timeout ]; do
        if kubectl get pods -n "$namespace" -l "$label_selector" --no-headers 2>/dev/null | grep -q "Running"; then
            log "Pods are running!"
            return 0
        fi
        
        # Show current pod status for debugging
        log "Current pod status:"
        kubectl get pods -n "$namespace" -l "$label_selector" 2>/dev/null || log "  No pods found yet"
        
        sleep 10
        counter=$((counter + 10))
        log "Waiting... (${counter}s/${timeout}s)"
    done
    
    log "ERROR: Timeout waiting for pods to be ready"
    return 1
}

# Function to check if namespace exists
ensure_namespace() {
    local namespace=$1
    if ! kubectl get namespace "$namespace" >/dev/null 2>&1; then
        log "Creating namespace: $namespace"
        kubectl create namespace "$namespace"
    else
        log "Namespace $namespace already exists"
    fi
}

log "Checking toolchain dependencies..."

# Check dependencies
for tool in colima minikube kubectl docker helm; do
    if command -v $tool >/dev/null 2>&1; then
        log "$tool is installed."
    else
        log "ERROR: $tool is not installed or not in PATH"
        exit 1
    fi
done

log "Waiting for 2 seconds..."
sleep 2

log "Performing full cleanup of Minikube and Colima environments..."
minikube delete --all
log "Stopping and cleaning up Colima..."
colima stop
colima delete --force

log "Waiting for 5 seconds..."
sleep 5

log "Initializing and Starting Colima with Docker runtime..."
log "Starting colima..."
colima start --runtime docker

log "Waiting for 5 seconds..."
sleep 5

log "Starting Minikube with Docker driver..."
minikube start --driver=docker

log "Waiting for 5 seconds..."
sleep 5

log "Creating log directory inside Minikube VM..."
minikube ssh -- 'sudo mkdir -p /var/log/awx'

log "Waiting for 5 seconds..."
sleep 5

log "Cleaning up Kubernetes cluster..."
kubectl delete all --all --all-namespaces --ignore-not-found=true
kubectl delete namespace awx --ignore-not-found=true

log "Waiting for 5 seconds..."
sleep 5

echo "-------------------------------------------------------------------------"
echo "Install AWX"
echo "-------------------------------------------------------------------------"

# Add AWX operator Helm repository
helm repo add awx-operator https://ansible.github.io/awx-operator/
helm repo update

# Ensure namespace exists
ensure_namespace awx

# Install AWX operator with explicit wait
log "Installing AWX operator..."
helm install my-awx-operator awx-operator/awx-operator -n awx --wait --timeout=10m

echo "-------------------------------------------------------------------------"
echo "Configure AWX"
echo "-------------------------------------------------------------------------"

# Wait for AWX operator pod to be running with proper error handling
if wait_for_pods "awx" "app.kubernetes.io/name=awx-operator" 300; then
    log "AWX operator is ready!"
    
    # Show pod details for confirmation
    kubectl get pods -n awx -l "app.kubernetes.io/name=awx-operator"
    
    # Apply AWX instance configuration
    log "Creating AWX instance..."
    cat <<EOF | kubectl apply -f -
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
  namespace: awx
spec:
  service_type: nodeport
  storage_type: existing_pv
  storage_class_name: standard
  storage_access_mode: ReadWriteOnce
  storage_size: 8Gi
  postgres_storage_class: standard
  postgres_storage_size: 8Gi
EOF

    log "Waiting for AWX instance to be ready..."
    if wait_for_pods "awx" "app.kubernetes.io/name=awx-demo" 600; then
        log "AWX instance is ready!"
        
        # Get the NodePort service details
        log "Getting AWX service information..."
        kubectl get svc -n awx
        
        # Get the Minikube IP
        MINIKUBE_IP=$(minikube ip)
        AWX_PORT=$(kubectl get svc awx-demo-service -n awx -o jsonpath='{.spec.ports[0].nodePort}')
        
        log "AWX is accessible at: http://$MINIKUBE_IP:$AWX_PORT"
        log "Default admin username: admin"
        log "To get admin password, run: kubectl get secret awx-demo-admin-password -n awx -o jsonpath='{.data.password}' | base64 --decode"
        
    else
        log "ERROR: AWX instance failed to start"
        log "Debugging information:"
        kubectl get all -n awx
        kubectl describe awx awx-demo -n awx
        exit 1
    fi
else
    log "ERROR: AWX operator failed to start"
    log "Debugging information:"
    kubectl get all -n awx
    kubectl logs -n awx -l "app.kubernetes.io/name=awx-operator" --tail=50
    exit 1
fi

log "Script completed successfully!"