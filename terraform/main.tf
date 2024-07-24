/**
 * @author Andrea C. Crawford
 * @email acm@us.ibm.com
 * @create date 2024-06-27
 * @modify date 2024-06-27
 * @desc Terraform to provision a PowerVS workspace and a single instance
 */


###############################################################################
## Create a Resource Group
##
## Gets reference to an existing resource group, specified in terraform.tfvars
###############################################################################
data "ibm_resource_group" "resource_group" {
   name   = var.resource_group
}


###############################################################################
## Create a Power VS Workspace
##
##
###############################################################################
resource ibm_pi_workspace "powervs_workspace" {
  pi_name          = join("-", [var.prefix, "power-workspace"])

  pi_datacenter    = var.region
  pi_resource_group_id  = data.ibm_resource_group.resource_group.id
}

###############################################################################
## Create an ssh key in the PowerVS workspace
##
## This assumes there is a public key available in Secrets Manager as an
## arbitraty secret. This will pull the secret (public key payload) and create
## an ssh key object in the PowerVS workspace. This will be used to provision
## a PowerVS instance later.
###############################################################################
# gets reference to an existing Secrets Manager instance
# CRN of Secrets Manager should be specified in terraform.tfvars
data "ibm_resource_instance" "secrets_manager" {
  identifier = var.secrets_manager_instance_crn
}

# gets reference to an existing public ssh key stored in your existing
# Secrets Manager instance
# CRN of Secrets Manager should be specified in terraform.tfvars
data "ibm_sm_arbitrary_secret" "ssh_key_secret" {
  instance_id   = data.ibm_resource_instance.secrets_manager.guid
  region        = var.region
  name          = var.ssh_key_secret_name
  secret_group_name = var.ssh_key_secret_group_name
  #secret_id = "4d83c74c-1bc8-c167-bd32-428e5b38bba3"
}

# Create SSH Key object in PowerVS workspace, based on the ssh public key
# payload from Secrets Manager
resource "ibm_pi_key" "power_vsi_ssh_key" {
  pi_key_name       = join("-", [var.prefix, "ssh-key"])
  pi_ssh_key        = data.ibm_sm_arbitrary_secret.ssh_key_secret.payload
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
}

###############################################################################
## Create a subnet in the PowerVS workspace
##
## This creates a PRIVATE vlan (or subnet) in the PowerVS workspace
###############################################################################
resource "ibm_pi_network" "workload-subnet" {
  count                = 1
  pi_network_name      = "workload-subnet"
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
  pi_network_type      = "vlan"
  pi_cidr              = var.powervs_subnet_cidr
}


###############################################################################
## Create a PowerVS instance
##
## This creates a PowerVS instance (or a vm) using the ssh key and subnet above
###############################################################################
resource "ibm_pi_instance" "powervs-instance" {
    pi_memory             = var.powervs_instance_memory
    pi_processors         = var.powervs_instance_cores
    pi_instance_name      = join("-", [var.prefix, "power-vsi"])
    pi_proc_type          = "shared"
    pi_image_id           = data.ibm_pi_image.rhel9_image.id
    pi_key_pair_name      = ibm_pi_key.power_vsi_ssh_key.pi_key_name
    pi_sys_type           = var.powervs_system_type
    pi_cloud_instance_id  = ibm_pi_workspace.powervs_workspace.id
    pi_pin_policy         = "none"
    pi_health_status      = "WARNING"
    pi_network {
      network_id = ibm_pi_network.workload-subnet[0].network_id
    }
}

data "ibm_pi_image" "rhel9_image" {
    pi_image_name = "RHEL9-SP2"
    pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
}
