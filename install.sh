#/bin/bash

DOTPATH=~/dotfiles

# https://qiita.com/koara-local/items/1377ddb06796ec8c628a
# https://gist.github.com/natefoo/814c5bf936922dad97ff
function os() {
  distro_name="unknown"
  if [ -e /etc/debian_version ] || [ -e /etc/debian_release ]; then
    if [ -e /etc/lsb-release ]; then
      # Ubuntu
      # include Elementary OS
      distro_name="ubuntu"
    else
      # Debian
      distro_name="debian"
    fi
  elif [ -e /etc/redhat-release ]; then
    if [ -e /etc/oracle-release ]; then
      # Oracle Linux
      distro_name="oracle"
    elif [ -e /etc/centos-release ]; then
      # CentOS
      distro_name="centos"
    else
      # Red Hat Enterprise Linux
      distro_name="redhat"
    fi
  elif [ -e /etc/fedora-release ]; then
    # Fedra
    distro_name="fedora"
  elif [ -e /etc/SuSE-release ]; then
    # SuSE Linux
    distro_name="suse"
  elif [ -e /etc/arch-release ]; then
    # Arch Linux
    distro_name="arch"
  elif [ -e /etc/turbolinux-release ]; then
    # Turbolinux
    distro_name="turbol"
  elif [ -e /etc/mandriva-release ]; then
    # Mandriva Linux
    distro_name="mandriva"
  elif [ -e /etc/vine-release ]; then
    # Vine Linux
    distro_name="vine"
  elif [ -e /etc/gentoo-release ]; then
    # Gentoo Linux
    distro_name="gentoo"
  elif [ -e /etc/os-release ]; then
    # FIXME
    NAME=$(cat /etc/os-release | grep --regexp="^NAME=" | sed -e "s/\"//g" | sed -e "s/NAME=//g")

    case $NAME in
      "Amazon Linux AMI")
        # Amazon Linux
        distro_name="amazon"
        ;;
      "Arch Linux")
        # Arch Linux
        distro_name="arch"
        ;;
      "CentOS Linux")
        # CentOS
        distro_name="centos"
        ;;
      "Debian GNU/Linux")
        # Debian
        distro_name="debian"
        ;;
      "Fedora")
        # Fedora
        distro_name="fedora"
        ;;
      "Kali GNU/Linux")
        # Kali Linux
        distro_name="kali"
        ;;
      "Mageia")
        # Mageia
        distro_name="mageia"
        ;;
      "openSUSE")
        # openSUSE
        distro_name="opensuse"
        ;;
      "Raspbian GNU/Linux")
        # Raspberry Pi OS
        distro_name="raspbian"
        ;;
      "Scientific Linux")
        # Scientific Linux
        distro_name="scientific"
        ;;
      "Slackware")
        # Slackware Linux
        distro_name="slackware"
        ;;
      "SLES")
        # SUSE Linux Enterprise Server
        distro_name="sles"
        ;;
      "Ubuntu")
        # Ubuntu
        distro_name="ubuntu"
        ;;
    esac
  fi

  echo "${distro_name}"
}

# https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
function install_if_not_exist() {
  if [ -x "$(command -v $1)" ]; then
    echo "already installed ${1}"
  else
    echo "----- install ${1} -----"
    case "$(os)" in
      ubuntu | debian | raspbian)
        sudo apt install -y $1
        ;;
      redhat | centos | amazon)
        sudo yum -y install $1
        ;;
      *)
        echo "detected unsupported OS."
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

  # Permission deniedでinstallに失敗するので、予めsudoで作成
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
  ln -sf $DOTPATH/zsh/$file ~/$file
  echo "Linked: ${file}."; \
done

echo "##### finish to setup zsh #####"

echo "##### setup tmux #####"

install_if_not_exist tmux

echo "----- link tmux setting files -----"
LINK_FILES=(.tmux.conf .config/tmux)
for file in ${LINK_FILES[@]}; do \
  unlink ~/$file&>/dev/null
  ln -sf $DOTPATH/tmux/$file ~/$file
  echo "Linked: ${file}."; \
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
  ln -sf $DOTPATH/vim/$file ~/$file
  echo "Linked: ${file}."; \
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

# Permission deniedでinstallに失敗するので、予めsudoで作成
MAKE_DIRS=(. .cache repos/github.com)
for dir in ${MAKE_DIRS[@]}; do \
  sudo mkdir -p ~/.config/dein/$dir
  sudo chmod -R 777 ~/.config/dein/$dir; \
done

echo "##### finish to setup vim #####"

cd ~

echo "##### setup linuxbrew #####"
# by https://docs.brew.sh/Homebrew-on-Linux

echo "----- install requirement packeage -----"
install_if_not_exist file
install_if_not_exist git
case "$(os)" in
  ubuntu | debian | raspbian)
    sudo apt-get install -y build-essential
    ;;
  redhat | centos | amazon)
    sudo yum groupinstall -y 'Development Tools'
    sudo yum install -y libxcrypt-compat # needed by Fedora 30 and up
    ;;
  *)
    echo "detected unsupported OS by linuxbrew."
    echo "please check https://docs.brew.sh/Homebrew-on-Linux."
    ;;
esac

echo "----- install linuxbrew -----"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.zshrc && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.zshrc

echo "----- install command using linuxbrew -----"
brew install exa
brew install procs
brew install fd
brew install ripgrep

echo "##### finish to setup linuxbrew #####"

echo
echo "zsh:"
echo "please run the following command."
echo "  chsh -s $(command -v zsh)"
echo
echo "docker:"
echo "if you want to install docker, please run the following command."
echo "  cd ${DOTPATH}/bin"
echo "  ./install_docker.sh"
echo
echo
echo "Installed."
echo

exit 0
