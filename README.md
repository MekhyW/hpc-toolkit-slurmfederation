# HPC-Toolkit SlurmFederation

TODO: update description and about for vagrant-cluster-hybrid project

[Hybrid Cluster Guide](https://github.com/GoogleCloudPlatform/slurm-gcp/blob/5.10.6/docs/hybrid.md)

[Full Hybrid Slurm Cluster Example](https://github.com/GoogleCloudPlatform/slurm-gcp/blob/5.10.6/terraform/slurm_cluster/examples/slurm_cluster/hybrid/full/README.md)

[Federated Cluster Guide](https://github.com/GoogleCloudPlatform/slurm-gcp/blob/master/docs/federation.md#federated-cluster-guide)

## Description

HPC Toolkit is an open-source software offered by Google Cloud which makes it
easy for customers to deploy HPC environments on Google Cloud.

HPC Toolkit allows customers to deploy turnkey HPC environments (compute,
networking, storage, etc.) following Google Cloud best-practices, in a repeatable
manner. The HPC Toolkit is designed to be highly customizable and extensible,
and intends to address the HPC deployment needs of a broad range of customers.

## Default settings

- The default region is `us-central1`.
- The default zone is `us-central1-a`.
- The DNS domain name is `laboratorioderedesinsper.com.br`.
- The on-premise IP range for the VPN is `192.168.50.0/24`.
- The shared secret for the VPN is `osbatutinhas`.

## Quickstart

Running through the
[quickstart tutorial](https://cloud.google.com/hpc-toolkit/docs/quickstarts/slurm-cluster)
is the recommended path to get started with the HPC Toolkit.

---

If a self directed path is preferred, you can use the following commands to
build the `ghpc` binary:

```shell
git clone https://github.com/MekhyW/hpc-toolkit-slurmfederation.git
cd hpc-toolkit-slurmfederation
make
./ghpc --version
./ghpc --help
```

> **_NOTE:_** You may need to [install dependencies](#dependencies) first.

## HPC Toolkit Components

Learn about the components that make up the HPC Toolkit and more on how it works
on the
[Google Cloud Docs Product Overview](https://cloud.google.com/hpc-toolkit/docs/overview#components).

## GCP Credentials

### Supplying cloud credentials to Terraform

Terraform can discover credentials for authenticating to Google Cloud Platform
in several ways. We will summarize Terraform's documentation for using
[gcloud][terraform-auth-gcloud] from your workstation and for automatically
finding credentials in cloud environments. We do **not** recommend following
Hashicorp's instructions for downloading
[service account keys][terraform-auth-sa-key].

[terraform-auth-gcloud]: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#configuring-the-provider
[terraform-auth-sa-key]: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials

### Cloud credentials on your workstation

You can generate cloud credentials associated with your Google Cloud account
using the following command:

```shell
gcloud auth application-default login
```

You will be prompted to open your web browser and authenticate to Google Cloud
and make your account accessible from the command-line. Once this command
completes, Terraform will automatically use your "Application Default
Credentials."

If you receive failure messages containing "quota project" you should change the
quota project associated with your Application Default Credentials with the
following command and provide your current project ID as the argument:

```shell
gcloud auth application-default set-quota-project ${PROJECT-ID}
```

## Enable GCP APIs

In a new GCP project there are several APIs that must be enabled to deploy your
HPC cluster. These will be caught when you perform `terraform apply` but you can
save time by enabling them upfront.

See
[Google Cloud Docs](https://cloud.google.com/hpc-toolkit/docs/setup/configure-environment#enable-apis)
for instructions.

## Troubleshooting

### Authentication

Confirm that you have [properly setup Google Cloud credentials](#gcp-credentials)

### Slurm Clusters

Please see the dedicated [troubleshooting guide for Slurm](docs/slurm-troubleshooting.md).

### Terraform Deployment

When `terraform apply` fails, Terraform generally provides a useful error
message. Here are some common reasons for the deployment to fail:

* **GCP Access:** The credentials being used to call `terraform apply` do not
  have access to the GCP project. This can be fixed by granting access in
  `IAM & Admin`.
* **Disabled APIs:** The GCP project must have the proper APIs enabled. See
  [Enable GCP APIs](#enable-gcp-apis).
* **Insufficient Quota:** The GCP project does not have enough quota to
  provision the requested resources. See [GCP Quotas](#gcp-quotas).
* **Filestore resource limit:** When regularly deploying Filestore instances
  with a new VPC you may see an error during deployment such as:
  `System limit for internal resources has been reached`. See
  [this doc](https://cloud.google.com/filestore/docs/troubleshooting#system_limit_for_internal_resources_has_been_reached_error_when_creating_an_instance)
  for the solution.
* **Required permission not found:**
  * Example: `Required 'compute.projects.get' permission for 'projects/... forbidden`
  * Credentials may not be set, or are not set correctly. Please follow
    instructions at [Cloud credentials on your workstation](#cloud-credentials-on-your-workstation).
  * Ensure proper permissions are set in the cloud console
    [IAM section](https://console.cloud.google.com/iam-admin/iam).

## Inspecting the Deployment

The deployment will be created with the following directory structure:

```text
<<OUTPUT_PATH>>/<<DEPLOYMENT_NAME>>/{<<DEPLOYMENT_GROUPS>>}/
```

If an output directory is provided with the `--output/-o` flag, the deployment
directory will be created in the output directory, represented as
`<<OUTPUT_PATH>>` here. If not provided, `<<OUTPUT_PATH>>` will default to the
current working directory.

The deployment directory is created in `<<OUTPUT_PATH>>` as a directory matching
the provided `deployment_name` deployment variable (`vars`) in the blueprint.

Within the deployment directory are directories representing each deployment
group in the blueprint named the same as the `group` field for each element
in `deployment_groups`.

In each deployment group directory, are all of the configuration scripts and
modules needed to deploy. The modules are in a directory named `modules` named
the same as the source module, for example the
[vpc module](./modules/network/vpc/README.md) is in a directory named `vpc`.

A hidden directory containing meta information and backups is also created and
named `.ghpc`.

From the [hpc-slurm.yaml example](./examples/hpc-slurm.yaml), we
get the following deployment directory:

```text
hpc-slurm/
  primary/
    main.tf
    modules/
    providers.tf
    terraform.tfvars
    variables.tf
    versions.tf
  .ghpc/
```

## Dependencies

See
[Cloud Docs on Installing Dependencies](https://cloud.google.com/hpc-toolkit/docs/setup/install-dependencies).

> **_NOTE:_** The hybrid module requires the following dependencies to be
> installed on the system deploying the module:
> * [gcloud]
> * [terraform]
> * [addict]
> * [httplib2]
> * [pyyaml]
> * [google-api-python-client]
> * [google-cloud-pubsub]
> * [go-lang]
> * A full list of recommended python packages is available in a
>   [requirements.txt] file in the [slurm-gcp] repo.

[gcloud]: https://cloud.google.com/sdk/docs/install?hl=pt-br#linux
[terraform]: https://learn.hashicorp.com/tutorials/terraform/install-cli
[addict]: https://pypi.org/project/addict/
[httplib2]: https://pypi.org/project/httplib2/
[pyyaml]: https://pypi.org/project/PyYAML/
[google-api-python-client]: https://pypi.org/project/google-api-python-client/
[google-cloud-pubsub]: https://pypi.org/project/google-cloud-pubsub/
[go-lang]: https://go.dev/doc/install
[requirements.txt]: https://github.com/GoogleCloudPlatform/slurm-gcp/blob/5.10.6/scripts/requirements.txt
