#/bin/bash

DOTPATH=~/dotfiles

# https://qiita.com/koara-local/items/1377ddb06796ec8c628a
function os() {
  distri_name=""
  if [ -e /etc/debian_version ] || [ -e /etc/debian_release ]; then
    # Check Ubuntu or Debian
    if [ -e /etc/lsb-release ]; then
      # Ubuntu
      # include Elementary OS
      distri_name="ubuntu"
    else
      # Debian
      distri_name="debian"
    fi
  elif [ -e /etc/fedora-release ]; then
    # Fedra
    distri_name="fedora"
  elif [ -e /etc/redhat-release ]; then
    if [ -e /etc/oracle-release ]; then
      # Oracle Linux
      distri_name="oracle"
    else
      # Red Hat Enterprise Linux
      # include centOS
      distri_name="redhat"
    fi
  elif [ -e /etc/arch-release ]; then
    # Arch Linux
    distri_name="arch"
  elif [ -e /etc/turbolinux-release ]; then
    # Turbolinux
    distri_name="turbol"
  elif [ -e /etc/SuSE-release ]; then
    # SuSE Linux
    distri_name="suse"
  elif [ -e /etc/mandriva-release ]; then
    # Mandriva Linux
    distri_name="mandriva"
  elif [ -e /etc/vine-release ]; then
    # Vine Linux
    distri_name="vine"
  elif [ -e /etc/gentoo-release ]; then
    # Gentoo Linux
    distri_name="gentoo"
  else
    # Other
    distri_name="unknown"
  fi

  echo "${distri_name}"
}

# https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
function install_if_not_exist() {
  if [ -x "$(command -v $1)" ]; then
    echo "already installed ${1}"
  else
    echo "----- install ${1} -----"
    case "$(os)" in
      ubuntu | debian)
        sudo apt install -y $1
        ;;
      redhat | suse)
        sudo yum -y install $1
        ;;
      *)
        echo "unsupported os."
        echo "please check https://github.com/PiroHiroPiro/dotfiles_for_server."
        exit 1
        ;;
    esac
  fi
}

echo "##### download dotfiles #####"

install_if_not_exist curl
install_if_not_exist tar

curl -sSL "https://github.com/PiroHiroPiro/dotfiles_for_server/archive/master.tar.gz" | tar -zxv
# 解凍したら，DOTPATH に置く
mv -f dotfiles_for_server-master $DOTPATH

cd "${DOTPATH}"

if [ $? -ne 0 ]; then
  echo "Not found: ${DOTPATH}"
  exit 1
fi

echo "##### finish to download dotfiles #####"

echo "##### setup zsh #####"

install_if_not_exist zsh

if [ ! -d ~/.zplug ]; then
  echo "----- install zplug -----"
  install_if_not_exist git
  # git clone https://github.com/zplug/zplug ~/.zplug
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

  # Permission deniedでinstallに失敗するので
  MAKE_DIRS=(log cache repos)
  for dir in ${MAKE_DIRS[@]}; do \
    sudo mkdir ~/.zplug/$dir
    sudo chmod -R 777 ~/.zplug/$dir; \
  done
fi

echo "----- link zsh setting files -----"
if [ ! -d ~/.config ]; then
  mkdir ~/.config
fi
LINK_FILES=(.zshrc .zsh_aliases .config/zsh)
for file in ${LINK_FILES[@]}; do \
  unlink ~/$file&>/dev/null
  ln -sf $(pwd)/zsh/$file ~/$file; \
done

echo "##### finish to setup zsh #####"

echo "##### setup tmux #####"

install_if_not_exist tmux

echo "----- link tmux setting files -----"
LINK_FILES=(.tmux.conf .config/tmux)
for file in ${LINK_FILES[@]}; do \
  unlink ~/$file&>/dev/null
  ln -sf $(pwd)/tmux/$file ~/$file; \
done

# https://did2memo.net/2017/05/18/tmux-attach-no-sessions-error/
export TMUX_TMPDIR=/tmp

echo "##### finish to setup tmux #####"

echo "##### setup vim #####"

install_if_not_exist vim

echo "----- link vim setting files -----"
LINK_FILES=(.vimrc dein.toml dein_lazy.toml .config/dein)
for file in ${LINK_FILES[@]}; do \
  unlink ~/$file&>/dev/null
  ln -sf $(pwd)/vim/$file ~/$file; \
done

echo "----- install dein.vim -----"
if [ -d ~/.config/dein/repos/github.com/Shougo/dein.vim/ ]; then
  echo "dein.vim is already installed"
else
  if [ ! -f ~/.config/dein/installer.sh ]; then
    echo "install dein installer.sh"
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > ~/.config/dein/installer.sh
  fi
  bash ~/.config/dein/installer.sh ~/.config/dein/ &>/dev/null
fi

# Permission deniedでinstallに失敗するので
MAKE_DIRS=(. .cache repos/github.com)
for dir in ${MAKE_DIRS[@]}; do \
  sudo mkdir -p ~/.config/dein/$dir
  sudo chmod -R 777 ~/.config/dein/$dir; \
done

echo "##### finish to setup vim #####"

echo
echo "zsh:"
echo "  please run the following command."
echo "    chsh -s $(command -v zsh)"
echo
echo "docker:"
echo "  if you want to install docker, please run the following command."
echo "    cd ${DOTPATH}/bin"
echo "    ./install_docker.sh"
echo
echo "Installed."
echo

exit 0
