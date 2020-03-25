# terraform import module.oda.aws_cloudfront_distribution.distribution E23GKFXVZMJP10
locals {
  origin_id = "dlap-prod-cloudfront"
  viewer_protocol_policy = "redirect-to-https"
}
module "oda" {
  source = "../"
  enabled = true
  ipv6_enabled = true
  price_class = "PriceClass_100"
  aliases = ["disasterloan.sba.gov"]
  waf_id = ""
  logging_enabled = true
  logging_config = {
    bucket = "oda-dlap-prod-cloudfront-logs"
    prefix = "prod-cloudfront/"
    include_cookies = false
  }
  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:191171412319:certificate/23fd9ba5-cc4c-447a-ae99-44a415e44909"
    iam_certificate_id = ""
    minimum_protocol_version = "TLSv1.2_2018"
  }
  custom_origins = [
    {
      domain_name = "www.disasterloan.sba.gov"
      origin_id = local.origin_id
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout = 180
      http_port = 80
      https_port = 443
    }
  ]
  geo_restriction = {
    type = "none"
    locations = []
  }
  default_cache_behavior = {
    allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    cached_methods = ["GET","HEAD"]
    origin_id = local.origin_id
    default_ttl = 0
    min_ttl = 0
    max_ttl = 0
    viewer_protocol_policy = local.viewer_protocol_policy
    forward_cookies = "all"
    forward_cookies_whitelist = []
    forward_headers = ["*"]
    forward_querystring = true
    forward_querystring_cache_keys = []
  }
  cache_behaviors = [
    #{
    #  path_pattern = "/ela/Information/*"
    #  allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    #  cached_methods = ["GET","HEAD"]
    #  origin_id = local.origin_id
    #  default_ttl = 3600
    #  min_ttl = 900
    #  max_ttl = 3600
    #  viewer_protocol_policy = local.viewer_protocol_policy
    #  forward_cookies = "whitelist"
    #  forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
    #  forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
    #  forward_querystring = true
    #  forward_querystring_cache_keys = []
    #},
    #{
    #  path_pattern = "/ela/Documents/*"
    #  allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    #  cached_methods = ["GET","HEAD"]
    #  origin_id = local.origin_id
    #  default_ttl = 3600
    #  min_ttl = 900
    #  max_ttl = 3600
    #  viewer_protocol_policy = local.viewer_protocol_policy
    #  forward_cookies = "whitelist"
    #  forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
    #  forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
    #  forward_querystring = true
    #  forward_querystring_cache_keys = []
    #},
    #{
    #  path_pattern = "/ela/Declarations/DeclarationDetails"
    #  allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    #  cached_methods = ["GET","HEAD"]
    #  origin_id = local.origin_id
    #  default_ttl = 3600
    #  min_ttl = 900
    #  max_ttl = 3600
    #  viewer_protocol_policy = local.viewer_protocol_policy
    #  forward_cookies = "whitelist"
    #  forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
    #  forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
    #  forward_querystring = true
    #  forward_querystring_cache_keys = []
    #},
    #{
    #  path_pattern = "/ela/Declarations/ViewDisasterDocument/*"
    #  allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    #  cached_methods = ["GET","HEAD"]
    #  origin_id = local.origin_id
    #  default_ttl = 3600
    #  min_ttl = 900
    #  max_ttl = 3600
    #  viewer_protocol_policy = local.viewer_protocol_policy
    #  forward_cookies = "whitelist"
    #  forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
    #  forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
    #  forward_querystring = true
    #  forward_querystring_cache_keys = []
    #},
    {
      path_pattern = "/ela/Declarations/*"
      allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
      cached_methods = ["GET","HEAD"]
      origin_id = local.origin_id
      default_ttl = 3600
      min_ttl = 900
      max_ttl = 3600
      viewer_protocol_policy = local.viewer_protocol_policy
      forward_cookies = "whitelist"
      forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
      forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
      forward_querystring = true
      forward_querystring_cache_keys = []
    },
    #{
    #  path_pattern = "/ela/Home/*"
    #  allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    #  cached_methods = ["GET","HEAD"]
    #  origin_id = local.origin_id
    #  default_ttl = 3600
    #  min_ttl = 900
    #  max_ttl = 3600
    #  viewer_protocol_policy = local.viewer_protocol_policy
    #  forward_cookies = "whitelist"
    #  forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
    #  forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
    #  forward_querystring = true
    #  forward_querystring_cache_keys = []
    #},
    {
      path_pattern = "/ela/Content/*"
      allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
      cached_methods = ["GET","HEAD"]
      origin_id = local.origin_id
      default_ttl = 3600
      min_ttl = 900
      max_ttl = 3600
      viewer_protocol_policy = local.viewer_protocol_policy
      forward_cookies = "whitelist"
      forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
      forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
      forward_querystring = true
      forward_querystring_cache_keys = []
    },
    {
      path_pattern = "/ela/bundles/*"
      allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
      cached_methods = ["GET","HEAD"]
      origin_id = local.origin_id
      default_ttl = 3600
      min_ttl = 900
      max_ttl = 3600
      viewer_protocol_policy = local.viewer_protocol_policy
      forward_cookies = "none"
      forward_cookies_whitelist = []
      forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
      forward_querystring = true
      forward_querystring_cache_keys = []
    },
    {
      path_pattern = "/ela"
      allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
      cached_methods = ["GET","HEAD"]
      origin_id = local.origin_id
      default_ttl = 3600
      min_ttl = 900
      max_ttl = 3600
      viewer_protocol_policy = local.viewer_protocol_policy
      forward_cookies = "whitelist"
      forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
      forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
      forward_querystring = true
      forward_querystring_cache_keys = []
    },
    {
      path_pattern = "/ela/"
      allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
      cached_methods = ["GET","HEAD"]
      origin_id = local.origin_id
      default_ttl = 3600
      min_ttl = 900
      max_ttl = 3600
      viewer_protocol_policy = local.viewer_protocol_policy
      forward_cookies = "whitelist"
      forward_cookies_whitelist = [".AspNet.ApplicationCookie"]
      forward_headers = ["Accept","Accept-Encoding","Accept-Language","Host"]
      forward_querystring = true
      forward_querystring_cache_keys = []
    },
  ]
}
