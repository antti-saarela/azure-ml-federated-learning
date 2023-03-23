set basename=flx
set silonum=2
az deployment group create --template-file ./mlops/bicep/modules/fl_pairs/vnet_compute_storage_pair.bicep --resource-group rg-amlhs-dev --parameters pairBaseName="%basename%%silonum%" pairRegion="northeurope" machineLearningName="mlw-amlhs-dev" machineLearningRegion="northeurope" subnetPrefix="10.0.10%silonum%.0/24"
