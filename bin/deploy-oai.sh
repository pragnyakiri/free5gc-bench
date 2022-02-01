set -ex
COMMIT_HASH=$1
NODE_ROLE=$2
#BINDIR=`dirname $0`
ETCDIR=/local/repository/etc
SRCDIR=/var/tmp
CFGDIR=/local/repository/etc
CN5G_REPO="https://github.com/pragnyakiri/free5gc-compose"

#source $BINDIR/common.sh

if [ -f $SRCDIR/oai-setup-complete ]; then
    echo "setup already ran; not running again"
    if [ $NODE_ROLE == "cn" ]; then
        sudo sysctl net.ipv4.conf.all.forwarding=1
        sudo iptables -P FORWARD ACCEPT
    fi
    #exit 0
fi

function setup_cn_node {
    # Install docker, docker compose, wireshark/tshark
    echo setting up cn node
    sudo apt-get update && sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

    echo "adding docker gpg key"
    until curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
    do
        echo "."
        sleep 2
    done

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo add-apt-repository -y ppa:wireshark-dev/stable
    echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections

    sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        wireshark \
        tshark

    #sudo systemctl enable docker
    #sudo usermod -aG docker $USER

    #printf "installing compose"
    #until sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; do
    #    printf '.'
    #    sleep 2
    #done

    #sudo chmod +x /usr/local/bin/docker-compose

    #echo creating demo-oai bridge network...
    #sudo docker network create \
    #  --driver=bridge \
    #  --subnet=192.168.70.128/26 \
    #  -o "com.docker.network.bridge.name"="demo-oai" \
    #  demo-oai-public-net
    #echo creating demo-oai bridge network... done.

    #sudo sysctl net.ipv4.conf.all.forwarding=1
    #sudo iptables -P FORWARD ACCEPT

    #echo cloning and syncing free5gc-compose...
    #cd $SRCDIR
    #git clone $CN5G_REPO free5gc-compose
    #cd free5gc-compose
    #git checkout $COMMIT_HASH
    #echo cloning and syncing free5gc-compose... done.
    #sudo make base
    #sudo docker-compose build
    #echo setting up cn node... done.

}

if [[ $NODE_ROLE == "cn" ]]; then
    setup_cn_node
fi

touch $SRCDIR/oai-setup-complete