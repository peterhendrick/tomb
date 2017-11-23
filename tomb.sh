#! /bin/bash

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
	tar -zx -f ~/.tomb/tomb.tar.gz -C ~/.tomb/ --strip-components=3
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
	pass_change_date="$(git -C ~/.password-store/ log -1 --format=%ct)"
	tomb_change_date="$(git -C ~/.tomb log -1 --format=%ct)"
	if [[ "$pass_change_date" -lt "$tomb_change_date" && -d ~/.password-store/.git/ && -d ~/.tomb/.git/ && -e ~/.tomb/tomb.tar.gz.gpg ]]; then
		rm -rf ~/.password-store/
		echo "No changes since last close. Removing password store, but no updates to be made."
	else
		cp -a ~/.password-store/ ~/.tomb/tomb
		if [[ -e ~/.tomb/tomb.tar.gz.gpg ]]; then
			rm ~/.tomb/tomb.tar.gz.gpg
		fi
		tar -zc -f ~/.tomb/tomb.tar.gz ~/.tomb/tomb
		gpg -s -r "EC3ED53D" -e ~/.tomb/tomb.tar.gz && rm -rf ~/.tomb/tomb ~/.tomb/tomb.tar.gz 
		git -C ~/.tomb/ add ~/.tomb/tomb.tar.gz.gpg
		git -C ~/.tomb/ commit -m 'tomb update'
		rm -rf ~/.password-store/
		git -C ~/.tomb/ push
	fi
}

function initFunction {
	if [[ -d ~/.tomb/ ]]; then
		echo "Tomb is already initialized."
		exit 1
	fi
	mkdir ~/.tomb/
	git -C ~/.tomb/ init
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
		-*) exitFunction "$1"; shift 1;;
                *) exitFunction "$1"; shift 1;;
        esac
done

exit 0

