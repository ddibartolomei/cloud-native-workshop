#!/bin/sh

if [[ $# -eq 0 ]]; then
    SCRIPT_NAME=`basename "$0"`
    echo "Usage:"
    echo "./$SCRIPT_NAME <project-name> <build-type>"
    echo "  <build-type> can be one of 'jvm' or 'native'"
    exit 0
fi

if [[ $# -ne 2 ]]; then
    echo "Illegal number of parameters"
    exit 1
fi

PROJECT_NAME=$1
BUILD_TYPE=$2

DOCKERFILE_TYPE=""
COMPILE_EXTRA_PARAMS=""

if [[ $BUILD_TYPE == "native" ]]; then
    DOCKERFILE_TYPE="native"
    COMPILE_EXTRA_PARAMS="-Pnative -Dquarkus.native.container-runtime=docker"
    echo "------------------------------\nExecuting native build\n------------------------------\n"
elif [[ $BUILD_TYPE == "jvm" ]]; then
    DOCKERFILE_TYPE="jvm"
    COMPILE_EXTRA_PARAMS=""
    echo "------------------------------\nExecuting jvm build\n------------------------------\n"
else
    echo "Invalid value for parameter <build-type>: $BUILD_TYPE"
    exit 2
fi

# compile package locally
./mvnw clean package -DskipTests $COMPILE_EXTRA_PARAMS

# Build an image on Openshift using the Docker strategy
oc new-build --name=store-catalog --binary -l app=store-catalog -n $PROJECT_NAME
oc patch bc/store-catalog -p "{\"spec\":{\"strategy\":{\"dockerStrategy\":{\"dockerfilePath\":\"src/main/docker/Dockerfile.$DOCKERFILE_TYPE\"}}}}" -n $PROJECT_NAME
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