resource "aws_cloudfront_distribution" "distribution" {
  # required - wheather or not the distibution is active
  enabled = var.enabled

  # only creates a logging configuration when logging_enabled is true
  dynamic "logging_config" {
    iterator = x
    for_each = var.logging_enabled ? [var.logging_config] : []
    content {
      bucket          = "${x.bucket_name}.s3.amazonaws.com"
      include_cookies = x.include_cookies
      prefix          = x.prefix
    }
  }

  # configuration for ACM certificate
  dynamic "viewer_certificate" {
    iterator = x
    for_each = length(var.viewer_certificate.acm_certificate_arn) > 0 ? [var.viewer_certificate] : []
    content {
      acm_certificate_arn            = x.acm_certificate_arn
      minimum_protocol_version       = x.minimum_protocol_version
      ssl_support_method             = "sni-only"
      cloudfront_default_certificate = false
    }
  }

  # configuration for IAM certificates
  dynamic "viewer_certificate" {
    iterator = x
    for_each = length(var.viewer_certificate.iam_certificate_id) > 0 ? [var.viewer_certificate] : []
    content {
      iam_certificate_id             = x.iam_certificate_id
      minimum_protocol_version       = x.minimum_protocol_version
      ssl_support_method             = "sni-only"
      cloudfront_default_certificate = false
    }
  }

  # use the default cloudfront certificate when ACM and IAM is not configured
  dynamic "viewer_certificate" {
    iterator = x
    for_each = length(var.viewer_certificate.iam_certificate_id) > 0 && length(var.viewer_certificate.acm_certificate_arn) > 0 ? [] : [true]
    content {
      minimum_protocol_version       = var.viewer_certificate_config.minimum_protocol_version
      cloudfront_default_certificate = true
    }
  }


  dynamic "origin" {
    iterator = x
    for_each = var.origins
    content {
      domain_name = x.domain_name
      origin_id   = x.origin_id
    }
  }

  default_cache_behavior {
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    target_origin_id       = var.default_cache_behavior.origin_id
    default_ttl            = var.default_cache_behavior.default_ttl
    min_ttl                = var.default_cache_behavior.min_ttl
    max_ttl                = var.default_cache_behavior.max_ttl
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy

    forwarded_values {
      cookies {
        forward           = var.default_cache_behavior.forward_cookies
        whitelisted_names = length(var.default_cache_behavior.forward_cookies_whitelist) == 0 ? null : var.default_cache_behavior.forward_cookies_whitelist
      }
      headers                 = var.default_cache_behavior.forward_headers
      query_string            = var.default_cache_behavior.forward_querystring
      query_string_cache_keys = length(var.default_cache_behavior.forward_querystring_cache_keys) == 0 ? null : var.default_cache_behavior.forward_querystring_cache_keys
    }
  }


  dynamic "ordered_cache_behavior" {
    iterator = x
    for_each = var.cache_behaviors
    content {
      path_pattern           = x.path_pattern
      allowed_methods        = x.allowed_methods
      cached_methods         = x.cached_methods
      target_origin_id       = x.origin_id
      default_ttl            = x.default_ttl
      min_ttl                = x.min_ttl
      max_ttl                = x.max_ttl
      viewer_protocol_policy = x.viewer_protocol_policy

      forwarded_values {
        cookies {
          forward           = x.forward_cookies
          whitelisted_names = length(x.forward_cookies_whitelist) == 0 ? null : x.forward_cookies_whitelist
        }
        headers                 = x.forward_headers
        query_string            = x.forward_querystring
        query_string_cache_keys = length(x.forward_querystring_cache_keys) == 0 ? null : x.forward_querystring_cache_keys
      }
    }
  }
}
