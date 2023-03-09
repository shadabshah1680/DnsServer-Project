#!/bin/bash

# Install required packages
sudo yum update -y
sudo yum install -y openssh-server

# Create a new user
sudo useradd -m -s /bin/bash myuser

# Set a password for the user (OPTIONAL - only needed if you want to allow password authentication)
sudo passwd myuser

# Generate an SSH key pair for the user
sudo su - myuser -c "ssh-keygen -t rsa -b 4096"

# Add the public key to the authorized_keys file
sudo mkdir -p /home/myuser/.ssh
sudo cp /home/myuser/.ssh/id_rsa.pub /home/myuser/.ssh/authorized_keys
sudo chown -R myuser:myuser /home/myuser/.ssh
sudo chmod 700 /home/myuser/.ssh
sudo chmod 600 /home/myuser/.ssh/authorized_keys

# Edit the sudoers file to allow the user to run commands with sudo without a password
sudo visudo

# Add the following line to the bottom of the file:
myuser ALL=(ALL) NOPASSWD: ALL

# Save and close the file

# Restart the SSH service
sudo systemctl restart sshd