# Spring Boot

## Run the application locally

```
mvn clean compile spring-boot:run
```

## Prerequisites for Openshift deployment

### 

### Add *view* role to the default service account of the project

The Spring Boot microservice calls the Kubernetes API to retrieve a ConfigMap, which requires *view* access.
```
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default -n $(oc project -q)
```

### Create PostgreSQL instance on Openshift
```
oc new-app --template=postgresql-ephemeral --param POSTGRESQL_USER=puser --param POSTGRESQL_PASSWORD=ppassword --param POSTGRESQL_DATABASE=pdb --param POSTGRESQL_VERSION=9.6 --name=sb-postgresql
```

### Create a secret for database credentials
```
oc create -f openshift/spring-boot-db-credentials-secret.yml
```

### Create the config map
```
oc create configmap catalog --from-file=application.properties=openshift/application.properties
```

## Run on Openshift using Fabric8 maven plugin

### Build and deploy using Fabric8
```
mvn clean fabric8:deploy
```

## Run on Openshift from remote git repository

### Create the app on OpenShift specifying the base image and the git repository
```
oc new-app registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift~<GIT_REPOSITORY> --context-dir=spring-boot --name=catalog
```

### Patch the deployment config to add extra configuration

```
oc scale dc/catalog --replicas=0

oc set env --from=secret/spring-boot-db-credentials  --prefix=SPRING_ dc/catalog

oc set probe dc/catalog --liveness --get-url=http://:8080/actuator/health --initial-delay-seconds=10

oc set probe dc/catalog --readiness --get-url=http://:8080/actuator/health --initial-delay-seconds=10

oc scale dc/catalog --replicas=1
```

### Create the route
```
oc expose svc/catalog
```

## Check out build process logs
```
oc logs -f bc/catalog
```

## Test the service
```
curl -X GET http://$(oc get route catalog -o template --template='{{.spec.host}}')/api/catalog
```

## Delete all the resources of *catalog* app (excluding config map and secret)
```
oc delete all -l app=catalog
```

