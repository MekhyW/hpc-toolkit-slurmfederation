variable "project_id" {
  description = "The ID of the Google Cloud project."
}

variable "domain_name" {
  description = "The domain name for which DNS configuration will be applied."
}

variable "dns_records" {
  description = "A list of DNS records to create."
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    rrdatas = list(string)
  }))
}