# Creating Azure ML with VNET 

**Prompt:**

_write me a terraform script for creating an azure machine learning workspace with network isolation and private endpoint in North Europe location. Also provide instructions on how to run it to deploy the resources into Azure._

**Answer:**

Here is a Terraform script for creating an Azure Machine Learning Workspace with network isolation and a private endpoint in the North Europe location:

```java

provider "azurerm" {
  version = "2.0"
}

resource "azurerm_resource_group" "ml_workspace_rg" {
  name     = "ml-workspace-rg"
  location = "northeurope"
}

resource "azurerm_virtual_network" "ml_workspace_vnet" {
  name                = "ml-workspace-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ml_workspace_rg.location
  resource_group_name = azurerm_resource_group.ml_workspace_rg.name
}

resource "azurerm_subnet" "ml_workspace_subnet" {
  name                 = "ml-workspace-subnet"
  resource_group_name  = azurerm_resource_group.ml_workspace_rg.name
  virtual_network_name = azurerm_virtual_network.ml_workspace_vnet.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_private_endpoint" "ml_workspace_private_endpoint" {
  name                = "ml-workspace-private-endpoint"
  location            = azurerm_resource_group.ml_workspace_rg.location
  resource_group_name = azurerm_resource_group.ml_workspace_rg.name
  subnet_id           = azurerm_subnet.ml_workspace_subnet.id

  private_service_connection {
    name                 = "ml-workspace-private-service-connection"
    private_connection_resource_id = "${azurerm_machine_learning_workspace.ml_workspace.id}"
    subresource_names    = ["Microsoft.MachineLearningServices/workspaces"]
  }
}

resource "azurerm_machine_learning_workspace" "ml_workspace" {
  name                = "ml-workspace"
  location            = azurerm_resource_group.ml_workspace_rg.location
  resource_group_name = azurerm_resource_group.ml_workspace_rg.name
  subnet_id           = azurerm_subnet.ml_workspace_subnet.id
}

```

To deploy these resources into Azure, follow these steps:

Install Terraform: https://www.terraform.io/downloads.html

Clone this script to a local directory.

Run terraform init to download the required plugins.

Run terraform plan to preview the changes that will be made to your Azure environment.

Run terraform apply to deploy the resources into Azure.

Once the resources are deployed, run terraform show to view the details of the resources that were created.

Note: You will need to have an active Azure subscription and have the necessary permissions to create resources in your Azure environment.

