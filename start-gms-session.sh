#!/bin/bash

# --------------------------------------------------------
# start-gms-session.sh
#
# Description: script para automatizar a criação de sessão  
#  	       tmux para usuário alvo
# Autor: gdon - gabriellopes.zip@gmail.com
# Version: 2.0
# Data: 2025-11-04 23:03:04
# --------------------------------------------------------

CONF_FILE="/home/gms/scripts/tmux_gms_session.conf"

if [ ! -f "$CONF_FILE" ]; then
    echo "❌ Erro: arquivo de configuração não encontrado em $CONF_FILE"
    exit 1
fi
source "$CONF_FILE"

# Verifica se a sessão já existe
tmux has-session -t $SESSION_NAME 2>/dev/null
if [ \$? != 0 ]; then
    # Cria nova sessão no background (-d)
    tmux new-session -d -s $SESSION_NAME -n $WINDOW0_NAME

    # Cria outras janelas
    tmux new-window -t $SESSION_NAME:1 -n $WINDOW1_NAME
    tmux new-window -t $SESSION_NAME:2 -n $WINDOW2_NAME

    echo "Sessão tmux '$SESSION_NAME' criada para $USER_TARGET."
else
    echo "Sessão tmux '$SESSION_NAME' já existe."
fi

