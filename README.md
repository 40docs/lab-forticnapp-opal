
# FortiCNAPP OPAL Lab

This repository provides a fast-start demo for working with FortiCNAPP's OPAL policy engine using the CLI. It includes a sample custom policy, metadata, and passing/failing test cases.

## 📦 What's Included

- `metadata.yaml`: Policy metadata
- `policy.rego`: OPAL policy logic
- `tests/pass`: Passing Terraform config
- `tests/fail`: Failing Terraform config

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

## 🚀 Running the Demo

### 1. Clone this repo

```bash
git clone https://github.com/your-org/lab-forticnapp-opal.git
cd lab-forticnapp-opal/policies
```

### 2. Run the Policy Test

```bash
lacework iac policy test -d opal/sample_custom_policy
```

This runs the policy against both pass and fail test cases.

---

## 🧪 Optional: Upload or Run Against Real Projects

### Upload your policy set:

```bash
lacework iac policy upload -d .
```

### Run OPAL on a Terraform project:

```bash
lacework iac tf-scan opal --disable-custom-policies=false -d /path/to/your/project
```

---

## 📝 Notes

- Policy logic lives in `policy.rego`
- Use `print()` for debugging, but avoid committing debug statements
- OPAL v0.3.5+ is recommended for print statement output support
