"""This is an example to run predictions to call rest apis from containers.

This is intended to be released to open source. To obtain the latency
percentiles, set num_of_requests to a number larger than 1.

Examples:
python3 ./predict_assembly.py --input_image_file=./<your test image>.jpg --port=8602

python3 ./predict_assembly.py --input_image_file=./<your test image>.jpg --port=8602 --num_of_requests=10

"""
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import base64
import json
import time
import re

from absl import app
from absl import flags
import numpy as np
import requests

flags.DEFINE_string('hostname', 'http://localhost', 'The hostname for serving.')
flags.DEFINE_string('input_image_file', None, 'The input image file name.')
flags.DEFINE_string('output_result_file', None, 'The prediction output file name.')
flags.DEFINE_integer('port', None, 'The port of rest api.')
flags.DEFINE_integer('num_of_requests', 1, 'The number of requests to send.')

FLAGS = flags.FLAGS

def create_request_body(input_image_file):
    """Creates the request body to perform api calls.

    Args:
    input_image_file: String, the input image file name.

    Returns:
    A json format string of the request body. The format is like below:
        {"image_bytes":<BASE64_IMAGE_BYTES>}
    """

    with open(input_image_file, 'rb') as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

    request_body = {'image_bytes': str(encoded_string)}

    return json.dumps(request_body)


def predict(hostname, input_image_file, port):
    """Predict results on the input image using services at the given port.

    Args:
    hostname: String, the host name for the serving.
    input_image_file: String, the input image file name.
    port: Integer, the port that runs the rest api service.

    Returns:
    The predicted results in json format. 
    """
    url = hostname + ':' + str(port) + '/v1beta1/visualInspection:predict'
    request_body = create_request_body(input_image_file)
    response = requests.post(url, data=request_body)
    return response.json()

def compute_latency_percentile(hostname, input_image_file, port,
                             num_of_requests):
    """Computes latency percentiles of server's prediction endpoint.

    Args:
    hostname: String, the host name for the serving.
    input_image_file: String, the input image file name.
    port: Integer, the port that runs the rest api service.
    num_of_requests: The number of requests to send.

    Returns:
    The dictionary of latency percentiles of 75%, 90%, 95%, 99%.
    """
    latency_list = []

    for _ in range(num_of_requests):
        response = predict(hostname, input_image_file, port)
        latency_in_ms = float(response['predictionLatency'][:-1])
        latency_list.append(latency_in_ms)

    latency_percentile = {}
    percentiles = [75, 90, 95, 99]
    for percentile in percentiles:
        latency_percentile[percentile] = np.percentile(latency_list, percentile)

    return latency_percentile


def main(_):
    if FLAGS.num_of_requests > 1:
        latency_percentile = compute_latency_percentile(FLAGS.hostname,
                                                        FLAGS.input_image_file,
                                                        FLAGS.port,
                                                        FLAGS.num_of_requests)
        print(latency_percentile)
        with open(FLAGS.output_result_file, 'w+') as latency_result:
            latency_result.write(json.dumps(latency_percentile))
    else:
        start = time.time()
        results = predict(FLAGS.hostname, FLAGS.input_image_file, FLAGS.port)
        end = time.time()
        print('Processed image {} in {}s.'.format(FLAGS.input_image_file, end - start))
        print(json.dumps(results, indent=2))
        with open(FLAGS.output_result_file, 'w+') as prediction_result:
            prediction_result.write(json.dumps(results, indent=2))


if __name__ == '__main__':
    flags.mark_flag_as_required('input_image_file')
    flags.mark_flag_as_required('port')
    flags.mark_flag_as_required('output_result_file')
    app.run(main)
