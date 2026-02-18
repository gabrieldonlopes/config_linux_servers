#!/bin/bash

# --------------------------------------------------------
# monitor_chat.sh
#
# Descrição: Ler log do minecraft, puxa resposta de uma função de ia
#            e envia resultado para chat interno do servidor
# Autor: gdon - gabriellopes.zip@gmail.com
# Versão: 2.1v
# Data: 2026-02-18 05:11:00
# --------------------------------------------------------

# Arquivo de configuração
CONF_FILE="/home/gdon/minecraft-config/minecraft-cobblemon-server.conf"
LOG_FILE="/var/log/minecraft/monitor_chat.log"

# Função para log de erros
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [monitor] ERRO: $1" >> "$LOG_FILE"
}

# Função para log de informação
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [monitor] INFO: $1" >> "$LOG_FILE"
}

# Lendo arquivo de configuração
if [ ! -f "$CONF_FILE" ]; then
    log_error "Arquivo de configuração $CONF_FILE não encontrado!"
    echo "Erro: arquivo de configuração não encontrado (consulte $LOG_FILE)" >&2
    exit 1
fi

source "$CONF_FILE"

# Verificar se as variáveis necessárias existem
if [ -z "$LOG_DIR" ]; then
    log_error "LOG_DIR não definido no arquivo de configuração"
    echo "Erro: LOG_DIR não configurado" >&2
    exit 1
fi

if [ -z "$USER_TO_RUN" ]; then
    log_error "USER_TO_RUN não definido no arquivo de configuração"
    echo "Erro: USER_TO_RUN não configurado" >&2
    exit 1
fi

if [ -z "$LOG_CHAT" ]; then
    log_error "LOG_CHAT não definido no arquivo de configuração"
    echo "Erro: LOG_CHAT não configurado" >&2
    exit 1
fi

if [ ! -f "$LOG_CHAT" ]; then
    log_error "Script de chat $LOG_CHAT não encontrado"
    echo "Erro: script de chat não encontrado" >&2
    exit 1
fi

# Lendo log do minecraft
if [ ! -f "$LOG_DIR/minecraft.log" ]; then
    log_error "Arquivo de log $LOG_DIR/minecraft.log não encontrado!"
    echo "Erro: arquivo de log não encontrado (consulte $LOG_FILE)" >&2
    exit 1
fi

LOG="$LOG_DIR/minecraft.log"

# Verificar se TMUX_SE e TMUX_WINDOW estão definidos
if [ -z "$TMUX_SESSION" ] || [ -z "$TMUX_WINDOW" ]; then
    log_error "TMUX_SESSION ou TMUX_WINDOW não definidos no arquivo de configuração"
    echo "Erro: configuração do tmux incompleta" >&2
    exit 1
fi

# Sessão que está rodando o servidor
TMUX_SESSION="$TMUX_SE:$TMUX_WINDOW"

log_info "Monitor de chat iniciado. Monitorando: $LOG"
log_info "Sessão tmux: $TMUX_SESSION"
log_info "Script de chat: $LOG_CHAT"

# Verificar se a sessão tmux existe
if ! sudo -u "$USER_TO_RUN" tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
    log_error "Sessão tmux $TMUX_SESSION não encontrada!"
    echo "Erro: servidor Minecraft não está rodando?" >&2
    exit 1
fi

tail -Fn0 "$LOG" | while read -r line; do
    if [[ "$line" == *"!chat "* ]]; then
        log_info "Comando detectado: $line"
        
        MESSAGE=$(echo "$line" | sed -E 's/.*!chat (.*)/\1/')
        
        # Mensagem inicial
        if ! sudo -u "$USER_TO_RUN" tmux send-keys -t "$TMUX_SESSION" \
        'tellraw @a {"text":"Processando...","color":"gray"}' C-m 2>/dev/null; then
            log_error "Falha ao enviar mensagem inicial para o tmux"
        fi
        
        (
            # Chama função que invoca a ia
            FULL_RESPONSE=$("$LOG_CHAT" "$MESSAGE" 2>> "$LOG_FILE" | tr -d '\r')
            EXIT_CODE=$?
            
            if [ $EXIT_CODE -ne 0 ]; then
                log_error "Script $LOG_CHAT falhou com código $EXIT_CODE para mensagem: $MESSAGE"
                sudo -u "$USER_TO_RUN" tmux send-keys -t "$TMUX_SESSION" \
                'tellraw @a {"text":"Erro ao processar comando","color":"red"}' C-m 2>/dev/null
                exit
            fi
            
            if [ -z "$FULL_RESPONSE" ]; then
                log_error "Resposta vazia do script de chat para: $MESSAGE"
                sudo -u "$USER_TO_RUN" tmux send-keys -t "$TMUX_SESSION" \
                'tellraw @a {"text":"Resposta vazia da IA","color":"red"}' C-m 2>/dev/null
                exit
            fi
            
            while IFS= read -r line_response; do
                if [ -n "$line_response" ]; then
                    # Escapa aspas duplas dentro da mensagem
                    line_response=$(echo "$line_response" | sed 's/"/\\"/g')
                    
                    # Constrói o JSON corretamente
                    JSON="{\"text\":\"[Professor Caralho] $line_response\",\"color\":\"green\"}"
                    
                    # Envia o comando com o JSON
                    if ! sudo -u "$USER_TO_RUN" tmux send-keys -t "$TMUX_SESSION" \
                    "tellraw @a $JSON" C-m 2>/dev/null; then
                        log_error "Falha ao enviar mensagem para o tmux: $line_response"
                    fi
                    
                    sleep 0.3
                fi
            done <<< "$FULL_RESPONSE"
            
            log_info "Resposta enviada com sucesso para: $MESSAGE"
            
        ) &
    fi
done