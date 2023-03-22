# Running FL MNIST example on Hub and Spoke network

## Prepare the Azure resouuce group following the prerequisites here:
https://github.com/Azure-Samples/azure-ml-federated-learning/blob/main/docs/provisioning/silo_vnet_newstorage.md#prerequisites

Specifically **manually** create the private DNS Zone first.

### Deploy the resources

https://github.com/Azure-Samples/azure-ml-federated-learning/blob/main/docs/provisioning/silo_vnet_newstorage.md#using-az-cli

Modify the BAT file below and then run it

```
create_silo.bat
```

https://github.com/Azure-Samples/azure-ml-federated-learning/blob/main/docs/provisioning/orchestrator_vnet.md#using-az-cli

Modify the BAT file below and then run it

```
create_orchestrator.bat
```

## Prepare the FL MNIST sample dev env 

```
az login -t 81b59a4e-f4e0-4903-be71-0ee63ff2b992

create_conda_env.bat

activate_conda_env.bat
```

## Run the FL MNIST sample ML Pipeline 
```
run-mnist.bat
```


## Authentication to AMLS from jumpbox VM

By default in an Azure VM you'll see 

```
Submitting the pipeline job to your AzureML workspace...
[INFO azure.identity._credentials.environment] No environment configuration found.
[INFO azure.identity._credentials.managed_identity] ManagedIdentityCredential will use IMDS
[INFO azure.identity._credentials.chained] DefaultAzureCredential acquired a token from ManagedIdentityCredential
```

ManagedIdentityCredential needs to be disabled by authenticating without it:
```python
    credential = DefaultAzureCredential(exclude_managed_identity_credential=True)
```

Refer to 
https://learn.microsoft.com/en-us/python/api/azure-identity/azure.identity.defaultazurecredential?view=azure-python

```
exclude_environment_credential bool
Whether to exclude a service principal configured by environment variables from the credential. Defaults to False.

exclude_managed_identity_credential bool
Whether to exclude managed identity from the credential. Defaults to False.

exclude_powershell_credential bool
Whether to exclude Azure PowerShell. Defaults to False.

exclude_visual_studio_code_credential
bool
Whether to exclude stored credential from VS Code. Defaults to False.

exclude_shared_token_cache_credential bool
Whether to exclude the shared token cache. Defaults to False.
```


## Prepare k8s in Silo

```
sudo kubectl create namespace fl-mnist-tr

sudo kubectl config set-context $(sudo kubectl config current-context) --namespace=fl-mnist-tr
```

2. Attach the Arc cluster to the orchestrator workspace, or in other words _create an Azure ML attached compute pointing to the Arc cluster_:

```bash
az ml compute attach --resource-group <workspace-resource-group> --workspace-name <workspace-name> --type Kubernetes --name <azureml-compute-name> --resource-id "/subscriptions/<subscription-id>/resourceGroups/<connected-cluster-resource-group>/providers/Microsoft.Kubernetes/connectedClusters/<Azure-Arc-enabled-k8s-resource-name>" --identity-type UserAssigned --user-assigned-identities "subscriptions/<subscription-id>/resourceGroups/<workspace-resource-group>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-<azureml-compute-name>" --no-wait    
```
