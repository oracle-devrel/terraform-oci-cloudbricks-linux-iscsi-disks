# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# blockstorage.tf
#
# Purpose: The following script defines the declaration for block volumes using ISCSI Disks
# Registry: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment


# Create Disk
resource "oci_core_volume" "ISCSIDisk" {
  count               = var.amount_of_disks
  availability_domain = var.compute_availability_domain_list[count.index % length(var.compute_availability_domain_list)]
  compartment_id      = local.compartment_id
  display_name        = "${var.compute_display_name}_${var.volume_display_name}_${count.index}"
  size_in_gbs         = var.disk_size_in_gb
  vpus_per_gb         = var.vpus_per_gb

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  defined_tags = {
    "${oci_identity_tag_namespace.devrel.name}.${oci_identity_tag.release.name}" = local.release
  }

}

# Create Disk Attachment
resource "oci_core_volume_attachment" "ISCSIDiskAttachment" {
  depends_on      = [oci_core_volume.ISCSIDisk]
  count           = var.attach_disks ? var.amount_of_disks : 0
  attachment_type = var.attachment_type
  instance_id     = var.linux_compute_id
  volume_id       = oci_core_volume.ISCSIDisk[count.index].id
}

# Assignament of backup policy for ProdDisk
resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_ISCSI_Disk" {
  count     = var.amount_of_disks
  asset_id  = oci_core_volume.ISCSIDisk[count.index].id
  policy_id = local.backup_policy_iscsi_disk_id
}
