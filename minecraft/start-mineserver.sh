#!/bin/bash

# --------------------------------------------------------
# start-minecraft.sh
#
# Descrição: Script para iniciar servidor Minecraft baseado em tmux
# Autor: gdon - gabriellopes.zip@gmail.com
# Versão: 2.2v
# Data: 2025-10-07 16:22:00
# --------------------------------------------------------

CONF_FILE="/home/gdon/minecraft-config/minecraft-cobblemon-server.conf"

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
# Função: iniciar_monitor_chat
# Inicia o monitor de chat em background
# --------------------------------------------------------
iniciar_monitor_chat() {
    echo "Iniciando monitor de chat..."
    
    # Verificar se o script do monitor existe
    if [ ! -f "/home/gdon/minecraft-config/monitor_chat.sh" ]; then
        echo "ERRO: Script /home/gdon/minecraft-config/monitor_chat.sh não encontrado!"
        return 1
    fi
    
    # Verificar se o script de chat existe
    if [ ! -f "$LOG_CHAT" ]; then
        echo "ERRO: Script $LOG_CHAT não encontrado!"
        return 1
    fi
    
    # Iniciar o monitor em background com redirecionamento de log
    nohup sudo /home/gdon/minecraft-config/monitor_chat.sh >> "/var/log/minecraft/monitor_chat.log" 2>&1 &
    
    MONITOR_PID=$!
    
    # Pequena pausa para verificar se o processo iniciou corretamente
    sleep 2
    
    if kill -0 $MONITOR_PID 2>/dev/null; then
        echo "✓ Monitor de chat iniciado com PID: $MONITOR_PID"
        echo "$MONITOR_PID" > /tmp/minecraft-chat-monitor.pid
        echo "✓ Logs disponíveis em: /var/log/minecraft/monitor_chat.log"
    else
        echo "ERRO: Falha ao iniciar monitor de chat!"
        return 1
    fi
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

    JAR_FILE=$(find "$SERVER_DIR" -maxdepth 1 -type f -name "*server*.jar" | head -n 1)
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
        "cd '$SERVER_DIR' && java -Xms$MIN_RAM -Xmx$MAX_RAM -jar '$JAR_FILE' nogui > /var/log/minecraft/minecraft.log 2>&1" C-m

    echo "Servidor iniciado na sessão tmux '${TMUX_SESSION}', janela '${TMUX_WINDOW}' como usuário '$USER_TO_RUN'."
}

# --------------------------------------------------------
# Execução principal
# --------------------------------------------------------
carregar_config

parar_monitor_chat # para monitores existentes

iniciar_servidor

# Aguardar servidor inicializar completamente
echo "Aguardando servidor inicializar (5 segundos)..."
sleep 5
iniciar_monitor_chat

echo "=========================================="
echo "Sistema iniciado completamente!"
echo "Para acessar o console do servidor: tmux attach -t $TMUX_SESSION"
echo "Para parar o monitor de chat: kill \$(cat /tmp/minecraft-chat-monitor.pid)"
echo "Para ver o log do servidor: lnav $LOG_DIR/minecraft.log"
echo "=========================================="


# --------------------------------------------------------
# Fim do script
# --------------------------------------------------------
