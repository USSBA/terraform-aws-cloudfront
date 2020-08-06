# Terraform CloudFront Module

In creating numerous CloudFront distributions across our projects, we found the native aws_cloudfront_distribution
resource to be a bit boilerplate heavy.  This led us to making a wrapper for it that attempts to simplify the resource
and make configuration a bit more readable.

## Example Usage

```
module "my_cloudfront" {
  source = "USSBA/terraform-aws-cloudfront"
  ## For Terraform 0.12
  version = "~> 1.0"
  ## For Terraform 0.13
  #version = "~> 2.0"

  enabled = true
  ipv6_enabled = true
  price_class = "PriceClass_100"
  aliases = ["my_domain.example.com"]
  waf_id = "8b633f9-8b63-8b63-8b63-8b633f9f837"

  default_root_object = "index.html"

  logging_enabled = true
  logging_config  = {
    bucket = "my-cloudfront-logs"
    prefix = "my_cloudfront/"
    include_cookies = true
  }

  # TLS Configuration
  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-90ab-cdef-1234-567890abcdef"
    iam_certificate_id = ""
    minimum_protocol_version = "TLSv1.2_2018" # Can only be set if cloudfront_default_certificate = false. One of SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016 or TLSv1.2_2018
    ssl_support_method = "sni-only" # One of vip or sni-only, should probably be sni-only unless you have a good reason
  }

  # Custom origin configuration, such as ALBs, Hostnames, etc
  custom_origins = [
    {
      domain_name = "example-com-alb-111111111.us-east-1.elb.amazonaws.com"
      origin_id = "example-alb"
      origin_protocol_policy = "https-only" # allow-all, https-only, redirect-to-https
      origin_ssl_protocols = ["TLSv1.2"] # SSLv3, TLSv1, TLSv1.1, and TLSv1.2
      origin_keepalive_timeout = 5
      origin_read_timeout = 180
      http_port = 80
      https_port = 443
      custom_headers = [
        {
          name  = "My-Custom-Header-Key",
          value = "my_custom_header_value"
        }
      ]
    }
  ]

  # S3-backed origins
  s3_origins = [
    {
      origin_id = "example_bucket_origin"
      domain_name            = aws_s3_bucket.example.bucket_regional_domain_name

      # Optional OAI
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    },
  ]

  # Optional: Geo Restriction
  geo_restriction = {
    type = "none"  # none, whitelist, blacklist
    locations = [] # List of 2-letter country codes
  }

  # Default behavior
  default_cache_behavior = {
    allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    cached_methods = ["GET","HEAD"]
    origin_id = "example-alb"
    default_ttl = 0
    min_ttl = 0
    max_ttl = 0
    viewer_protocol_policy = "redirect-to-https" # allow-all, https-only, redirect-to-https
    forward_cookies = "all"
    forward_cookies_whitelist = []
    forward_headers = ["*"]
    forward_querystring = true
    forward_querystring_cache_keys = []
  }

  # Ordered list of cache behaviors; top down precedence
  cache_behaviors = [
    {
      path_pattern = "/static/images/*"
      allowed_methods = ["GET","HEAD"]
      cached_methods = ["GET","HEAD"]
      origin_id = "example-alb"
      default_ttl = 900
      min_ttl = 900
      max_ttl = 900
      viewer_protocol_policy = "redirect-to-https"

      # Cookies
      forward_cookies = "none" # none, all, whitelist
      forward_cookies_whitelist = []

      # Headers
      forward_headers   = []                     # Forward/key on no headers
      # forward_headers = ["Host", "User-Agent"] # Forward/cache-key on "Host" and "User-Agent" headers
      # forward_headers = ["*"]                  # Forward/cache-key on all headers

      # Query String
      forward_querystring = true                             # Forward all querystring values
      forward_querystring_cache_keys = []                    # Cache key based on all querystring values
      # forward_querystring_cache_keys = ["my_version_hash"] # Cache key based on only 'my_version_hash' value
    },
    {
      path_pattern = "/static/scripts/*"
      allowed_methods = ["GET","HEAD"]
      cached_methods = ["GET","HEAD"]
      origin_id = "example-alb"
      default_ttl = 900
      min_ttl = 900
      max_ttl = 900
      viewer_protocol_policy = "redirect-to-https"
      forward_cookies = "none"
      forward_cookies_whitelist = []
      forward_headers = ["Host"]
      forward_querystring = true
      forward_querystring_cache_keys = ["version_hash"]
    },
  ]
}

```


## Variables


