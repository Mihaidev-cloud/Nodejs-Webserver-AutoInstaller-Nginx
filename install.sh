# Created by Mihaidev-Cloud 2022
#!/bin/bash
# Script for automatically configuration nodejs webserver using nginx



                                                                                                    

echo "Welcome to installation!"

echo "open this with sudo su"




echo "are you agree to install? type yes or press enter to cancel"

read answer
if [ "$answer" ]; then 

echo $answer, "lets get started!"
else
echo "Ok good bye!"
exit
fi


sudo apt update -y
sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install nodejs -y 

sudo apt-get install -y npm 
node --version
npm -v
sudo npm i pm2 -g
pm2 startup ubuntu

echo pm2 has been download type example: pm2 start "npm run dev" or pm2 start app.js



sudo apt install nginx -y

rm -rv /etc/nginx/sites-available/default

touch /etc/nginx/sites-available/default

echo yourdomain!

read yourdomain

echo Good now subdomain!

read subdomain

echo the port of nodejs file

read port

echo "type here (".http_upgrade but replace "." with dollar sign!")"

read http_upgrade

echo "type here (".host but replace "." with dollar sign!")"

read host

echo "Thank you!"


echo  "

# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Default server configuration
#
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        # SSL configuration
        #
        # listen 443 ssl default_server;
        # listen [::]:443 ssl default_server;
        #
        # Note: You should disable gzip for SSL traffic.
        # See: https://bugs.debian.org/773332
        #
        # Read up on ssl_ciphers to ensure a secure configuration.
        # See: https://bugs.debian.org/765782
        #
        # Self signed certs generated by the ssl-cert package
        # Don't use them in a production server!
        #
        # include snippets/snakeoil.conf;

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        server_name $yourdomain $subdomain;

        location / {
          proxy_pass http://localhost:$port; #whatever port your app runs on
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        }
}


# Virtual Host configuration for example.com
#
# You can move that to a different file under sites-available/ and symlink that
# to sites-enabled/ to enable it.
#
#server {
#       listen 80;
#       listen [::]:80;
#
#       server_name example.com;
#
#       root /var/www/example.com;
#       index index.html;
#
#       location / {
#               try_files  / =404;
#       }
#}

" >> /etc/nginx/sites-available/default

sudo ufw allow 'Nginx Full'

sudo nginx -t

sudo service nginx restart


echo "Do you want SSL Free? type "yes" for confirm! , if not just press enter to exit "

read yes

if [ "$yes" ]; then 


echo "installing certbot for free certificate ssl"



sudo apt-get install python3-certbot-nginx



echo yourdomain!

read yourdomain

echo Good now subdomain!

read subdomain

sudo certbot --nginx -d $yourdomain  -d $subdomain

certbot renew --dry-run

echo "done now check your website! to run the nodejs type this, example: pm2 start "npm run dev" or pm2 start app.js , created by Mihaidev-Cloud!"

else

echo "Ok good bye!"
exit
fi

