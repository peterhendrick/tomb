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
	check=$(tomb status)
	echo "$check"
	if [[ "$check" = "Tomb is open." ]]; then
		echo "Closing tomb."
		closeFunction
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
		check) checkFunction; shift 1;;
		-*) exitFunction "$1"; shift 1;;
                *) exitFunction "$1"; shift 1;;
        esac
done

exit 0

