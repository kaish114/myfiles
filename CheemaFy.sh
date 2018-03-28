#!/usr/bin/env bash
if [ "$1" = "--remove" ]
then
    echo "removing CheemaFy"
    sh ~/programs/CheemaFy/myPlugins/restore_old_config.sh
    exit
fi

place=`pwd`
prog=$HOME"/programs"

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
#    stty -echo
#    printf "enter your password : " && read  passwrd
#    stty echo
#    echo ""
#    echo $passwrd > ~/.CheemaFy/.pass
fi

if ! [ $place = $prog"/CheemaFy" ]
then
    echo creating CheemaFy
    cp -r ../CheemaFy $prog
    cd $prog"/CheemaFy/"
    sh $prog"/CheemaFy/myPlugins/save_old_config.sh"
    sh $prog"/CheemaFy/CheemaFy.sh"
    exit
fi


#here begins main CheemaFy

#customise terminal
UUID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
#gsettings list-keys  org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    cursor-shape ibeam
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    background-color 'rgb(0,0,0)'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    default-size-columns 126
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    default-size-rows 33
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    background-transparency-percent 23
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ \
    foreground-color 'rgb(231,238,232)'



#these commands are safe to execute .. updates the files ..
#they can only add new files to system cannot delete older ones with diff names

#copy home_files to its position
cp -r ~/programs/CheemaFy/home_files/. ~/

#copy folder srbScripts to  ~/programs/srbScript
cp -r ~/programs/CheemaFy/srbScripts ~/programs

#copy importlib
cp -r ~/programs/CheemaFy/importlib ~/programs/python

sudo -S -k apt-get update -y < ~/.CheemaFy/.pass

## safe commands
#install xsel
if ! type xsel > /dev/null 2>&1;
then
    echo installing xsel
    sudo -S -k apt-get install xsel -y < ~/.CheemaFy/.pass
fi

#install vim
if ! type vim > /dev/null 2>&1;
then
    echo installing vim
    sudo -S -k apt-get install vim -y < ~/.CheemaFy/.pass
fi


#install Vundle
if ! [ -d "$HOME"/.vim/bundle/ ]
then
    #can create folder on its own
    echo installing vim bundle
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    echo installing YouCompleteMe
    cp ~/programs/CheemaFy/myPlugins/vim/bundle/YouCompleteMe ~/.vim/bundle/
fi

echo instaling vimSyntax
cp -r ~/programs/CheemaFy/myPlugins/vim/syntax   ~/.vim/
cp -r ~/programs/CheemaFy/myPlugins/vim/ftdetect ~/.vim/

#install other useful things
sudo -S -k apt-get install build-essential -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install cmake -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install xdotool -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install wmctrl -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install tilda -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install tree -y < ~/.CheemaFy/.pass

#install vim plugins
vim hell -c ":PluginInstall" -c ":q!" -c ":q!"
sudo -S -k apt-get install vim-gnome -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install clang-format-5.0 -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install clang-4.0 -y < ~/.CheemaFy/.pass
sudo -S -k apt-get install libboost-all-dev -y < ~/.CheemaFy/.pass
~/.vim/bundle/YouCompleteMe/install.py --clang-completer --system-libclang

#let the changes begin
gnome-terminal -e "bash -c \"echo 'Thanks for using CheemaFy' ; exec bash\"" & disown
wmctrl -i -c `xdotool getactivewindow` &
