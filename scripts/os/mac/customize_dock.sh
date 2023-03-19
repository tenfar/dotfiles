#!/usr/bin/env bash
#
# ░█▀▄░█▀█░█▀▀░█░█░░░█▀▀░█▀█░█▀█░█▀▀░▀█▀░█▀▀
# ░█░█░█░█░█░░░█▀▄░░░█░░░█░█░█░█░█▀▀░░█░░█░█
# ░▀▀░░▀▀▀░▀▀▀░▀░▀░░░▀▀▀░▀▀▀░▀░▀░▀░░░▀▀▀░▀▀▀
#
create_items() {

	large_blank='{tile-data={}; tile-type="spacer-tile";}'

	small_blank='{tile-data={}; tile-type="small-spacer-tile";}'

	launchpad=$(dock_item "/System/Applications/Launchpad.app")

	settings=$(dock_item "/System/Applications/System Settings.app")

	appstore=$(dock_item "/System/Applications/App Store.app")

	notes=$(dock_item "/System/Applications/Notes.app")


	messages=$(dock_item "/System/Applications/Messages.app")

	teams=$(dock_item "/Applications/Microsoft Teams.app")

	safari=$(dock_item "/Applications/Safari.app")

	reminders=$(dock_item "/System/Applications/Reminders.app")

	music=$(dock_item "/System/Applications/Music.app")

	iina=$(dock_item "/Applications/IINA.app")

	code=$(dock_item "/Applications/Visual Studio Code.app")

	# visualstudio=$(dock_item "/Application/Visual Studio (Preview).app")

	alacritty=$(dock_item "/Applications/Alacritty.app")

	kitty=$(dock_item "/Applications/kitty.app")

	spotify=$(dock_item "/Applications/Spotify.app")

	discord=$(dock_item "/Applications/Discord.app")

}

dock_item() {
	printf "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" "$1"
}

customize_dock() {
	message "Customizing the dock"
	warning_message "Enter password to delete contents of dock and replace with new setup"

	create_items

	sudo su "$USER" -c 'defaults delete com.apple.dock persistent-apps'

	sudo su "$USER" -c "defaults write com.apple.dock persistent-apps -array 	\
'$launchpad' '$settings' '$appstore' '$small_blank' 																		\
'$messages'  '$discord' '$mail' '$small_blank' 										\
'$safari' '$reminders' '$notes' '$small_blank' 								\
'$music' '$spotify' '$plex' '$small_blank' 																							\
'$code' '$small_blank' 													\
'$alacritty' '$kitty'"

	success_message "Dock contents were updated. Restarting dock..."

	killall Dock
}
