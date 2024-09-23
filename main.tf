terraform {
  required_providers {
    civo = {
      source = "civo/civo"
    }
  }
}
provider "civo" {
  token = var.civo_apitoken
}

data "civo_disk_image" "debian" {
   filter {
        key = "name"
        values = ["Debian-11"]
   }
}

data "civo_firewall" "get_firewall_k8s" {
    name = var.firewall-k8s
    region = var.region
}

data "civo_network" "get_network_k8s" {
    label = var.network-k8s
    region = var.region
}

data "civo_ssh_key" "get_ssh_key" {
  name = var.ssh_key_Name
}

# Create a new instance
# resource "civo_instance" "Civo_Compute" {
#     hostname = var.VM_name
#     tags = ["build", "k8s"]
#     notes = "This is a K8s Build Server"
#     size = var.VM_size
#     firewall_id = data.civo_firewall.get_firewall_k8s.id
#     network_id = data.civo_network.get_network_k8s.id
#     disk_image = "debian-11"
#     sshkey_id = data.civo_ssh_key.get_ssh_key.id
#     initial_user =var.initial_user
#     script = file("./boostrap-data.sh")
#     region = var.region

# }


# Create a cluster with k3s

resource "civo_kubernetes_cluster" "k8sCluster" {
    name = var.cluster_name
    kubernetes_version = var.k8s_version
    # applications = "Traefik-v2"
    firewall_id = data.civo_firewall.get_firewall_k8s.id
    # firewall_id = 20d35c62-7562-4259-b6e6-eaa847876edd
    network_id = data.civo_network.get_network_k8s.id
    # network_id = "a5118555-cb00-40ec-9761-457c9ae32ba3"
    cluster_type = "k3s"
    region = var.region
    cni    = var.cni
    pools {
        label = "sharang-prod"
        size = var.node_size
        node_count = var.num_of_nodes
        # public_ip_node_pool =
        
    }
    
}

# data "civo_kubernetes_cluster" "get-k8s-cluster" {
#     name = var.cluster_name
# }

# output "k8s-master_ip" {
#   value = data.civo_kubernetes_cluster.get-k8s-cluster.master_ip
# }

# output "k8s-kubeconfig" {
#   value = data.civo_kubernetes_cluster.get-k8s-cluster.kubeconfig
  
# }

# output "k8s-api-endpoint" {
#   value = data.civo_kubernetes_cluster.get-k8s-cluster.api_endpoint
  
# }



# module "compute_instance" {
#   source  = "./modules/civo-compute"
# }

# module "k8s_cluster" {
#   source  = "./modules/civo-k8s"
# }
