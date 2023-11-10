
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Unauthorized Pod Execution Alert

Unauthorized Pod Execution is an incident type that occurs when an unauthorized entity attempts to create a pod in a system without proper permissions. This incident is considered a potential intrusion and triggers an alert to notify the appropriate personnel. The alert is designed to prevent unauthorized access and protect the system's integrity.

### Parameters

```shell
export AUTHORIZED_ENTITY="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export API_SERVER_POD_NAME="PLACEHOLDER"
export USER_OR_SERVICE_ACCOUNT="PLACEHOLDER"
export SERVICE_ACCOUNT="PLACEHOLDER"
export ROLE_NAME="PLACEHOLDER"
export ROLE_BINDING_NAME="PLACEHOLDER"
export NAMESPACE="PLACEHOLDER"
```

## Debug

### First, check if there are any unauthorized pods running in the cluster

```shell
kubectl get pods --all-namespaces | grep -v ${AUTHORIZED_ENTITY}
```

### Check the audit logs for any suspicious activity

```shell
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp | grep PodCreate | grep -v ${AUTHORIZED_ENTITY}
```

### Check the pod's metadata to see who created it

```shell
kubectl describe pod ${POD_NAME}
```

### Check the pod's security context to see if any privileged actions were performed

```shell
kubectl get pod ${POD_NAME} -o=jsonpath='{.spec.containers[*].securityContext.privileged}'
```

### Check the pod's service account to see if it has elevated privileges

```shell
kubectl get pod ${POD_NAME} -o=jsonpath='{.spec.serviceAccountName}'
```

### Check the Kubernetes API server logs for any suspicious activity

```shell
kubectl logs -n kube-system ${API_SERVER_POD_NAME} -c kube-apiserver | grep -v ${AUTHORIZED_ENTITY}
```

### Check the role bindings and cluster roles to see if the user or service account has the necessary permissions

```shell
kubectl get rolebindings,clusterrolebindings --all-namespaces | grep ${USER_OR_SERVICE_ACCOUNT}
```

### Check the pod's YAML file for any suspicious configurations

```shell
kubectl get pod ${POD_NAME} -o=yaml
```

## Repair

### Immediately remove the unauthorized pod from the system.

```shell
#!/bin/bash

# Set the pod name
POD_NAME=${POD_NAME}

# Delete the unauthorized pod
kubectl delete pod $POD_NAME

# Check if the pod has been deleted
POD_STATUS=$(kubectl get pod $POD_NAME | awk '{print $3}' | tail -n1)
if [ $POD_STATUS == "Terminating" ]; then
  echo "The pod is being terminated"
else
  echo "The pod has been deleted"
fi
```

### Implement a stronger access control policy to prevent unauthorized pod creation in the future.

```shell
#!/bin/bash

# Define variables
NAMESPACE=${NAMESPACE}
SERVICE_ACCOUNT=${SERVICE_ACCOUNT}
ROLE_NAME=${ROLE_NAME}
ROLE_BINDING_NAME=${ROLE_BINDING_NAME}

# Create a new Role with stricter access control
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $ROLE_NAME
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["create", "get", "list", "watch"]
EOF

# Create a new RoleBinding to associate the Role with the ServiceAccount
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $ROLE_BINDING_NAME
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $ROLE_NAME
subjects:
- kind: ServiceAccount
  name: $SERVICE_ACCOUNT
  namespace: $NAMESPACE
EOF

echo "Access control policy updated successfully."
```