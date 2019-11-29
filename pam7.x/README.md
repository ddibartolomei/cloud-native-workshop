# Process Automation Manager 7.x

## Provisioning a PAM 7.5 environment on Openshift

```
git clone https://github.com/jbossdemocentral/rhpam7-install-demo

./support/openshift/provision.sh setup <project-name-prefix> --with-imagestreams --project-suffix <project-name-suffix>
```

- ```<project-name-prefix>```: a prefix string for the Openshift project name (e.g rhpam7-install)
- ```<project-name-suffix>```: a suffix string, in order to have a unique project name (e.g. 01)

The resulting project name will be: ```<project-name-prefix>-<project-name-suffix>```

> Do not use long prefix and/or suffix otherwise route hostname length will exceed the limit

This provisioning model is based on the template named *template.template.openshift.io/rhpam75-authoring* which creates one pod for the *kie-server* and one for the *business-central* application.

## Creating a demo process definition

Connect to the Business Central using the https route obtained with the following command:

```
rhpam7-install-rhpamcentr-rhpam7-install-01.apps.rhpds3x.openshift.opentlc.com
```

### Create a new project
- Click on **Projects** link
- Click on **MySpace** space
- Click on **Add Project** and set ***test01*** as name
- Inside the new project, click on **Add Asset** and then on **Business Process** to create a new *bpmn* file with the process definition: call it ***process01***
- Open the new process


git clone -c http.sslVerify=false https://rhpam7-install-rhpamcentr-rhpam7-install-01.apps.rhpds3x.openshift.opentlc.com:443/git/MySpace/test01