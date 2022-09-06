#!/bin/bash

export PROJECT_ID=$(gcloud config get-value core/project)
gsutil cp gs://${PROJECT_ID}/demo_pcb_images/image_439_cx31_cy-35_r-4.png .

python3 ./prediction_script.py --input_image_file=./image_439_cx31_cy-35_r-4.png  --port=8602 --output_result_file=non_def_prediction_result.json
python3 ./prediction_script.py --input_image_file=./image_275_cx98_cy16_r-5.png  --port=8602 --num_of_requests=10 --output_result_file=non_def_latency_result.json
