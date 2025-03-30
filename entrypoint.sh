#!/bin/bash

# Function to generate random password
generate_random_password() {
    openssl rand -base64 6
}

# Check if password file exists
if ! [ -f "/root/.ssh/.container_init.pwd" ]; then
    # If password file not exists
    
    # Generate a random password
    password=$(generate_random_password)
    
    # Set the generated password for root user
    echo "${password}" > /root/.ssh/.container_init.pwd

    # Set the password for root user
    echo "root:${password}" | chpasswd
    
    # Output the password (optional)
    echo "WARNING: Change the password immediately after logging into the dev container for security reasons"
    echo "root password: ${password}"

    # Set the password to outdated
    chage -d 0 root
fi

# Start the SSH server
/usr/sbin/sshd -D
