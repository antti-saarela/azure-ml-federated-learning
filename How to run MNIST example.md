
## Prepare the Azure rg following the prerequisites here:
https://github.com/Azure-Samples/azure-ml-federated-learning/blob/main/docs/provisioning/silo_vnet_newstorage.md#prerequisites

Specifically **manually** create the private DNS Zone first.

Deploy the resources

Modify the BAT file below and then run it

```
create_silo.bat
```

```
az login -t 81b59a4e-f4e0-4903-be71-0ee63ff2b992

create_conda_env.bat

activate_conda_env.bat

run-mnist.bat
```



