# Splunk Windows Installation - Quick Start Guide

## 5-Minute Setup

### Step 1: Prerequisites
```bash
# On your control machine (Linux/Mac)
pip install -r requirements.txt
```

### Step 2: Configure Windows Hosts
Edit `inventory/windows_hosts.ini`:
```ini
[windows]
win-splunk-01 ansible_host=192.168.1.100
```

### Step 3: Secure Your Credentials
```bash
ansible-vault create group_vars/windows/vault.yml
```

Add these variables:
```yaml
windows_admin_user: Administrator
windows_admin_password: YourSecurePassword!
vault_splunk_password: SplunkServicePassword!
vault_splunk_admin_password: SplunkWebAdminPassword!
```

### Step 4: Test Connection
```bash
ansible windows -m win_ping --ask-vault-pass
```

### Step 5: Install Splunk
```bash
chmod +x deploy_splunk.sh
./deploy_splunk.sh
# or
ansible-playbook playbooks/splunk_windows_install.yml --ask-vault-pass
```

## What Gets Installed?

✅ Splunk Enterprise (latest version configurable)
✅ Splunk Windows Service
✅ Web Interface (http://host:8000)
✅ Windows Firewall Rules
✅ Service Auto-start Enabled

## Default Settings

| Setting | Value | Change In |
|---------|-------|-----------|
| Web Port | 8000 | `roles/splunk_windows/vars/main.yml` |
| Installation Path | C:\Program Files\Splunk | `roles/splunk_windows/vars/main.yml` |
| Admin User | admin | `roles/splunk_windows/vars/main.yml` |
| Forwarding Port | 9997 | `roles/splunk_windows/vars/main.yml` |

## Post-Installation Access

```
URL: http://<your-host-ip>:8000
Username: admin
Password: <vault_splunk_admin_password>
```

## Troubleshooting

### Test WinRM connectivity
```bash
ansible windows -m win_shell -a "Get-Service SplunkWeb" --ask-vault-pass
```

### Check installation progress
```bash
ansible windows -m win_shell -a "Get-Process splunkd" --ask-vault-pass
```

### View detailed logs
```bash
ansible-playbook playbooks/splunk_windows_install.yml -vvv --ask-vault-pass
```

## Next Steps

1. Configure Splunk forwarders to send data to this instance
2. Set up SSL certificates (see README.md for details)
3. Configure deployment server for centralized management
4. Add custom apps and configurations

## Need Help?

- Check [README.md](README.md) for detailed documentation
- Review task details in [roles/splunk_windows/tasks/main.yml](roles/splunk_windows/tasks/main.yml)
- Visit https://docs.splunk.com for Splunk-specific questions
