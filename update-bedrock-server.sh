#!/bin/bash

today=$(date +"%Y-%m-%d")

# Find if Minecraft Bedrock exist on the file system. If multiple installations exsist choose which one to update.
find_installations() {
    find / -type f -name "bedrock_server" -execdir test -e server.properties \; -printf "%h\n"
}

user_selection() {
    echo "Multiple Minecraft Bedrock server installations found:"
    PS3="Select an installation directory, if unsure Quit: "
    select installation_dir in "${installations_array[@]}" "Quit"; do
        if [ "$installation_dir" == "Quit" ]; then
            echo "Exiting..."
            exit 0
        elif [ -n "$installation_dir" ]; then
            break
        else
            echo "Invalid selection. Please choose a number from the list."
        fi
    done
}

installations=$(find_installations)

if [ -z "$installations" ]; then
    echo "No Minecraft Bedrock server installations found."
    exit 1
fi

readarray -t installations_array <<< "$installations"
if [ "${#installations_array[@]}" -eq 1 ]; then
    installation_dir="${installations_array[0]}"
    echo "Found one Minecraft Bedrock server installation at: $installation_dir"
else
    user_selection
fi

echo "Selected installation directory: $installation_dir"

while true; do
    read -p "To continue with update type 'u', to exit type 'x': " choice
    if [ "$choice" == "u" ]; then
        echo "Starting update..."
        # Place update code here
        break
    elif [ "$choice" == "x" ]; then
        echo "Exiting..."
        exit 0
    else
        echo "Invalid choice. Please choose 'U' to continue with update or 'X' to exit."
    fi
done

# Check the latest Minecraft Bedrock Edition Server available.
source=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" https://www.minecraft.net/en-us/download/server/bedrock)

link=$(echo "$source" | grep -o '"https://minecraft\.azureedge\.net/bin-linux/bedrock-server-[^"]*"' | sed 's/"//g')

zip_file=$(basename "$link")

# Check the version of the installed Minecraft Bedrock Edition Server.

cd $installation_dir
output=$(sudo $installation_dir/bedrock_server 2>&1 &)

version=$(echo "$output" | grep -o 'Version: [0-9.]\+' | awk '{print $2}')

if [ -z "$version" ]; then
    echo "Failed to extract version from server output. Exiting."
    exit 1
fi

echo "Minecraft Bedrock server version is: $version"

if [[ $zip_file == *$version* ]]; then
echo "Minecraft Server is up to date, nothing to do!"
    exit 1
else
    echo "Downloading $link... "
    wget $link
fi

sudo supervisorctl stop bedrock-server

# Make a backup of current Minecraft home directory.
cp -R $installation_dir $installation_dir-$today
echo "Backing up $installation_dir to $installation_dir-$today..."

# Extract latest Minecraft Bedrock Edition Server.
unzip -o $zip_file -d $installation_dir

echo "Updating Minecraft... "
cp $installation_dir-$today/server.properties $installation_dir
cp $installation_dir-$today/allowlist.json $installation_dir
cp $installation_dir-$today/permissions.json $installation_dir

# Start updated server
sudo supervisorctl reload
