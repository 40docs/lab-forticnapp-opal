# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **lab-forticnapp-opal** repository - a hands-on lab for FortiCNAPP's OPAL policy engine integration. It demonstrates security policy development, testing, and validation using OPA (Open Policy Agent) Rego policies for Infrastructure as Code security scanning.

## Common Development Commands

### FortiCNAPP CLI Setup
```bash
# Install FortiCNAPP CLI (choose one method)
curl https://raw.githubusercontent.com/lacework/go-sdk/main/cli/install.sh | bash  # Bash
brew install lacework/tap/lacework-cli                                            # Homebrew

# Configure CLI with API credentials
lacework configure                    # Interactive setup
lacework configure -j /path/to/key.json  # Using downloaded API key file

# Install IaC Security component
lacework component install iac
```

### Policy Development & Testing
```bash
# Test policy against pass/fail cases
lacework iac policy test -d opal/sample_custom_policy

# Upload policy set to FortiCNAPP
lacework iac policy upload -d .

# Run OPAL scan on Terraform project with custom policies
lacework iac tf-scan opal --disable-custom-policies=false -d /path/to/project
```

### Lab Workflow
```bash
# Standard lab execution from policies/ directory
cd policies
lacework iac policy test -d opal/sample_custom_policy
```

## Architecture and Structure

### Policy Framework Architecture
- **OPAL Integration**: Open Policy Agent (OPA) Rego policies for Infrastructure as Code security
- **Policy Structure**: Hierarchical organization under `policies/opal/`
- **Test-Driven Development**: Pass/fail test cases validate policy logic
- **Metadata-Driven**: YAML metadata defines policy characteristics

### Repository Structure
```
policies/opal/sample_custom_policy/
├── metadata.yaml           # Policy metadata (severity, category, description)
├── terraform/
│   ├── policy.rego        # OPA Rego policy logic
│   └── tests/
│       ├── pass/main.tf   # Terraform config that should pass policy
│       └── fail/main.tf   # Terraform config that should fail policy
```

### Policy Development Pattern
1. **metadata.yaml**: Defines policy metadata including `checkTool: opal`, `checkType: terraform`, target resource type, severity, and description
2. **policy.rego**: Contains OPA Rego logic with `input_type`, `resource_type`, and policy rules
3. **Test Cases**: Pass/fail Terraform configurations validate policy behavior

### Key Policy Components
- **Package Declaration**: `package policies.sample_custom_policy`
- **Input Constraints**: `input_type := "tf"` and `resource_type := "aws_s3_bucket"`
- **Default Behavior**: `default allow = false` (deny by default)
- **Policy Logic**: Rego rules that define compliance conditions

## Security Policy Guidelines

### Policy Development Standards
- Use descriptive package names following `policies.{policy_name}` convention
- Implement deny-by-default security model (`default allow = false`)
- Include comprehensive test cases covering both compliant and non-compliant configurations
- Avoid debug `print()` statements in production policies

### Testing Requirements
- Every policy must include both passing and failing test cases
- Test cases should use realistic Terraform resource configurations
- Policy logic should be tested against edge cases and common misconfigurations

### Metadata Standards
- Required fields: `checkTool`, `checkType`, `provider`, `resourceType`, `category`, `severity`, `title`, `description`
- Severity levels: `low`, `medium`, `high`, `critical`
- Categories align with security frameworks (e.g., `logging`, `encryption`, `access_control`)

## Configuration Files

### API Authentication
- **Location**: `$HOME/.lacework.toml`
- **Structure**: Contains account, access key, and secret for FortiCNAPP API access
- **Security**: Never commit credentials to repository

### Policy Metadata Schema
```yaml
checkTool: opal                    # Policy engine (always 'opal')
checkType: terraform               # IaC type being scanned
provider: aws                      # Cloud provider
resourceType: aws_s3_bucket        # Specific resource type
category: logging                  # Security category
severity: medium                   # Risk level
title: "Sample Custom Policy"      # Human-readable policy name
description: "Policy description"   # Detailed explanation
```

## Important Guidelines

### Security-First Development
- All policies implement security-by-default principles
- Test cases must demonstrate both secure and insecure configurations
- Policy logic should be readable and maintainable for security audits

### OPAL Policy Best Practices
- Use specific resource targeting (`resource_type`) for performance
- Implement clear policy logic that security teams can understand
- Include meaningful error messages when policies fail
- Test policies against real-world Terraform configurations

### Lab Environment Standards
- Follow Markdown standards for documentation clarity
- Include clear instructions and expected results in lab guides
- Reference OPAL and Fortinet best practices in examples
- Never include lab credentials or sensitive data in repository