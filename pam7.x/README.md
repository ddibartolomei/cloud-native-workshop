# Process Automation Manager 7.x

## Provisioning PAM 7.5 *demo* environment on Openshift

```
git clone https://github.com/jbossdemocentral/rhpam7-install-demo

./support/openshift/provision.sh setup <project-name-prefix> --with-imagestreams --project-suffix <project-name-suffix>
```

- ```<project-name-prefix>```: a prefix string for the Openshift project name (e.g *rhpam7-install*)
- ```<project-name-suffix>```: a suffix string, in order to have a unique project name (e.g. *01* or *demo*)

The resulting project name on Openshift will be: ```<project-name-prefix>-<project-name-suffix>```

> Do not use long prefix and/or suffix otherwise route hostname length could exceed the limit

This provisioning model is based on the template named ***rhpam75-authoring*** which creates one pod for the *kie-server* and one for the *business-central* application.

## Importing PAM demo project

Connect to the Business Central using the hostname obtained with the following command:
```
oc get route <your-project-name-prefix>-rhpamcentr -o template --template='{{.spec.host}}' -n <your-project-name-prefix>-<your-project-name-suffix>
```

Login with admin username and password.

> If not changed during PAM provisioning, they should be *pamAdmin / redhatpam1!*

Import the project from a git repository:
- Click on **Projects** link
- Click on **MySpace** space
- Click on the *option* icon (3 dots in vertical line) in the top/right part of the page and choose **Import Project**
  - Set as *Repository URL* your git repository clone url (e.g. https://github.com/ddibartolomei/cloud-native-workshop.git)
  - Set *Authentication Options* if the git repository requires authentication
  - Click **Import**
  - In the next page select the found PAM project (*test01*) and click **Import**
- The imported project with all the assets will be available in the *MySpace* space

> NB: The business process inside the project (*Approval-Process*) has two service tasks to make REST invocations on the enpoints of the Spring Boot and Quarkus services. The hostname in the *URL* parameter of both the service tasks **must be changed** in order to point to the right routes of the REST services.

## Project assets

- **Approval-Process**: the Business Processes (bpmn file)
- **Approve-taskform**: Form for Approve task
- **com_myspace_test01_Product**: Sub Form for showing Product object attributes
- **Product**: Data Object (a POJO file)
- **Rest**: Work Item Definition for REST WorkItemHandler Task
- **test01.process01-taskform**: Form for data input on process start
- **WorkDefinitions**: descriptor for all supported WorkItem Definitions 

## Cloning the project from the Business Central internal git repository

Inside the project (in the Project Designer of Business Central), click **Settings**.
Copy the url contained in the field *URL* of the *General Settings* section.

Then use (use admin user and password when required):
```
git clone -c http.sslVerify=false <copied-internal-git-url>
```

