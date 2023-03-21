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



