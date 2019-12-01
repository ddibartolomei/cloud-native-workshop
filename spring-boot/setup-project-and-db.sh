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

# Delete and create the project on Openshift
oc get projects | grep $PROJECT_NAME > /dev/null
if [[ $? -eq 0 ]]; then
    echo "Project already exists: deleting it..."
    oc delete project $PROJECT_NAME
    echo "Waiting for project to be completely deleted..."
    sleep 20
fi
oc new-project $PROJECT_NAME

# Add view role to the default service account of the project
oc policy add-role-to-user view system:serviceaccount:$PROJECT_NAME:default -n $PROJECT_NAME

# Create an ephemeral PostgreSQL instance on Openshift
oc new-app --template=postgresql-ephemeral --param POSTGRESQL_USER=puser --param POSTGRESQL_PASSWORD=ppassword --param POSTGRESQL_DATABASE=pdb --param POSTGRESQL_VERSION=9.6 --name=sb-postgresql -n $PROJECT_NAME

# Create a secret for database credentials
oc create -f openshift/spring-boot-db-credentials-secret.yml
