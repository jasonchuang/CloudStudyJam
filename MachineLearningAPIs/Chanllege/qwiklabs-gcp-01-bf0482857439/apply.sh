#!/bin/bash


# 1
export PROJECT=<Your_Project_ID>
gcloud iam service-accounts create my-account --display-name my-account

gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:my-account@$PROJECT.iam.gserviceaccount.com --role=roles/bigquery.admin
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:my-account@$PROJECT.iam.gserviceaccount.com --role=roles/storage.admin


# 2
gcloud iam service-accounts keys create key.json --iam-account=my-account@$PROJECT.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=key.json

# 3
export BUCKET=$PROJECT
python analyze-images.py $PROJECT $BUCKET
