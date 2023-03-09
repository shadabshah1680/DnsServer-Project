#!/bin/bash

# Install BIND9
sudo apt-get update
sudo apt-get install bind9 -y

# Backup the default BIND configuration file
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak

# Configure the DNS zone for shadab.com
sudo cat >> /etc/bind/named.conf.local << EOF
zone "shadab.com" {
        type master;
        file "/etc/bind/db.shadab.com";
};
EOF

# Create a new zone file for shadab.com
sudo cp /etc/bind/db.empty /etc/bind/db.shadab.com

# Add DNS records to the zone file
sudo cat >> /etc/bind/db.shadab.com << EOF
\$TTL 86400
@       IN      SOA     ns1.shadab.com. admin.shadab.com. (
                        2023030901      ; serial
                        3600            ; refresh
                        1800            ; retry
                        604800          ; expire
                        86400           ; minimum TTL
                        )
        IN      NS      ns1.shadab.com.

ns1     IN      A       192.0.2.1
www     IN      A       192.0.2.2
EOF

# Generate DNSSEC keys for shadab.com
sudo dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE shadab.com

# Move the keys to the /etc/bind/keys directory
sudo mkdir /etc/bind/keys
sudo cp Kshadab.com.+*.key /etc/bind/keys/
sudo chown bind:bind /etc/bind/keys/Kshadab.com.+*.key

# Enable DNSSEC in BIND
sudo sed -i '/options {/a \ \ dnssec-enable yes;\n \ \ dnssec-validation yes;' /etc/bind/named.conf.options

# Update the zone configuration to enable DNSSEC
sudo sed -i '/zone "shadab.com" {/a \ \ key-directory "\/etc\/bind\/keys";\n \ \ auto-dnssec maintain;\n \ \ inline-signing yes;' /etc/bind/named.conf.local

# Check the syntax of the BIND configuration files
sudo named-checkconf
sudo named-checkzone shadab.com /etc/bind/db.shadab.com

# Restart BIND
sudo systemctl restart bind9
