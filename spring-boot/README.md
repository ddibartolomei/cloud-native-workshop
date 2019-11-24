# Spring Boot

## Run the application

To run the application locally use:

```
mvn clean compile spring-boot:run
```

## Run on Openshift using Fabric8 maven plugin

### Create a secret for database credentials
```
oc delete secret spring-boot-db-credentials
oc create -f openshift/spring-boot-db-credentials-secret.yml
```

### Deploy using Fabric8
```
mvn clean fabric8:deploy
```

### Test the service
```
export URL="http://$(oc get route | grep catalog | awk '{print $2}')"
curl $URL/api/catalog
```

## Running on Openshift from remote git repository

### Create a secret for database credentials
```
oc delete secret spring-boot-db-credentials
oc create -f openshift/spring-boot-db-credentials-secret.yml
```

### Create the app on OpenShift specifying the base image and the git repository
```
oc new-app registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift~https://github.com/ddibartolomei/cloud-native-workshop.git --context-dir=spring-boot --name=catalog
```

### Check out build process logs
```
oc logs -f bc/catalog
```

### Create the route
```
oc expose svc/catalog
```
