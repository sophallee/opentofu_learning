# Azure Customer Infrastructure Deployment

This project contains OpenTofu (or Terraform) configurations to deploy a standardized customer infrastructure on Azure. It sets up a dedicated resource group, networking, security rules, and virtual machines (PMDS, Webapps, and optional OEM).

## Architecture Overview

The configuration deploys the following resources:

- **Resource Group:** A dedicated RG for the customer.
- **Networking:**
    - **Subnet:** Created within an existing Virtual Network (VNet).
    - **Network Security Group (NSG):** Configured with custom allow/deny rules based on CIDR blocks.
    - **Route Table:** Sets up routing for internet traffic (via a virtual appliance) and local LAN traffic.
- **Virtual Machines:**
    - **PMDS Server:** Linux VM with OS, Data, and DB disks.
    - **Webapps Server:** Linux VM with OS, Data, and DB disks.
    - **OEM Server (Optional):** Linux VM with OS and Data disks.
- **Storage:** Managed disks for OS, application data, and databases.

## Prerequisites

- [OpenTofu](https://opentofu.org/docs/intro/install/) or [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.0.0)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- An active Azure Subscription

## Usage

### 1. Initialize the Workspace

```bash
tofu init
# or
terraform init
```

### 2. Configure Variables and Environment

Copy the template files and fill in your customer-specific details:

```bash
cp terraform.tfvars.template terraform.tfvars
cp env.template .env
```

Edit `terraform.tfvars` with the required infrastructure values:
- `customer_name`: Name of the customer (used for naming and tagging).
- `server_prefix`: Prefix for VM naming (e.g., `ABC`).
- `subnet_cidr`: The CIDR block for the customer subnet.
- `ssh_password`: Admin password for the VMs.

Edit `.env` with your environment-specific credentials and configuration as defined in the template.

### 3. Plan and Apply

Review the execution plan:

```bash
tofu plan
```

Deploy the infrastructure:

```bash
tofu apply
```

## Configuration Details

### Key Variables

| Name | Description | Default |
|------|-------------|---------|
| `customer_name` | Customer name for resource naming | `""` |
| `server_prefix` | Prefix for server naming | `""` |
| `location` | Azure region | `australiaeast` |
| `subnet_cidr` | Subnet CIDR for customer subnet | `""` |
| `create_oem` | Whether to create the OEM server | `false` |
| `ssh_username` | Admin username for VMs | `autoit` |

### File Structure

- `main.tf`: Provider configuration and Resource Group definition.
- `variables.tf`: Core variable definitions.
- `global_variables.tf`: Global/shared variable definitions.
- `vm_variables.tf`: VM-specific configurations and sizes.
- `locals.tf`: Computed values for naming and networking.
- `network.tf`: Subnet and VNet integration.
- `nsg.tf`: Security group rules.
- `route_table.tf`: Routing configuration.
- `vms.tf`: Virtual Machine and disk resources.
- `outputs.tf`: Connection strings and resource details.

## Outputs

After a successful apply, the following information will be displayed:
- `resource_group_name`: The name of the created resource group.
- `vm_names`: List of created VM names.
- `vm_ips`: Private IP addresses of the VMs.
- `ssh_connection_strings`: Helper strings for connecting to the VMs via SSH.

## License

[Specify License if applicable]
