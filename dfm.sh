#!/bin/bash
mkdir -p ~/.dfm/dotfiles
prog_name="$(basename $0)"
VER="1.0"
set -e

# Create a new dotfile. In ~/.dfm/dotfiles, files usually do not have a dot at the start for easier navigation.
function create() {
    touch ~/.dfm/dotfiles/"$1"

    echo "Created dotfile $1."
}

# Remove a dotfile.
function remove() {
    rm ~/.dfm/dotfiles/"$1"
    find / -type l -samefile "$1" -delete
    echo "Removed dotfile $1."
}

# Move a dotfile to ~/.dfm/dotfiles and remove first dot from basename.
function occupy() {
    mv ~/."$1" ~/.dfm/dotfiles/"${1#.}"
    ln -s ~/.dfm/dotfiles/"${1#.}" ~/."${1#.}"
    echo "$1 has now been occupied by dfm. If you plan publishing"
    echo "please ensure the dotfiles have no personal info."
}

# Move a file out of ~/.dfm/dotfiles and add a dot to the name.
function liberate() {
    rm ~/."${1#.}"
    mv ~/.dfm/dotfiles/"$1" ~/."${1#.}"
    echo "$1 has been liberated and is no longer under dfm's control."
}

# Print help message.
function dfmhelp() {
    echo "usage: $prog_name [command] [arguments]"
    echo ""
    echo "subcommands:"
    echo "  create   [filename]               Create a new dotfile. Optionally, do not create a link"
    echo "                                    (see dfm help-full)."
    echo "  remove   [filename]               Remove a dotfile."
    echo "  occupy   [filename]               Occupy an existing dotfile."
    echo "  liberate [filename]               Liberate a dotfile from dfm."
    echo "  help                              Print this help message."
    echo "  help-full                         Print a more complex help message with options." 
}
function dfmhelp2() {
    echo "usage: $prog_name [command] [arguments]"
    echo ""
    echo "subcommands:"
    echo "  create   [filename]               Create a new dotfile."
    echo "  remove   [filename]               Remove a dotfile."
    echo "  occupy   [filename]               Occupy an existing dotfile."
    echo "  liberate [filename]               Liberate a dotfile from dfm."
    echo "  help                              Print the simple help message."
    echo "  help-full                         Print this help message." 
    echo "  update                            Update to the newest version of dfm."
    echo "options:"
    echo "  -n                                Use with the create subcommand to inhibit creation of a symlink"
    echo "                                    to the traditional dotfile name."
}

# Parse command line arguments.
case "$1" in
    create)
        create "$2"
        ;;
    remove)
        remove "$2"
        ;;
    occupy)
        occupy "$2"
        ;;
    liberate)
        liberate "$2"
        ;;
    update)
        echo "Downloading dfm..."
        git clone -s https://github.com/getdfm/dfm.git ~/.dfm-copy
        echo "Copying..."
        cp ~/.dfm-copy/dfm.sh ~/.local/bin/dfm
        rm -rf ~/.dfm-copy
        echo "New version installed, try dfm version"
        ;;
    help)
        dfmhelp
        ;;
    help-full)
        dfmhelp2
        ;;
    version)
        echo "dfm $VER"
        ;;
    *)
        if [ -z "$1" ]; then
          dfmhelp
        else
          echo "$1: subcommand not found, run $0 help"
        fi
        ;;
esac
