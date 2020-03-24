variable "enabled" {
  type    = bool
  default = true
}
variable "logging_enabled" {
  type    = bool
  default = false
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
  })
}
variable "origins" {
  type = object({
    domain_name = string
    origin_id   = string
  })
}
variable "geo_restriction" {
  type = object({
    type      = string
    locations = list(string)
  })
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
  }))
}
