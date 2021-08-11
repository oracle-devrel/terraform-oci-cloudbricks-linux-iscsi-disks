# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# datasource.tf
#
# Purpose: The following script defines the lookup logic used in code to obtain pre-created or JIT-created resources in tenancy.


/********** Compartment and CF Accessors **********/
data "oci_identity_compartments" "COMPARTMENTS" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  filter {
    name   = "name"
    values = [var.iscsi_disk_instance_compartment_name]
  }
}

/********** Block Volume Backup Accessor **********/


data "oci_core_volume_backup_policies" "BACKUPPOLICYISCSI" {
  filter {
    name = "display_name"

    values = [var.backup_policy_level]
  }
}

locals {
  # Compartment and backup policy local accessors
  compartment_id              = data.oci_identity_compartments.COMPARTMENTS.compartments[0].id
  backup_policy_iscsi_disk_id = data.oci_core_volume_backup_policies.BACKUPPOLICYISCSI.volume_backup_policies[0].id

  # Command aliases for format and mounting iscsi disks
  iscsiadm = "sudo iscsiadm"
  fdisk    = "(echo n; echo p; echo '1'; echo ''; echo ''; echo 't';echo '8e'; echo w) | sudo /sbin/fdisk "
  pvcreate = "sudo /sbin/pvcreate"
  vgcreate = "sudo /sbin/vgcreate"
  mkfs_xfs = "sudo /sbin/mkfs.xfs"
}
