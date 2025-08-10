
# FortiCNAPP OPAL Lab

This repository provides a comprehensive hands-on lab for FortiCNAPP's OPAL (Open Policy Agent Language) policy engine integration. Learn how to develop, test, and deploy custom Infrastructure as Code (IaC) security policies using OPA Rego with FortiCNAPP's security scanning platform.

## 🎯 Learning Objectives

- Understand FortiCNAPP OPAL policy development workflow
- Learn OPA Rego policy syntax and best practices
- Master test-driven policy development with pass/fail scenarios
- Practice policy deployment and validation in real environments

## 📦 What's Included

This lab contains a complete policy development example:

- **`metadata.yaml`**: Policy classification and configuration
- **`policy.rego`**: OPA Rego policy logic for AWS S3 bucket logging validation
- **`tests/pass/main.tf`**: Compliant Terraform configuration (should pass policy)
- **`tests/fail/main.tf`**: Non-compliant Terraform configuration (should fail policy)

### Policy Structure
```
policies/opal/sample_custom_policy/
├── metadata.yaml           # Policy metadata and classification
├── terraform/
│   ├── policy.rego        # OPA Rego policy implementation
│   └── tests/
│       ├── pass/main.tf   # Compliant test case
│       └── fail/main.tf   # Non-compliant test case
```

---

## ⚙️ Prerequisites

- [FortiCNAPP (Lacework) CLI](https://docs.fortinet.com/document/lacework-forticnapp/latest/cli-reference/68020/get-started-with-the-lacework-forticnapp-cli)
- Terraform CLI
- Unix-like shell (macOS/Linux or WSL)
- FortiCNAPP API Key & Secret

---

## 🔧 Installation & Configuration

### 1. Install the FortiCNAPP CLI

#### Bash (macOS/Linux)

```bash
curl https://raw.githubusercontent.com/lacework/go-sdk/main/cli/install.sh | bash
```

#### Powershell (Windows)

```bash
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/lacework/go-sdk/main/cli/install.ps1'))
```

#### Homebrew (macOS/Linux)

```bash
brew install lacework/tap/lacework-cli
```

#### Chocolatey (Windows)

```bash
choco install lacework-cli
```

---

### 2. Create API Key

The FortiCNAPP CLI requires an API key and secret to authenticate.

1. Log in to the **FortiCNAPP Console**
2. Navigate to **Settings > API keys**
3. Click **Add New**
4. Provide a name and optional description
5. Click **Save**
6. Click the **⋯ (more)** icon and select **Download**

This downloads a JSON file like:

```json
{
  "keyId": "ACCOUNT_ABCDEF01234559B9B07114E834D8570F567C824039756E03",
  "secret": "_abc1234e243a645bcf173ef55b837c19",
  "subAccount": "myaccount",
  "account": "myaccount.lacework.net"
}
```

---

### 3. Configure the CLI

You can configure using the interactive prompt:

```bash
lacework configure
```

Or with the downloaded API key file:

```bash
lacework configure -j /path/to/key.json
```

Example output:

```text
Account: example
Access Key ID: EXAMPLE_1234567890ABCDE1EXAMPLE1EXAMPLE123456789EXAMPLE
Secret Access Key: **********************************
You are all set!
```

The configuration is stored at:

```text
$HOME/.lacework.toml
```

**To configure the Lacework FortiCNAPP CLI for IaC Security:**
1. Run `lacework component install iac` in the Lacework FortiCNAPP CLI.
2. The Lacework FortiCNAPP CLI is now configured for IaC. You can now run `lacework iac ....`

---

## 🚀 Running the Lab

### 1. Navigate to the Policies Directory

```bash
cd policies
```

### 2. Test the Sample Policy

Run the policy test to validate both compliant and non-compliant configurations:

```bash
lacework iac policy test -d opal/sample_custom_policy
```

**Expected Output:**
- ✅ `tests/pass/main.tf` should PASS (S3 bucket has correct logging configuration)
- ❌ `tests/fail/main.tf` should FAIL (S3 bucket has incorrect logging configuration)

### 3. Understanding the Results

The test validates the policy logic:
- **Pass Test**: S3 bucket with `target_bucket = "example"` meets policy requirements
- **Fail Test**: S3 bucket with `target_bucket = "bad-example"` violates policy requirements

This demonstrates the deny-by-default security model where only explicitly allowed configurations pass validation.

---

## 🧪 Advanced Exercises

### Exercise 1: Upload Policy to FortiCNAPP

Deploy your custom policy to the FortiCNAPP platform:

```bash
lacework iac policy upload -d .
```

This uploads all policies in the current directory to your FortiCNAPP account for use in security scans.

### Exercise 2: Scan Real Terraform Projects

Test your custom policies against actual Terraform projects:

```bash
lacework iac tf-scan opal --disable-custom-policies=false -d /path/to/terraform/project
```

**Tip**: Use `--disable-custom-policies=false` to include your uploaded custom policies alongside FortiCNAPP's built-in policy set.

### Exercise 3: Modify the Policy

Try extending the sample policy:

1. **Edit** `policies/opal/sample_custom_policy/terraform/policy.rego`
2. **Modify** the logic to accept multiple valid bucket names
3. **Update** test cases to validate your changes
4. **Run** `lacework iac policy test -d opal/sample_custom_policy` to verify

**Example Enhancement:**
```rego
# Allow multiple target buckets
allowed_buckets := {"example", "logs", "audit-logs"}

allow {
  input.logging[i].target_bucket in allowed_buckets
}
```

---

## 🔍 Understanding the Policy Components

### Metadata Configuration (`metadata.yaml`)
```yaml
checkTool: opal                    # Policy engine type
checkType: terraform               # Infrastructure type
provider: aws                      # Cloud provider
resourceType: aws_s3_bucket        # Specific resource to check
category: logging                  # Security category
severity: medium                   # Risk level
title: "Sample Custom Policy"      # Display name
description: "Example policy..."   # Description
```

### Policy Logic (`policy.rego`)
```rego
package policies.sample_custom_policy

input_type := "tf"                 # Terraform input
resource_type := "aws_s3_bucket"   # Target resource
default allow = false              # Deny by default (security best practice)

allow {
  input.logging[i].target_bucket == "example"  # Allow only specific configuration
}
```

---

## 📚 Learning Resources

### Policy Development Best Practices
- **Deny by Default**: Start with `default allow = false` for security
- **Specific Targeting**: Use `resource_type` to limit policy scope
- **Test-Driven**: Write test cases before implementing policy logic
- **Clear Documentation**: Use meaningful titles and descriptions in metadata

### OPA Rego Resources
- [OPA Rego Language Reference](https://www.openpolicyagent.org/docs/latest/policy-language/)
- [Rego Built-in Functions](https://www.openpolicyagent.org/docs/latest/policy-reference/)
- [FortiCNAPP Policy Documentation](https://docs.fortinet.com/product/lacework-forticnapp)

---

## 🛠️ Troubleshooting

### Common Issues

**Policy Test Failures:**
- Verify file structure matches expected layout
- Check Rego syntax with proper indentation
- Ensure test Terraform files are valid

**CLI Authentication:**
- Verify `~/.lacework.toml` configuration
- Check API key permissions in FortiCNAPP console
- Run `lacework configure` to reconfigure if needed

**Debug Tips:**
- Use `print()` statements in Rego for debugging (remove before production)
- Test individual Terraform files with `terraform validate`
- Use `lacework iac policy test -v` for verbose output

---

## 📝 Notes

- **Policy Logic**: All policy rules are defined in `policy.rego` using OPA Rego syntax
- **Debugging**: Use `print()` statements for development debugging, but remove before production deployment
- **Version Compatibility**: OPAL v0.3.5+ recommended for full print statement output support
- **Security Model**: Policies implement deny-by-default with explicit allow conditions
