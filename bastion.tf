## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_bastion_bastion" "bastion-service" {
  count          = var.use_private_subnet ? 1 : 0
  bastion_type   = "STANDARD"
  compartment_id = var.compartment_ocid
  #  target_subnet_id             = oci_core_subnet.BastionSubnet[0].id
  target_subnet_id             = oci_core_subnet.CassandraSubnet.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  name                         = "BastionService"
  max_session_ttl_in_seconds   = 1800
}
