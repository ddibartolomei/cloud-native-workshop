#!/bin/sh

oc delete all -l app=catalog
oc delete configmap catalog
