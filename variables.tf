# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# variables.tf 
#
# Purpose: The following file declares all variables used in this backend repository

/********** Provider Variables NOT OVERLOADABLE **********/

variable "region" {
  description = "Target region where artifacts are going to be created"
}

variable "tenancy_ocid" {
  description = "OCID of tenancy"
}

variable "user_ocid" {
  description = "User OCID in tenancy."
}

variable "fingerprint" {
  description = "API Key Fingerprint for user_ocid derived from public API Key imported in OCI User config"
}

variable "private_key_path" {
  description = "Private Key Absolute path location where terraform is executed"

}

/********** Provider Variables NOT OVERLOADABLE **********/

/********** Brick Variables **********/

/************* Datasource Script Variables *************/

variable "iscsi_disk_instance_compartment_name" {
  description = "Defines the compartment name where the infrastructure will be created"
}
/************* Datasource Script Variables *************/


/************* Disk Variables *************/
variable "ssh_private_is_path" {
  description = "Determines if key is supposed to be on file or in text"
  default     = true
}

variable "ssh_private_key" {
  description = "Determines what is the private key to connect to machine"
}

variable "amount_of_disks" {
  description = "Amount of equally sized disks"
}

variable "disk_size_in_gb" {
  description = "Size in GB for Product Disk"
}

variable "volume_display_name" {
  description = "Disk display name."
}

variable "attachment_type" {
  description = "Atacchment type can be iscsi or paravirtualized"
  default     = "iscsi"
}

variable "linux_compute_id" {
  description = "OCI Id for instance to attach the disk"
  default     = null
}

variable "attach_disks" {
  description = "Atach disk to a Linux instance"
  default     = true
}

variable "backup_policy_level" {
  description = "Backup policy level for ISCSI disks"
}

variable "vpus_per_gb" {
  default = 10
}

variable "compute_display_name" {
  description = "Name of the compute where the disk will be attached to"

}

variable "compute_availability_domain_list" {
  description = "Availability Domain where the block storage will be created at"

}

variable "linux_compute_private_ip" {
  description = "Compute private IP to logon into machine"
}

variable "is_opc" {
  description = "Describes if user to use is opc or not. Setting this to false, will default to ubuntu user"
  default     = true

}
/************* Disk Variables *************/

/********** Brick Variables **********/


