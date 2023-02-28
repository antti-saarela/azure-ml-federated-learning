Connect to remote Ubuntu VM

https://dev.azure.com/tietodata/hus-findata/_wiki/wikis/hus-findata.wiki/497/Installing-Arc-enabled-Kind-on-Ubuntu


Add your Azure user account an IAM role `Virtual Machine Administrator Login`

Then login to the VM using Azure AD authentication

For example:

arc-ubuntu-vm:
`az ssh vm --ip 137.135.221.8`

arc-vm-ubuntu:
`az ssh vm --ip 74.234.66.194`

Or connect using Azure portal -> Ubuntu VM -> Bastion
Enter username and password and connect

# Prepare local env

# Install Azure CLI

```
sudo apt remove azure-cli -y && sudo apt autoremove -y
```

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

# Install _arcade_
```
curl -sLS https://get.arkade.dev | sudo sh
ark -h
```

# Install k8s tooling

Get k8s tools
```
ark get kubectl kubectx helm kind
```

Install
```
sudo mv /home/antti.saarela/.arkade/bin/kubectl /usr/local/bin/
sudo mv /home/antti.saarela/.arkade/bin/helm /usr/local/bin/
sudo mv /home/antti.saarela/.arkade/bin/kind /usr/local/bin/
sudo mv /home/antti.saarela/.arkade/bin/kubectx /usr/local/bin/
```

# Install docker
```
sudo apt-get remove docker docker-engine docker.io containerd runc
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Add your user to the Docker group

```
sudo usermod -aG docker $USER
```

`Log out and log back in for changes to take effect`

# Add privileges to run dockerd to your user

Run `sudo visudo`

Add this line:

`<your user> ALL=(ALL) NOPASSWD: /usr/bin/dockerd`

### Start docker daemon

```
sudo systemctl start docker.service
```

Enable automatic start of docker on reboot
```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

### Test docker

```
systemctl status docker
```

```
docker ps
```

#### If out of storage check usage

```
df -h
```

```
sudo du -d1 -h /var/lib/docker | sort -hr
```

Clear docker files

```
sudo rm -rf /var/lib/docker
```

Start docker daemon
```
sudo systemctl start docker
```

Check status of docker
```
sudo systemctl status docker
```

# Create and start a KinD cluster 

## Set environment variables

### KinD Ubuntu instance to isfss-caretech-datadev
```

export subscription_id=4fcaeb12-537a-4364-9e34-0e499d30c4c1
export AML_RG=asa-fml
export AML_WS_NAME=aml-fmldemo
export ArcRG=AzureArcTest
export CLUSTER_NAME=arckind
export K8S_CLUSTER_NAME=kind-$CLUSTER_NAME
export ArcMLClusterName=cc-kind-$CLUSTER_NAME
export AML_Compute=arc-k8s-$CLUSTER_NAME
export UAI_AML_Compute=uai-$AML_Compute

```

### For HUS Tietoallastesti use:

```

export subscription_id=63f1b6c1-4995-43a2-8a16-26940300677f
export AML_RG=husfd-te-federated-learning
export AML_WS_NAME=aml-fld4
export ArcRG=husfd-te-federated-learning
export CLUSTER_NAME=arc-te
export K8S_CLUSTER_NAME=kind-$CLUSTER_NAME
export ArcMLClusterName=cc-kind-$CLUSTER_NAME
export AML_Compute=k8s-$CLUSTER_NAME
export UAI_AML_Compute=uai-$AML_Compute

```

For TE OD sub ArcBox use:

### CAPI instance
```

export subscription_id=c681687c-a73f-4eb6-ba76-6660ef58bf50
export AML_RG=od-tdp-fl-silo-poc-ArcBox-RG
export AML_WS_NAME=od-tdp-fl-aml-ws
export ArcRG=od-tdp-fl-silo-poc-ArcBox-RG
export CLUSTER_NAME=arcbxca
export K8S_CLUSTER_NAME=$CLUSTER_NAME
export ArcMLClusterName=cc-ca-$CLUSTER_NAME
export AML_Compute=k8s-$CLUSTER_NAME
export UAI_AML_Compute=uai-$AML_Compute

```

### CAPI instance to isfss-caretech-datadev
```

export subscription_id=4fcaeb12-537a-4364-9e34-0e499d30c4c1
export AML_RG=asa-fml
export AML_WS_NAME=aml-fmldemo
export ArcRG=AzureArcTest

export CLUSTER_NAME=arcbxca
export K8S_CLUSTER_NAME=$CLUSTER_NAME
export ArcMLClusterName=cc-ca-$CLUSTER_NAME
export AML_Compute=k8s-$CLUSTER_NAME
export UAI_AML_Compute=uai-$AML_Compute

```


### K3s instance
```

export subscription_id=c681687c-a73f-4eb6-ba76-6660ef58bf50
export AML_RG=od-tdp-fl-silo-poc-ArcBox-RG
export AML_WS_NAME=od-tdp-fl-aml-ws
export ArcRG=od-tdp-fl-silo-poc-ArcBox-RG

export CLUSTER_NAME=arcbox-k3s
export K8S_CLUSTER_NAME=$CLUSTER_NAME
export ArcMLClusterName=cc-$CLUSTER_NAME
export AML_Compute=k8s-$CLUSTER_NAME
export UAI_AML_Compute=uai-$AML_Compute

```

### K3s instance to isfss-caretech-datadev

```
export subscription_id=4fcaeb12-537a-4364-9e34-0e499d30c4c1
export AML_RG=asa-fml
export AML_WS_NAME=aml-fmldemo
export ArcRG=AzureArcTest

export CLUSTER_NAME=arcbox-k3s
export K8S_CLUSTER_NAME=$CLUSTER_NAME
export ArcMLClusterName=cc-$CLUSTER_NAME
export AML_Compute=k8s-$CLUSTER_NAME
export UAI_AML_Compute=uai-$AML_Compute

az account set -n $subscription_id
```

---

1. If not created, create a kind cluster 
    1. Run `kind create cluster -n $CLUSTER_NAME`
1. Run `kubectl cluster-info`
1. List Kind cluster with `kind get clusters`

If needed switch kube context back to this cluster with `kubectl config set current-context $K8S_CLUSTER_NAME`

To delete the Kind cluster run `kind delete cluster -n $CLUSTER_NAME`



## Install specific version of Helm

```
wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz

tar xvf helm-v3.6.3-linux-amd64.tar.gz

sudo mv linux-amd64/helm /usr/local/bin

rm helm-v3.6.3-linux-amd64.tar.gz

rm -rf linux-amd64

helm version
```

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

## Install the Arc and k8s extensions

```
az extension add --name connectedk8s
az extension add --name k8s-extension
az extension add --name ml

az extension update --name connectedk8s
az extension update --name k8s-extension
az extension update --name ml
```

### Login to a speficic Azure tenant using your Azure account

HUS Tietoallastesti
```
az login -u ext-antti.saarela@hustietoallastesti.fi -t 7de4405f-a24c-490d-af4a-f2ec4a6835c9
```

Industry Software Development 
```
az login -u antti.saarela@tietoevry.com -t 81b59a4e-f4e0-4903-be71-0ee63ff2b992
```

Tietoevry Care - Cloud Data Analytics OD
```
az login -u antti.saarela@tietoevry.com -t e0f2cbcb-d762-4271-911d-c230db46c8ac
```

Set default subscription
```
az account set -n $subscription_id

# get the current default subscription using list
az account list --query "[?isDefault]" -o table
```

# Connect KinD cluster to Azure with Arc

Verify kubeconfig
```
more "$HOME/.kube/config"
```

## List Arc-enabled connected k8s clusters

```
az connectedk8s list -o table
```

## Connect the k8s cluster to Azure using Arc

The command below will connect a k8s cluster to Azure in ConnectedClusters mode

```
az connectedk8s connect --name $ArcMLClusterName --resource-group $ArcRG --kube-config $HOME/.kube/config --kube-context $K8S_CLUSTER_NAME
```

or just

```
az connectedk8s connect --name $ArcMLClusterName --resource-group $ArcRG
```

### Show details of a connected cluster
```
az connectedk8s show --name cc-kind-$CLUSTER_NAME --resource-group $ArcRG
```

### Troubleshoot the Arc ConnectCluster connection
To troubleshoot the Arc ConnectCluster connection run

```
az connectedk8s troubleshoot --name $ArcMLClusterName --resource-group $ArcRG
```

and

```
kubectl get pods -n azure-arc
```

### Delete an Arc-enabled connected k8s cluster connection to Azure

```
az connectedk8s delete --name $ArcMLClusterName --resource-group $ArcRG --kube-config $HOME/.kube/config  --kube-context $K8S_CLUSTER_NAME
```

```
az connectedk8s delete --name od-tdp-fl-silo-poc-ArcBox-K3s-0Fud --resource-group od-tdp-fl-silo-poc-ArcBox-RG
```


Wait...

# Install Azure Arc ML extension

## Create Arc ML extension to cluster

```
az k8s-extension create --name arc-k8s-ml --extension-type Microsoft.AzureML.Kubernetes --config enableTraining=True --cluster-type connectedClusters --cluster-name $ArcMLClusterName --resource-group $ArcRG --scope cluster
```


## Verify ML extension install

Verify Arc ML extension installation


Check the details of installed Azure Arc ML extension

```
az k8s-extension show --name arc-k8s-ml --cluster-type connectedClusters --cluster-name $ArcMLClusterName --resource-group $ArcRG
```

Check also the pods

```
kubectl get pods -n azureml
```

It should return something like:

```
NAME                                              READY   STATUS      RESTARTS      AGE
healthcheck                                       0/1     Completed   0             52m
metrics-controller-manager-54dcd8c5b-lxc2h        2/2     Running     1 (49m ago)   51m
prometheus-prom-prometheus-0                      2/2     Running     0             50m
relayserver-6dc46db4cf-5mf76                      2/2     Running     0             51m
relayserver-6dc46db4cf-wl7vg                      2/2     Running     0             50m
volcano-admission-79ccc96f98-99hrj                1/1     Running     0             51m
volcano-controllers-695dd87b59-j59m4              1/1     Running     0             50m
volcano-scheduler-65dcb7666-t7j96                 1/1     Running     0             51m
```



## Create a dedicated namespace for FL jobs

`kubectl create ns aml-fl-ns`


## Attach the Arc cluster to the FL orchestrator AML workspace

Create a user-assigned identity (UAI) that will later be assigned to the Azure ML attached compute:

```
az identity create --name $UAI_AML_Compute --resource-group $AML_RG
```

### Attach the Arc-enabled k8s cluster as k8s compute

```
az ml compute attach --resource-group $AML_RG --workspace-name $AML_WS_NAME --type Kubernetes --name $AML_Compute --resource-id "/subscriptions/$subscription_id/resourceGroups/$ArcRG/providers/Microsoft.Kubernetes/connectedClusters/$ArcMLClusterName" --identity-type UserAssigned --user-assigned-identities "subscriptions/$subscription_id/resourceGroups/$AML_RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$UAI_AML_Compute" --no-wait

```

# Running AML Pipelines from remote client

##  Install python env on Ubuntu

```
sudo apt install python3-pip

pip3 install --upgrade setuptools

sudo apt-get install -y python3-venv

python3 -m venv ~/fedml_venv

source ~/fedml_venv/bin/activate
```

## Clone federated learning repo

```
mkdir fl-repo
cd fl-repo
git clone https://github.com/Azure-Samples/azure-ml-federated-learning.git
```

# git config --global user.email "antti.saarela@tietoevry.com"
# git config --global user.name "saarela"

*TBD*

## Install requirements

```
cd azure-ml-federated-learning
pip install -r examples/pipelines/requirements.txt 
```

**TODO: Left here on 6.2.2023**

# Run Federated Learning samples on Ubuntu

```
cd azure-ml-federated-learning
source ~/fedml_venv/bin/activate
```

Then run

```
python "azure-ml-federated-learning/examples/pipelines/fl_cross_silo_literal/submit.py" --submit
```

or

```
python "azure-ml-federated-learning/examples/pipelines/pneumonia/submit.py" --submit
```

or

```
python "azure-ml-federated-learning/examples/pipelines/fl_cross_silo_factory/submit.py" --submit
```

or to run without validation

```
python "azure-ml-federated-learning/examples/pipelines/fl_cross_silo_factory/submit.py" --submit --ignore_validation
```




# Mount local data folder to KinD

## Provision and configure your local k8s cluster

### Create a Persistent Volume
Now we are going to create a Persistent Volume (PV) and the associated Claim (PVC), and deploy it.

To create the PV, first make sure that the path value of the hostPath entry in pv.yaml matches the containerPath value of the extraMounts in k8s_config.yaml. 

Then run: 

`kubectl apply -f ./mlops/k8s_templates/pv.yaml`

### Create a Persistent Volume Claim
To create the PVC, first make sure that the name in the metadata of pvc.yaml matches the name of the claimRef in pv.yaml. Also make sure that the metadata has the following labels and annotations, as these are the key parts that are required for the Azure ML job to be able to access the local data:

```
labels:
    app: demolocaldata
    ml.azure.com/pvc: "true"
annotations:
    ml.azure.com/mountpath: "/mnt/localdata" # The path from which the local data will be accessed during the Azure ML job. 
```

Then run: 

`kubectl apply -f ./mlops/k8s_templates/pvc.yaml`

### Deploy a Persistent Volume Claim

Finally, to deploy, first make sure that the claimName in deploy_pvc.yaml matches the PVC name in pvc.yaml, and that the mountPath matches the path in pv.yaml. 

Then run:

`kubectl apply -f ./mlops/k8s_templates/deploy_pvc.yaml`

🏁 Checkpoint:
Before moving forward, we recommend you check that the local data can indeed by accessed from the k8s cluster. To do so, start by getting the name of the pod that was created by the deployment by running kubectl get pods. Then, open a bash session on the k8s by running kubectl exec -it <your-pod-name> bash. Finally, run ls <path-in-docker> to check that the data in that folder are indeed visible (if you didn't change the default values in the yaml files mentioned above, then your <path-on-docker> should be /localdata - it is simply the path in pv.yaml).



## Deleting the Kind cluster

```
kind delete cluster -n $CLUSTER_NAME
```

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

<br>

---
<br>




# RDP connection into Ubuntu Azure VM

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop?tabs=azure-cli

See this page for install instructions:

https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-rdp-linux


```
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4
```

Wait...

```
sudo apt install xfce4-session

sudo apt-get -y install xrdp
sudo systemctl enable xrdp

sudo adduser xrdp ssl-cert

echo xfce4-session >~/.xsession

sudo service xrdp restart

sudo apt install net-tools

```

## Create a Network Security Group rule for Remote Desktop traffic

```
az vm open-port --resource-group <rg-name> --name <vm-name> --port 3389
```

# Install Remote VS Code on Ubuntu VM

## Create SSH authentication

Generate SSH key pairs

`ssh-keygen -t rsa -b 4096 -f %USERPROFILE%/.ssh/linux_rsa`

Copy public key to remote VM

`scp %USERPROFILE%/.ssh/linux_rsa.pub saarela@137.135.221.8:~/key.pub`

or

`scp %USERPROFILE%/.ssh/linux_rsa.pub saarela@74.234.66.194:~/key.pub`


Login to remote VM

`ssh saarela@137.135.221.8`

or

`ssh saarela@74.234.66.194`

Run

```
cat ~/key.pub >> ~/.ssh/authorized_keys
rm ~/key.pub
```

```bash
sudo nano /etc/ssh/sshd_config
```

Find the AllowTcpForwarding yes line, and uncomment it. 

Restart the service:

`systemctl restart sshd`

## Test the SSH connection


Connect VS Code to Remote VM

`ssh -i %USERPROFILE%/.ssh/linux_rsa saarela@137.135.221.8`

or

`ssh -i %USERPROFILE%/.ssh/linux_rsa saarela@74.234.66.194`

# Install VS Code extensions to remote VM

Press F1 and select Connect to host

Select extensions on the left pane

Search for extensions and install on remote VM
