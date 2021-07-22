# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# output.tf
#
# Purpose: The following file defines the output for module


output "volumen_ids" {
  value = oci_core_volume.ISCSIDisk.*.id
}

output "core_volumens" {
  value = oci_core_volume.ISCSIDisk
}

output "core_volumens_attachment" {
  value = oci_core_volume_attachment.ISCSIDiskAttachment
}
