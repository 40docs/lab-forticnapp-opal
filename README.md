# FortiCNAPP OPAL Lab: Beyond Spell-Check Security

> **Standard IaC scanning is like spell-check - necessary but not sufficient. OPAL is like having your security architect review every change.**

This repository demonstrates why custom OPAL policies are essential for enterprise security. **Clone and run immediately**, or follow the full learning guide.

## 🚀 Quick Demo

**Prerequisites**: FortiCNAPP CLI installed and configured (see setup below)

```bash
# 1. Clone and setup
git clone https://github.com/40docs/lab_forticnapp_opal.git
cd lab_forticnapp_opal

# 2. Run standard scan - only finds 3 minor issues
lacework iac scan -d terraform/ 2>&1 | grep "false.*false"

# 3. Run with OPAL custom policies - finds critical business violations!
lacework iac scan -d terraform/ --upload=false --custom-policy-dir=policies 2>&1 | grep "^c-opl"
```

**Result**: OPAL catches critical business requirements that standard scanning misses!

## 📚 Full Learning Experience: [LAB_GUIDE.md](LAB_GUIDE.md)

Step-by-step tutorial covering:
- Why standard IaC scanning isn't enough
- How to create custom OPAL policies
- Unit testing your policies
- Business logic enforcement

## 📦 What's Included (Ready to Use)

- `terraform/looks_secure.tf`: Infrastructure that passes standard scans but violates business rules
- `policies/opal/my_audit_policy/`: Custom policy demonstrating production audit logging requirement
- `terraform/looks_secure.tf.fixed`: Example of how to fix violations
- `LAB_GUIDE.md`: Complete step-by-step tutorial

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

## 📝 Key Takeaway

> "Standard IaC scanning is spell-check. OPAL is having your security architect review every change."

Your infrastructure is only as secure as the rules you enforce. Generic rules give you generic security. Custom rules give you custom security - the kind YOUR business actually needs.

## 🔗 Next Steps

1. Follow the complete [LAB_GUIDE.md](LAB_GUIDE.md) tutorial
2. Identify YOUR organization's specific security requirements
3. Write OPAL policies that enforce them
4. Test thoroughly with both pass AND fail cases
5. Integrate into your CI/CD pipeline