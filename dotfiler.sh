#!/bin/bash
mkdir -p ~/.dotfiler/dotfiles
prog_name="$(basename $0)"
VER="1.0"
set -e

# Create a new dotfile. In ~/.dotfiler/dotfiles, files usually do not have a dot at the start for easier navigation.
function create() {
    while getopts "n" opt; do
      case $opt in
        n)
          export NO_LINK=1
          ;;
        \?)
          echo "create: invalid option: -$OPTARG" >&2
          ;;
      esac
    done
    touch ~/.dotfiler/dotfiles/"$1"
    if [ "$NO_LINK" != 1 ]; then
        ln -s ~/.dotfiler/dotfiles/"${1#.}" ~/."${1#.}"
    fi
    echo "Created dotfile $1."
}

# Remove a dotfile.
function remove() {
    rm ~/.dotfiler/dotfiles/"$1"
    find $HOME/ -type l -samefile "$1" -delete
    echo "Removed dotfile $1."
}

# Move a dotfile to ~/.dotfiler/dotfiles and remove first dot from basename.
function occupy() {
    mv ~/."$1" ~/.dotfiler/dotfiles/"${1#.}"
    ln -s ~/.dotfiler/dotfiles/"${1#.}" ~/."${1#.}"
    echo "$1 has now been occupied by dotfiler. If you plan publishing"
    echo "please ensure the dotfiles have no personal info."
}

# Move a file out of ~/.dotfiler/dotfiles and add a dot to the name.
function liberate() {
    rm ~/."${1#.}"
    mv ~/.dotfiler/dotfiles/"$1" ~/."${1#.}"
    echo "$1 has been liberated and is no longer under dotfiler's control."
}

# Print help message.
function dotfilerhelp() {
    echo "usage: $prog_name [command] [arguments]"
    echo ""
    echo "subcommands:"
    echo "  create   [filename]               Create a new dotfile. Optionally, do not create a link"
    echo "                                    (see dotfiler help -f)."
    echo "  remove   [filename]               Remove a dotfile."
    echo "  occupy   [filename]               Occupy an existing dotfile."
    echo "  liberate [filename]               Liberate a dotfile from dotfiler."
    echo "  edit                              Edit an occupied dotfile."
    echo "  help                              Print this help message. Pass -f to see a longer one."
    echo "  update                            Update to the newest version of dotfiler."
}
function dotfilerhelp2() {
    echo "usage: $prog_name [command] [arguments]"
    echo ""
    echo "subcommands:"
    echo "  create   [filename]               Create a new dotfile."
    echo "  remove   [filename]               Remove a dotfile."
    echo "  occupy   [filename]               Occupy an existing dotfile."
    echo "  liberate [filename]               Liberate a dotfile from dotfiler."
    echo "  help                              Print this help message with -f, or a simpler one with no"
    echo "                                    arguments."
    echo "  edit                              Edit an occupied dotfile."
    echo "  update                            Update to the newest version of dotfiler."
    echo
    echo "options:"
    echo "  -n                                Use with the create subcommand to inhibit creation of a"
    echo "                                    symlink to the traditional dotfile name."
    echo "  -f                                Show the full help message."
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
        echo "Downloading dotfiler..."
        git clone -q https://github.com/getdotfiler/dotfiler.git ~/.dotfiler-copy
        echo "Copying..."
        cp ~/.dotfiler-copy/dotfiler.sh ~/.local/bin/dotfiler
        rm -rf ~/.dotfiler-copy
        echo "New version installed, try dotfiler version"
        ;;
    help)
        while getopts "f" opt; do
          case $opt in
            f)
              export FULL=1
              ;;
            \?)
              echo "create: invalid option: -$OPTARG" >&2
              ;;
          esac
        done
        if [ "$FULL" = 1 ]; then
            dotfilerhelp2
        else
            dotfilerhelp
        fi
        ;;
    version)
        echo "dotfiler $VER"
        ;;
    *)
        if [ -z "$1" ]; then
          dotfilerhelp
        else
          echo "$1: subcommand not found, run $0 help"
        fi
        ;;
esac
