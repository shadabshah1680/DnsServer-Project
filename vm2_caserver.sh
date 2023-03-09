#!/bin/bash

# Install OpenSSL if it's not already installed
sudo apt-get update
sudo apt-get install openssl -y

# Create a directory to store the CA files
sudo mkdir /etc/ssl/localca
sudo chmod 700 /etc/ssl/localca

# Create the CA private key
sudo openssl genrsa -out /etc/ssl/localca/ca.key 4096
sudo chmod 400 /etc/ssl/localca/ca.key

# Create the CA certificate
sudo openssl req -x509 -new -nodes -key /etc/ssl/localca/ca.key -sha256 -days 3650 -out /etc/ssl/localca/ca.crt -subj "/CN=Local CA"

# Configure OpenSSL to use the local CA
sudo cat >> /etc/ssl/openssl.cnf << EOF
[ca]
default_ca = local_ca

[local_ca]
dir = /etc/ssl/localca
database = \$dir/index.txt
new_certs_dir = \$dir/newcerts
certificate = \$dir/ca.crt
serial = \$dir/serial
private_key = \$dir/ca.key
default_days = 3650
default_md = sha256
policy = local_ca_policy
x509_extensions = local_ca_extensions

[local_ca_policy]
commonName = supplied

[local_ca_extensions]
basicConstraints = CA:true
subjectKeyIdentifier = hash
EOF

# Create the index file for the CA
sudo touch /etc/ssl/localca/index.txt
sudo echo 1000 > /etc/ssl/localca/serial

# Check the syntax of the OpenSSL configuration file
sudo openssl cnf -noout -text -config /etc/ssl/openssl.cnf

# Copy the CA certificate to the webserver machine using scp
# Replace <username> and <webserver_ip_address> with the appropriate values
sudo scp /etc/ssl/localca/ca.crt <username>@<webserver_ip_address>:~/ca.crt
