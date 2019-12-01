#!/bin/sh

if [[ $# -eq 0 ]]; then
    SCRIPT_NAME=`basename "$0"`
    echo "Usage:"
    echo "./$SCRIPT_NAME <project-name>"
    exit 0
fi

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    exit 1
fi

PROJECT_NAME=$1

# compile package locally
./mvnw clean package -DskipTests

# Build an image on Openshift using the Docker strategy
oc new-build --name=store-catalog --binary -l app=store-catalog -n $PROJECT_NAME
oc patch bc/store-catalog -p "{\"spec\":{\"strategy\":{\"dockerStrategy\":{\"dockerfilePath\":\"src/main/docker/Dockerfile.jvm\"}}}}" -n $PROJECT_NAME
oc start-build store-catalog --from-dir=. --follow -n $PROJECT_NAME

# Create an app deployment using the built image
oc new-app --image-stream=store-catalog:latest -l app=store-catalog -n $PROJECT_NAME

# Pause the deployment config in order to apply updates on it
oc rollout pause dc store-catalog -n $PROJECT_NAME

# Set environment variables for database credentials from the secret
oc set env --from=secret/quarkus-db-credentials  --prefix=QUARKUS_ dc/store-catalog -n $PROJECT_NAME

# Add probes
oc set probe dc/store-catalog --liveness --get-url=http://:8080/health/live --initial-delay-seconds=180 -n $PROJECT_NAME
oc set probe dc/store-catalog --readiness --get-url=http://:8080/health/ready --initial-delay-seconds=20 -n $PROJECT_NAME

# Expose the service
oc expose svc/store-catalog -n $PROJECT_NAME

# Resume the deployment config
oc rollout resume dc store-catalog -n $PROJECT_NAME