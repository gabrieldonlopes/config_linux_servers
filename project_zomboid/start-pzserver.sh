#!/bin/bash

# --------------------------------------------------------
# start-pzserver.sh
#
# Descrição: Script para iniciar servidor Project Zomboid em server tmux
# Autor: gdon - gabriellopes.zip@gmail.com
# Versão: 2.1v
# Data: 2025-10-07 16:23:00
# --------------------------------------------------------

CONF_FILE="/home/gdon/minecraft-config/pzserver.conf"

carregar_config() {
    if [ ! -f "$CONF_FILE" ]; then
        echo "Erro: arquivo de configuração $CONF_FILE não encontrado!"
        exit 1
    fi
    source "$CONF_FILE"
}

iniciar_servidor() {
    echo "=========================================="
    echo "Iniciando servidor Project Zomboid"
    echo "Diretório: $SERVER_DIR"
    echo "Usuário: $USER_TO_RUN"
    echo "Sessão tmux: $TMUX_SESSION"
    echo "Janela tmux: $TMUX_WINDOW"
    echo "Script: $SCRIPT"
    echo "=========================================="

    if [ ! -d "$SERVER_DIR" ]; then
        echo "Erro: diretório $SERVER_DIR não encontrado!"
        exit 1
    fi

    if [ ! -f "$SERVER_DIR/$SCRIPT" ]; then
        echo "Erro: Script $SCRIPT não encontrado em $SERVER_DIR!"
        exit 1
    fi

    if ! id "$USER_TO_RUN" &>/dev/null; then
        echo "Erro: Usuário $USER_TO_RUN não existe!"
        exit 1
    fi

    if ! command -v tmux &>/dev/null; then
        echo "Erro: tmux não está instalado!"
        exit 1
    fi

    # Cria sessão se não existir
    if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux new-session -d -s "$TMUX_SESSION" -c "$SERVER_DIR"
    fi

    # Cria janela se não existir
    if ! tmux list-windows -t "$TMUX_SESSION" | grep -q "^$TMUX_WINDOW:"; then
        tmux new-window -t "${TMUX_SESSION}:${TMUX_WINDOW}" -c "$SERVER_DIR"
    fi

    # Executa o servidor com o usuário especificado
    sudo -u "$USER_TO_RUN" tmux send-keys -t "${TMUX_SESSION}:${TMUX_WINDOW}" \
        "cd '$SERVER_DIR' && ./$SCRIPT -nosteam  >> /var/log/pz/pz.log" C-m

    echo "Servidor iniciado na sessão tmux '${TMUX_SESSION}', janela '${TMUX_WINDOW}' como usuário '$USER_TO_RUN'."
}

# --------------------------------------------------------
# Execução principal
# --------------------------------------------------------
carregar_config
iniciar_servidor
