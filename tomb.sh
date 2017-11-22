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

        gpg -d ~/.tomb/tomb.tar.gpg > ~/.tomb/tomb.tar
	tar x -f ~/.tomb/tomb.tar -C ~/.tomb/ --strip-components=3
	mkdir ~/.password-store
	cp -a ~/.tomb/tomb/ ~/.password-store/
	rm -rf ~/.tomb/tomb/ ~/.tomb/tomb.tar
}

function closeFunction {
	if [[ -e ~/.tomb/tomb.tar.gpg ]]; then
		rm ~/.tomb/tomb.tar.gpg
	fi
        cp -a ~/.password-store/ ~/.tomb/tomb	
	tar c -f ~/.tomb/tomb.tar ~/.tomb/tomb
	gpg -s -r "EC3ED53D" -e ~/.tomb/tomb.tar && rm -rf ~/.tomb/tomb ~/.tomb/tomb.tar ~/.password-store/
}

# while loop to parse arguments
while [ "$#" -gt 0 ]; do
        case "$1" in
                --help) helpFunction; shift 1;;
                -h) helpFunction; shift 1;;
                open) openFunction; shift 1;;
                close) closeFunction; shift 1;;
		status) statusFunction; shift 1;;
                -*) exitFunction "$1"; shift 1;;
                *) exitFunction "$1"; shift 1;;
        esac
done


exit 0

