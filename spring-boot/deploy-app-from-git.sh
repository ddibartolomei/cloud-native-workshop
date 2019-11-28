#!/bin/sh

if [[ $# -eq 0 ]]; then
    SCRIPT_NAME=`basename "$0"`
    echo "Usage:"
    echo "./$SCRIPT_NAME <git-repository-url> <context-dir>"
    exit 0
fi

if [[ $# -ne 2 ]]; then
    echo "Illegal number of parameters"
    exit 1
fi

GIT_REPOSITORY=$1
CONTEXT_DIR=$2

# Create the config map for application.properties config file
oc create configmap catalog --from-file=application.properties=openshift/application.properties

# Create the app from git repository
oc new-app registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift~$GIT_REPOSITORY --context-dir=$CONTEXT_DIR --name=catalog

# Temporarily scale down pods to zero in order to create/update some resources
oc scale dc/catalog --replicas=0

# Set environment variables for database credentials from the secret
oc set env --from=secret/spring-boot-db-credentials  --prefix=SPRING_ dc/catalog

# Add probes
oc set probe dc/catalog --liveness --get-url=http://:8080/actuator/health --initial-delay-seconds=180
oc set probe dc/catalog --readiness --get-url=http://:8080/actuator/health --initial-delay-seconds=20

# Expose the service
oc expose svc/catalog

# Scale up again
oc scale dc/catalog --replicas=1
