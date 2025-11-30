#!/bin/bash

# Update package list
sudo apt update -y

# Install Nginx
sudo apt install -y nginx

# Get instance metadata
PUBLIC_IP=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/public-ipv4 || true)
PRIVATE_IP=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/local-ipv4 || true)
INSTANCE_ID=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/instance-id || true)
AVAIL_ZONE=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/availability-zone || true)
HOSTNAME=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/hostname || hostname -f || true)

# Normalize values
if [ -z "$PUBLIC_IP" ]; then
  PUBLIC_IP="No public IP assigned"
fi
if [ -z "$PRIVATE_IP" ]; then
  PRIVATE_IP="Unknown"
fi
if [ -z "$INSTANCE_ID" ]; then
  INSTANCE_ID="Unknown"
fi
if [ -z "$AVAIL_ZONE" ]; then
  AVAIL_ZONE="Unknown"
fi
if [ -z "$HOSTNAME" ]; then
  HOSTNAME="Unknown"
fi

# Overwrite the default index file
sudo bash -c "cat > /var/www/html/index.nginx-debian.html <<EOF
<html>
  <body>
    <h1>Hello from instance</h1>
    <p>Instance ID: ${INSTANCE_ID}</p>
    <p>Hostname: ${HOSTNAME}</p>
    <p>Public IP: ${PUBLIC_IP}</p>
    <p>Private IP: ${PRIVATE_IP}</p>
    <p>Availability Zone: ${AVAIL_ZONE}</p>
    <p>Note: If this instance is behind an ALB/ASG and has no public IP, the Public IP will show as "No public IP assigned".</p>
  </body>
</html>
EOF"

# Start Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx
# Set permissions for the index file
sudo chmod 644 /var/www/html/index.nginx-debian.html
# Restart Nginx to apply changes
sudo systemctl restart nginx
# Print completion message
echo "User data script executed successfully. Nginx is running and serving the index file."
# End of user data script
# Ensure the script is executable (if rc.local exists)
if [ -f /etc/rc.local ]; then
  chmod +x /etc/rc.local
fi

