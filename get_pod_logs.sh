#!/bin/bash

if [ -z "$1" ]; then
  echo "Namespace argument is missing."
  echo "Usage: ./get_pod_logs.sh <namespace>"
  exit 1
fi

namespace="$1"

logs_directory="pod_logs"
mkdir -p "$logs_directory"

pods=$(kubectl get pods -n "$namespace" --no-headers -o custom-columns=":metadata.name")

for pod in $pods; do
  containers=$(kubectl get pod "$pod" -n "$namespace" --no-headers -o custom-columns=":spec.containers[*].name")

  for container in ${containers//,/ }; do
    log_file="${logs_directory}/${pod}-${container}.txt"
    kubectl logs "$pod" -n "$namespace" -c "$container" > "$log_file"
    echo "Logs for pod $pod and container $container saved to $log_file"
  done
done

zip_file="pod_logs.zip"
zip -r "$zip_file" "$logs_directory"

echo "Log files have been exported and stored in $zip_file"

