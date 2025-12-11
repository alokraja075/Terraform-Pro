#!/bin/bash

# Update package list
sudo apt update -y

# Install Nginx
sudo apt install -y nginx

# Get instance metadata (support IMDSv2 with a token; fallback to IMDSv1)
TOKEN=""
for i in 1 2 3 4 5; do
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)
  if [ -n "$TOKEN" ]; then
    break
  fi
  sleep 1
done

get_meta() {
  local meta_path="$1"
  local out=""
  for i in 1 2 3 4 5; do
    if [ -n "$TOKEN" ]; then
      out=$(curl -s --max-time 2 -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/${meta_path}" || true)
    else
      out=$(curl -s --max-time 2 "http://169.254.169.254/latest/meta-data/${meta_path}" || true)
    fi
    if [ -n "$out" ]; then
      echo "$out"
      return
    fi
    sleep 1
  done
  echo ""
}

PUBLIC_IP=$(get_meta "public-ipv4")
PRIVATE_IP=$(get_meta "local-ipv4")
INSTANCE_ID=$(get_meta "instance-id")
AVAIL_ZONE=$(get_meta "placement/availability-zone")
HOSTNAME=$(get_meta "hostname")

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

