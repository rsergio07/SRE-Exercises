#!/bin/bash

kubectl delete ns application
kubectl delete ns opentelemetry
kubectl delete ns monitoring
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
kubectl apply -f ../exercise10/storage.yaml;
kubectl apply -f ../exercise10/deployment.yaml;
kubectl apply -f ../exercise10/otel-collector.yaml;
kubectl apply -f ../exercise8/jaeger.yaml;
kubectl apply -f ../exercise9/prometheus.yaml;
kubectl apply -f ./grafana-loki.yaml;
kubectl apply -f ./grafana.yaml;
echo "-------------------------------------------------------------------------"
echo "wait"
echo "-------------------------------------------------------------------------"
sleep 10;
kubectl get pods -A