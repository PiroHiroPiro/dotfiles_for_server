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
  source ~/.zplug/init.zsh
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

if [ ! -d ~/.zsh ]; then
  mkdir ~/.zsh
fi
LINK_FILES=(.zshrc)
for file in ${LINK_FILES[@]}; do \
  unlink ~/.zsh/$file&>/dev/null
  ln -sf $(pwd)/zsh/$file ~/.zsh/$file; \
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

echo "##### setup docker #####"
case "$(os)" in
  ubuntu | debian)
    echo "----- uninstall dependencies -----" 
    sudo apt-get remove -y docker docker-engine docker.io containerd runc

    echo "----- install dependencies -----" 
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key  add -
    sudo apt-key fingerprint 0EBFCD88

    echo "----- add repository -----" 
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    echo "----- install docker -----" 
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    ;;

  redhat | suse)
    echo "----- uninstall dependencies -----" 
    sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

    echo "----- install dependencies -----"
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2

    echo "----- add repository -----" 
    yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

    echo "----- install docker -----" 
    sudo yum -y install docker-ce docker-ce-cli containerd.io
    ;;
  *)
    echo "unsupported os."
    echo "please check https://github.com/PiroHiroPiro/dotfiles_for_server."
    exit 1
    ;;
esac

echo "----- setup docker -----" 
sudo gpasswd -a $(whoami) docker
sudo chmod 666 /var/run/docker.sock    
        
echo "----- install docker-compose -----"
export compose='1.24.0'
echo "install v${compose}"
echo "if you want other version, please check https://github.com/docker/compose/blob/master/CHANGELOG.md ."
sudo curl -L https://github.com/docker/compose/releases/download/${compose}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod 0755 /usr/local/bin/docker-compose

echo "##### finish to setup docker #####"

echo
echo "zsh:"
echo "  please run the following command."
echo "    sudo echo $(command -v zsh) >> /etc/shells"
echo "    chsh -s $(command -v zsh)"
echo "    zsh"
echo "    source ~/.zshrc"
echo
echo "Installed."
echo

exit 0
