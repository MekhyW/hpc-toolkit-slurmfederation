# Google HPC-Toolkit

TODO: update description for vagrant-cluster-hybrid project (assume cloud shell for setting up, which already comes with the updated dependencies preinstalled [gcloud, terraform, git, packer and go])

Reference for setting up cluster federation:
https://github.com/GoogleCloudPlatform/slurm-gcp/blob/master/docs/federation.md#federated-cluster-guide

## Description

HPC Toolkit is an open-source software offered by Google Cloud which makes it
easy for customers to deploy HPC environments on Google Cloud.

HPC Toolkit allows customers to deploy turnkey HPC environments (compute,
networking, storage, etc.) following Google Cloud best-practices, in a repeatable
manner. The HPC Toolkit is designed to be highly customizable and extensible,
and intends to address the HPC deployment needs of a broad range of customers.

## Detailed documentation and examples

The Toolkit comes with a suite of [tutorials], [examples], and full
documentation for a suite of [modules] that have been designed for HPC use cases.
More information can be found on the
[Google Cloud Docs](https://cloud.google.com/hpc-toolkit/docs/overview).

[tutorials]: docs/tutorials/README.md
[examples]: examples/README.md
[modules]: modules/README.md

## Quickstart

Running through the
[quickstart tutorial](https://cloud.google.com/hpc-toolkit/docs/quickstarts/slurm-cluster)
is the recommended path to get started with the HPC Toolkit.

---

If a self directed path is preferred, you can use the following commands to
build the `ghpc` binary:

```shell
git clone https://github.com/GoogleCloudPlatform/hpc-toolkit
cd hpc-toolkit
make
./ghpc --version
./ghpc --help
```

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

### Cloud credentials in virtualized cloud environments

In virtualized settings, the cloud credentials of accounts can be attached
directly to the execution environment. For example: a VM or a container can
have [service accounts](https://cloud.google.com/iam/docs/service-accounts)
attached to them. The Google [Cloud Shell][cloud-shell] is an interactive
command line environment which inherits the credentials of the user logged in
to the Google Cloud Console.

[cloud-shell]: https://console.cloud.google.com/home/dashboard?cloudshell=true
[cloud-shell-limitations]: https://cloud.google.com/shell/docs/quotas-limits#limitations_and_restrictions

Many of the above examples are easily executed within a Cloud Shell environment.
Be aware that Cloud Shell has [several limitations][cloud-shell-limitations],
in particular an inactivity timeout that will close running shells after 20
minutes. Please consider it only for blueprints that are quickly deployed.

## VM Image Support

### Standard Images

The HPC Toolkit officially supports the following VM images:

* HPC CentOS 7
* HPC Rocky Linux 8
* Debian 11
* Ubuntu 20.04 LTS

For more information on these and other images, see
[docs/vm-images.md](docs/vm-images.md).

### Slurm Images

> **_Warning:_** Slurm Terraform modules cannot be directly used on the standard OS images. They must be used in combination with images built for the versioned release of the Terraform module.

The HPC Toolkit provides modules and examples for implementing pre-built and custom Slurm VM images, see [Slurm on GCP](docs/vm-images.md#slurm-on-gcp)

## Blueprint Validation

The Toolkit contains "validator" functions that perform basic tests of the
blueprint to ensure that deployment variables are valid and that the HPC
environment can be provisioned in your Google Cloud project. Further information
can be found in [dedicated documentation](docs/blueprint-validation.md).

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

## Development

Please use the `pre-commit` hooks [configured](./.pre-commit-config.yaml) in
this repository to ensure that all changes are validated, tested and properly
documented before pushing code changes. The pre-commits configured
in the HPC Toolkit have a set of dependencies that need to be installed before
successfully passing.

Follow these steps to install and setup pre-commit in your cloned repository:

1. Install pre-commit using the instructions from [the pre-commit website](https://pre-commit.com/).
1. Install TFLint using the instructions from
   [the TFLint documentation](https://github.com/terraform-linters/tflint#installation).

   > **_NOTE:_** The version of TFLint must be compatible with the Google plugin
   > version identified in [tflint.hcl](.tflint.hcl). Versions of the plugin
   > `>=0.20.0` should use `tflint>=0.40.0`. These versions are readily
   > available via GitHub or package managers. Please review the [TFLint Ruleset
   > for Google Release Notes][tflint-google] for up-to-date requirements.

[tflint-google]: https://github.com/terraform-linters/tflint-ruleset-google/releases

1. Install ShellCheck using the instructions from
   [the ShellCheck documentation](https://github.com/koalaman/shellcheck#installing)
1. The other dev dependencies can be installed by running the following command
   in the project root directory:

    ```shell
    make install-dev-deps
    ```

1. Pre-commit is enabled on a repo-by-repo basis by running the following command
   in the project root directory:

    ```shell
    pre-commit install
    ```

Now pre-commit is configured to automatically run before you commit.
