#!/bin/bash

pushd orchestrate-with-kubernetes/kubernetes/
    gcloud config set project qwiklabs-gcp-00-897ee0b3187a
    gcloud config set compute/zone us-east1-d

    gcloud container clusters create bootcamp \
      --machine-type e2-small \
      --num-nodes 3 \
      --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"
    kubectl create -f deployments/auth.yaml
    kubectl create -f services/auth.yaml
    kubectl create -f deployments/hello.yaml
    kubectl create -f services/hello.yaml
    kubectl create secret generic tls-certs --from-file tls/
    kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
    kubectl create -f deployments/frontend.yaml
    kubectl create -f services/frontend.yaml

    kubectl create -f deployments/hello-canary.yaml
    kubectl apply -f services/hello-blue.yaml
popd


