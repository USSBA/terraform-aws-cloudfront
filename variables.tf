variable "enabled" {
  type    = bool
  default = true
}
variable "ipv6_enabled" {
  type    = bool
  default = false
}
variable "logging_enabled" {
  type    = bool
  default = false
}
variable "waf_id" {
  type    = string
  default = ""
}
variable "aliases" {
  type    = list(string)
  default = []
}
variable "logging_config" {
  type = object({
    bucket          = string
    prefix          = string
    include_cookies = bool
  })
}
variable "viewer_certificate" {
  type        = any
  description = "Viewer certificate map with fields: acm_certificate_arn, iam_certificate_id, minimum_protocol_version, ssl_support_method"
}
variable "custom_origins" {
  type        = any
  default     = []
  description = "List of custom origin maps"
}
variable "s3_origins" {
  type = list(object({
    domain_name            = string
    origin_id              = string
    origin_access_identity = string
  }))
  default = []
}
variable "geo_restriction" {
  type = object({
    type      = string
    locations = list(string)
  })
  default = {
    type      = "none"
    locations = []
  }
}
variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "default_cache_behavior" {
  type        = any
  description = "The default cache behavior"
}
variable "cache_behaviors" {
  type        = any
  default     = []
  description = "List of cache behavior maps"
}

variable "default_root_object" {
  type    = string
  default = null
}
variable "comment" {
  type        = string
  default     = null
  description = "Comment field for the distribution"
}
variable "http_version" {
  type        = string
  default     = null #terraform will default this to http2
  description = "http_version field for the distribution; options are http1.1, http2"
}
variable "tags" {
  default     = null
  description = "List of key-value pairs to assign to tags of the distribution"
}
