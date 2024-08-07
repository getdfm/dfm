#!/bin/bash
# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}
function select_opt {
    select_option "$@" 1>&2
    local result=$?
    echo $result
    return $result
}
echo "> dotfiler installer"
echo
echo "Press ctrl+c to cancel, else install will start."
printf "\rInstalling in 3..."; sleep 1
printf "\rInstalling in 2..."; sleep 1
printf "\rInstalling in 1..."; sleep 1
echo -e "\rInstalling NOW...    "
set -e
git clone https://github.com/getdotfiler101/dotfiler.git ~/.dotfiler-copy
cp ~/.dotfiler-copy/dotfiler.sh ~/.local/bin/dotfiler
mkdir ~/.dotfiler/dotfiles -p
rm -rf ~/.dotfiler-copy
echo "Installed!"
echo "Please choose which dotfiles you want to manage."
echo "If you use the GitHub integration, note that you"
echo "should remove personal info from your dotfiles"
echo "and put them in files not occupied by dotfiler. Then"
echo "you can source those files through a sourcing"
echo "command in the respective dotfiles."
if [ -f "~/.zshrc" ]; then
echo "Do you want to control your zshrc using dotfiler?"
options=("Yes" "No")
case `select_opt "${options[@]}"` in
    0) ~/.local/bin/dotfiler occupy zshrc;;
    *) true;;
esac
fi
if [ -f "~/.bashrc" ]; then
echo "Do you want to control your bashrc using dotfiler?"
options=("Yes" "No")
case `select_opt "${options[@]}"` in
    0) ~/.local/bin/dotfiler occupy bashrc;;
    *) true;;
esac
fi
if [ -f "~/.vimrc" ]; then
echo "Do you want to control your vimrc using dotfiler?"
options=("Yes" "No")
case `select_opt "${options[@]}"` in
    0) ~/.local/bin/dotfiler occupy zshrc;;
    *) true;;
esac
fi
if [ -f "~/.profile" ]; then
echo "Do you want to control your profile (login script) using dotfiler?"
options=("Yes" "No")
case `select_opt "${options[@]}"` in
    0) ~/.local/bin/dotfiler occupy profile;;
    *) true;;
esac
fi
echo "> Tips:"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo "* Add .local/bin to your PATH by adding the following lines to your login script"
  echo "  (bashrc, zshrc, etc):"
  echo 'if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi'
fi
echo "* If you have other dotfiles, run dotfiler occupy [filename without dot] to occupy them."
echo "* Create a github repository (requires GitHub CLI to be installed) to publish dotfiles"
echo "  that HAVE NO PERSONAL DATA. Run dotfiler create-gh-repo to do this now."
