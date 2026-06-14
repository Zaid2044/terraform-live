# HashiCorp Vault Setup Guide

This guide documents the Vault configuration used in the InfraForge project for Terraform and GitHub Actions integration.

---

# 1. Install Vault

Update packages:

```bash
sudo apt update
sudo apt install -y gpg wget unzip
```

Add HashiCorp repository:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Install Vault:

```bash
sudo apt update
sudo apt install vault -y
```

Verify:

```bash
vault version
```

---

# 2. Configure Persistent Storage

Create storage directory:

```bash
sudo mkdir -p /opt/vault/data
sudo chown -R vault:vault /opt/vault/data
```

---

# 3. Configure Vault

Edit:

```bash
sudo nano /etc/vault.d/vault.hcl
```

Configuration:

```hcl
ui = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
```

### Important

```text
0.0.0.0:8200  → Accessible externally
127.0.0.1:8200 → Localhost only
```

GitHub Actions requires Vault to listen on:

```text
0.0.0.0:8200
```

otherwise GitHub runners cannot connect.

---

# 4. Start Vault Service

Enable service:

```bash
sudo systemctl enable vault
```

Start service:

```bash
sudo systemctl start vault
```

Verify:

```bash
sudo systemctl status vault
```

---

# 5. Verify Listener

```bash
ss -tulpn | grep 8200
```

Expected:

```text
0.0.0.0:8200
```

NOT:

```text
127.0.0.1:8200
```

---

# 6. Verify External Connectivity

From your local machine:

```bash
curl http://<VAULT_PUBLIC_IP>:8200/v1/sys/health
```

Expected:

```json
{
  "initialized": false,
  "sealed": true
}
```

This confirms GitHub Actions can reach Vault.

---

# 7. Initialize Vault

Set environment:

```bash
export VAULT_ADDR=http://127.0.0.1:8200
```

Initialize:

```bash
vault operator init
```

Save:

```text
Unseal Key 1
Unseal Key 2
Unseal Key 3
Unseal Key 4
Unseal Key 5

Initial Root Token
```

Store these securely.

---

# 8. Unseal Vault

Vault uses Shamir Secret Sharing.

Run three times:

```bash
vault operator unseal
```

Enter:

```text
Unseal Key 1
```

Again:

```bash
vault operator unseal
```

Enter:

```text
Unseal Key 2
```

Again:

```bash
vault operator unseal
```

Enter:

```text
Unseal Key 3
```

Verify:

```bash
vault status
```

Expected:

```text
Initialized  true
Sealed       false
Storage Type file
```

---

# 9. Login as Root

```bash
vault login
```

Paste:

```text
Initial Root Token
```

Verify:

```bash
vault token lookup
```

---

# 10. Enable AppRole Authentication

```bash
vault auth enable approle
```

Verify:

```bash
vault auth list
```

Expected:

```text
approle/
token/
```

---

# 11. Enable KV v2 Secret Engine

```bash
vault secrets enable -path=secret kv-v2
```

Verify:

```bash
vault secrets list
```

Expected:

```text
secret/
```

---

# 12. Store AWS Credentials

```bash
vault kv put secret/aws \
  access_key="YOUR_ACCESS_KEY" \
  secret_key="YOUR_SECRET_KEY"
```

Verify:

```bash
vault kv get secret/aws
```

Expected:

```text
access_key
secret_key
```

---

# 13. Create Terraform Policy

Create file:

```bash
nano terraform-policy.hcl
```

Contents:

```hcl
path "secret/data/aws" {
  capabilities = ["read"]
}
```

Upload policy:

```bash
vault policy write terraform-policy terraform-policy.hcl
```

Verify:

```bash
vault policy list
```

Expected:

```text
default
root
terraform-policy
```

---

# 14. Create Terraform AppRole

```bash
vault write auth/approle/role/terraform-role \
  token_policies="terraform-policy"
```

Verify:

```bash
vault read auth/approle/role/terraform-role
```

---

# 15. Generate Role ID

```bash
vault read auth/approle/role/terraform-role/role-id
```

Example:

```text
role_id = xxxxxxxx
```

Store securely.

---

# 16. Generate Secret ID

```bash
vault write -f auth/approle/role/terraform-role/secret-id
```

Example:

```text
secret_id = xxxxxxxx
```

Store securely.

---

# 17. Test AppRole Login

Authenticate:

```bash
vault write auth/approle/login \
  role_id="<ROLE_ID>" \
  secret_id="<SECRET_ID>"
```

Response:

```text
token
token_accessor
token_policies
```

Copy the token.

---

# 18. Verify Policy Access

Export token:

```bash
export VAULT_TOKEN=<TOKEN>
```

Read secret:

```bash
vault kv get secret/aws
```

Expected:

```text
access_key
secret_key
```

This confirms:

```text
AppRole → Policy → Secret Access
```

is functioning correctly.

---

# 19. GitHub Actions Integration

Create Repository Secrets:

```text
VAULT_ADDR
VAULT_ROLE_ID
VAULT_SECRET_ID
```

Example:

```text
VAULT_ADDR=http://<VAULT_PUBLIC_IP>:8200
```

Workflow Authentication Flow:

```text
GitHub Actions
      │
      ▼
AppRole Login
      │
      ▼
Vault Token
      │
      ▼
Read secret/aws
      │
      ▼
AWS Credentials
      │
      ▼
Terraform
```

---

# Architecture

```text
GitHub Actions
      │
      ▼
HashiCorp Vault
(AppRole + KV v2)
      │
      ▼
AWS Credentials
      │
      ▼
Terraform
      │
      ▼
AWS Infrastructure
```

---

# Security Notes

- AWS credentials are stored only in Vault.
- GitHub Actions authenticates using AppRole.
- No AWS keys are stored in the repository.
- Vault uses file-based persistent storage.
- Remote access requires Vault to listen on `0.0.0.0:8200`.
- Protect your Root Token and Unseal Keys.
- Rotate Secret IDs and AWS keys periodically.
