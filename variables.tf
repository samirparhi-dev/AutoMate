variable "civo_apitoken" {
  description = "This is the Api token Variable "
  type        = string
  default     = "null"
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
  default     = "spx7-default"
}

variable "region" {
  description = "The region to create the cluster in"
  type        = string
  default     = "fra1"
}

variable "num_of_nodes" {
  description = "The number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "node_size" {
  description = "The size of the nodes in the cluster"
  type        = string
  default     = "g4s.kube.xsmall"
}
variable "cni" {
  description = "The CNI for the K8s Cluster"
  type        = string
  default     = "flannel"
}

variable "k8s_version" {
  description = "kubernetes Version"
  type        = string
  default     = "1.28.7-stable"
}

variable "ssh_key_Name" {
  description = "Name of the SSH Key"
  type        = string
  default     = "mac-14-ssh-key"
}

variable "VM_name" {
  description = "name of the instance"
  type        = string
  default     = "spx7-Vm"
}

variable "VM_size" {
  description = "The size of the VM"
  type        = string
  default     = "g3.medium"
}

variable "initial_user" {
  description = "The default user"
  type        = string
  default     = "root"
}

variable "network-k8s" {
  description = "This is K8s-network"
  type        = string
  default     = "sp7x-net"
}

variable "firewall-k8s" {
  description = "The k8s Firewall"
  type        = string
  default     = "sp7x-firewall"
}
