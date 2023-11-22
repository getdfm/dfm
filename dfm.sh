#!/bin/bash
mkdir -p ~/.dfm/dotfiles
prog_name="$(basename $0)"
set -e

# Create a new dotfile. In ~/.dfm/dotfiles, files usually do not have a dot at the start for easier navigation.
function create() {
    touch ~/.dfm/dotfiles/"$1"
    if [[ ! " $@ " =~ " --no-link " ]]; then
      ln -s ~/.dfm/dotfiles/"$1" ~/."${1#.}"
    fi
    echo "Created dotfile $1."
}

# Remove a dotfile.
function remove() {
    rm ~/.dfm/dotfiles/"$1"
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
    echo "  create   [filename] [--no-link]   Create a new dotfile. Optionally, do not create a link."
    echo "  remove   [filename]               Remove a dotfile."
    echo "  occupy   [filename]               Occupy an existing dotfile."
    echo "  liberate [filename]               Liberate a dotfile from dfm."
    echo "  help                              Print this help message."
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
    help)
        dfmhelp
        ;;
    *)
        if [ -z "$1" ]; then
          dfmhelp
        else
          echo "$1: subcommand not found, run $0 help"
        fi
        ;;
esac
