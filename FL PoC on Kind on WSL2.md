# Prepare local env

## Install _arcade_

```
curl -sLS https://get.arkade.dev | sudo sh
ark -h
```

```
ark get kubectl kubectx helm kind
```

# Manual tool installation options

## Install docker on WSL2
Follow one of the instructions for example here:
 - https://nickjanetakis.com/blog/install-docker-in-wsl-2-without-docker-desktop
 - https://dev.solita.fi/2021/12/21/docker-on-wsl2-without-docker-desktop.html 
 - https://blog.avenuecode.com/running-docker-engine-on-wsl-2


Install Docker, you can ignore the warning from Docker about using WSL
```
sudo apt-get remove docker docker-engine docker.io containerd runc
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Add your user to the Docker group

```
sudo usermod -aG docker $USER
```

## Install kind on WSL2
 - https://mohitgoyal.co/2021/03/19/setup-local-kubernetes-cluster-with-docker-wsl2-and-kind/ 
 You can ignore the Docker Desktop installation part in the link above

## Install Azure CLI

## Install Azure CLI

Remove any pre-installed version
```
sudo apt remove azure-cli -y && sudo apt autoremove -y
```

Install latest version
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az version
```

## Install specific version of Helm

```
wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz

tar xvf helm-v3.6.3-linux-amd64.tar.gz

sudo mv linux-amd64/helm /usr/local/bin

rm helm-v3.6.3-linux-amd64.tar.gz

rm -rf linux-amd64

helm version
```


## Install the Arc and k8s extensions

```
az extension add --name connectedk8s
az extension add --name k8s-extension
az extension add --name ml

az extension update --name connectedk8s
az extension update --name k8s-extension
az extension update --name ml
```

```
export subscription_id=4fcaeb12-537a-4364-9e34-0e499d30c4c1
export AML_RG=asa-fml
export AML_WS_NAME=aml-fmldemo
export ArcRG=AzureArcTest
export ArcMLClusterName=arcml-kind-laptop
export AML_Compute=arc-kind-laptop
export UAI_AML_Compute=uai-$AML_Compute
```

# Create and start a Kind cluster 

1. Open VS Code
1. Open WSL terminal
1. If not created, create a kind cluster with 
    1. Run `kind create cluster -n arc-kind`
    1. Switch kube context with `kubectl config set current-context kind-arc-kind`
1. Run `sudo dockerd`
1. Open another WSL terminal
1. Run `kubectl cluster-info`
1. List Kind cluster with `kind get clusters`


## Verify kube config
Verify context with `kubectl config current-context`

## (OPTIONAL) Install Portainer
 - Included in one of the links above  https://blog.avenuecode.com/running-docker-engine-on-wsl-2
 - Login to http://localhost:9000
 


# Connect Kind cluster to Azure with Arc

Configure VSCode to use kube config file from inside the WSL2 env.

Move to WSL2 user home directory first.

`cd ~`

The command below will connect a k8s cluster to Azure in ConnectedClusters mode

```
az connectedk8s connect --name AzureArcKind --resource-group $ArcRG --kube-config ~/.kube/config  --kube-context kind-arc-kind
```

## List Arc-enabled connected k8s clusters

```
az connectedk8s list -o table
```

## Show details of a connected cluster
```
az connectedk8s show --name AzureArcKind --resource-group $ArcRG
```

## Delete an Arc-enabled connected k8s cluster

```
az connectedk8s delete --name AzureArcKind --resource-group $ArcRG --kube-config ~/.kube/config  --kube-context kind-arc-kind
```

# Install Azure Arc ML extension

```
az k8s-extension create --name arc-k8s-ml --extension-type Microsoft.AzureML.Kubernetes --config enableTraining=True --cluster-type connectedClusters --cluster-name AzureArcKind --resource-group $ArcRG --scope cluster
```

## Verify ML extension install

```
kubectl get pods -n azureml
```

## Deleting the Kind cluster

```
kind delete cluster --name arc-kind
```

<br>

---
<br>

# Install Kind cluster with local data folder

Use WSL2 on Windows or run on Ubuntu/Debian VM

## Create a Kind cluster with a mounted data folder

Get sample config files from 

https://github.com/Azure-Samples/azure-ml-federated-learning/tree/release-05/mlops

Modify them to your needs and place under the working directory

## Create a new Kind cluster with a local mount

```
export KINDCLUSTER=arclocal
export subscription_id=4fcaeb12-537a-4364-9e34-0e499d30c4c1
export AML_RG=asa-fml
export AML_WS_NAME=aml-fmldemo
export ArcRG=AzureArcTest
export ArcMLClusterName=arcml-$KINDCLUSTER
export AML_Compute=aml-cmp-$KINDCLUSTER
export UAI_AML_Compute=uai-$AML_Compute
```

Check contents of k8s config

```
more "./mlops/k8s_templates/k8s_config.yaml"
```

```
kind create cluster -n $KINDCLUSTER --config="./mlops/k8s_templates/k8s_config.yaml"
```

Connect the new Kind cluster to Azure with Arc

```
az login
```

```
az connectedk8s connect --name $ArcMLClusterName --resource-group $ArcRG --kube-config ~/.kube/config  --kube-context kind-$KINDCLUSTER
```

To troubleshoot the Arc ConnectCluster connection run

```
az connectedk8s troubleshoot --name $ArcMLClusterName --resource-group $ArcRG
```

To remove the Azure Arc connection run

```
az connectedk8s delete --name $ArcMLClusterName --resource-group $ArcRG --kube-config ~/.kube/config  --kube-context kind-$KINDCLUSTER
```

Install the Arc ML extension to the new Kind cluster

```
az k8s-extension create --name arc-k8s-ml --extension-type Microsoft.AzureML.Kubernetes --config enableTraining=True --cluster-type connectedClusters --cluster-name $ArcMLClusterName --resource-group $ArcRG --scope cluster
```

Verify Arc ML extension installation

```
az k8s-extension show --name arc-k8s-ml --cluster-type connectedClusters --cluster-name $ArcMLClusterName --resource-group $ArcRG
```

## Attach the Arc cluster to the orchestrator ML workspace

Create a user-assigned identity (UAI) that will later be assigned to the Azure ML attached compute:

```
az identity create --name $UAI_AML_Compute --resource-group $AML_RG
```

```
az ml compute attach --resource-group $AML_RG --workspace-name $AML_WS_NAME --type Kubernetes --name $AML_Compute --resource-id "/subscriptions/$subscription_id/resourceGroups/$ArcRG/providers/Microsoft.Kubernetes/connectedClusters/$ArcMLClusterName" --identity-type UserAssigned --user-assigned-identities "subscriptions/$subscription_id/resourceGroups/$AML_RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$UAI_AML_Compute" --no-wait    
```


## Deleting the Arc ML extension

```
az k8s-extension delete --name arc-k8s-ml --cluster-type connectedClusters --cluster-name $ArcMLClusterName --resource-group $ArcRG
```

## Deleting the cluster
```
kind delete cluster --name $KINDCLUSTER
```

# Create an external silo for FL

https://github.com/Azure-Samples/azure-ml-federated-learning/blob/main/docs/provisioning/external-silos.md



# Mount local data folder to KinD

## Provision and configure your local k8s cluster

### Create a Persistent Volume
Now we are going to create a Persistent Volume (PV) and the associated Claim (PVC), and deploy it.

To create the PV, first make sure that the path value of the hostPath entry in pv.yaml matches the containerPath value of the extraMounts in k8s_config.yaml. 

Then run: 

`kubectl apply -f ./mlops/k8s_templates/pv.yaml`

### Create a Persistent Volume Claim
To create the PVC, first make sure that the name in the metadata of pvc.yaml matches the name of the claimRef in pv.yaml. Also make sure that the metadata has the following labels and annotations, as these are the key parts that are required for the Azure ML job to be able to access the local data:
labels:
    app: demolocaldata
    ml.azure.com/pvc: "true"
annotations:
    ml.azure.com/mountpath: "/mnt/localdata" # The path from which the local data will be accessed during the Azure ML job. 

Then run: 

`kubectl apply -f ./mlops/k8s_templates/pvc.yaml`

### Deploy a Persistent Volume Claim

Finally, to deploy, first make sure that the claimName in deploy_pvc.yaml matches the PVC name in pvc.yaml, and that the mountPath matches the path in pv.yaml. 

Then run:

`kubectl apply -f ./mlops/k8s_templates/deploy_pvc.yaml`

🏁 Checkpoint:
Before moving forward, we recommend you check that the local data can indeed by accessed from the k8s cluster. To do so, start by getting the name of the pod that was created by the deployment by running kubectl get pods. Then, open a bash session on the k8s by running kubectl exec -it <your-pod-name> bash. Finally, run ls <path-in-docker> to check that the data in that folder are indeed visible (if you didn't change the default values in the yaml files mentioned above, then your <path-on-docker> should be /localdata - it is simply the path in pv.yaml).


## Create a dedicated namespace for FL jobs

`kubectl create ns aml-fl-ns`

<br>

---

<br>

# Run sample ML Pipeline in Azure

# Attach k8s compute to Azure ML workspace

1. Open AML portal
1. Go to Compute / Kubernetes clusters
1. Click New / Kubernetes
1. Select your Arc-enabled k8s from the drop down list
1. Give it some descriptive name


# Run a sample ML pipeline on local k8s
1. Open AML portal
1. Select on of the Designer sample ML Pipelines
    1. For example _Automobile Price prediction_ sample
1. Go to settings on the right pane
1. Select _Compute type_ as _Kubernetes compute_
1. Select your k8s compute
1. Click _Save_ in the ribbon above
1. Click _Submit_
1. Select an existing ML experiment or create a new one
1. Click _Submit_ in the bottom of the dialogue

 
# Install python env on Ubuntu

```
sudo apt install python3-pip

pip3 install --upgrade setuptools

sudo apt-get install -y python3-venv

python3 -m venv ~/fedml_venv

source ~/fedml_venv/bin/activate
```

## Install requirements

```
pip install -r examples/pipelines/requirements.txt 
```


```
cd ~
sudo chmod -R ugo+r ./mnt/localdata/
```
---
**Once the local k8s setup is done you can continue from here**
 
 | | | | | | | | |

 \\/\\/\\/\\/\\/\\/

<br>

---

<br>

# Run samples in WSL2 Ubuntu

```
cd ~
source ~/fedml_venv/bin/activate
```

Then run

```
python "/mnt/c/Users/saareant/OneDrive - TietoEVRY/Care/git/GitHub/azure-ml-federated-learning/examples/pipelines/fl_cross_silo_literal/submit.py" --submit
```

or to test using local data

```
python "/mnt/c/Users/saareant/OneDrive - TietoEVRY/Care/git/GitHub/azure-ml-federated-learning/examples/pipelines/read_local_data_in_k8s/submit.py" --submit
```

or with more complex "factory" setup

```
python "/mnt/c/Users/saareant/OneDrive - TietoEVRY/Care/git/GitHub/azure-ml-federated-learning/examples/pipelines/fl_cross_silo_factory/submit.py" --submit
```

or to run without validation

```
python "/mnt/c/Users/saareant/OneDrive - TietoEVRY/Care/git/GitHub/azure-ml-federated-learning/examples/pipelines/fl_cross_silo_factory/submit.py" --submit --ignore_validation
```

<br>

---


## (OPTIONAL) Share files using python httpServer

```
python3 -m  http.server 8888
```

```
sudo iptables -I INPUT -p tcp --dport 8888 -j ACCEPT
```

<br>

---

## (OPTIONAL) Share local files over http using Samba server

`sudo apt-get install samba -y`

`sudo nano /etc/samba/smb.conf`

Make necessary changes to Samba conf.

```
[public]
  comment = public anonymous access
  path = /home/saareant/
  browsable =no
  create mask = 0660
  directory mask = 0771
  writable = no
  guest ok = yes
```

Then restart Samba service

`sudo systemctl restart smbd`

