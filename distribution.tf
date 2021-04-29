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
      minimum_protocol_version       = try(x.value.minimum_protocol_version, "TLSv1.2_2018")
      ssl_support_method             = try(x.value.ssl_support_method, "sni-only")
      cloudfront_default_certificate = false
    }
  }

  # configuration for IAM certificates
  dynamic "viewer_certificate" {
    iterator = x
    for_each = local.use_iam_certificate ? [var.viewer_certificate] : []
    content {
      iam_certificate_id             = x.value.iam_certificate_id
      minimum_protocol_version       = try(x.value.minimum_protocol_version, "TLSv1.2_2018")
      ssl_support_method             = try(x.value.ssl_support_method, "sni-only")
      cloudfront_default_certificate = false
    }
  }

  # use the default cloudfront certificate when ACM and IAM is not configured
  dynamic "viewer_certificate" {
    iterator = x
    for_each = !local.use_iam_certificate && !local.use_acm_certificate ? [true] : []
    #for_each = length(var.viewer_certificate.iam_certificate_id) > 0 || length(var.viewer_certificate.acm_certificate_arn) > 0 ? [] : [true]
    content {
      minimum_protocol_version       = "TLSv1" # Only TLSv1 is compatible with default certificate
      cloudfront_default_certificate = true
    }
  }


  dynamic "origin" {
    iterator = x
    for_each = var.custom_origins
    content {
      domain_name = x.value.domain_name
      origin_id   = x.value.origin_id
      origin_path = try(x.value.origin_path, null)
      dynamic "custom_header" {
        iterator = y
        for_each = x.value.custom_headers
        content {
          name  = y.value.name
          value = y.value.value
        }
      }
      custom_origin_config {
        origin_protocol_policy   = try(x.value.origin_protocol_policy, "match-viewer")
        origin_ssl_protocols     = try(x.value.origin_ssl_protocols, ["TLSv1.1", "TLSv1.2"])
        origin_keepalive_timeout = try(x.value.origin_keepalive_timeout, 60)
        origin_read_timeout      = try(x.value.origin_read_timeout, 60)
        http_port                = try(x.value.http_port, 80)
        https_port               = try(x.value.https_port, 443)
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
          origin_access_identity = nonsensitive(y.value)
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = try(var.default_cache_behavior.allowed_methods, ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
    cached_methods         = try(var.default_cache_behavior.cached_methods, ["GET", "HEAD"])
    target_origin_id       = var.default_cache_behavior.origin_id
    default_ttl            = try(var.default_cache_behavior.default_ttl, 86400)
    min_ttl                = try(var.default_cache_behavior.min_ttl, 0)
    max_ttl                = try(var.default_cache_behavior.max_ttl, 31536000)
    viewer_protocol_policy = try(var.default_cache_behavior.viewer_protocol_policy, "redirect-to-https")

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
      target_origin_id       = x.value.origin_id
      allowed_methods        = try(x.value.allowed_methods, ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      cached_methods         = try(x.value.cached_methods, ["GET", "HEAD"])
      min_ttl                = try(x.value.min_ttl, 0)
      default_ttl            = try(x.value.default_ttl, 86400)
      max_ttl                = try(x.value.max_ttl, 31536000)
      viewer_protocol_policy = try(x.value.viewer_protocol_policy, "redirect-to-https")
      compress               = try(x.value.compress, "false")

      forwarded_values {
        cookies {
          forward           = try(x.value.forward_cookies, "none")
          whitelisted_names = try(x.value.forward_cookies_whitelist, null)
        }
        headers                 = try(x.value.forward_headers, null)
        query_string            = try(x.value.forward_querystring, true)
        query_string_cache_keys = try(x.value.forward_querystring_cache_keys, null)
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
