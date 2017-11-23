#! /bin/bash

if [ "$#" = 0 ]; then
        echo "Error: use open or close or use -h or --help." >&2
        exit 1
fi

# Function Definitions
function exitFunction {
        echo "Error - Bad Argument: $1 not found. Use -h or --help." >&2
        exit 1
}

function helpFunction {
        echo "Usage: $0 [arguments...]"; echo
        echo "   -h| --help                 Show help."; echo
        echo "   open                       open the tomb for pass"; echo
	echo "   close                      close the ~/.password-store/ dir into a tomb"; echo
	echo "   status                     show the tomb's current status"; echo
	exit 1
}

function statusFunction {
	if [[ -d ~/.password-store/ ]]; then
		echo "Tomb is open."
	else
		echo "Tomb is closed."
	fi
	exit 0
}

function openFunction {
        if [[ -d ~/.password-store/ ]]; then
                echo "Password store already exists"
                exit 1
        fi
	if [[ -d ~/.tomb/tomb/ ]]; then
		rm -rf ~/.tomb/tomb/
	fi

        gpg -d ~/.tomb/tomb.tar.gz.gpg > ~/.tomb/tomb.tar.gz || { echo 'Decryption failed' ; exit 1; }
	tar -zx -f ~/.tomb/tomb.tar.gz -C ~/.tomb/ --strip-components=3
	mkdir ~/.password-store
	cp -a ~/.tomb/tomb/ ~/.password-store/
	rm -rf ~/.tomb/tomb/ ~/.tomb/tomb.tar.gz
}

function closeFunction {
	pass_change_date="$(git -C ~/.password-store/ log -1 --format=%ct)"
	tomb_change_date="$(git -C ~/.tomb log -1 --format=%ct)"
	if [[ "$pass_change_date" -lt "$tomb_change_date" ]]; then
		rm -rf ~/.password-store/
		echo "No changes since last close. No update to be made."
	else
		cp -a ~/.password-store/ ~/.tomb/tomb
		if [[ -e ~/.tomb/tomb.tar.gz.gpg ]]; then
			rm ~/.tomb/tomb.tar.gz.gpg
		fi
		tar -zc -f ~/.tomb/tomb.tar.gz ~/.tomb/tomb
		gpg -s -r "EC3ED53D" -e ~/.tomb/tomb.tar.gz && rm -rf ~/.tomb/tomb ~/.tomb/tomb.tar.gz ~/.password-store/
		git -C ~/.tomb/ add ~/.tomb/tomb.tar.gz.gpg
		git -C ~/.tomb/ commit -m 'tomb update'
		git -C ~/.tomb/ push
	fi
}

# while loop to parse arguments
while [ "$#" -gt 0 ]; do
        case "$1" in
                --help) helpFunction; shift 1;;
                -h) helpFunction; shift 1;;
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

