#!/bin/bash
# =========================================================
# Enhanced Fail2ban + PortSentry + SSH + UFW Security Setup
# Improved security configuration with advanced features
# Tested on Debian / Ubuntu
# =========================================================

set -e

echo "🔒 Starting enhanced Fail2ban and PortSentry installation..."

sudo apt update -y
sudo apt install -y fail2ban portsentry ufw mailutils

# =========================================================
# STEP 1. Modify SSH settings
# =========================================================
echo "⚙️ Setting SSH Port..."
read -p "Please enter SSH port (default: 2222): " ssh_port
ssh_port=${ssh_port:-2222}
echo "Setting SSH Port to $ssh_port..."
sudo sed -i 's/^#Port .*/Port '"$ssh_port"'/' /etc/ssh/sshd_config
sudo sed -i 's/^Port .*/Port '"$ssh_port"'/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# =========================================================
# STEP 2. Configure firewall
# =========================================================
echo "🧱 Configuring UFW firewall..."

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow $ssh_port/tcp

# Remove ICMP (ping) packets
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type destination-unreachable/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type time-exceeded/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type parameter-problem/s/ACCEPT/DROP/' /etc/ufw/before.rules
sudo sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request/s/ACCEPT/DROP/' /etc/ufw/before.rules

sudo ufw logging on
sudo ufw --force enable

# =========================================================
# STEP 3. Enhanced Fail2ban configuration
# =========================================================
echo "⚙️ Configuring enhanced Fail2ban..."

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak 2>/dev/null || true

# Create enhanced jail.local configuration
sudo tee /etc/fail2ban/jail.local >/dev/null <<EOF
[DEFAULT]
# Ban settings
bantime = 1h
findtime = 10m
maxretry = 3
backend = auto

# Email notifications
destemail = root@localhost
sender = fail2ban@$(hostname)
mta = sendmail
action = %(action_mwl)s

# Whitelist trusted IPs
ignoreip = 127.0.0.1/8 ::1 192.168.0.0/16 10.0.0.0/8 172.16.0.0/12

# Logging
logpath = /var/log/fail2ban.log
loglevel = INFO
logtarget = /var/log/fail2ban.log

[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 2h
findtime = 10m

[apache-auth]
enabled = false
port = http,https
filter = apache-auth
logpath = /var/log/apache*/*error.log
maxretry = 3

[apache-badbots]
enabled = false
port = http,https
filter = apache-badbots
logpath = /var/log/apache*/*access.log
bantime = 172800
maxretry = 1

[apache-noscript]
enabled = false
port = http,https
filter = apache-noscript
logpath = /var/log/apache*/*access.log
maxretry = 6

[apache-overflows]
enabled = false
port = http,https
filter = apache-overflows
logpath = /var/log/apache*/*error.log
maxretry = 2
bantime = 600

[nginx-http-auth]
enabled = false
port = http,https
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3

[nginx-limit-req]
enabled = false
port = http,https
filter = nginx-limit-req
logpath = /var/log/nginx/error.log
maxretry = 10
findtime = 600
bantime = 600

[ufw]
enabled = true
filter = ufw.aggressive
action = iptables-allports[name=UFW]
logpath = /var/log/ufw.log
maxretry = 3
bantime = 1h
findtime = 10m

[recidive]
enabled = true
filter = recidive
logpath = /var/log/fail2ban.log
action = iptables-allports[name=recidive]
bantime = 86400
findtime = 86400
maxretry = 5
EOF

# Create enhanced UFW filter
sudo tee /etc/fail2ban/filter.d/ufw.aggressive.conf >/dev/null <<'EOF'
[Definition]
failregex = \[UFW BLOCK\].*SRC=<HOST> DST
ignoreregex = 
EOF

# Create recidive filter for repeat offenders
sudo tee /etc/fail2ban/filter.d/recidive.conf >/dev/null <<'EOF'
[Definition]
failregex = ^.*\[.*\]\s+<HOST>\s+.*$
ignoreregex = 
EOF

# =========================================================
# STEP 4. Enhanced PortSentry configuration
# =========================================================
echo "⚙️ Configuring enhanced PortSentry..."

# Configure PortSentry modes
sudo sed -i 's/^TCP_MODE=.*/TCP_MODE="atcp"/' /etc/default/portsentry
sudo sed -i 's/^UDP_MODE=.*/UDP_MODE="audp"/' /etc/default/portsentry

# Enhanced PortSentry configuration
sudo tee /etc/portsentry/portsentry.conf >/dev/null <<'EOF'
# PortSentry Configuration
# Advanced TCP scan detection
TCP_MODE="atcp"
UDP_MODE="audp"

# Blocking settings
BLOCK_TCP="1"
BLOCK_UDP="1"

# Kill route command
KILL_ROUTE="/sbin/iptables -I INPUT -s $TARGET$ -j DROP"

# Advanced scan detection
ADVANCED_PORTS_TCP="1024,65535"
ADVANCED_PORTS_UDP="1024,65535"

# Scan detection sensitivity
SCAN_TRIGGER="0"

# Logging
SYSLOG="1"
SYSLOG_FACILITY="daemon"

# Notification settings
EMAIL_ALERT="1"
EMAIL_ALERT_DEST="root@localhost"

# Port ranges to monitor
PORT_BANNER="1"
EOF

# Enhanced ignore list with common services and CDNs
sudo tee /etc/portsentry/portsentry.ignore.static >/dev/null <<'EOF'
# Local addresses
127.0.0.1/32
::1

# Private networks
192.168.0.0/16
10.0.0.0/8
172.16.0.0/12

# Common CDN and cloud services (add your specific ones)
# Cloudflare
173.245.48.0/20
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
141.101.64.0/18
108.162.192.0/18
190.93.240.0/20
188.114.96.0/20
197.234.240.0/22
198.41.128.0/17
162.158.0.0/15
104.16.0.0/12
104.24.0.0/14
172.64.0.0/13
131.0.72.0/22

# AWS
3.0.0.0/8
13.0.0.0/8
18.0.0.0/8
23.0.0.0/8
34.0.0.0/8
35.0.0.0/8
52.0.0.0/8
54.0.0.0/8

# Google Cloud
8.34.208.0/20
8.35.192.0/20
23.236.48.0/20
23.251.128.0/20
35.184.0.0/13
35.192.0.0/14
35.196.0.0/15
35.198.0.0/16
35.199.0.0/17
35.199.128.0/18
35.199.192.0/19
35.199.224.0/20
35.199.240.0/21
35.199.248.0/22
35.199.252.0/23
35.199.254.0/24
35.200.0.0/13
35.208.0.0/12
35.224.0.0/12
35.240.0.0/13
35.248.0.0/14
104.154.0.0/15
104.196.0.0/14
107.167.160.0/19
107.178.192.0/18
108.59.80.0/20
108.170.192.0/18
108.177.0.0/17
130.211.0.0/16
146.148.0.0/17
162.216.148.0/22
162.222.176.0/21
173.255.112.0/20
199.36.154.0/23
199.36.156.0/24
199.192.112.0/22
199.223.232.0/21
EOF

# =========================================================
# STEP 5. Additional security measures
# =========================================================
echo "🛡️ Applying additional security measures..."

# Configure log rotation for security logs
sudo tee /etc/logrotate.d/security-logs >/dev/null <<'EOF'
/var/log/fail2ban.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 root root
    postrotate
        systemctl reload fail2ban
    endscript
}

/var/log/portsentry.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 root root
    postrotate
        systemctl reload portsentry
    endscript
}
EOF

# Create security monitoring script
sudo tee /usr/local/bin/security-monitor.sh >/dev/null <<'EOF'
#!/bin/bash
# Security monitoring script

LOG_FILE="/var/log/security-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Security Monitor Check" >> $LOG_FILE

# Check Fail2ban status
if systemctl is-active --quiet fail2ban; then
    echo "[$DATE] ✓ Fail2ban is running" >> $LOG_FILE
else
    echo "[$DATE] ✗ Fail2ban is not running" >> $LOG_FILE
    systemctl start fail2ban
fi

# Check PortSentry status
if systemctl is-active --quiet portsentry; then
    echo "[$DATE] ✓ PortSentry is running" >> $LOG_FILE
else
    echo "[$DATE] ✗ PortSentry is not running" >> $LOG_FILE
    systemctl start portsentry
fi

# Check UFW status
if ufw status | grep -q "Status: active"; then
    echo "[$DATE] ✓ UFW firewall is active" >> $LOG_FILE
else
    echo "[$DATE] ✗ UFW firewall is not active" >> $LOG_FILE
fi

# Check for recent attacks
RECENT_ATTACKS=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $4}')
if [ "$RECENT_ATTACKS" -gt 0 ]; then
    echo "[$DATE] ⚠️ $RECENT_ATTACKS IPs currently banned by Fail2ban" >> $LOG_FILE
fi
EOF

sudo chmod +x /usr/local/bin/security-monitor.sh

# Add to crontab for regular monitoring
(crontab -l 2>/dev/null; echo "*/15 * * * * /usr/local/bin/security-monitor.sh") | crontab -

# =========================================================
# STEP 6. Start services
# =========================================================
echo "🚀 Starting services..."

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

sudo systemctl enable portsentry
sudo systemctl restart portsentry

# =========================================================
# STEP 7. Display status and information
# =========================================================
echo
echo "======================================"
echo "✅ Enhanced installation completed!"
echo "======================================"
sudo systemctl status ssh --no-pager | grep Active
sudo systemctl status ufw --no-pager | grep Active
sudo systemctl status fail2ban --no-pager | grep Active
sudo systemctl status portsentry --no-pager | grep Active

echo
echo "🔍 Checking Fail2ban Jail status..."
sudo fail2ban-client status

echo
echo "🎯 Enhanced security features enabled:"
echo " - SSH Port: $ssh_port"
echo " - ICMP packets blocked (ping will not respond)"
echo " - Enhanced Fail2ban with email notifications"
echo " - Advanced PortSentry with CDN whitelist"
echo " - UFW firewall enabled"
echo " - Security monitoring script installed"
echo " - Log rotation configured"
echo " - Repeat offender detection (recidive jail)"
echo
echo "📧 Email notifications configured for:"
echo " - Fail2ban bans and unbans"
echo " - PortSentry scan detection"
echo
echo "🔧 Management commands:"
echo " - View Fail2ban status: sudo fail2ban-client status"
echo " - Unban IP: sudo fail2ban-client set sshd unbanip <IP>"
echo " - View security logs: tail -f /var/log/security-monitor.log"
echo " - Manual security check: /usr/local/bin/security-monitor.sh"
echo
echo "💡 To login to server, use: ssh -p $ssh_port user@your-server-ip"
echo "💡 Test blocking: sudo fail2ban-client set ufw banip 1.2.3.4"
echo "💡 View blocked IPs: sudo iptables -L -n | grep DROP"
