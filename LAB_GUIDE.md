# FortiCNAPP OPAL Lab Guide: Beyond Spell-Check Security

## Introduction: The Security Gap

**Key Insight**: Standard IaC scanning is like spell-check - necessary but not sufficient. Your business needs security that understands YOUR requirements, not just generic best practices.

---

## Part 1: The Problem - When Standard Scanning Isn't Enough

### Scenario: Your Company's Requirements

Your organization has specific security requirements:
- Production web servers MUST use port 8443 (not 443) for HTTPS
- ALL production instances require an audit logging security group
- Development and production resources must NEVER share security groups
- Web servers need specific security groups based on their role

### Exercise 1: Run Standard IaC Scan

Let's examine infrastructure that looks secure to standard scanners:

```bash
# First, look at our "secure" infrastructure
cat terraform/looks_secure.tf

# Run standard IaC scan
lacework iac scan -d terraform/

# To see only the failures (pass = false):
lacework iac scan -d terraform/ 2>&1 | grep "false.*false"
```

**What You'll See:**
- ✅ Most checks PASS (shown as `pass = true`)
- ⚠️ Only 3 minor issues found:
  - S3 bucket missing cross-region replication (Medium)
  - S3 bucket missing access logging (Medium)
  - EC2 not EBS-optimized (Low)

**What's Actually Wrong (that standard scanning missed):**
- ❌ Production server missing required audit-logging security group
- ❌ Custom port 8443 not properly secured
- ❌ Web server using database security group
- ❌ Production instance sharing development security group

### The Gap

Standard scanners check for:
- Open ports to 0.0.0.0/0
- Missing encryption
- Default passwords
- Known CVEs

They DON'T check for:
- YOUR specific port requirements
- YOUR environment isolation rules
- YOUR role-based security requirements
- YOUR compliance needs

> 💡 **This is where OPAL changes the game**

---

## Part 2: The Solution - Custom Policies with OPAL

### What is OPAL?

OPAL (Open Policy Agent for Lacework) lets you write custom policies that understand YOUR business logic, not just generic security rules.

### Your First Custom Policy

Let's create a policy that enforces YOUR specific requirement: "All production instances must have the audit-logging-sg security group"

#### Step 1: Understand the Requirement

```rego
# What we're checking:
# IF instance.tags.Environment == "production"
# THEN instance.security_groups MUST include "audit-logging-sg"
```

#### Step 2: Create the Policy Structure

```bash
cd policies/opal
mkdir my_audit_policy
cd my_audit_policy

# Create metadata file
cat > metadata.yaml <<EOF
policy_id: "my-audit-requirement"
title: "Production Audit Logging Requirement"
severity: "High"
description: "All production instances must have audit logging security group"
resource_type: "aws_instance"
provider: "aws"
category: "Compliance"
EOF
```

#### Step 3: Write the Policy Logic

```bash
cat > policy.rego <<'EOF'
package policies.my_audit_policy

input_type := "tf"
resource_type := "aws_instance"
default allow = false

# Production instances must have audit-logging-sg
allow {
    # Check if this is a production instance
    input.tags.Environment == "production"

    # Check if audit-logging-sg is present
    has_audit_logging_sg
}

# Non-production instances don't need audit logging
allow {
    input.tags.Environment != "production"
}

# Helper to check for audit logging security group
has_audit_logging_sg {
    sg_ref := input.vpc_security_group_ids[_]
    contains(sg_ref, "audit_logging_sg")
}
EOF

# IMPORTANT: Copy policy to terraform directory for testing
cp policy.rego terraform/
```

---

## Part 3: The Critical Step - Unit Testing Your Policy

### Why Unit Testing Matters

**Common Mistake**: "My test passed, so my policy works!"

**Reality**: A passing test only proves your policy accepts good configurations. It doesn't prove it rejects bad ones!

### Creating Comprehensive Tests

#### Step 1: Create Test Structure

```bash
mkdir -p terraform/tests/{pass,fail}
```

#### Step 2: Create PASSING Test Cases

```bash
cat > terraform/tests/pass/compliant.tf <<'EOF'
# This SHOULD pass - production instance with audit logging
resource "aws_instance" "good_production" {
  ami           = "ami-12345"
  instance_type = "t3.micro"

  security_groups = [
    aws_security_group.web_sg.id,
    aws_security_group.audit_logging_sg.id  # Required for production
  ]

  tags = {
    Name        = "prod-web-01"
    Environment = "production"
  }
}

# This SHOULD pass - development instance without audit logging
resource "aws_instance" "good_development" {
  ami           = "ami-12345"
  instance_type = "t3.micro"

  security_groups = [
    aws_security_group.dev_sg.id  # No audit required for dev
  ]

  tags = {
    Name        = "dev-web-01"
    Environment = "development"
  }
}
EOF
```

#### Step 3: Create FAILING Test Cases (CRUCIAL!)

```bash
cat > terraform/tests/fail/violations.tf <<'EOF'
# This SHOULD fail - production instance WITHOUT audit logging
resource "aws_instance" "bad_production" {
  ami           = "ami-12345"
  instance_type = "t3.micro"

  security_groups = [
    aws_security_group.web_sg.id
    # MISSING: aws_security_group.audit_logging_sg.id
  ]

  tags = {
    Name        = "prod-web-02"
    Environment = "production"  # Production requires audit logging!
  }
}
EOF
```

#### Step 4: Run the Tests

```bash
# Test your policy
lacework iac policy test -d policies/opal/my_audit_policy

# Expected output:
# ✅ Pass test: compliant.tf - PASSED (policy accepted good config)
# ✅ Fail test: violations.tf - PASSED (policy rejected bad config)
```

### The Testing Insight

If your fail test doesn't actually fail, your policy has a bug! Common issues:
- Policy logic is too permissive
- Missing edge cases
- Incorrect field references

---

## Part 4: Victory Lap - Catching Real Issues

Now let's apply your tested policy to the original infrastructure:

### Step 1: Scan with Standard IaC

```bash
# Standard scan - only finds generic issues
lacework iac scan -d terraform/ 2>&1 | grep "false.*false"

# Result: Only 3 minor issues (S3 replication, logging, EBS optimization)
```

### Step 2: Scan with YOUR Custom OPAL Policy

```bash
# OPAL scan with your custom policies
lacework iac scan -d terraform/ --upload=false --custom-policy-dir=policies

# Check what custom policies found:
lacework iac scan -d terraform/ --upload=false --custom-policy-dir=policies 2>&1 | grep "^c-opl"

# Result: BUSINESS LOGIC VIOLATIONS FOUND!
# c-opl-my-audit-policy     High     false     Production Audit Logging Requirement
# Production instance missing critical audit-logging-sg!
```

### Step 3: The Clear Difference

```bash
# Compare results side-by-side:
echo "=== STANDARD SCAN - What it catches ==="
lacework iac scan -d terraform/ 2>&1 | grep "false.*false" | cut -d' ' -f1-10

# Output:
# - S3 bucket missing replication (operational issue)
# - S3 bucket missing logging (operational issue)
# - EC2 not EBS-optimized (performance issue)

echo "=== OPAL CUSTOM POLICIES - What YOU need caught ==="
lacework iac scan -d terraform/ --upload=false --custom-policy-dir=policies 2>&1 | grep "c-opl-my-audit"

# Output:
# c-opl-my-audit-policy  High  false  Production Audit Logging Requirement
# ^^^ YOUR CRITICAL BUSINESS REQUIREMENT VIOLATION CAUGHT!
```

---

## Part 5: Advanced - Business Logic Policies

### Example: Environment Isolation

```rego
# Production instances can't use development security groups
deny[msg] {
    input.tags.Environment == "production"
    sg_ref := input.security_groups[_]
    contains(sg_ref, "dev")
    msg := sprintf("Production instance %s using development security group", [input.tags.Name])
}
```

### Example: Role-Based Requirements

```rego
# Web servers must have specific security groups
allow {
    input.tags.Role == "web"
    has_required_web_sgs
}

has_required_web_sgs {
    required := {"web-sg", "monitoring-sg", "audit-sg"}
    provided := {sg | sg := extract_sg_name(input.security_groups[_])}
    required == required & provided  # Set intersection
}
```

---

## Key Takeaways

1. **Standard IaC scanning** catches generic issues but misses YOUR specific requirements
2. **OPAL policies** enforce YOUR business logic and security requirements
3. **Unit testing** must validate BOTH acceptance AND rejection of configurations
4. **Custom policies** are your security architect in code form

## Next Steps

1. Identify YOUR organization's specific security requirements
2. Write OPAL policies that enforce them
3. Test thoroughly with both pass AND fail cases
4. Integrate into your CI/CD pipeline
5. Sleep better knowing YOUR requirements are enforced

---

## Remember

> "Standard IaC scanning is spell-check. OPAL is having your security architect review every change."

Your infrastructure is only as secure as the rules you enforce. Generic rules give you generic security. Custom rules give you custom security - the kind YOUR business actually needs.