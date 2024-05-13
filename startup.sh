#!/bin/bash

# Update package lists
apt-get update

# Install Apache
apt-get install -y apache2

# Start Apache
systemctl start apache2

# Enable Apache to start on boot
systemctl enable apache2
