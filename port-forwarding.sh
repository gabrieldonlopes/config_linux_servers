#!/bin/bash

# --------------------------------------------------------
# port-forwarding.sh
#
# Description: Script para redirecionamento de portas com iptables
# Autor: gdon - gabriellopes.zip@gmail.com
# Version: 2.0
# Data: 2025-10-01 14:53:01
#
# Uso:
#    ./port-forwarding.sh <SERVER_IP> <PROTOCOLO> <PORTA_LOCAL> <PORTA_DESTINO>
# Exemplo:
#    ./port-forwarding.sh 192.168.0.2 tcp 8080 8080
#    ./port-forwarding.sh 192.168.0.2 udp 25565 25565
#
# --------------------------------------------------------


SERVER_IP=$1
PROTO=${2,,}      # protocolo (tcp/udp) em minúsculo
LOCAL_PORT=$3     # porta exposta no VPS
DEST_PORT=$4      # porta real no servidor

if [[ -z "$SERVER_IP" || -z "$PROTO" || -z "$LOCAL_PORT" || -z "$DEST_PORT" ]]; then
  echo "Uso: $0 <SERVER_IP> <PROTOCOLO tcp|udp> <PORTA_LOCAL> <PORTA_DESTINO>"
  exit 1
fi

echo "Redirecionando $PROTO $LOCAL_PORT → $SERVER_IP:$DEST_PORT ..."

sudo iptables -t nat -A PREROUTING -p $PROTO --dport $LOCAL_PORT -j DNAT --to-destination $SERVER_IP:$DEST_PORT
sudo iptables -t nat -A POSTROUTING -p $PROTO -d $SERVER_IP --dport $DEST_PORT -j MASQUERADE
sudo iptables -A INPUT -p $PROTO --dport $LOCAL_PORT -j ACCEPT

echo "Redirecionamento configurado."


# --------------------------------------------------------
# Fim do script
# --------------------------------------------------------
