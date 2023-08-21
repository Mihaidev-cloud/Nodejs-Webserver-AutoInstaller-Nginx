# Created by Mihaidev-Cloud 2023
#!/bin/bash
# Script for automatically configuration nodejs webserver using nginx

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

echo "You are running this script as root!"



cat << "EOF" 
     .-') _              _ .-') _     ('-.             .-')              .-') _                         .-') _) (`-.      
    ( OO ) )            ( (  OO) )  _(  OO)           ( OO ).           ( OO ) )                       ( OO ) )( OO ).    
,--./ ,--,'  .-'),-----. \     .'_ (,------.     ,--.(_)---\_)      ,--./ ,--,'  ,----.     ,-.-') ,--./ ,--,'(_/.  \_)-. 
|   \ |  |\ ( OO'  .-.  ',`'--..._) |  .---' .-')| ,|/    _ |       |   \ |  |\ '  .-./-')  |  |OO)|   \ |  |\ \  `.'  /  
|    \|  | )/   |  | |  ||  |  \  ' |  |    ( OO |(_|\  :` `.       |    \|  | )|  |_( O- ) |  |  \|    \|  | ) \     /\  
|  .     |/ \_) |  |\|  ||  |   ' |(|  '--. | `-'|  | '..`''.)      |  .     |/ |  | .--, \ |  |(_/|  .     |/   \   \ |  
|  |\    |    \ |  | |  ||  |   / : |  .--' ,--. |  |.-._)   \      |  |\    | (|  | '. (_/,|  |_.'|  |\    |   .'    \_) 
|  | \   |     `'  '-'  '|  '--'  / |  `---.|  '-'  /\       /      |  | \   |  |  '--'  |(_|  |   |  | \   |  /  .'.  \  
`--'  `--'       `-----' `-------'  `------' `-----'  `-----'       `--'  `--'   `------'   `--'   `--'  `--' '--'   '--' 
EOF

echo "Welcome to Nodejs Webserver Nginx AutoInstaller"

echo "Attention! this is compatible with Debian 10 and Ubuntu 20.04 or newer because of the EOL support of deb.nodesource.com for nodejs."

echo "I recommend to install on a fresh new server, to avoid any problems!"

read -p "Do you want to execute the scripts? (y/n): " choice

if [ "$choice" = "y" ]; then
  
    echo "Executing scripts..."
echo "Installing the latest Nodejs Version(v20.x)"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
apt-get install -y nodejs
apt-get install  npm
node --version
npm -v

echo "Installing the Nodejs Process Manager (PM2)"

npm i pm2 -g

echo "Activating PM2 on startup"

pm2 startup ubuntu

read -p "Do you want to automatically configure the firewall? (iptables) (y/n): " choice2

if [ "$choice2" = "y" ]; then
   echo "Alright! you can now stay comfortable without worrying about configure the firewall"

read -p "Write your nodejs app port number! " portnumber

echo "Install the iptables-persistant package for Ubuntu and Debian."
apt-get update && apt-get install iptables-persistent -y

echo "Configuring the HTTP/HTTPS & Nodejs APP Port"
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport $portnumber -j ACCEPT
sudo iptables -A INPUT -p udp --dport $portnumber -j ACCEPT

echo "Saving the iptablees rules"
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6

echo "To ensure that iptables-persistent is loading the rules correctly during the startup
We gonna enable netfilter-persistent"

sudo systemctl enable netfilter-persistent

 echo "Installing the Webserver Nginx"

 sudo apt-get install nginx -y
 
 # Ask the user to enter the server name
read -p "Enter the server name (e.g., example.com): " server_name

echo "Your Directory is /var/www/$server_name"

# Create the Nginx configuration content
config_content='server {
    listen 80;
    server_name '"$server_name"';

    location / {
        proxy_pass http://localhost:'"$port_number"';
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection '\''upgrade'\'';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        root '"/var/www/$server_name"';
        index index.html index.htm;
    }
}'

# Ask the user to enter the filename for the configuration file
read -p "Enter the filename for the Nginx configuration (e.g., mysite.conf): " config_filename

# Write the configuration content to the specified file
echo "$config_content" > "$config_filename"


# Check if the file was created successfully
if [ $? -eq 0 ]; then
  echo "Nginx configuration file '$config_filename' created successfully."
else
  echo "Failed to create Nginx configuration file '$config_filename'."
fi

echo "you can modify the server conf anytime you want!"

echo "Testing the Nginx Configuration file"

sudo nginx -t

echo "Reloading the Nginx Webserver"

sudo systemctl restart nginx


echo "Congratulations, the Nginx has been configured for the $server_name"

read -p "Do you want free SSL certificates from certbot? (e.g., y/n) " choice3

if [ "$choice3" = "y" ]; then
    # Put your scripts here that you want to execute when the user enters 'y'
    echo "You really appreciate your time, right?"

    echo "Installing Certbot"

sudo apt-get install python3-certbot-nginx -y

echo "Running the Certbot SSL Execution!"

sudo certbot --nginx -d $server_name

echo "Configuring it to automatically renew the certificate"

(crontab -1 2>/dev/null; echo "0 23 * * * certbot renew --quiet --deploy-hook "systemctl restart nginx"")
  
   echo "Alright, that's it folks! Now before you go and enjoy your free time
    make sure to add your app nodejs project files by using cd /var/www/$server_name"

    echo "Have a great day! and thanks for using the bash script :3"

    echo "Created with love by mihaidev-cloud :3"


elif [ "$choice3" = "n" ]; then
    echo "Alright, that's it folks! Now before you go and enjoy your free time
    make sure to add your app nodejs project files by using cd /var/www/$server_name"

    echo "Have a great day! and thanks for using the bash script :3"

     echo "Created with love by mihaidev-cloud :3"
else
    echo "Invalid choice. Please enter 'y' or 'n'."
fi


elif [ "$choice2" = "n" ]; then
 echo "Alright, if you are brave enough to configure the firewall by yourself :D"


 echo "Installing the Webserver Nginx"

 sudo apt-get install nginx -y
 
 # Ask the user to enter the server name
read -p "Enter the server name (e.g., example.com): " server_name

echo "Your Directory is /var/www/$server_name"

# Create the Nginx configuration content
config_content='server {
    listen 80;
    server_name '"$server_name"';

    location / {
        proxy_pass http://localhost:'"$port_number"';
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection '\''upgrade'\'';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        root '"/var/www/$server_name"';
        index index.html index.htm;
    }
}'

# Ask the user to enter the filename for the configuration file
read -p "Enter the filename for the Nginx configuration (e.g., mysite.conf): " config_filename

# Write the configuration content to the specified file
echo "$config_content" > "$config_filename"


# Check if the file was created successfully
if [ $? -eq 0 ]; then
  echo "Nginx configuration file '$config_filename' created successfully."
else
  echo "Failed to create Nginx configuration file '$config_filename'."
fi

echo "you can modify the server conf anytime you want!"

echo "Testing the Nginx Configuration file"

sudo nginx -t

echo "Reloading the Nginx Webserver"

sudo systemctl restart nginx


echo "Congratulations, the Nginx has been configured for the $server_name"

read -p "Do you want free SSL certificates from certbot? (e.g., y/n) " choice3

if [ "$choice3" = "y" ]; then
    # Put your scripts here that you want to execute when the user enters 'y'
    echo "You really appreciate your time, right?"

    echo "Installing Certbot"

sudo apt-get install python3-certbot-nginx -y

echo "Running the Certbot SSL Execution!"

sudo certbot --nginx -d $server_name

echo "Configuring it to automatically renew the certificate"

(crontab -1 2>/dev/null; echo "0 23 * * * certbot renew --quiet --deploy-hook "systemctl restart nginx"")
  
   echo "Alright, that's it folks! Now before you go and enjoy your free time
    make sure to add your app nodejs project files by using cd /var/www/$server_name"

    echo "Have a great day! and thanks for using the bash script :3"

    echo "Created with love by mihaidev-cloud :3"


elif [ "$choice3" = "n" ]; then
    echo "Alright, that's it folks! Now before you go and enjoy your free time
    make sure to add your app nodejs project files by using cd /var/www/$server_name"

    echo "Have a great day! and thanks for using the bash script :3"

     echo "Created with love by mihaidev-cloud :3"
else
    echo "Invalid choice. Please enter 'y' or 'n'."
fi


else
    echo "Invalid choice. Please enter 'y' or 'n'."
fi



elif [ "$choice" = "n" ]; then
    echo "Aww, you don't want to run the bash-script-chan? I worked hard for this
    :( "
    echo "You made me really sad today, i'm gonna cry :("

    exit 1
else
    echo "Invalid choice. Please enter 'y' or 'n'."
fi
