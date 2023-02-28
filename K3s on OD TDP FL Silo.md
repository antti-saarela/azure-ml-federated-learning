
# K3s on OD TDP FL Silo

https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cluster-connect?tabs=azure-cli#service-account-token-authentication-option

```

kubectl create serviceaccount demo-user

kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --serviceaccount default:demo-user

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: demo-user-secret
  annotations:
    kubernetes.io/service-account.name: demo-user
type: kubernetes.io/service-account-token
EOF

TOKEN=$(kubectl get secret demo-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g')

echo $TOKEN

```


Token:

```

eyJhbGciOiJSUzI1NiIsImtpZCI6Inh4Q242b0ljdmNRRWRmd3lpUFBIR3huU05WVWJsUThBMWlfREhKdGQ5c1EifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlbW8tdXNlci1zZWNyZXQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVtby11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNDUzMjlkM2EtMjcwNy00ODY1LThlY2QtZDM2ZGViNDk4MTdiIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6ZGVtby11c2VyIn0.haZfmtWUrNRkBxuV8fIshZJ-7lAsQEAzaopuAiyILptCFxkNLqYQUaj5sv3l6kgWpCeVKyT38MoWtz2bPblwtMJFpK8TRVu2cyjKC8WUpCzJgJyakzOTccDpqnjbWspWeiARsgdGHegmE_ydp3OzuvyrOOdAjaYRcLiQCSn1a-_vdSnFKCBi__Gc4SuUgyjClVqM0BU-y4Cl0J54o-SeuCalqOF7-parC3eqnWQ7Mt1_sUuqujrix6VZ_x816Jv3pOzdLnXZfK7eGKWbtcjm76Zm_WBjqmW896mQNOQMITLfCbeJ31_NVQ9dqjdi04tt9r1gRkuPVWhcPGsFiZUcrw

```

