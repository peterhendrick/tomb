#! /bin/bash

PATH=$PATH:/usr/local/bin:~/bin

function exitFunction {
        echo "Error - Bad Argument: $1 not found." >&2
	helpFunction
        exit 1
}

function helpFunction {
        echo "Usage: $0 [arguments...]"; echo
        echo "   help | h | -h | --help      Show help."; echo
        echo "   init | i | -i               Initialize tomb"; echo
	echo "   open | o | -o               Open the tomb and restore your password store"; echo
	echo "   close | c | -c              Close the password store into a tomb"; echo
	echo "   status | s | -s             Show the tomb's current status"; echo
	exit 1
}

if [ "$#" = 0 ]; then
	echo "Error: no argument given" >&2
	helpFunction
	exit 1
fi

function tombExistanceCheck {
	if [[ ! -d ~/.tomb/ ]]; then
		echo "Tomb has not been initialized."
		echo
		echo "Type: tomb init"
		exit 1
	fi
}

function checkFunction {
	if [[ -d ~/.password-store ]]; then
		echo "Closing tomb."
		closeFunction
	else
		echo "Tomb is closed."
	fi
}

function statusFunction {
	tombExistanceCheck
	if [[ -d ~/.password-store/ ]]; then
		echo "Tomb is open."
	else
		echo "Tomb is closed."
	fi
	exit 0
}

function openFunction {
        tombExistanceCheck
	if [[ -d ~/.password-store/ ]]; then
                echo "Password store already exists"
                exit 1
        fi
	
	
        gpg -d ~/.tomb/tomb.tar.gz.gpg > ~/.tomb/tomb.tar.gz || { echo 'Decryption failed' ; exit 1; }
	gzip -d ~/.tomb/tomb.tar.gz
	tar -x -f ~/.tomb/tomb.tar -C ~/.tomb/ --strip-components=3
	mkdir ~/.password-store
	cp -a ~/.tomb/tomb/ ~/.password-store/
	rm -rf ~/.tomb/tomb/ ~/.tomb/tomb.tar.gz
}

function closeFunction {
	tombExistanceCheck
	if [[ ! -d ~/.password-store/ ]]; then
 		echo "Tomb is already closed"
 		exit 1
 	fi
	cp -a ~/.password-store/ ~/.tomb/tomb
	tar -cf ~/.tomb/tomb.tar ~/.tomb/tomb
	new_sha="$(shasum -a 256 ~/.tomb/tomb.tar)"
	old_sha="$(cat ~/.tomb/.tarsha)"
	if [[ "$new_sha" = "$old_sha" ]]; then
		echo "No changes since last close, removing password store, but no updates to be made"
		rm -rf ~/.password-store/ ~/.tomb/tomb.tar ~/.tomb/tomb/
	else
		if [[ -e ~/.tomb/tomb.tar.gz.gpg ]]; then
			rm ~/.tomb/tomb.tar.gz.gpg
		fi
		shasum -a 256 ~/.tomb/tomb.tar > ~/.tomb/.tarsha
		gzip ~/.tomb/tomb.tar
		gpg_key="$( cat ~/.tomb/.gpg_key )"
		gpg -u "$gpg_key" -s -r "$gpg_key" -e ~/.tomb/tomb.tar.gz || { echo 'Encryption failed. Exiting.' && rm -rf ~/.tomb/tomb ~/.tomb/tomb/tar ~/.tomb/tomb.tar.gz ; exit 1; }
		rm -rf ~/.tomb/tomb ~/.tomb/tomb.tar ~/.tomb/tomb.tar.gz
		git -C ~/.tomb/ add ~/.tomb/tomb.tar.gz.gpg
		git -C ~/.tomb/ commit -m 'tomb update'
		[[ "$(git -C ~/.tomb/ remote)" && "$(git -C ~/.tomb/ remote get-url origin)" ]] && git -C ~/.tomb/ push
		rm -rf ~/.password-store/
	fi
}

function initFunction {
	if [[ -d ~/.tomb/ && -e ~/.tomb/.gpg_key && -d ~/.tomb/.git ]]; then
		echo "Tomb is already initialized."
		exit 1
	fi
	read -p "Enter the gpg id you would like to use with tomb: " gpg_key
	[[ $(gpg --list-keys | grep "$gpg_key") ]] && echo "Key Exists. Adding to .tomb store." || { echo 'No key found, exiting.' ; exit 1; }
	read -p "What is your git username? " git_user
	read -p "What is your git email? " git_email
	read -p "Enter a remote git url or ssh (type "skip" to skip): " git_remote

	echo "Configuring .tomb and git."

	mkdir ~/.tomb/
	git -C ~/.tomb/ init
	git -C ~/.tomb/ config user.name "$git_user"
	git -C ~/.tomb/ config user.email "$git_email"
	git -C ~/.tomb/ config user.signingkey "$gpg_key"
	git -C ~/.tomb/ config commit.gpgsign true
	[[ "$git_remote" != "skip" ]] && git -C ~/.tomb/ remote add origin "$git_remote"
	
	echo "git initialized. setting up tomb."
	touch ~/.tomb/.tarsha
	echo "$gpg_key" > ~/.tomb/.gpg_key
	echo ".tarsha" > ~/.tomb/.gitignore
	echo ".gpg_key" >> ~/.tomb/.gitignore
	git -C ~/.tomb/ add ~/.tomb/.gitignore
	git -C ~/.tomb/ commit -m 'initialized .git and added .gitignore'
	[[ "$git_remote" != "skip" ]] && git -C ~/.tomb/ push
	echo "Success, tomb is initialized."
}

while [ "$#" -gt 0 ]; do
        case "$1" in
		help) helpFunction; shift 1;;
                --help) helpFunction; shift 1;;
                -h) helpFunction; shift 1;;
		h) helpFunction; shift 1;;
                init) initFunction; shift 1;;
		i) initFunction; shift 1;;
		-i) initFunction; shift 1;;
		open) openFunction; shift 1;;
		o) openFunction; shift 1;;
		-o) openFunction; shift 1;;
                close) closeFunction; shift 1;;
		c) closeFunction; shift 1;;
		-c) closeFunction; shift 1;;
		status) statusFunction; shift 1;;
                s) statusFunction; shift 1;;
		-s) statusFunction; shift 1;;
		check) checkFunction; shift 1;;
		-*) exitFunction "$1"; shift 1;;
                *) exitFunction "$1"; shift 1;;
        esac
done

exit 0

