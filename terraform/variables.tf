variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key"
}

variable "region" {
  type        = string
  description = "IBM Cloud region to provision the resources."
  default     = "us-south"
}

variable "zone" {
  type        = string
  description = "IBM Cloud availability zone within a region to provision the resources."
  default     = "dal10"
}

variable "resource_group" {
  type        = string
  default     = "demo-rg"
  description = "Name of the resource group"
}

variable "prefix" {
  type        = string
  default = "demo"
  description = "The string that needs to be attached to every resource created"
}

variable "secrets_manager_instance_crn" {
  type        = string
  description = "CRN of existing Secrets Manager instance"
}

variable "ssh_key_secret_name" {
  type        = string
  description = "NAME of the Arbitrary Secret in Secrets Manager that contains the public ssh key contents that will be used to provision the PowerVS instance"
}

variable "ssh_key_secret_group_name" {
  type        = string
  description = "GROUP NAME in which the Arbitrary Secret belongs to in Secrets Manager"
  default = "default"
}

variable "powervs_subnet_cidr" {
  type        = string
  description = "IP Address CIDR for PowerVS workspace"
}

variable "powervs_instance_cores" {
  type        = string
  description =  "number of physical cores (can be fractional to .25)"
  default = ".25"
}

variable "powervs_instance_memory" {
  type        = number
  description =  "amount of memory (GiB)"
  default = 2
}

variable "powervs_system_type" {
  type = string
  description = "Power System type: 922, 980, 1080. Check data centers for availability. Defaults to Power9 scale-out (922)"
  default = "s922"
}
