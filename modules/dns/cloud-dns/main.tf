resource "google_dns_managed_zone" "dns_zone" {
  name        = "dns-zone-${var.domain_name}"
  dns_name    = var.domain_name
  description = "Managed DNS zone for ${var.domain_name}."
  project     = var.project_id
  force_destroy = true
}

resource "google_dns_record_set" "dns_records" {
  count = length(var.dns_records)
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = var.dns_records[count.index].name
  type         = var.dns_records[count.index].type
  ttl          = var.dns_records[count.index].ttl
  rrdatas      = var.dns_records[count.index].rrdatas
}