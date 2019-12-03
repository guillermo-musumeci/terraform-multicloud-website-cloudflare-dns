# cloudflare-variables.tf | Variables for the Cloudflare module

# Cloudflare email
variable "cloudflare_email" {
  type        = string
  description = "Cloudflare Email Address"
}

# Cloudflare API key
variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
}

# Cloudflare zone id
variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}
