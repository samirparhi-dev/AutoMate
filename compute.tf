# Create a new instance
resource "civo_instance" "Civo_Compute" {
    hostname = var.VM_name
    tags = ["build", "k8s"]
    notes = "This is a K8s Build Server"
    size = var.VM_size
    firewall_id = data.civo_firewall.get_firewall_k8s.id
    network_id = data.civo_network.get_network_k8s.id
    disk_image = "debian-11"
    sshkey_id = data.civo_ssh_key.get_ssh_key.id
    initial_user =var.initial_user
    script = file("./boostrap-container.sh")
    region = var.region

}
