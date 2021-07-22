# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# tags.tf 
#
# Purpose: The following file declares the logic for tracking usage of modules inside Dev-Rel Community. Do not override

resource "random_id" "tag" {
  byte_length = 2
}

resource "oci_identity_tag_namespace" "devrel" {
  provider       = oci.home
  compartment_id = local.compartment_id
  description    = "Developer Relations Tag Namespace"
  name           = "DevRel\\terraform-oci-cloudbricks-linux-iscsi-disks-${random_id.tag.hex}"

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "oci_identity_tag" "release" {
  provider         = oci.home
  description      = "Release tag."
  name             = "release"
  tag_namespace_id = oci_identity_tag_namespace.devrel.id

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 120"
  }
}