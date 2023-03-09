>> ###  Note: These Scripts Run on Ubuntu | 20.04 recommended
- You can change the desired parameters
- Make  sure to copy keys in webserver for using those keys to distribute the content securely
- sshd for creating user without user with username and password so you can login using same credentials
- Please Make Sure that `vm3.sh` have username and ca_server_ip_address `scp <username>@<ca_server_ip_address>:~/etc/ssl/certs/ca.crt /etc/ssl/certs/ca.crt`
- Use telnet to debug ports for connection
- Check Network Types For debugging Network Connection
- You can able to allow ports using `ufw allow port_number host_address`
- You can secure copy from source to destination server and vice versa using `scp` command 
- scp works on port `22`
- Permission Eror Solve with "`chmod` and chown `commands`"
- Example to run script `sh vm3.sh`
- vm1 is just client for testing vm2 and vm3-webserver

# USe Case 1
>> To set up the secure web communication over HTTPS between the Client (C) and the Web Server (WS) using the local Certification Authority (CA) provided by the Central Server (CS):
- Script for generating the CA certificate and the server certificate for WS:
``` bash
#!/bin/bash

# Generate CA key and self-signed certificate
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt -subj "/CN=My Local CA"

# Generate WS key and certificate signing request (CSR)
openssl genrsa -out ws.key 2048
openssl req -new -key ws.key -out ws.csr -subj "/CN=mywebserver.com"

# Sign the WS CSR with the CA
openssl x509 -req -in ws.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out ws.crt -days 365 -sha256

# Verify the WS certificate with the CA
openssl verify -CAfile ca.crt ws.crt

```
- Script for configuring the CS as the trusted CA on C:

``` bash
#!/bin/bash

# Copy the CA certificate to C
scp user@cs:/path/to/ca.crt /etc/ssl/certs/

# Add the CA certificate to the trusted certificates on C
update-ca-certificates

```
- Script for configuring the web server to use the generated certificate:

``` bash
#!/bin/bash

# Copy the server key and certificate to the web server
scp user@ws:/path/to/ws.key /etc/ssl/private/
scp user@ws:/path/to/ws.crt /etc/ssl/certs/

# Update the Apache configuration to use the server key and certificate
sudo a2enmod ssl
sudo sed -i 's/^SSLCertificateFile.*$/SSLCertificateFile \/etc\/ssl\/certs\/ws.crt/' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i 's/^SSLCertificateKeyFile.*$/SSLCertificateKeyFile \/etc\/ssl\/private\/ws.key/' /etc/apache2/sites-available/default-ssl.conf

# Restart Apache to apply the changes
sudo systemctl restart apache2

```
# Use Case 2
>> Here are three bash scripts that could be used to set up the secure DNS communication over DNSSEC for the Client (C) to access the Web Server (WS) using the Central Server (CS) as the local DNS server:

- Script for configuring the CS as the local DNS server on C:

``` bash
#!/bin/bash

# Configure C to use the CS as the local DNS server
sudo sed -i 's/^nameserver.*$/nameserver <IP address of CS>/' /etc/resolv.conf

```
- Script for configuring DNSSEC on CS:
``` bash
#!/bin/bash

# Install DNSSEC packages
sudo apt-get install bind9 dnssec-tools -y

# Generate a new DNSSEC key pair for the WS domain
cd /etc/bind
dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE mywebserver.com

# Create a signed zone file for the WS domain
dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) -N INCREMENT -o mywebserver.com -t mywebserver.com.zone mywebserver.com.mywebserver.com.key

# Configure BIND to serve the signed zone file
sudo sed -i 's/^zone.*$/zone "mywebserver.com" { type master; file "\/etc\/bind\/mywebserver.com.zone.signed"; };/' /etc/bind/named.conf.local

# Restart BIND to apply the changes
sudo systemctl restart bind9

```

- Script for testing the secure DNS communication on C:

``` bash
#!/bin/bash

# Query the WS domain and verify the DNSSEC signature
dig +dnssec mywebserver.com

# Verify that the DNS response is signed and validated
dig +sigchase +trusted-key=/etc/bind/mywebserver.com.mywebserver.com.key mywebserver.com

```