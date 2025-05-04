#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install ZSH, curl, wget, and git
echo "Installing zsh, curl, wget, and git..."
sudo apt-get install -y zsh curl wget git

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Installation complete."

## Install tools

# Instal Github CLI
printf "\033[0;32mInstalling Github CLI.\033[0m\n"
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
printf "\033[0;32mGithub CLI installation complete.\033[0m\n"

# Login and add Github SSH keys
printf "\033[0;32mCreating Github Auth and signing ssh keys.\033[0m\n"
read -p "Enter file in which to save the key ($HOME/.ssh/id_ed25519):  " key_file
# If the input is empty, assign "id_ed25519" to the variable
if [ -z "$key_file" ]
then
  key_file="$HOME/.ssh/id_ed25519"
else
    key_file="$HOME/.ssh/$key_file"
fi

read -p "Enter the email to be used with this key:  " email
ssh-keygen -t ed25519 -C $email -f $key_file

# Login and add Github SSH keys
gh auth login -h github.com -s admin:ssh_signing_key
while true; do
  read -p "Title for your signing SSH key: " signing_name

  # If the input is not empty, break the loop
  if [ ! -z "$signing_name" ]; then
    break
  fi
done

gh ssh-key add "$key_file.pub" --title "$signing_name" --type 'signing'
printf "\033[0;32mGithub Auth and signing ssh keys created.\033[0m\n"

printf "\033[0;32mSetting .gitconfig file.\033[0m\n"
key_file=$HOME/.ssh/id_ed25519
public_key=$(cat "$key_file.pub")
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global user.signingKey "$public_key"

allowedSignerFile=$HOME/.ssh/allowed_signers
echo "$email $public_key" > $allowedSignerFile
git config --global gpg.ssh.allowedSignersFile $allowedSignerFile
printf "\033[0;32m .gitconfig file configured.\033[0m\n"

#Install Fira Code Nerd Font:
printf "\033[0;32mInstalling Fira Code Nerd Font.\033[0m\n"
sudo apt install fonts-firacode
printf "\033[0;32mInstallation complete.\033[0m\n"

# Install Starship
printf "\033[0;32mInstalling BunJS.\033[0m\n"
sudo sh -c "$(curl -fsSL https://starship.rs/install.sh)"
printf "\033[0;32mStarship installation complete.\033[0m\n"

## Install plugins

# Install zsh-autosuggestions
printf "\033[0;32mInstalling zsh-autosuggestions.\033[0m\n"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
printf "\033[0;32mInstallation complete.\033[0m\n"

# Install zsh-syntax-highlighting
printf "\033[0;32mInstalling zsh-syntax-highlighting.\033[0m\n"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
printf "\033[0;32mInstallation complete.\033[0m\n"

# Install autoupdate plugin
printf "\033[0;32mInstalling autoupdate.\033[0m\n"
git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoupdate
printf "\033[0;32mInstallation complete.\033[0m\n"

# Install zsh-completions plugin
printf "\033[0;32mInstalling zsh-completions.\033[0m\n"
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
printf "\033[0;32mInstallation complete.\033[0m\n"

# Install zsh-history-substring-search plugin
printf "\033[0;32mInstalling zsh-history-substring-search.\033[0m\n"
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
printf "\033[0;32mInstallation complete.\033[0m\n"

# Initialize starship config
mkdir -p ~/.config && touch ~/.config/starship.toml
echo -e "[azure]\\ndisabled = false\\nformat = 'on [$symbol($subscription)]($style) '\\nsymbol = '󰠅 '\\nstyle = 'blue bold'\\n\\n" >> ~/.config/starship.toml
echo -e "[bun]\\nformat = 'via [🍔 $version](bold green) '\\n\\n" >> ~/.config/starship.toml
echo -e "[git_branch]\\nsymbol = '🌱 '\\ntruncation_length = 4\\ntruncation_symbol = ''" >> ~/.config/starship.toml

# Add plugins to .zshrc
sed -i 's/plugins=(git)/plugins=(\n    git\n    sudo\n    pip\n    npm\n    docker\n    encode64\n    wd\n    zsh-completions\n    zsh-autosuggestions\n    zsh-history-substring-search\n    zsh-syntax-highlighting\n    ssh-agent\n    autoupdate\n    helm\n    terraform\n    vscode)/g' ~/.zshrc
sed -i 's/robbyrussell/steeef/g' ~/.zshrc
sed -i '101,105 s/^# //' ~/.zshrc
sed -i '101,105 s/mvim/code-insiders/g' ~/.zshrc
sed -i '101,105 s/vim/code-insiders/g' ~/.zshrc

# Initialize the completion system.
echo -e 'autoload -U compinit && compinit' >> ~/.zshrc

# Setup ssh agent
read -p "Do you want to setup an ssh agent? (y/n) " answer
case ${answer:0:1} in
    y|Y )
        echo -e 'eval "$(ssh-agent -s)"' >> ~/.zshrc
        echo -e 'ssh-add ~/.ssh/id_ed25519' >> ~/.zshrc
        printf "\033[0;32mSSH agent configured.\033[0m\n"
    ;;
    * )
        printf "\033[0;32mSkipping ssh agent setup.\033[0m\n"
    ;;
esac

# Add starship to .zshrc
echo -e 'eval "$(starship init zsh)"' >> ~/.zshrc