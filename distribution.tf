locals {
  use_acm_certificate = var.viewer_certificate.acm_certificate_arn != null && length(var.viewer_certificate.acm_certificate_arn) > 0
  use_iam_certificate = var.viewer_certificate.iam_certificate_id != null && length(var.viewer_certificate.iam_certificate_id) > 0
}
resource "aws_cloudfront_distribution" "distribution" {

  # wheather or not the distribution is enabled
  enabled = var.enabled

  # wheather or not IPV6 is enabled
  is_ipv6_enabled = var.ipv6_enabled

  # attach the WAF when an Id is given
  web_acl_id = length(var.waf_id) == 0 ? null : var.waf_id

  default_root_object = var.default_root_object

  comment      = var.comment
  http_version = var.http_version
  tags         = var.tags

  # wire in any aliases given
  aliases = var.aliases

  # country restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.type
      locations        = var.geo_restriction.locations
    }
  }

  # price class for the distribution
  price_class = var.price_class

  # only creates a logging configuration when logging_enabled is true
  dynamic "logging_config" {
    iterator = x
    for_each = var.logging_enabled ? [var.logging_config] : []
    content {
      bucket          = "${x.value.bucket}.s3.amazonaws.com"
      include_cookies = x.value.include_cookies
      prefix          = x.value.prefix
    }
  }

  # configuration for ACM certificate
  dynamic "viewer_certificate" {
    iterator = x
    for_each = local.use_acm_certificate ? [var.viewer_certificate] : []
    content {
      acm_certificate_arn            = x.value.acm_certificate_arn
      minimum_protocol_version       = x.value.minimum_protocol_version
      ssl_support_method             = x.value.ssl_support_method
      cloudfront_default_certificate = false
    }
  }

  # configuration for IAM certificates
  dynamic "viewer_certificate" {
    iterator = x
    for_each = local.use_iam_certificate ? [var.viewer_certificate] : []
    content {
      iam_certificate_id             = x.value.iam_certificate_id
      minimum_protocol_version       = x.value.minimum_protocol_version
      ssl_support_method             = x.value.ssl_support_method
      cloudfront_default_certificate = false
    }
  }

  # use the default cloudfront certificate when ACM and IAM is not configured
  dynamic "viewer_certificate" {
    iterator = x
    for_each = ! local.use_iam_certificate && ! local.use_acm_certificate ? [true] : []
    #for_each = length(var.viewer_certificate.iam_certificate_id) > 0 || length(var.viewer_certificate.acm_certificate_arn) > 0 ? [] : [true]
    content {
      minimum_protocol_version       = var.viewer_certificate.minimum_protocol_version
      cloudfront_default_certificate = true
    }
  }


  dynamic "origin" {
    iterator = x
    for_each = var.custom_origins
    content {
      domain_name = x.value.domain_name
      origin_id   = x.value.origin_id
      dynamic "custom_header" {
        iterator = y
        for_each = x.value.custom_headers
        content {
          name  = y.value.name
          value = y.value.value
        }
      }
      custom_origin_config {
        origin_protocol_policy   = x.value.origin_protocol_policy
        origin_ssl_protocols     = x.value.origin_ssl_protocols
        origin_keepalive_timeout = x.value.origin_keepalive_timeout
        origin_read_timeout      = x.value.origin_read_timeout
        http_port                = x.value.http_port
        https_port               = x.value.https_port
      }
    }
  }

  dynamic "origin" {
    iterator = x
    for_each = var.s3_origins
    content {
      domain_name = x.value.domain_name
      origin_id   = x.value.origin_id
      dynamic "s3_origin_config" {
        iterator = y
        for_each = x.value.origin_access_identity != null ? [x.value.origin_access_identity] : []
        content {
          origin_access_identity = y.value
        }
      }
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
    dynamic "lambda_function_association" {
      iterator = x
      for_each = var.default_cache_behavior.lambda_function_association
      content {
        event_type   = x.value.event_type
        lambda_arn   = x.value.lambda_arn
        include_body = x.value.include_body
      }
    }
  }


  dynamic "ordered_cache_behavior" {
    iterator = x
    for_each = var.cache_behaviors
    content {
      path_pattern           = x.value.path_pattern
      allowed_methods        = x.value.allowed_methods
      cached_methods         = x.value.cached_methods
      target_origin_id       = x.value.origin_id
      default_ttl            = x.value.default_ttl
      min_ttl                = x.value.min_ttl
      max_ttl                = x.value.max_ttl
      viewer_protocol_policy = x.value.viewer_protocol_policy
      compress               = x.value.compress

      forwarded_values {
        cookies {
          forward           = x.value.forward_cookies
          whitelisted_names = length(x.value.forward_cookies_whitelist) == 0 ? null : x.value.forward_cookies_whitelist
        }
        headers                 = x.value.forward_headers
        query_string            = x.value.forward_querystring
        query_string_cache_keys = length(x.value.forward_querystring_cache_keys) == 0 ? null : x.value.forward_querystring_cache_keys
      }
      dynamic "lambda_function_association" {
        iterator = y
        for_each = x.value.lambda_function_association
        content {
          event_type   = y.value.event_type
          lambda_arn   = y.value.lambda_arn
          include_body = y.value.include_body
        }
      }
    }
  }
}
