#!/usr/bin/env bash
if [ "$1" = "--remove" ]
then
    echo "removing CheemaFy"
    sh ~/programs/CheemaFy/myPlugins/restore_old_config.sh
    exit
fi

place=`pwd`
prog=$HOME"/programs"

# get linux name
__linux=`lsb_release -i`
IFS=':'
read -a _linux <<< "$__linux"
__linux=${_linux[1]}


#these commands are safe to execute they create folder only when
#the folders are missing, they dont harm old content
mkdir -p $prog"/python/importlib"
mkdir -p $HOME"/.CheemaFy/srb_clip_board"


#file to hold your password
if ! [ -f ~/.CheemaFy/.pass ]
then
    i=1
    while [ $i -ne 0 ]
    do
        stty -echo
        printf "[sudo] password for $USER:" && read passwrd
        stty echo
        echo "" && echo $passwrd > ~/.CheemaFy/.pass
        sudo -k -S ls < ~/.CheemaFy/.pass > /dev/null 2>&1
        i=$?
        if [ $i -ne 0 ]
        then
            sleep 1
            if [ -f ~/dead.letter ]
            then
                rm ~/dead.letter
            fi
            echo "[sudo], try again."
        fi
    done
fi


printf "Do you want to add vim plugins y/n : "
read ans


if ! [ $place = $prog"/CheemaFy" ]
then
    echo creating CheemaFy
    cp -r ../CheemaFy $prog
    cd $prog"/CheemaFy/"
    sh $prog"/CheemaFy/myPlugins/save_old_config.sh"
    sh $prog"/CheemaFy/CheemaFy.sh"
    exit
fi


#customise terminal
UUID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
#gsettings list-keys  org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    cursor-shape ibeam
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    background-color 'rgb(0,0,0)'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    default-size-columns 126
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    default-size-rows 33
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    foreground-color 'rgb(231,238,232)'

_comment="
 I removed these settings as they are not  in new gnome, so they cause problem in arch.
 they work only in ubuntu
 not in arch as it has updated gnome.
 I will soon figure something out as I love transparent terminal
"
if [ "$__linux" = "	Ubuntu" ]
then
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
        use-transparent-background true
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
        background-transparency-percent 3
fi



#copy home_files to its position
cp -r ~/programs/CheemaFy/home_files/. ~/
cp -r ~/programs/CheemaFy/srbScripts ~/programs
cp -r ~/programs/CheemaFy/importlib ~/programs/python


#install other useful things
if [ "$__linux" = "	Ubuntu" ]
then
    sudo -S -k apt-get update -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install vim -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install xsel -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install build-essential -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install cmake -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install xdotool -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install wmctrl -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install tilda -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install tree -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install vim-gnome -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install clang-format-5.0 -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install clang-4.0 -y < ~/.CheemaFy/.pass
    sudo -S -k apt-get install libboost-all-dev -y < ~/.CheemaFy/.pass
elif [ "$__linux" = "	Arch" ]
then
    echo "in arch"
    sudo pacman -Syu
    sudo pacman -S wpa_supplicant wireless_tools networkmanager network-manager-applet

    sudo pacman -S base-devel python python3 gcc firefox bash-completion lsb-release
    sudo pacman -S ntfs-3g
    sudo pacman -S xsel gvim cmake xdotool wmctrl tilda tree clang boost boost-libs

    systemctl enable NetworkManager.service
    systemctl enable wpa_supplicant.service
    systemctl start NetworkManager.service
fi



#install Vundle
if ! [ -d "$HOME"/.vim/bundle/ ]
then
    echo installing vim bundle
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

echo instaling vimSyntax
cp -r ~/programs/CheemaFy/myPlugins/vim/syntax   ~/.vim/
cp -r ~/programs/CheemaFy/myPlugins/vim/ftdetect ~/.vim/

if [ $ans = "y" ]
then
    vim hell -c ":PluginInstall" -c ":q!" -c ":q!"
    ~/.vim/bundle/YouCompleteMe/install.py --clang-completer --system-libclang
fi

#gnome-terminal -e "bash -c \"echo 'Thanks for using CheemaFy' ; exec bash\"" & disown
#wmctrl -i -c `xdotool getactivewindow` &
echo 'Thanks for using CheemaFy'
