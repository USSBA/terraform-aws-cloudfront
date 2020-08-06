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
  type = object({
    acm_certificate_arn      = string
    iam_certificate_id       = string
    minimum_protocol_version = string
    ssl_support_method       = string
  })
}
variable "custom_origins" {
  type = list(object({
    domain_name              = string
    origin_id                = string
    origin_protocol_policy   = string
    origin_ssl_protocols     = list(string)
    origin_keepalive_timeout = number
    origin_read_timeout      = number
    http_port                = number
    https_port               = number
    custom_headers           = list(any)
  }))
  default = []
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
  type = object({
    allowed_methods                = list(string)
    cached_methods                 = list(string)
    origin_id                      = string
    default_ttl                    = number
    min_ttl                        = number
    max_ttl                        = number
    viewer_protocol_policy         = string
    forward_cookies                = string
    forward_cookies_whitelist      = list(string)
    forward_headers                = list(string)
    forward_querystring            = bool
    forward_querystring_cache_keys = list(string)
    lambda_function_association    = list(any)
  })
}
variable "cache_behaviors" {
  type = list(object({
    path_pattern                   = string
    allowed_methods                = list(string)
    cached_methods                 = list(string)
    origin_id                      = string
    default_ttl                    = number
    min_ttl                        = number
    max_ttl                        = number
    viewer_protocol_policy         = string
    forward_cookies                = string
    forward_cookies_whitelist      = list(string)
    forward_headers                = list(string)
    forward_querystring            = bool
    forward_querystring_cache_keys = list(string)
    lambda_function_association    = list(any)
  }))
  default = []
}

variable "default_root_object" {
  type    = string
  default = null
}
