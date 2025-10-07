#!/bin/bash

# --------------------------------------------------------
# start-pzserver.sh
#
# Description: Script para iniciar servidor de project zomboid
# Autor: gdon - gabriellopes.zip@gmail.com
# Version: 1.0v
# Data: 2025-10-06 23:53:41
# --------------------------------------------------------

SERVER_DIR="/opt/pzserver"
USER="pzuser"
SCRIPT="start-server.sh"

echo "Iniciando servidor Project Zomboid como usuário $USER..."
echo "Diretório: $SERVER_DIR"
echo "Comando: $SCRIPT -nosteam"

# Verificar se o diretório existe
if [ ! -d "$SERVER_DIR" ]; then
    echo "Erro: Diretório $SERVER_DIR não encontrado!"
    exit 1
fi

# Verificar se o script existe
if [ ! -f "$SERVER_DIR/$SCRIPT" ]; then
    echo "Erro: Script $SCRIPT não encontrado em $SERVER_DIR!"
    exit 1
fi

# Verificar se o usuário existe
if ! id "$USER" &>/dev/null; then
    echo "Erro: Usuário $USER não existe!"
    exit 1
fi

# Iniciar o servidor
echo "Iniciando servidor..."
sudo -u $USER bash -c "cd '$SERVER_DIR' && ./'$SCRIPT' -nosteam"

# --------------------------------------------------------
# Fim do script
# --------------------------------------------------------
