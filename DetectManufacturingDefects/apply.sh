#!/bin/bash

export DOCKER_TAG=gcr.io/ql-shared-resources-test/defect_solution@sha256:776fd8c65304ac017f5b9a986a1b8189695b7abbff6aa0e4ef693c46c7122f4c


export VISERVING_CPU_DOCKER_WITH_MODEL=${DOCKER_TAG}
export HTTP_PORT=8602
export LOCAL_METRIC_PORT=8603

docker pull ${VISERVING_CPU_DOCKER_WITH_MODEL}


gsutil cp gs://cloud-training/gsp895/prediction_script.py .


docker run -v /secrets:/secrets --rm -d --name "test_cpu" \
    --network="host" \
    -p ${HTTP_PORT}:8602 \
    -p ${LOCAL_METRIC_PORT}:8603 \
    -t ${VISERVING_CPU_DOCKER_WITH_MODEL} \
    --metric_project_id="${PROJECT_ID}" \
    --use_default_credentials=false \
    --service_account_credentials_json=/secrets/assembly-usage-reporter.json
