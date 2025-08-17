#!/bin/bash

# Get the actual username from environment variable or use default
ACTUAL_USERNAME=${USERNAME:-developer}

# Set up iptables rules for network restriction
iptables -P OUTPUT DROP
iptables -P INPUT ACCEPT

# Allow loopback (for local processes including localhost:8080)
iptables -A OUTPUT -o lo -j ACCEPT

# Allow DNS (needed for domain resolution)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow established/related connections (crucial for RDP and other services)
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow traffic to Kubernetes networks (for proper pod networking)
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT

# Resolve gitlab.txninfra.com to IP and allow access
echo "Resolving gitlab.txninfra.com..."
GITLAB_IP=$(nslookup gitlab.txninfra.com | awk '/^Address: / { print $2 }' | head -1)

if [ ! -z "$GITLAB_IP" ]; then
    echo "Allowing access to gitlab.txninfra.com ($GITLAB_IP)"
    # Allow HTTPS/HTTP to gitlab.txninfra.com
    iptables -A OUTPUT -d ${GITLAB_IP} -p tcp --dport 443 -j ACCEPT
    iptables -A OUTPUT -d ${GITLAB_IP} -p tcp --dport 80 -j ACCEPT
    iptables -A OUTPUT -d ${GITLAB_IP} -p tcp --dport 22 -j ACCEPT  # SSH for git
else
    echo "Warning: Could not resolve gitlab.txninfra.com"
fi

# Also allow by domain name in case of DNS changes
iptables -A OUTPUT -p tcp --dport 443 -m string --string "gitlab.txninfra.com" --algo bm -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m string --string "gitlab.txninfra.com" --algo bm -j ACCEPT

# Allow INPUT connections for RDP and related services
iptables -A INPUT -p tcp --dport 3389 -j ACCEPT
iptables -A INPUT -p tcp --dport 3350 -j ACCEPT

# Update user credentials if environment variables are provided
if [ ! -z "$PASSWORD" ]; then
    echo "$ACTUAL_USERNAME:$PASSWORD" | chpasswd
fi

# Ensure user exists and home directory is properly set up
if ! id "$ACTUAL_USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash $ACTUAL_USERNAME
    echo "$ACTUAL_USERNAME:${PASSWORD:-password123}" | chpasswd
    usermod -aG sudo $ACTUAL_USERNAME
fi

# Create and set permissions for user home directory
mkdir -p /home/${ACTUAL_USERNAME}
chown -R ${ACTUAL_USERNAME}:${ACTUAL_USERNAME} /home/${ACTUAL_USERNAME}

# Ensure XFCE session files are properly configured
echo "startxfce4" > /home/${ACTUAL_USERNAME}/.xsession
chown ${ACTUAL_USERNAME}:${ACTUAL_USERNAME} /home/${ACTUAL_USERNAME}/.xsession
chmod +x /home/${ACTUAL_USERNAME}/.xsession

# Create .xsessionrc for proper environment
echo "export XDG_SESSION_DESKTOP=xfce" > /home/${ACTUAL_USERNAME}/.xsessionrc
echo "export XDG_DATA_DIRS=/usr/share/xfce4:/usr/local/share:/usr/share:/var/lib/snapd/desktop" >> /home/${ACTUAL_USERNAME}/.xsessionrc
echo "export XDG_CONFIG_DIRS=/etc/xdg/xdg-xfce:/etc/xdg" >> /home/${ACTUAL_USERNAME}/.xsessionrc
chown ${ACTUAL_USERNAME}:${ACTUAL_USERNAME} /home/${ACTUAL_USERNAME}/.xsessionrc

# Start dbus
service dbus start
sleep 1

# Configure XRDP for IPv4 specifically
sed -i 's/^port=3389/port=tcp:\/\/0.0.0.0:3389/' /etc/xrdp/xrdp.ini
echo "tcp_nodelay=true" >> /etc/xrdp/xrdp.ini
echo "tcp_keepalive=true" >> /etc/xrdp/xrdp.ini

# Start XRDP services in proper order
echo "Starting XRDP services..."
/usr/sbin/xrdp-sesman &
sleep 3
/usr/sbin/xrdp &
sleep 3

# Verify XRDP is running
if ! pgrep -x "xrdp" > /dev/null; then
    echo "WARNING: XRDP failed to start, attempting manual start..."
    /usr/sbin/xrdp &
    sleep 3
fi

if ! pgrep -x "xrdp-sesman" > /dev/null; then
    echo "WARNING: XRDP-SESMAN failed to start, attempting manual start..."
    /usr/sbin/xrdp-sesman &
    sleep 3
fi

# Start Code Server as the user
echo "Starting Code Server..."
su - ${ACTUAL_USERNAME} -c "code-server --bind-addr 0.0.0.0:8080 --auth none --disable-telemetry &"
sleep 2

# Debug information
echo "=== Service Status ==="
echo "XRDP processes:"
pgrep -f xrdp || echo "No XRDP processes found"
echo "Listening ports:"
netstat -tlnp 2>/dev/null | grep -E "(3389|3350|8080)" || echo "netstat not available, using ss:"
ss -tlnp 2>/dev/null | grep -E "(3389|3350|8080)" || echo "Port check tools not available"
echo "iptables INPUT rules:"
iptables -L INPUT -n | head -10
echo "======================"

# Keep container running
exec tail -f /dev/null
