output "export_kubeconfig"{
    value = "az aks get-credentials -n akssenfi -g akssenfi --file kubeconfig"
    depends_on = [
        azurerm_kubernetes_cluster.akssenfi,
    ]
}

output "acr_login_server" {
    value = azurerm_container_registry.acrsenfi.login_server
}

output "acr_admin_username" {
    value = azurerm_container_registry.acrsenfi.admin_username
}

output "acr_admin_password" {
    value = azurerm_container_registry.acrsenfi.admin_password
    sensitive = true
}

output "senfivm1_public_ip" {
    value = azurerm_linux_virtual_machine.senfivm1.public_ip_address
}

output "senfivm1_admin_ssh_key" {
    value = azurerm_linux_virtual_machine.senfivm1.admin_ssh_key
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.akssenfi.kube_config_raw
    sensitive = true
}

output "cluster_ca_certificate" {
    value = azurerm_kubernetes_cluster.akssenfi.kube_config.0.cluster_ca_certificate
    sensitive = true
}

#output "client_certificate" {
#    value = azurerm_kubernetes_cluster.akssenfi.0.client_certificate
#}

output "client_key" {
    value = azurerm_kubernetes_cluster.akssenfi.kube_config.0.client_key
    sensitive = true
}

output "host" {
    value = azurerm_kubernetes_cluster.akssenfi.kube_config.0.host
    sensitive = true
}
