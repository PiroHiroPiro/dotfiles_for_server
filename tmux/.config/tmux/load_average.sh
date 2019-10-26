#!/bin/bash -e

uptime | awk '{print substr($9, 0, 5)}'
