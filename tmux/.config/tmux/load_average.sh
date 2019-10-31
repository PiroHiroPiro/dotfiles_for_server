#!/bin/bash -e

uptime | awk '{print substr($10, 0, 4)}'
