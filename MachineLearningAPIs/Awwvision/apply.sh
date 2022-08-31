#!/bin/bash

gcloud config set compute/zone us-central1-a
gcloud container clusters create awwvision \
    --num-nodes 2 \
    --scopes cloud-platform

gcloud container clusters get-credentials awwvision


apt-get install -y virtualenv
python3 -m venv venv
source venv/bin/activate



pushd cloud-vision/python/awwvision
  make all
popd
