#!/bin/sh

yay -S fcitx fcitx-gtk2 fcitx-gtk3 fcitx-configtool fcitx-rime fcitx-googlepinyin

conf_file=$HOME/.xprofile

if [ -f $conf_file ]; then
    echo "$conf_file exists! Now it is moved to $HOME/.xprofile_bak"
    mv $conf_file $HOME/.xprofile_bak
fi

echo 'export GTK_IM_MODULE=fcitx' >>$conf_file
echo 'export QT_IM_MODULE=fcitx' >>$conf_file
echo 'export XMODIFIERS=@im=fcitx' >>$conf_file
