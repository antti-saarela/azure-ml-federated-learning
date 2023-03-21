az deployment group create --template-file ^
 ./mlops/bicep/modules/fl_pairs/vnet_compute_storage_pair.bicep ^
 --resource-group rg-amlhs-dev ^
  --parameters pairBaseName="orchestrator" pairRegion="northeurope" ^
  machineLearningName="mlw-amlhs-dev" machineLearningRegion="northeurope" ^
  subnetPrefix="10.0.100.0/24" ^
  storagePublicNetworkAccess=Enabled

