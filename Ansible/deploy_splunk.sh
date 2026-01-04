#!/bin/bash
# Ansible Splunk Windows Deployment Script
# This script automates the deployment of Splunk to Windows servers

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR="${SCRIPT_DIR}"
PLAYBOOK="${ANSIBLE_DIR}/playbooks/splunk_windows_install.yml"
INVENTORY="${ANSIBLE_DIR}/inventory/windows_hosts.ini"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

# Main script
main() {
    print_header "Splunk Windows Installation via Ansible"
    
    # Check if inventory file exists
    if [ ! -f "${INVENTORY}" ]; then
        print_error "Inventory file not found: ${INVENTORY}"
        echo "Please configure your Windows hosts in the inventory file."
        exit 1
    fi
    
    # Check if playbook exists
    if [ ! -f "${PLAYBOOK}" ]; then
        print_error "Playbook not found: ${PLAYBOOK}"
        exit 1
    fi
    
    echo "Checking Ansible installation..."
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible is not installed. Please install it first:"
        echo "pip install ansible pywinrm pywinrm[credssp]"
        exit 1
    fi
    
    print_success "Ansible found: $(ansible-playbook --version | head -n1)"
    
    echo ""
    echo "Available operations:"
    echo "1. Check syntax only (--syntax-check)"
    echo "2. Dry-run mode (--check)"
    echo "3. Execute installation"
    echo "4. Verbose execution (-v)"
    
    echo ""
    read -p "Select operation (1-4) [default: 3]: " operation
    operation=${operation:-3}
    
    case $operation in
        1)
            print_header "Checking Playbook Syntax"
            ansible-playbook "${PLAYBOOK}" --syntax-check
            print_success "Syntax check completed"
            ;;
        2)
            print_header "Running in Check Mode (Dry-Run)"
            ansible-playbook "${PLAYBOOK}" --check --ask-vault-pass
            print_success "Dry-run completed"
            ;;
        3)
            print_header "Executing Splunk Installation"
            print_warning "This will install Splunk on your Windows servers"
            read -p "Continue? (yes/no) [default: no]: " confirm
            if [ "$confirm" = "yes" ]; then
                ansible-playbook "${PLAYBOOK}" --ask-vault-pass
                print_success "Installation completed"
            else
                echo "Installation cancelled"
                exit 0
            fi
            ;;
        4)
            print_header "Executing with Verbose Output"
            read -p "Continue? (yes/no) [default: no]: " confirm
            if [ "$confirm" = "yes" ]; then
                ansible-playbook "${PLAYBOOK}" -v --ask-vault-pass
                print_success "Installation completed"
            else
                echo "Installation cancelled"
                exit 0
            fi
            ;;
        *)
            print_error "Invalid operation selected"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
