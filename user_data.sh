#!/bin/bash

# Install Nginx and Certbot
sudo apt-get update
sudo apt-get install -y nginx certbot python3-certbot-nginx

# Create Nginx configuration for Jenkins
cat <<EOF > /etc/nginx/sites-available/jenkins
server {
    listen 80;
    server_name ${domain_name};

    location / {
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_pass         http://localhost:8080;
    }
}
EOF

# Enable the new site and restart Nginx
sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# Obtain SSL certificate
# Use --staging flag for testing to avoid rate limits
sudo certbot --nginx -d ${domain_name} --non-interactive --agree-tos --email ${email} --redirect
