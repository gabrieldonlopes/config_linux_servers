#!/bin/bash

# --------------------------------------------------------
# start-minecraft.sh
#
# Descrição: Script para iniciar servidor Minecraft baseado em tmux
# Autor: gdon - gabriellopes.zip@gmail.com
# Versão: 2.2v
# Data: 2025-10-07 16:22:00
# --------------------------------------------------------

CONF_FILE="/home/gdon/minecraft-config/server.conf"

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
# Função: iniciar_servidor
# Inicia o servidor Minecraft dentro de uma sessão e janela tmux específicas
# --------------------------------------------------------
iniciar_servidor() {
    echo "=========================================="
    echo "Iniciando servidor Minecraft"
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
        tmux new-session -d -s "$TMUX_SESSION" -c "$SERVER_DIR"
    fi

    # Cria janela se não existir
    if ! tmux list-windows -t "$TMUX_SESSION" | grep -q "^$TMUX_WINDOW:"; then
        tmux new-window -t "${TMUX_SESSION}:${TMUX_WINDOW}" -c "$SERVER_DIR"
    fi

    # Executa o servidor com o usuário especificado
    sudo -u "$USER_TO_RUN" tmux send-keys -t "${TMUX_SESSION}:${TMUX_WINDOW}" \
        "cd '$SERVER_DIR' && java -Xms$MIN_RAM -Xmx$MAX_RAM -jar '$JAR_FILE' nogui" C-m

    echo "Servidor iniciado na sessão tmux '${TMUX_SESSION}', janela '${TMUX_WINDOW}' como usuário '$USER_TO_RUN'."
}

# --------------------------------------------------------
# Execução principal
# --------------------------------------------------------
carregar_config
iniciar_servidor

# --------------------------------------------------------
# Fim do script
# --------------------------------------------------------
