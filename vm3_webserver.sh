#!/bin/bash
sudo apt update
apt-get install -y apache2

# Install OpenSSL if it's not already installed
sudo apt-get update
sudo apt-get install openssl -y

# Copy the CA certificate to the webserver machine
# Replace <username> and <ca_server_ip_address> with the appropriate values
sudo scp <username>@<ca_server_ip_address>:~/ca.crt /etc/ssl/certs/ca.crt
sudo openssl verify /etc/ssl/certs/ca.crt
sudo openssl req -newkey rsa:2048 -nodes -keyout /etc/ssl/private/mywebserver.com.key -x509 -days 365 -out /etc/ssl/certs/mywebserver.com.crt -subj "/C=US/ST=CA/L=San Francisco/O=Shadab Inc./CN=mywebserver.com"
# Configure Apache for the mywebserver.com domain and SSL
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/mywebserver.com.conf
sudo sed -i 's/ServerAdmin webmaster@localhost/ServerAdmin shadab@mywebserver.com/g' /etc/apache2/sites-available/mywebserver.com.conf
sudo sed -i 's/ServerName www.example.com/ServerName mywebserver.com/g' /etc/apache2/sites-available/mywebserver.com.conf
sudo sed -i 's/SSLCertificateFile\s*\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/SSLCertificateFile \/etc\/ssl\/certs\/mywebserver.com.crt/g' /etc/apache2/sites-available/mywebserver.com.conf
sudo sed -i 's/SSLCertificateKeyFile\s*\/etc\/ssl\/private\/ssl-cert-snakeoil.key/SSLCertificateKeyFile \/etc\/ssl\/private\/mywebserver.com.key/g' /etc/apache2/sites-available/mywebserver.com.conf
sudo sed -i 's/#SSLCACertificateFile \/etc\/ssl\/certs\/ca-certificates.crt/SSLCACertificateFile \/etc\/ssl\/certs\/ca.crt/g' /etc/apache2/sites-available/mywebserver.com.conf

# Enable the new site and disable the default SSL site
sudo a2ensite mywebserver.com.conf
sudo a2dissite default-ssl.conf

# Restart Apache
sudo systemctl restart apache2