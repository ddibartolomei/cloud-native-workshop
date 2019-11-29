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

# Set current working project
oc project $PROJECT_NAME

# Create the config map for application.properties config file
oc create configmap catalog --from-file=application.properties=openshift/application.properties -n $PROJECT_NAME

# Create the app using fabric8 maven plugin
mvn clean fabric8:deploy