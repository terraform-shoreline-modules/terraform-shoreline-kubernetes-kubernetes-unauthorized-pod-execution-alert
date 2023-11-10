#!/bin/bash

# Set the pod name
POD_NAME=${POD_NAME}

# Delete the unauthorized pod
kubectl delete pod $POD_NAME

# Check if the pod has been deleted
POD_STATUS=$(kubectl get pod $POD_NAME | awk '{print $3}' | tail -n1)
if [ $POD_STATUS == "Terminating" ]; then
  echo "The pod is being terminated"
else
  echo "The pod has been deleted"
fi