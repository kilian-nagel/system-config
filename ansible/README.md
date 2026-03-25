# Debian 13 VPS bootstrap (Ansible)

This playbook installs and configures:
- Docker Engine + Compose plugin
- Bash aliases from `shell/aliases-deb`
- UFW enabled (only port 22 open)
- `/etc/sysctl.d/99-custom.conf` with ping kept **enabled**

## 🚀 Easy Setup (Single Command)

If you have already pushed your changes to GitHub, you can use the bootstrap script from any machine with Ansible installed. The script will automatically clone your repository, install requirements, and run the playbook on your target VPS.

Run the provided script locally:
```bash
./bootstrap-vps.sh
```
*Note: Because the script clones the public repository from GitHub, ensure any changes you make locally are **committed and pushed** before running the script, or it will fail with missing files.*

---

## 🛠️ Manual Installation (for local testing/development)

### 1) Install the required collection

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

### 2) Create your inventory

```bash
cp ansible/inventory.ini.example ansible/inventory.ini
# then edit ansible/inventory.ini
```

### 3) Run the playbook

```bash
ansible-playbook -i ansible/inventory.ini ansible/debian13-vps.yml
```

### Optional variables

You can override the user receiving aliases and docker group membership:

```bash
ansible-playbook -i ansible/inventory.ini ansible/debian13-vps.yml -e target_user=youruser
```


