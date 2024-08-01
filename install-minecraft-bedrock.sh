#!/bin/bash

#Set some variables
port='19132'
portv6='19133'
server='bedrock-server'
user='minecraft_user'
installation_dir="/opt/$server"

# Check if the script is being run with sudo privileges.
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run with sudo. Exiting."
    exit 1

# Check if is Ubuntu or Debian Linux
elif [ ! -f /etc/os-release ] || ( . /etc/os-release && [ "$ID" != "ubuntu" ] && [ "$ID" != "debian" ]); then
    echo "This is unsupported OS. Minecraft Bedcrock Edition is only suported on Ubuntu or Debian"
    exit 1

# Check if already installed
elif [ -d "$installation_dir" ]; then
    echo "Directory $installation_dir already exists. Exiting."
    exit 1

# Check if ports are available
elif ss -nlup | grep -q ":$port"; then
    echo "Port $port is being used by another process."
    if ss -nlup | grep -q ":$portv6"; then
        echo "Port $portv6 is being used by another process."
    fi
    exit 1
elif ss -nlup | grep -q ":$portv6"; then
    echo "Port $portv6 is being used by another process."
    exit 1
fi

# Update package lists and install required dependencies
apt-get update -y
apt-get install -y wget unzip supervisor

# Download and install lateast Minecraft Bedrock Edition Server.
source=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" https://www.minecraft.net/en-us/download/server/bedrock)

link=$(echo "$source" | grep -o '"https://minecraft\.azureedge\.net/bin-linux/bedrock-server-[^"]*"' | sed 's/"//g')

zip_file=$(basename "$link")

wget -P /tmp "$link"
if [ $? -ne 0 ]; then
    echo "Failed to download $zip_file. Exiting."
    exit 1
fi

useradd -M $user && usermod -L $user

unzip -o /tmp/"$zip_file" -d $installation_dir

# Update server name and ports in server.properties
sed -i "s/server-name=.*/server-name=$server/" "$installation_dir/server.properties"
sed -i "s/server-port=.*/server-port=$port/" "$installation_dir/server.properties"
sed -i "s/server-portv6=.*/server-portv6=$portv6/" "$installation_dir/server.properties"

chown -R $user:$user $installation_dir

echo "Cleaning up..."

rm /tmp/"$zip_file"

# Configure Supervisor to monitor and control Minecraft Server.

tee "/etc/supervisor/conf.d/${server}-process.conf" > /dev/null << EOF
    [program:$server]
    command=$installation_dir/bedrock_server                                  
    environment=LD_LIBRARY_PATH=$installation_dir
    directory=$installation_dir
    user=$user
    autostart=true
    autorestart=true
    redirect_stderr=true
    stdout_logfile=$installation_dir/$server.out.log
EOF

supervisorctl update
sleep 3
supervisorctl status

# Check if iptables installed
if command -v iptables &>/dev/null; then
    # Check if the rule allowing traffic on specified $port exists
    if sudo iptables -C INPUT -p udp --dport $port -j ACCEPT &>/dev/null; then
        echo "Port $port is open"
    else
    # Allow traffic on specified $port.
        echo "Opening port $port..."
        iptables -I INPUT -p udp -m udp --dport $port -j ACCEPT
        iptables-save > /etc/iptables/rules.v4
    fi
else
    echo "No iptables installed"
fi

sleep 5

if ss -nlup | grep -q ":$port"; then
    echo
    echo "Installation completed. Your server is running and listening on UDP port $port."
    echo
    echo "Please ensure that UDP port $port is also open in your security list/group."
    echo
    echo "To interact with Minecraft Server command-line console run: \"sudo supervisorctl fg $server\""else
    echo "Port $port UDP is not listening. Installation may have failed or the server is not running."
fi
