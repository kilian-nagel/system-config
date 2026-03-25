#!/usr/bin/env bash
set -e

echo "========================================="
echo " Debian 13 VPS Bootstrap Script"
echo "========================================="

# 1. Prompt for IP and User
read -p "Enter the target VPS IP address: " TARGET_IP
if [ -z "$TARGET_IP" ]; then
    echo "Error: IP address is required."
    exit 1
fi

read -p "Enter the SSH user (default: root): " SSH_USER
SSH_USER=${SSH_USER:-root}

# 2. Clone the repository into a temporary directory
WORKDIR=$(mktemp -d)
echo "Cloning repository https://github.com/kilian-nagel/system-config.git into $WORKDIR..."
git clone https://github.com/kilian-nagel/system-config.git "$WORKDIR" > /dev/null 2>&1

cd "$WORKDIR"

# 3. Install Ansible dependencies
echo "Installing Ansible collections..."
ansible-galaxy collection install -r ansible/requirements.yml > /dev/null

# 4. Run the playbook with inline inventory
echo "Executing playbook on $TARGET_IP as user $SSH_USER..."
# The comma after TARGET_IP is required to tell Ansible it's a host list, not a file path
ansible-playbook -i "$TARGET_IP," ansible/debian13-vps.yml -u "$SSH_USER"

echo "========================================="
echo "✅ Setup complete for $TARGET_IP!"
echo "========================================="

# Cleanup (optional)
rm -rf "$WORKDIR"
