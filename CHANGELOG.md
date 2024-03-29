# CHANGELOG

## Terraform 0.15

### v4.1.1

- Fixing cloudfront function parameters from `lambda_arn` to `function_arn`

### v4.1.0

- Adding CloudFront function capability.

### v4.0.2

- **REVERT v4.0.0**: The sensitivity of a variable should be resolved before module instantiation

### v4.0.1

- The required version constraint allows >= 0.13

### v4.0.0

- The OAI id will no longer be reguarded as a sensitive value

## Terraform 0.13

### v3.1.0

- Removing the strict typing on variables to allow for sane defaults.
  This should not impact any existing users, but would make for much simpler
  distribution config.

### v3.0.0

- **BREAKING CHANGE**: Adding configurable property: cached_behaviors[].compress
- Adding configurable fields: comment, http_version, tags

### v2.1.1

- Bump aws provider to support 3.*

### v2.1.0

- Adding S3 Origins
- Adding default_root_object
- Adding lambda at edge associations
- Updating some default variable values

### v2.0.0

- Terraform v0.13 Upgrade

## Terraform 0.12

### v1.1.0

- Adding S3 Origins
- Adding default_root_object
- Adding lambda at edge associations
- Updating some default variable values

### v1.0.0

- Initial Release
