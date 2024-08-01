# minecraft-bedrock-tools
Welcome to the minecraft-bedrock-tools repository!  This repository is dedicated to simplifying the installation, update process, and control of Minecraft Bedrock Edition servers on Debian-based systems. Whether you're setting up a private server for friends or launching a public realm, our tools make it easy to get started.

# Minecraft Bedrock Server Installation Script (install-bedrock-server.sh)

Description

This script automates the installation and setup of a Minecraft Bedrock Edition server on a Ubuntu or Debian-based Linux system. It ensures necessary dependencies are installed, downloads the latest server version, configures the server properties, and sets up supervision for automatic management of the server process.

Features

Environment Checks: Ensures the script is run with sudo privileges and checks for a supported operating system (Ubuntu or Debian).
Port Availability: Verifies that the default ports (19132 for IPv4 and 19133 for IPv6) are not in use by other processes.
Dependency Installation: Updates package lists and installs wget, unzip, and supervisor.
Server Download and Setup: Downloads the latest Minecraft Bedrock Edition server, extracts it to the specified directory, and configures server properties.
User Management: Creates a dedicated user for running the Minecraft server.
Supervisor Configuration: Sets up a supervisor configuration to manage the Minecraft server process, ensuring it starts automatically and restarts on failure.
Firewall Rules: Checks if iptables is installed and configures it to allow UDP traffic on the specified port.
Verification: Confirms the server is running and listening on the specified port.

Usage

Run the script with sudo privileges on a Ubuntu or Debian system:
  sudo ./install-bedrock-server.sh

The script will handle the entire setup process, and upon completion, your Minecraft Bedrock server will be up and running. You can interact with the server's command-line console using:
  sudo supervisorctl fg bedrock-server
