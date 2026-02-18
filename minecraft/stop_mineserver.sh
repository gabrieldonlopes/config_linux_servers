#!/bin/bash

# --------------------------------------------------------
# stop-minecraft.sh
#
# Descrição: Script para parar servidor Minecraft baseado em tmux
# Autor: gdon - gabriellopes.zip@gmail.com
# Versão: 1.0v
# Data: 2026-02-06 05:40:00
# --------------------------------------------------------

CONF_FILE="/home/gdon/minecraft-config/minecraft-server.conf"

# --------------------------------------------------------
# Função: carregar_config
# Lê as variáveis do arquivo .conf
# --------------------------------------------------------
carregar_config() {
    if [ ! -f "$CONF_FILE" ]; then
        echo "Erro: arquivo de configuração $CONF_FILE não encontrado!"
        exit 1
    fi
    source "$CONF_FILE"
}

# --------------------------------------------------------
# Função: parar_monitor_chat
# Para o monitor de chat se estiver em execução
# --------------------------------------------------------
parar_monitor_chat() {
    if [ -f /tmp/minecraft-chat-monitor.pid ]; then
        PID=$(cat /tmp/minecraft-chat-monitor.pid)
        if kill -0 "$PID" 2>/dev/null; then
            echo "Parando monitor de chat (PID: $PID)..."
            kill "$PID"
            rm /tmp/minecraft-chat-monitor.pid
        fi
    fi
}

# --------------------------------------------------------
# Função: parar_servidor
# Para o servidor Minecraft dentro de uma sessão e janela tmux específicas
# --------------------------------------------------------
parar_servidor() {
    echo "=========================================="
    echo "Parando servidor Minecraft"
    echo "Diretório: $SERVER_DIR"
    echo "Usuário: $USER_TO_RUN"
    echo "Sessão tmux: $TMUX_SESSION"
    echo "Janela tmux: $TMUX_WINDOW"
    echo "Memória mínima: $MIN_RAM"
    echo "Memória máxima: $MAX_RAM"
    echo "=========================================="

    if [ ! -d "$SERVER_DIR" ]; then
        echo "Erro: diretório $SERVER_DIR não encontrado!"
        exit 1
    fi

    JAR_FILE=$(find "$SERVER_DIR" -maxdepth 1 -type f -name "*.jar" | head -n 1)
    if [ -z "$JAR_FILE" ]; then
        echo "Erro: arquivo .jar do servidor não encontrado em $SERVER_DIR!"
        exit 1
    fi

    if ! command -v tmux &>/dev/null; then
        echo "Erro: tmux não está instalado!"
        exit 1
    fi

    # Cria sessão se não existir
    if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo "Erro: nenhuma sessao encontrada"
	exit 1
    fi

    # Cria janela se não existir
    if ! tmux list-windows -t "$TMUX_SESSION" | grep -q "^$TMUX_WINDOW:"; then
        echo "Erro: nenhuma janela encontrada"
    fi

    # Executa o servidor com o usuário especificado
    sudo -u "$USER_TO_RUN" tmux send-keys -t "${TMUX_SESSION}:${TMUX_WINDOW}" \
        "stop" C-m

    echo "Servidor desligado na sessão tmux '${TMUX_SESSION}', janela '${TMUX_WINDOW}' como usuário '$USER_TO_RUN'."
}

# --------------------------------------------------------
# Execução principal
# --------------------------------------------------------
carregar_config
parar_monitor_chat
parar_servidor

# --------------------------------------------------------
# Fim do script
# --------------------------------------------------------
