# cloudflare-dns.tf | Define cloudflare provider and create DNS records

# Define Cloudflare provider
provider "cloudflare" {
  version = "~> 2.0"
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

# Create www record for Amazon Web Services
resource "cloudflare_record" "aws-www" {
  zone_id    = var.cloudflare_zone_id
  name       = "www"
  value      = aws_eip.aws-web-eip.public_ip
  type       = "A"
  proxied    = true
  depends_on = [aws_eip.aws-web-eip]
}

# Create www record for Azure
resource "cloudflare_record" "azure-www" {
  zone_id    = var.cloudflare_zone_id
  name       = "www"
  value      = azurerm_public_ip.azure-web-ip.ip_address
  type       = "A"
  proxied    = true
  depends_on = [azurerm_public_ip.azure-web-ip]
}

# Create www record for Google Cloud
resource "cloudflare_record" "gcp-www" {
  zone_id    = var.cloudflare_zone_id
  name       = "www"
  value      = google_compute_address.gcp-web-ip.address
  type       = "A"
  proxied    = true
  depends_on = [google_compute_address.gcp-web-ip]
}

# Create root record for Amazon Web Services
resource "cloudflare_record" "aws-root" {
  zone_id    = var.cloudflare_zone_id
  name       = "@"
  value      = aws_eip.aws-web-eip.public_ip
  type       = "A"
  proxied    = true
  depends_on = [aws_eip.aws-web-eip]
}

# Create root record for Azure
resource "cloudflare_record" "azure-root" {
  zone_id    = var.cloudflare_zone_id
  name       = "@"
  value      = azurerm_public_ip.azure-web-ip.ip_address
  type       = "A"
  proxied    = true
  depends_on = [azurerm_public_ip.azure-web-ip]
}

# Create root record for Google Cloud
resource "cloudflare_record" "gcp-root" {
  zone_id    = var.cloudflare_zone_id
  name       = "@"
  value      = google_compute_address.gcp-web-ip.address
  type       = "A"
  proxied    = true
  depends_on = [google_compute_address.gcp-web-ip]
}

# Output AWS
output "cloudflare-aws-www-record-id" {
  value = cloudflare_record.aws-www.id
}

output "cloudflare-aws-www-record-hostname" {
  value = cloudflare_record.aws-www.hostname
}

output "cloudflare-aws-root-record-id" {
  value = cloudflare_record.aws-root.id
}

output "cloudflare-aws-root-record-hostname" {
  value = cloudflare_record.aws-root.hostname
}

# Output Azure
output "cloudflare-azure-www-record-id" {
  value = cloudflare_record.azure-www.id
}

output "cloudflare-azure-www-record-hostname" {
  value = cloudflare_record.azure-www.hostname
}

output "cloudflare-azure-root-record-id" {
  value = cloudflare_record.azure-root.id
}

output "cloudflare-azure-root-record-hostname" {
  value = cloudflare_record.azure-root.hostname
}

# Output GCP
output "cloudflare-gcp-www-record-id" {
  value = cloudflare_record.gcp-www.id
}

output "cloudflare-gcp-www-record-hostname" {
  value = cloudflare_record.gcp-www.hostname
}

output "cloudflare-gcp-root-record-id" {
  value = cloudflare_record.gcp-root.id
}

output "cloudflare-gcp-root-record-hostname" {
  value = cloudflare_record.gcp-root.hostname
}
