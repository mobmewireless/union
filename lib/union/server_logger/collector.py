# Code copied from https://github.com/mobmewireless/ossec-collector.
# This collects ossec logs from remote server.

import re
import time
import json

DEFAULT_OSSEC_ALERTS_LOG = '/var/ossec/logs/alerts/alerts.log'
PATTERN_ALERT_TIMESTAMP = re.compile('[0-9]+.[0-9]+')


def collect(ossec_alerts_log=DEFAULT_OSSEC_ALERTS_LOG):
    output_array = {}
    current_alert = None
    current_lines = []

    # Read the file /var/ossec/logs/alerts/alerts.log
    try:
        with open(ossec_alerts_log) as f:
            content = f.readlines()
    except IOError:
        content = ['** Alert ' + str(time.time()), 'OSSEC alerts log file is missing.']

    # Form an array of timestamp to data.
    for line in content:
        stripped_line = line.strip()

        if line.startswith('** Alert'):
            alert_match = PATTERN_ALERT_TIMESTAMP.search(line)
            current_alert = alert_match.group()
        elif stripped_line == "":
            if current_alert:
                output_array[current_alert] = current_lines
                current_alert = None
                current_lines = []
        else:
            if current_alert:
                if stripped_line:
                    current_lines.append(stripped_line)

    # Clear buffers.
    if current_alert:
        output_array[current_alert] = current_lines

    # Output the array as JSON.
    return output_array

print(json.dumps(collect()))