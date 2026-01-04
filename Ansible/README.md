# Splunk Windows Installation - Ansible Guide

## Overview

This Ansible automation framework provides a complete solution for deploying Splunk Enterprise on Windows servers. It includes reusable roles, playbooks, and inventory management for consistent deployments across your infrastructure.

## Directory Structure

```
Ansible/
├── ansible.cfg                 # Ansible configuration
├── playbooks/
│   └── splunk_windows_install.yml    # Main playbook for Windows Splunk installation
├── roles/
│   └── splunk_windows/
│       ├── tasks/
│       │   └── main.yml        # Installation and configuration tasks
│       ├── vars/
│       │   └── main.yml        # Default variables
│       ├── templates/          # Configuration templates
│       └── handlers/           # Event handlers (future)
├── inventory/
│   └── windows_hosts.ini       # Windows host inventory
└── group_vars/
    └── windows/
        ├── vault.yml          # Encrypted credentials (create with ansible-vault)
        └── main.yml           # Group variables
```

## Prerequisites

### On Control Machine (Linux/Mac)
```bash
# Install Ansible
pip install ansible pywinrm pywinrm[credssp]

# Verify installation
ansible --version
```

### On Windows Target Machines
```powershell
# Run as Administrator
Set-ExecutionPolicy RemoteSigned -Force
Enable-PSRemoting -Force

# Configure WinRM
winrm quickconfig
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true

# Install OpenSSH (optional, for SSH-based connections)
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

## Configuration

### 1. Update Inventory

Edit `Ansible/inventory/windows_hosts.ini`:
```ini
[windows]
win-splunk-01 ansible_host=192.168.1.100
win-splunk-02 ansible_host=192.168.1.101
prod-splunk-01 ansible_host=splunk.prod.example.com
```

### 2. Secure Credentials with Ansible Vault

```bash
cd Ansible
mkdir -p group_vars/windows

# Create encrypted vault file
ansible-vault create group_vars/windows/vault.yml
```

Add to vault.yml:
```yaml
windows_admin_user: Administrator
windows_admin_password: YourSecurePassword123!
vault_splunk_password: SplunkServicePassword123!
vault_splunk_admin_password: SplunkAdminPassword123!
```

### 3. Create Group Variables

```bash
# Create main variables file
touch group_vars/windows/main.yml
```

### 4. Customize Splunk Variables

Edit `Ansible/roles/splunk_windows/vars/main.yml`:
- `splunk_version`: Version to install (default: 9.1.1)
- `splunk_web_port`: Web UI port (default: 8000)
- `splunk_firewall_enabled`: Enable Windows firewall rules
- `splunk_additional_ports`: List of forwarding/management ports

## Usage

### Basic Installation

```bash
cd Ansible

# Validate playbook syntax
ansible-playbook playbooks/splunk_windows_install.yml --syntax-check

# Dry-run (check mode)
ansible-playbook playbooks/splunk_windows_install.yml --check \
  --ask-vault-pass

# Execute installation
ansible-playbook playbooks/splunk_windows_install.yml \
  --ask-vault-pass
```

### With Custom Variables

```bash
ansible-playbook playbooks/splunk_windows_install.yml \
  -e "splunk_version=9.2.0" \
  -e "splunk_web_port=8001" \
  --ask-vault-pass
```

### For Specific Hosts

```bash
# Install on single host
ansible-playbook playbooks/splunk_windows_install.yml \
  --limit win-splunk-01 \
  --ask-vault-pass

# Install on host group
ansible-playbook playbooks/splunk_windows_install.yml \
  --limit "windows" \
  --ask-vault-pass
```

### Verbose Output

```bash
# Show detailed execution
ansible-playbook playbooks/splunk_windows_install.yml \
  -vvv \
  --ask-vault-pass

# Show changed items only
ansible-playbook playbooks/splunk_windows_install.yml \
  -v \
  --ask-vault-pass
```

## Tasks Performed

The `splunk_windows` role performs the following tasks:

1. **Validation**
   - Checks if Splunk is already installed
   - Validates Windows host connectivity

2. **Installation**
   - Creates installation directories
   - Downloads Splunk Enterprise MSI
   - Installs Splunk with license acceptance
   - Creates Splunk service account

3. **Service Configuration**
   - Configures Splunk as Windows service
   - Starts Splunk service with auto-start enabled
   - Waits for service to be fully operational

4. **Verification**
   - Verifies Splunk web interface availability
   - Performs health checks

5. **Firewall Configuration**
   - Opens Windows firewall ports for Splunk
   - Configures ports: 8000 (Web), 9997 (Forwarding), 8089 (Management)

## Troubleshooting

### Connection Issues
```bash
# Test Windows connectivity
ansible windows -m win_ping --ask-vault-pass

# Check WinRM configuration
ansible windows -m win_shell -a "winrm get winrm/config" --ask-vault-pass
```

### Installation Verification
```bash
# Check Splunk service status
ansible windows -m win_service -a "name=SplunkWeb" --ask-vault-pass

# Check if port is listening
ansible windows -m win_shell -a "netstat -ano | findstr 8000" --ask-vault-pass
```

### Debug Tasks
```bash
# Run with maximum verbosity
ansible-playbook playbooks/splunk_windows_install.yml \
  -vvvv \
  --step \
  --ask-vault-pass
```

## Post-Installation

### Access Splunk Web
- URL: `http://<windows-host>:8000`
- Default Username: `admin`
- Default Password: Set in `vault_splunk_admin_password`

### Configure Splunk Forwarders
- All Windows machines can forward logs to this Splunk instance
- Configure forward agents to send to port 9997

### Add More Monitoring Ports
Edit `Ansible/roles/splunk_windows/vars/main.yml`:
```yaml
splunk_additional_ports:
  - 9997  # Forwarding
  - 8089  # Management
  - 9998  # License server
  - 8191  # Custom application port
```

## Advanced Configuration

### SSL/TLS Configuration
Create Splunk SSL certificates and configure:
```yaml
splunk_enable_ssl: true
splunk_ssl_certificate_path: "C:\\Program Files\\Splunk\\etc\\auth\\mycerts\\server.pem"
```

### Deployment Client
For managing multiple Splunk instances:
```yaml
splunk_deployment_client_enabled: true
splunk_deployment_server: "splunk-deployment-server.example.com"
splunk_deployment_server_port: 8089
```

## Security Considerations

1. **Use Ansible Vault** for all sensitive data
2. **Restrict Inventory** file permissions (chmod 600)
3. **Use Service Accounts** for Splunk (non-admin)
4. **Enable SSL/TLS** for Splunk communications
5. **Configure Windows Firewall** to restrict access
6. **Enable WinRM over HTTPS** for encrypted connections

## Support

For issues or enhancements:
- Check Splunk documentation: https://docs.splunk.com
- Review Ansible Windows guide: https://docs.ansible.com/ansible/latest/user_guide/windows.html
- Test connectivity with: `ansible-inventory --list`

## License

This Ansible configuration is provided as-is for use with Splunk Enterprise.
