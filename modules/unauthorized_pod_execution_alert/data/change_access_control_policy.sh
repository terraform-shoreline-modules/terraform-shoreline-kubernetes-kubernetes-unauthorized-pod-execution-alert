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