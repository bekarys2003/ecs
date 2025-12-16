output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "integrations_api_url" {
  value = module.integrations_api.api_endpoint
}
