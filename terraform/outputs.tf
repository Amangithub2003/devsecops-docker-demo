output "app_host_public_ip" {
  value = aws_instance.app_host.public_ip
}

output "app_url" {
  value = "http://${aws_instance.app_host.public_ip}:8080"
}

output "grafana_url" {
  value = "http://${aws_instance.app_host.public_ip}:3000"
}

output "kibana_url" {
  value = "http://${aws_instance.app_host.public_ip}:5601"
}
