# Quarkus

## Run the application locally

```
./mvnw clean compile quarkus:dev
```

## Prerequisites for Openshift deployment

### Add *view* role to the default service account of the project

```
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default -n $(oc project -q)
```

### Create PostgreSQL instance on Openshift
```
oc new-app --template=postgresql-ephemeral --param POSTGRESQL_USER=puser --param POSTGRESQL_PASSWORD=ppassword --param POSTGRESQL_DATABASE=pdb --param POSTGRESQL_VERSION=9.6 --name=q-postgresql
```

### Create a secret for database credentials
```
oc create -f openshift/quarkus-db-credentials-secret.yml
```

## Run on Openshift

### Compile the app locally
```
./mvnw clean package -DskipTests
```

### Build an image on Openshift using the Docker strategy
```
oc new-build --name=store-catalog --binary -l app=store-catalog -n $PROJECT_NAME

oc patch bc/store-catalog -p "{\"spec\":{\"strategy\":{\"dockerStrategy\":{\"dockerfilePath\":\"src/main/docker/Dockerfile.jvm\"}}}}" -n $PROJECT_NAME

oc start-build store-catalog --from-dir=. --follow -n $PROJECT_NAME
```

### Create an app deployment using the built image
```
oc new-app --image-stream=store-catalog:latest -l app=store-catalog -n $PROJECT_NAME
```

### Patch the deployment config to add extra configuration

```
oc rollout pause dc store-catalog

oc set env --from=secret/quarkus-db-credentials  --prefix=QUARKUS_ dc/store-catalog

oc set probe dc/store-catalog --liveness --get-url=http://:8080/health/live --initial-delay-seconds=180

oc set probe dc/store-catalog --readiness --get-url=http://:8080/health/ready --initial-delay-seconds=20

oc rollout resume dc store-catalog
```

### Create the route
```
oc expose svc/store-catalog
```

## Test the service
```
# Get all products
curl -X GET http://$(oc get route store-catalog -o template --template='{{.spec.host}}')/api/store/catalog

# Add/Update product
curl -k -X POST -H 'Content-Type: application/json' --header 'Accept: application/json' -d '{"itemId": "111111","name": "My product name","description": "My product description", "price": 10.99}' http://$(oc get route store-catalog -o template --template='{{.spec.host}}')/api/store/catalog
```

The Swagger UI is available at the */swagger-ui* relative url.

## Delete all the app resources of *store-catalog* app (excluding the database credentials secret)
```
oc delete all -l app=store-catalog 
```

## Create a Quarkus app from scratch (just the base skeleton):

Example:
```
mvn io.quarkus:quarkus-maven-plugin:1.0.0.CR1:create -DprojectGroupId=com.redhat.cloudnative.store.catalog -DprojectArtifactId=store-catalog -DclassName="com.redhat.cloudnative.store.catalog.service.StoreCatalogService" -Dpath="/store-catalog"
```