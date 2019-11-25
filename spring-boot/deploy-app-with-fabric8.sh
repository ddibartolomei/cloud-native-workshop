#!/bin/sh

# Create the config map for application.properties config file
oc create configmap catalog --from-file=application.properties=openshift/application.properties

# Create the app using fabric8 maven plugin
mvn clean fabric8:deploy