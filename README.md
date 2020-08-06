# terraform-from-scratch

Pre requisites:
* A GCP account
* Terraform v0.11.11
* gcloud CLI
* kubectl

<br>
### The first set of steps will set up the GCP pre-reqs
Login to yout GCP account via the CLI (this will launch a browser where you can select your Google acccount and provide credentials):
```
gcloud auth login
```
Create a GCP project:
```
gcloud projects create tf-from-scratch
```
Alternatively, if you want to use an existing project, switch yo is as follows:
```
gcloud config set project <your-gcp-project>
```
Create a service account:
```
gcloud iam service-accounts create tf-from-scratch-sa
```
Link this service account to your project:
```
gcloud projects add-iam-policy-binding tf-from-scratch \
    --member "serviceAccount:tf-from-scratch-sa@tf-from-scratch.iam.gserviceaccount.com" \
    --role "roles/owner"
```
Create and download a private key for this service account (Terraform will need this to authenticate to your gcp project):
```
gcloud iam service-accounts keys create \
    "/path/you/choose/tf-from-scratch-sa.json" \
    --iam-account "tf-from-scratch-sa@tf-from-scratch.iam.gserviceaccount.com"
```
Set up a remote backend to store terraform state: (note, you will need to link your GCP project to a billing account for this to work)
```
gsutil mb -p tf-from-scratch -l eu gs://tf-from-scratch-remote-state
```

<br>
### Now we've done the GCP pre-reqs, we can get on with writing the Terraform

Create a file named ```backend.tf``` with the following contents. This will tell terraform that we want to use Google Cloud Storage for our backend (remote state)

```
terraform { 
  backend "gcs" { 
    bucket                    = "tf-from-scratch-remote-state" 
    prefix                    = "terraform" 
    project                   = "tf-from-scratch" 
    credentials               = "/path/you/chose/earlier/when/you/downloaded/the/key/tf-from-scratch-sa.json" 
  } 
} 
```

Initialise the backend:
```
terraform init
```

This should result in something similar to the following:
<img src="/assets/images/terraform-from-scratch-01.png" width="70%"/>

Check that the remote state has been initialised (note - we’re not using workspaces yet, therefore we’re working in the default workspace)
```
gsutil cat gs://tf-from-scratch-remote-state/terraform/default.tfstate 
(note the file is named default.tfstate to reflect that we're using the default workspace)
```

This resulting display should be something similar to:
```
{ 
    "version": 3, 
    "serial": 1, 
    "lineage": "2c1eae35-87b7-8d2a-556a-09ab57d0bff7", 
    "modules": [ 
        { 
            "path": [ 
                "root" 
            ], 
            "outputs": {}, 
            "resources": {}, 
            "depends_on": [] 
        } 
    ] 
} 
```

Create a file named providers.tf with the following contents - This will tell terraform that we want to use the Terraform Google provider.
```
provider "google" { 
  project                     = “tf-from-scratch" 
  region                      = "europe-west2" 
  zone                        = "europe-west2-a" 
  credentials                 = "${file(“/path/you/chose/earlier/when/you/downloaded/the/key/tf-from-scratch-sa.json")}" 
} 
```
Initialise the provider: 
```
terraform init
```
This should result in something similar to the following output:<br>
<img src="/assets/images/terraform-from-scratch-02.png" width="70%"/>

Enable the container.googleapis.com API Service:
```
gcloud services enable container.googleapis.com
```

<br>
### We’re now ready to start building stuff - let’s use terraform modules to do this as they are pretty cool

Create a directory struture for out Kubernetes cluster module
```
mkdir -p modules/kubernetes_cluster
```

Create the file modules/kubernetes_cluster/main.tf with the following contents:

```
resource "google_container_cluster" "k8s_cluster" { 
  count              = "1" 
  name               = "terraform-from-scratch-k8s-cluster" 
  zone               = "europe-west2-a" 
  initial_node_count = "3" 
  project            = "terraform-from-scratch" 

  node_config { 
    oauth_scopes = [ 
      "https://www.googleapis.com/auth/compute", 
      "https://www.googleapis.com/auth/devstorage.read_only", 
      "https://www.googleapis.com/auth/logging.write", 
      "https://www.googleapis.com/auth/monitoring", 
    ] 
  } 
} 
```

Now we need to write the code to call this module. To do this cd back up to your top level directory (where backend.tf and providers.tf reside) and create main.tf with the following contents. </p>
```
module "kubernetes-cluster" { 
  source = "modules/kubernetes_cluster" 
}
```

Initialise the new module:
```
terraform init
```

Plan the build
```
terraform plan
```

If all looks OK, run the build
```
terraform apply -auto-approve
```

Once the cluster is ready, update your ~/.kube/config and set context to your new kubernetes cluster
```
gcloud container clusters get-credentials tf-from-scratch-k8s-cluster
```

Check kubectl connectivity
```
kubectl get pods -n kube-system
```

