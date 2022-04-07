## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "cassandra" {
  source                 = "github.com/oracle-devrel/terraform-oci-cassandra"
  compartment_ocid       = var.compartment_ocid
  node_count             = var.node_count
  seeds_count            = var.seeds_count
  availability_domains   = data.template_file.ad_names.*.rendered
  subnet_ocids           = oci_core_subnet.CassandraSubnet.*.id
  vcn_cidr               = oci_core_virtual_network.CassandraVCN.cidr_block
  image_ocid             = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
  node_shape             = var.node_shape
  node_flex_shape_ocpus  = var.node_flex_shape_ocpus
  node_flex_shape_memory = var.node_flex_shape_memory
  storage_port           = var.storage_port
  ssl_storage_port       = var.ssl_storage_port
  ssh_authorized_keys    = tls_private_key.public_private_key_pair.public_key_openssh
  ssh_private_key        = tls_private_key.public_private_key_pair.private_key_pem
  use_private_subnet     = var.use_private_subnet
  bastion_service_id     = var.use_private_subnet ? oci_bastion_bastion.bastion-service[0].id : ""
  bastion_service_region = var.use_private_subnet ? var.region : ""
  defined_tags           = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
