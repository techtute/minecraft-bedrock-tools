# minecraft-bedrock-tools
Welcome to the minecraft-bedrock-tools repository!  This repository is dedicated to simplifying the installation, update process, and control of Minecraft Bedrock Edition servers on Debian-based systems. Whether you're setting up a private server for friends or launching a public realm, our tools make it easy to get started.

# Minecraft Bedrock Server Installation Script (install-bedrock-server.sh)

## Description

This script automates the installation and setup of a Minecraft Bedrock Edition server on a Ubuntu or Debian-based Linux system. It ensures necessary dependencies are installed, downloads the latest server version, configures the server properties, and sets up supervision for automatic management of the server process.

## Features

- **Environment Checks**: Ensures the script is run with sudo privileges and checks for a supported operating system (Ubuntu or Debian).
- **Port Availability**: Verifies that the default ports (`19132` for IPv4 and `19133` for IPv6) are not in use by other processes.
- **Dependency Installation**: Updates package lists and installs `wget`, `unzip`, and `supervisor`.
- **Server Download and Setup**: Downloads the latest Minecraft Bedrock Edition server, extracts it to the specified directory, and configures server properties.
- **User Management**: Creates a dedicated user for running the Minecraft server.
- **Supervisor Configuration**: Sets up a supervisor configuration to manage the Minecraft server process, ensuring it starts automatically and restarts on failure.
- **Firewall Rules**: Checks if `iptables` is installed and configures it to allow UDP traffic on the specified port.
- **Verification**: Confirms the server is running and listening on the specified port.


## Usage

Run the script with sudo privileges on a Ubuntu or Debian system:
```
  sudo ./install-bedrock-server.sh
```
The script will handle the entire setup process, and upon completion, your Minecraft Bedrock server will be up and running. You can interact with the server's command-line console using:
```
  sudo supervisorctl fg bedrock-server
```



# Minecraft Bedrock Server Update Script (update-bedrock-server.sh)

## Important Note
This script is meant to work with Bedrock installations done using the (install-bedrock-server.sh) script. Any other setups and installations may not be compatible with this update script.

## Description

This script automates the process of updating an existing Minecraft Bedrock Edition server on a Linux system. It searches for existing installations, verifies the version, downloads the latest version if necessary, backs up the current server, and applies the update.

## Features

- **Find Installations: Searches the file system for existing Minecraft Bedrock server installations.
- **User Selection: Prompts the user to select which installation to update if multiple installations are found.
- **Version Check: Compares the current server version with the latest available version to determine if an update is needed.
- **Backup and Update: Backs up the current server directory before applying the update to ensure data integrity.
- **Supervisor Control: Stops the server using Supervisor before updating and restarts it afterward.

## Usage

Run the script with sudo privileges on a Linux system:
```
  sudo ./update-bedrock-server.sh
```
The script will guide you through selecting an installation to update and handle the update process if a newer version is available.

## Cleanup

This script does not automatically delete the backup or the latest downloaded zip file. You will need to manage these files manually to ensure your system does not run out of storage space.

## Consideration

If you want to automate the update process, you can add this script to cron and run it periodically. For example, to run the script daily at midnight, add the following line to your crontab file (crontab -e):
```
  0 0 * * * /bin/echo "u" | /bin/bash /path/to/update-bedrock-server.sh
```
Ensure the script has the necessary permissions and is executable:

```
  chmod +x /path/to/update-bedrock-server.sh

```
