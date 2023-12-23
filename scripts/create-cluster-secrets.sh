#!/bin/bash

# Define the environments
environments=("dev" "qa" "prod")

# Loop through each environment
for env in "${environments[@]}"; do
    echo "Processing environment: $env"

    # Define secret name and namespace
    secret_name="env-$env-access"
    namespace="env-$env"

    # Check if the secret already exists
    if kubectl get secret "$secret_name" -n "$namespace" &> /dev/null; then
        echo "Secret $secret_name already exists in namespace $namespace. Deleting..."
        kubectl delete secret "$secret_name" -n "$namespace"
    fi

    # Create the secret with the new configuration
    echo "Creating secret $secret_name in namespace $namespace"
    vcluster connect "env-$env" -n "$namespace" --server="env-$env.env-$env.svc.cluster.local" --insecure --update-current=false --print | \
    kubectl create secret generic "$secret_name" -n "$namespace" --from-file=config=/dev/stdin
done

echo "Secrets creation/update completed."
