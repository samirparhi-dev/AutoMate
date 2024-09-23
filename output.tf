
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
