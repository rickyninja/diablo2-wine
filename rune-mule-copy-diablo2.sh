#!/usr/bin/env bash
# Copy the item mules from backup when hashes don't match.
# This scripts is run via my PlugY launcher when I start the game
# so I don't have to manually copy runes.

dryrun=0
backupdir=/home/jeremys/archives/games/diablo2/item-mules
gamedir='/home/jeremys/.wine/drive_c/Program Files/Diablo II/save'
mules=(
    Runebrute.d2s
    eth_swords.d2s
    eth_polearms.d2s
    soc_flails.d2s
    foursoc_armor.d2s
    soc_helm.d2s
    soc_staff.d2s
    soc_shields.d2s
    phase_blades.d2s
    pgems.d2s
    soc_bow.d2s
    soj.d2s
)

function dry {
    if [ $dryrun -eq 1 ]; then
        return 0
    fi
    return 1
}

function md5 {
    local file=$1
    printf -- $(md5sum "$file" | cut -f1 -d ' ')
}

function cmp {
    local src=$1
    local dst=$2

    h1=$(md5 "$src")
    h2=$(md5 "$dst")
    if [[ $h1 != $h2 ]]; then
        if dry; then
            echo cp "$src" "$dst"
        else
            cp "$src" "$dst"
        fi
    fi
}

function comp {
    for mule in ${mules[@]}; do
        md5sum "$gamedir/$mule" "$backupdir/$mule"
        echo
    done
}

# After finding a new item, backup the game character files.
function backup {
    for mule in ${mules[@]}; do
        cmp "$gamedir/$mule" "$backupdir/$mule" 
    done
}

# Restore game files from backup.
function restore {
    for mule in ${mules[@]}; do
        cmp "$backupdir/$mule" "$gamedir/$mule"
    done
}

function usage {
    cat <<EOF
usage:

# restore game mule backups into game directory
$0 -r

# show what restorations would occur without clobbering any data
$0 -rd

# save game mules into backup directory
$0 -b

# show what backups would occur without clobbering any data
$0 -db

# show an md5 comparison of mule files
$0 -c

# show help
$0 -h
EOF
}

while getopts "hbcdr" arg; do
    case $arg in
        h) usage; exit ;;
        d) dryrun=1 ;;
        b) backup; exit ;;
        c) comp; exit ;;
        r) restore; exit ;;
        *) usage; exit ;;
    esac
done
usage
