#!/bin/bash

kubectl delete ns awx
kubectl delete ns application
kubectl delete ns opentelemetry
kubectl delete ns monitoring
kubectl delete pv --all 
kubectl delete pvc --all 
sleep 5;

echo "-------------------------------------------------------------------------"
echo "Install AWX"
echo "-------------------------------------------------------------------------"

brew install helm
helm repo add awx-operator https://ansible-community.github.io/awx-operator-helm/
helm install my-awx-operator awx-operator/awx-operator -n awx --create-namespace


echo "-------------------------------------------------------------------------"
echo "Configure AWX"
echo "-------------------------------------------------------------------------"


kubectl get pods -n awx #  awx-operator-controller-manager-*** is in a running state.
kubectl apply -f awx-demo.yaml
kubectl get service awx-demo-service -n awx #Wait for the awx-demo-service to become available: It could take someminutes
sleep 2;
kubectl get pods -A
minikube service awx-demo-service -n awx
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo
ansible-playbook -i ../exercise4.1/ansible_quickstart/inventory.ini job-template.yaml

echo "-------------------------------------------------------------------------"
echo "Install the rest of the Infra"
echo "-------------------------------------------------------------------------"

kubectl apply -f ../exercise10/storage.yaml;
kubectl apply -f ../exercise10/deployment.yaml;
kubectl apply -f ../exercise10/otel-collector.yaml;
kubectl apply -f ../exercise8/jaeger.yaml;
kubectl apply -f ../exercise9/prometheus.yaml;
kubectl apply -f ../exercise12/grafana-loki.yaml;
kubectl apply -f ./grafana.yaml;
echo "-------------------------------------------------------------------------"
echo "wait"
echo "-------------------------------------------------------------------------"
sleep 10;
kubectl get pods -A