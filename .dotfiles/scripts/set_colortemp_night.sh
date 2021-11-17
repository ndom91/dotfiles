#!/bin/bash

SCT=6500

while [ "$SCT" -gt 3200 ]; do
  /usr/bin/sct $SCT
  echo "sct:" $SCT
  ((SCT -= 100)) || true
  sleep 5
done
