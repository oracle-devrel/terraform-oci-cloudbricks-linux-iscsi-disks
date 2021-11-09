# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# diskprovision.tf
#
# Purpose: The following script defines the logic to format and present a disk to a machine idempotently 


#Create Disk Attachment
resource "null_resource" "provisioning_disk" {
  depends_on = [oci_core_volume_attachment.ISCSIDiskAttachment]
  count      = length(oci_core_volume_attachment.ISCSIDiskAttachment)

  connection {
    type        = "ssh"
    host        = var.linux_compute_private_ip
    user        = var.is_opc ? "opc" : "ubuntu"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  # register and connect the iSCSI block volume

  provisioner "remote-exec" {

    inline = [
      "set +x",
      "${local.iscsiadm} -m node -o new -T ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].port}",
      "${local.iscsiadm} -m node -o update -T ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn} -n node.startup -v automatic",
      "${local.iscsiadm} -m node -T ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn} -p ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].port} -l",
    ]
  }
}


resource "null_resource" "partition_disk" {
  depends_on = [null_resource.provisioning_disk]
  count      = length(oci_core_volume_attachment.ISCSIDiskAttachment)
  connection {
    type        = "ssh"
    host        = var.linux_compute_private_ip
    user        = var.is_opc ? "opc" : "ubuntu"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn}-lun-1",
      "if [ ${var.disk_size_in_gb} > 2000 ]; then ${local.parted} $${DEVICE_ID} mklabel gpt mkpart P1 xfs 0% 100%; else ${local.fdisk} $${DEVICE_ID}; fi",
    ]
  }
}


resource "null_resource" "pvcreate_exec" {
  depends_on = [null_resource.partition_disk]
  count      = length(oci_core_volume_attachment.ISCSIDiskAttachment)
  connection {
    type        = "ssh"
    host        = var.linux_compute_private_ip
    user        = var.is_opc ? "opc" : "ubuntu"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn}-lun-1",
      "${local.pvcreate} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "vgcreate_exec" {
  depends_on = [null_resource.pvcreate_exec]
  count      = length(oci_core_volume_attachment.ISCSIDiskAttachment)
  connection {
    type        = "ssh"
    host        = var.linux_compute_private_ip
    user        = var.is_opc ? "opc" : "ubuntu"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn}-lun-1",
      "${local.vgcreate} ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].display_name}_${count.index} $${DEVICE_ID}-part1",
    ]
  }
}


resource "null_resource" "format_disk_exec" {
  depends_on = [null_resource.vgcreate_exec,
    oci_core_volume_attachment.ISCSIDiskAttachment
  ]
  count = length(oci_core_volume_attachment.ISCSIDiskAttachment)
  connection {
    type        = "ssh"
    host        = var.linux_compute_private_ip
    user        = var.is_opc ? "opc" : "ubuntu"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s $${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -ne 0 ] ; then",
      "while [[ ! -e $${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "${local.mkfs_xfs} $${DEVICE_ID}-part1 -f",
      "fi",
    ]
  }
}

resource "null_resource" "mount_disk_exec" {
  depends_on = [null_resource.format_disk_exec,
    oci_core_volume_attachment.ISCSIDiskAttachment
  ]
  count = length(oci_core_volume_attachment.ISCSIDiskAttachment)
  connection {
    type        = "ssh"
    host        = var.linux_compute_private_ip
    user        = var.is_opc ? "opc" : "ubuntu"
    private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
  }

  # With provisioned disk, trigger fdisk, then pvcreate and vgcreate to tag the disk
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "export MOUNTED_DISKS=$(cat /etc/fstab |grep u0${count.index + 1} |wc -l)",
      "if [ $MOUNTED_DISKS -eq 0 ] ; then",
      "export DEVICE_ID=/dev/disk/by-path/ip-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}:${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].port}-iscsi-${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn}-lun-1",
      "sudo mkdir -p /u0${count.index + 1}/",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value $${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /u0${count.index + 1}/ xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "sudo chown -R opc:opc /u0${count.index + 1}/",
      "cd /",
      "fi",
    ]
  }
}

