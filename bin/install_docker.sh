#/bin/bash

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

echo "##### setup docker #####"

if [ -x "$(command -v docker)" ]; then
  echo "already installed docker"
else
  case "$(os)" in
    ubuntu | debian)
      echo "----- uninstall dependencies -----"
      sudo apt-get remove -y docker docker-engine docker.io containerd runc

      echo "----- install dependencies -----"
      sudo apt-get update -y
      sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key  add -
      sudo apt-key fingerprint 0EBFCD88

      echo "----- add repository -----"
      sudo add-apt-repository \
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
      sudo yum-config-manager \
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

  sudo gpasswd -a $(whoami) docker
  sudo chmod 666 /var/run/docker.sock
fi

if [ -x "$(command -v docker-compose)" ]; then
  echo "already installed docker-compose"
else
  echo "----- install docker-compose -----"
  export compose="1.24.0"
  echo "install docker-compose v${compose}"
  echo "if you want other version, please check https://github.com/docker/compose/blob/master/CHANGELOG.md ."
  sudo curl -L https://github.com/docker/compose/releases/download/${compose}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod 0755 /usr/local/bin/docker-compose
fi

echo "##### finish to setup docker #####"
