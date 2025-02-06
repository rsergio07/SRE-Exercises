#!/bin/bash

echo "-------------------------------------------------------------------------"
echo "Cleaning all"
echo "-------------------------------------------------------------------------"

minikube delete
minikube start

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
kubectl apply -f ../exercise13/awx-demo.yml
kubectl get service awx-demo-service -n awx #Wait for the awx-demo-service to become available: It could take someminutes
sleep 2;
kubectl get pods -A
#wait until
#awx           awx-demo-migration-24.6.1-js69h                    0/1     Completed   0          82s
#awx           awx-demo-postgres-15-0                             1/1     Running     0          2m59s
#awx           awx-demo-task-676f8784d6-j6b55                     0/4     Init:0/2    0          2m28s
#awx           awx-demo-web-6cc8c7cbf6-zk9md                      3/3     Running     0          2m28s
#awx           awx-operator-controller-manager-748c67f659-kf6jh   2/2     Running     0          4m15s
minikube service awx-demo-service -n awx
# admin and the password of the following command
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo

echo "-------------------------------------------------------------------------"
echo "Execute an ansible playbook"
echo "-------------------------------------------------------------------------"
ansible-playbook -i ../exercise4.1/ansible_quickstart/inventory.ini ../exercise13/collect-status-application.yaml

echo "-------------------------------------------------------------------------"
echo "Install the rest of the Infra"
echo "-------------------------------------------------------------------------"

helm uninstall sre-app
helm delete sre-app
helm install sre-app ./my-sre-app-chart 

echo "-------------------------------------------------------------------------"
echo "wait"
echo "-------------------------------------------------------------------------"
sleep 10;
kubectl get pods -A