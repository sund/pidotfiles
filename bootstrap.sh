#!/bin/bash
# bootstrap installs things.

###
## Variables
#

OSNAME=`uname -s`
cd "$(dirname "${BASH_SOURCE}")"
DOTFILES_ROOT="`pwd`"
set -e

### 
## functions
#

# fix missing ~/.vim/backups & ~/.vim/swaps
if [ ! -f ~/.vim/backups ]; then mkdir -p ~/.vim/backups; fi
if [ ! -f ~/.vim/swaps ]; then mkdir -p ~/.vim/swaps; fi
}

function updateRepo() {
    git pull
}

function getGist() {
    if [ -e gist/rawFile.conf ]
    then
        echo 'Found gist config!'
        bash gist/gistGet.sh
    fi
}

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

link_files () {
  ln -fs $1 $2
  success "linked $1 to $2"
}

install_dotfiles () {
  info 'installing dotfiles\n'

  overwrite_all=false
  backup_all=false
  skip_all=false

  for source in `find -L $DOTFILES_ROOT -maxdepth 2  -not \( -path *.AppleDouble* -prune \)  -name \*.symlink  -print`
  do
    dest="$HOME/.`basename \"${source%.*}\"`"

    if [ -f $dest ] || [ -d $dest ]
    then

      overwrite=false
      backup=false
      skip=false

      if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
      then
        user "File already exists: `basename $source`.\nWhat do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi

      if [ "$overwrite" == "true" ] || [ "$overwrite_all" == "true" ]
      then
        rm -rf $dest
        success "removed $dest"
      fi

      if [ "$backup" == "true" ] || [ "$backup_all" == "true" ]
      then
        mv $dest $dest\.backup
        success "moved $dest to $dest.backup"
      fi

      if [ "$skip" == "false" ] && [ "$skip_all" == "false" ]
      then
        link_files $source $dest
      else
        success "skipped $source"
      fi

    else
      link_files $source $dest
    fi

  done
}

###
## Work
#

pwd

if ( updateRepo )
then
	install_dotfiles
	getGist
else
	fail "Git pull."
fi

echo ''
echo '  All installed!'

###
## unset things we don't need
#

unset getGist
source ~/.bash_profile
