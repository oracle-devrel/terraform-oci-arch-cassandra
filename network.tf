## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "CassandraVCN" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "CassandraVCN"
  dns_label      = "ocicassandra"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


############################################
# Create Internet Gateway
############################################
resource "oci_core_internet_gateway" "CassandraIG" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}CassandraIG"
  vcn_id         = oci_core_virtual_network.CassandraVCN.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


############################################
# Create NAT Gateway
############################################
resource "oci_core_nat_gateway" "CassandraNATGW" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}CassandraNATGW"
  vcn_id         = oci_core_virtual_network.CassandraVCN.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


############################################
# Create Route Table for Public Network
############################################
resource "oci_core_route_table" "CassandraPublicRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.CassandraVCN.id
  display_name   = "${var.label_prefix}CassandraPublicRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.CassandraIG.id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


############################################
# Create Route Table for Private Network
############################################
resource "oci_core_route_table" "CassandraPrivateRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.CassandraVCN.id
  display_name   = "${var.label_prefix}CassandraPrivateRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.CassandraNATGW.id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "CassandraSL" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}CassandraSecurityList"
  vcn_id         = oci_core_virtual_network.CassandraVCN.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = var.storage_port
      min = var.storage_port
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = var.ssl_storage_port
      min = var.ssl_storage_port
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_subnet" "CassandraSubnet" {
  cidr_block                 = var.cassandra_subnet_cidr
  display_name               = "${var.label_prefix}CassandraSubnet"
  dns_label                  = "cassandra"
  security_list_ids          = [oci_core_virtual_network.CassandraVCN.default_security_list_id, oci_core_security_list.CassandraSL.id]
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.CassandraVCN.id
  route_table_id             = var.use_private_subnet ? oci_core_route_table.CassandraPrivateRT.id : oci_core_route_table.CassandraPublicRT.id
  dhcp_options_id            = oci_core_virtual_network.CassandraVCN.default_dhcp_options_id
  prohibit_public_ip_on_vnic = var.use_private_subnet ? true : false
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
