#!/bin/bash
echo "---- Starting SSH setup ----"
read -p "Enter the remote username: "REMOTE_USER
read -p "Enter the remote IP address: "REMOTE_IP

# Generating SSH key (if it does not exist)
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating a new ed25519 SSH key pair..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
else
    echo "SSH key already exists.Skipping Generation step..."
fi
#Copying the public key to the remote machine
echo "Transferring the public key..."
echo "Note: You will be asked for $REMOTE_USER's password one final time."
ssh-copy-id "$REMOTE_USER@$REMOTE_IP"
#testing the automation process
echo "Testing the passwordless connection..."
ssh -o BatchMode=yes "$REMOTE_USER@$REMOTE_IP" "echo 'Success! Passwordless SSH is working."
if [ $? -eq 0 ]; then
    echo "Setup complete! You can now use remote_access.sh for this IP address..."
else
    echo "Setup failed! Please check your credentials..."
fi
