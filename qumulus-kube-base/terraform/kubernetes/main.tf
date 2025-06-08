provider "openstack" {
  auth_url    = var.auth_url
  user_name   = var.user_name
  tenant_name = var.tenant_name
  password    = var.password
  region      = var.region
}

# Master node
resource "openstack_compute_instance_v2" "k8s_master" {
  name            = "k8s-master"
  image_name      = var.image_name
  flavor_name     = var.master_flavor
  key_pair        = var.key_pair
  security_groups = ["default"]
  network {
    name = var.network_name
  }
}

# Worker nodes
resource "openstack_compute_instance_v2" "k8s_worker" {
  count           = var.worker_count
  name            = "k8s-worker-${count.index}"
  image_name      = var.image_name
  flavor_name     = var.worker_flavor
  key_pair        = var.key_pair
  security_groups = ["default"]
  network {
    name = var.network_name
  }
}