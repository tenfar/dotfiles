#!/usr/bin/env bash
#
# ░█▀▀░█░█░█▀█░█▀▄░█▀▀░█▀▄░░░█▀▀░█▀█░█▀█░█▀▀░▀█▀░█▀▀░█▀▀
# ░▀▀█░█▀█░█▀█░█▀▄░█▀▀░█░█░░░█░░░█░█░█░█░█▀▀░░█░░█░█░▀▀█
# ░▀▀▀░▀░▀░▀░▀░▀░▀░▀▀▀░▀▀░░░░▀▀▀░▀▀▀░▀░▀░▀░░░▀▀▀░▀▀▀░▀▀▀
#
SHARED_HOME="$DOTS_DIR"/shared/home/

shared_backup_existing() {
	message "Backing up existing dotfiles to $BACKUP_LOCATION"

	# backup .config
	backup_files "$HOME"/.config/alacritty "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/astronvim "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/bat "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/btop "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/cava "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/davmail "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/fastfetch "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/fish "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/kitty "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/micro "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/ohmyposh "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/nvim "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.local/share/nvim "$BACKUP_LOCATION"/.local/share/
	backup_files "$HOME"/.config/ranger "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/spicetify "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/topgrade.toml "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/nix "$BACKUP_LOCATION"/.config/
	backup_files "$HOME"/.config/tmux "$BACKUP_LOCATION"/.config/

	backup_files "$HOME"/.mozilla "$BACKUP_LOCATION"/
	backup_files "$HOME"/.oh-my-bash "$BACKUP_LOCATION"/
	backup_files "$HOME"/.oh-my-zsh "$BACKUP_LOCATION"/

	backup_files "$HOME"/.bashenv "$BACKUP_LOCATION"/
	backup_files "$HOME"/.bashrc "$BACKUP_LOCATION"/
	backup_files "$HOME"/.gitconfig "$BACKUP_LOCATION"
	backup_files "$HOME"/.gitconfig.functions "$BACKUP_LOCATION"
	backup_files "$HOME"/.gitignore_global "$BACKUP_LOCATION"
	backup_files "$HOME"/.zshenv "$BACKUP_LOCATION"/
	backup_files "$HOME"/.zshrc "$BACKUP_LOCATION"/
	backup_files "$HOME"/.p10k.zsh "$BACKUP_LOCATION"/
	backup_files "$HOME"/.aliases "$BACKUP_LOCATION"/
	backup_files "$HOME"/.functions "$BACKUP_LOCATION"/

	git_crypt_check && backup_files "$HOME"/.gnupg "$BACKUP_LOCATION"
	git_crypt_check && backup_files "$HOME"/.gitconfig.signing "$BACKUP_LOCATION"
	git_crypt_check && backup_files "$HOME"/.ssh "$BACKUP_LOCATION"
	git_crypt_check && backup_files "$HOME"/.wakatime.cfg "$BACKUP_LOCATION"
	git_crypt_check && backup_files "$HOME"/.wegorc "$BACKUP_LOCATION"
	git_crypt_check && backup_files "$HOME"/weather_url "$BACKUP_LOCATION"
	git_crypt_check && backup_files "$HOME"/wttr_location "$BACKUP_LOCATION"
	git_crypt_check && backup_files "$HOME"/.config/gh "$BACKUP_LOCATION"/.config/
	git_crypt_check && backup_files "$HOME"/.config/github-copilot "$BACKUP_LOCATION"/.config/
}

correct_ssh_permissions() {
	message "Settings $HOME/.ssh permissions"

	chmod 700 "$HOME"/.ssh
	chmod 600 "$HOME"/.ssh/*
}

install_bat_themes() {
	if [[ $(command -v bat) ]]; then
		message "Installing bat theme"
		# bat requires cache to be rebuilt to detect themes in config directory
		bat cache --build
	else
		warning_message "bat not detected... installation instructions: https://github.com/sharkdp/bat#installation"
	fi
}

install_fish_plugins() {
	if [[ $(command -v fish) ]]; then
		message "Installing fisher..."
		fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"

		message "Installing fish plugins"
		warning_message "DO NOT configure Tide when prompted"

		git restore "$SHARED_HOME"/.config/fish/fish_plugins

		fish -c "fisher update"
	else
		warning_message "Fish not detected... installation instructions: https://fishshell.com/"
	fi
}


initialize_submodules() {
	message "Pulling submodules"

	git submodule update --init --recursive --remote
	git pull --recurse-submodules
}

shared_copy_configuration() {
	message "Copying shared config files"

	# copy home folder dotfiles if you dont want to use symlinks
	# copy_files "$DOTS_DIR"/shared/home/. ~

	# link files that replace contents of location
	link_locations "$SHARED_HOME"/.config/alacritty "$HOME"/.config/alacritty
	link_locations "$SHARED_HOME"/.config/nvim "$HOME"/.config/nvim
	link_locations "$SHARED_HOME"/.config/astronvim/lua/user "$HOME"/.config/nvim/lua/user
	link_locations "$SHARED_HOME"/.config/bat "$HOME"/.config/bat
	link_locations "$SHARED_HOME"/.config/btop "$HOME"/.config/btop
	link_locations "$SHARED_HOME"/.config/cava/config "$HOME"/.config/cava/config
	link_locations "$SHARED_HOME"/.config/davmail "$HOME"/.config/davmail
	link_locations "$SHARED_HOME"/.config/fastfetch "$HOME"/.config/fastfetch
	link_locations "$SHARED_HOME"/.config/fish "$HOME"/.config/fish
	link_locations "$SHARED_HOME"/.config/kitty "$HOME"/.config/kitty
	link_locations "$SHARED_HOME"/.config/micro "$HOME"/.config/micro
	link_locations "$SHARED_HOME"/.config/ohmyposh "$HOME"/.config/ohymyposh
	link_locations "$SHARED_HOME"/.config/ranger "$HOME"/.config/ranger
	link_locations "$SHARED_HOME"/.config/topgrade.toml "$HOME"/.config/topgrade.toml
	link_locations "$SHARED_HOME"/.config/tmux "$HOME"/.config/tmux

	link_locations "$SHARED_HOME"/.oh-my-bash "$HOME"/.oh-my-bash
	link_locations "$SHARED_HOME"/.oh-my-bash-custom/themes/powerlevel10k "$HOME"/.oh-my-bash/custom/themes/powerlevel10k

	link_locations "$SHARED_HOME"/.bashenv "$HOME"/.bashenv
	link_locations "$SHARED_HOME"/.bashrc "$HOME"/.bashrc
	link_locations "$SHARED_HOME"/.face "$HOME"/.face
	link_locations "$SHARED_HOME"/.face.icon "$HOME"/.face.icon
	link_locations "$SHARED_HOME"/.gitconfig "$HOME"/.gitconfig
	link_locations "$SHARED_HOME"/.gitconfig.functions "$HOME"/.gitconfig.functions
	link_locations "$SHARED_HOME"/.gitignore_global "$HOME"/.gitignore_global
	link_locations "$SHARED_HOME"/.p10k.zsh "$HOME"/.p10k.zsh
	link_locations "$SHARED_HOME"/.zshrc "$HOME"/.zshrc
	link_locations "$SHARED_HOME"/.zshenv "$HOME"/.zshenv
	link_locations "$SHARED_HOME"/.aliases "$HOME"/.aliases
	link_locations "$SHARED_HOME"/.functions "$HOME"/.functions

	git_crypt_check && link_locations "$SHARED_HOME"/.gnupg "$HOME"/.gnupg
	git_crypt_check && link_locations "$SHARED_HOME"/.gitconfig.signing "$HOME"/.gitconfig.signing
	git_crypt_check && link_locations "$SHARED_HOME"/.ssh "$HOME"/.ssh
	git_crypt_check && link_locations "$SHARED_HOME"/.wakatime.cfg "$HOME"/.wakatime.cfg
	git_crypt_check && link_locations "$SHARED_HOME"/.wegorc "$HOME"/.wegorc
	git_crypt_check && link_locations "$SHARED_HOME"/weather_url "$HOME"/weather_url
	git_crypt_check && link_locations "$SHARED_HOME"/wttr_location "$HOME"/wttr_location
	git_crypt_check && link_locations "$SHARED_HOME"/.config/nix/nix.conf "$HOME"/.config/nix/nix.conf
	git_crypt_check && link_locations "$SHARED_HOME"/.config/gh "$HOME"/.config/gh
	git_crypt_check && link_locations "$SHARED_HOME"/.config/github-copilot "$HOME"/.config/github-copilot

	# copy files that dont replace contents of location
	copy_files "$SHARED_HOME"/.fonts/ "$HOME"/.fonts/
	copy_files "$SHARED_HOME"/.local/ "$HOME"/.local/
	copy_files "$SHARED_HOME"/.mozilla/ "$HOME"/.mozilla/
}

shared_install() {

	# Backup
	shared_backup_existing

	# Fetch dependencies
	initialize_submodules

	# Copy config
	shared_copy_configuration
	correct_ssh_permissions

	# Installations
	shared_theme_install
}

shared_theme_install() {

	install_bat_themes
	install_fish_plugins
}
