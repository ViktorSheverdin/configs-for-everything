# Step 1: Check for Existing SSH Keys

`ls -al ~/.ssh`

If you see files named id_rsa.pub or id_ed25519.pub, you have existing keys. You can use these or generate new ones.

# Step 2: Generate a New SSH Key

`ssh-keygen -t ed25519 -C "your_email@example.com"`

# Step 3: Add Your SSH Key to the SSH Agent

Start the SSH agent in the background:
`eval "$(ssh-agent -s)"`

# Add your SSH private key to the ssh-agent. If you used the default filename, the command is:

`ssh-add ~/.ssh/id_ed25519`

# Step 4: Add the Public Key to GitHub

Copy your public key to your clipboard. The command varies by operating system:
Linux (requires xclip package): `xclip -sel clip < ~/.ssh/id_ed25519.pub`
Alternatively, you can manually open the id_ed25519.pub file in a text editor and copy its entire content.
Navigate to GitHub settings:
Go to GitHub.com and log in.
Click your profile photo in the top-right corner, then click Settings.
Add the key:
In the left sidebar, click SSH and GPG keys.
Click the New SSH key or Add SSH key button.
In the "Title" field, add a descriptive name for the new key (e.g., "My personal laptop").
In the "Key" field, paste the public key you copied.
Click Add SSH key. If prompted, confirm access to your account.

# Step 5: Test Your SSH Connection

Verify your connection by running the following command in your terminal:
`ssh -T git@github.com`
You may see a prompt to confirm the host's authenticity. Type yes and press Enter. You will then see a message like:
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
This confirms your SSH key is set up correctly.

# Step 6: Configure Your Repository to Use SSH

Finally, ensure your local repository is using the SSH URL instead of HTTPS. Navigate to your local project's directory in the terminal and run:
`git remote set-url origin git@github.com:OWNER/REPOSITORY.git`

# Step 7: Set global user

`git config --global user.email "viktor.sheverdin@gmail.com"`
`git config --global user.name "Viktor Sheverdin"`
