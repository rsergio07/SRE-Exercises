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
kubectl get pods -A