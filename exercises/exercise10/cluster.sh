#!/bin/bash

podman login docker.io
podman build -t cguillenmendez/sre-abc-training-python-app:latest .
podman build -t cguillenmendez/sre-abc-training-python-app:0.0.23 .
podman push cguillenmendez/sre-abc-training-python-app:latest
podman push cguillenmendez/sre-abc-training-python-app:0.0.23

sudo mkdir -p /Users/cristianguillenmendez/Documents/aaaaaaa
#sudo chown -R 1000:1000 /opt/sre-app/logs
sudo chmod -R 775 /Users/cristianguillenmendez/Documents/aaaaaaa

kubectl delete ns test
kubectl delete ns application
kubectl delete ns opentelemetry
kubectl delete ns monitoring
kubectl delete ns storage
kubectl delete pv --all 
kubectl delete pvc --all 
sleep 5;

## Run commands inside Minikube
## Create the directory for logs
# sudo mkdir -p /data/sre-app/logs
  
## Change permissions to make it writable by all users
# sudo chmod 777 /data/sre-app/logs

## Exit from the Minikube SSH session
# exit
echo "-------------------------------------------------------------------------"
echo "Start creating"
echo "-------------------------------------------------------------------------"
kubectl apply -f ./storage.yaml;
kubectl apply -f ./deployment.yaml;
kubectl apply -f ./otel-collector.yaml;
kubectl apply -f ../exercise8/jaeger.yaml;
kubectl apply -f ../exercise9/prometheus.yaml;
kubectl apply -f ./grafana-loki.yaml;
kubectl apply -f ./grafana.yaml;
echo "-------------------------------------------------------------------------"
echo "wait"
echo "-------------------------------------------------------------------------"
sleep 10;
kubectl get pods -A



#minikube ssh
#ls /data/sre-app/logs
#cat /data/sre-app/logs/sre-app.log