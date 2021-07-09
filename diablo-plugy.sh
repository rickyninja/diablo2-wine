#!/usr/bin/env bash
# Trying to find a way to have the game look good resolution-wise,
# and restore native desktop resolution after game exits.
# This script typically called via
# /home/jeremys/.local/share/applications/Diablo II - PlugY.desktop

function xrandr_output {
    printf -- $(xrandr | grep 'connected primary' | cut -d' ' -f1)
}

# Sometimes full resolution is not restored when the game exits; so far
# unable to figure out why.  I read something recently that said this
# is a bug in xorg that has yet to be resolved.
cleanup () {
    #xrandr -s 0 # native resolution
    #local res=$(xrandr | grep -A1 primary | tail -1 | awk '{print $1}')
    #if [[ "$res" != "2560x1600" ]]; then
    #    xrandr -s 2560x1600
    #fi
    /usr/bin/xrandr --output $(xrandr_output) --mode 2560x1600
    # Game.exe lingers after wine exits; kill it.
    # Oops, this prevents the game from starting.  wine must immediately
    # fork when running executables.
    #killall Game.exe
}

function waitGameEnd {
    while true; do
        ps auxwww | grep -q [G]ame.exe || break
        sleep 1
    done
}

# 24 Jun 2021 I installed some newer drivers that were not stable, but worked long enough for me to notice
# that Game.exe exited as expected with newer drivers.
#
# All the exe processes continue to run after I have exited the game.
#jeremys    4656  0.1  0.0 2671012 21664 ?       SNsl 14:47   0:00 C:\windows\system32\services.exe
#jeremys    4659  0.1  0.0 2685960 22632 ?       SNl  14:47   0:00 C:\windows\system32\winedevice.exe
#jeremys    4666  0.1  0.0 2681756 22444 ?       SNl  14:47   0:00 C:\windows\system32\plugplay.exe
#jeremys    4670  0.8  0.0 2708572 24084 pts/0   SNl+ 14:47   0:00 C:\windows\system32\explorer.exe /desktop
#jeremys    4674  0.2  0.0 2680832 22780 ?       SNl  14:47   0:00 C:\windows\system32\winedevice.exe
#jeremys    4688  0.0  0.0 2661644 12456 ?       SNl  14:47   0:00 C:\windows\system32\svchost.exe -k LocalServiceNetworkRestricted
#jeremys    4695  0.0  0.0 2665784 21280 ?       SNl  14:47   0:00 C:\windows\system32\rpcss.exe
#jeremys    4705  0.0  0.0 2677424 11996 pts/0   SN+  14:47   0:00 C:\windows\system32\conhost.exe --unix --width 151 --height 52 --server 0x10
#jeremys    4707 85.0  0.0 3060404 121768 pts/0  RNl+ 14:47   0:33 C:\Program Files\Diablo II\Game.exe
#jeremys    4816  0.0  0.0   6076   888 pts/1    SN+  14:48   0:00 grep --color=auto \.exe

#trap cleanup EXIT

# Copy item mules when game starts.  Do NOT copy on game exit, or it
# will not be possible to update the source files with new items.
/home/jeremys/bin/rune-mule-copy-diablo2.sh -r

# pwd will typically be set via the .desktop file, but cd if pwd
# is wrong so script may be tested from shell.
if [[ $(pwd) != "$HOME/PlugY" ]]; then
    cd $HOME/PlugY || exit 1
fi

export WINEPREFIX="/home/jeremys/.wine"
/usr/bin/xrandr --output $(xrandr_output) --mode 800x600
# I think PlugY forks before running the game.  The wine command returns immediately,
# complicating the killing of Game.exe.
wine PlugY.exe
#wine explorer /desktop=diablo2,800x600 "PlugY.exe"
# wineserver -w will wait forever, but works ok with sigint.  This wouldn't work when the game
# is lauched via desktop shortcut.
#wineserver -w

waitGameEnd
/usr/bin/xrandr --output $(xrandr_output) --mode 2560x1600
