#!/bin/bash

# --------------------------------------------------------
# chat_cobblemon.sh
#
# Descrição: Repassa uma mensagem para AI com contexto de cobblemon
# Autor: gdon - gabriellopes.zip@gmail.com
# Versão: 1.6v
# Data: 2026-02-18 05:11:00
# --------------------------------------------------------

# Arquivo de configuração
CONF_FILE="/home/gdon/minecraft-config/minecraft-cobblemon-server.conf"
LOG_FILE="/var/log/minecraft/monitor_chat.log"

# Função para log de erros
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERRO: $1" >> "$LOG_FILE"
}

# Função para log de informação
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$LOG_FILE"
}

# Lendo arquivo de configuração
if [ ! -f "$CONF_FILE" ]; then
    log_error "Arquivo de configuração $CONF_FILE não encontrado!"
    echo "Erro: arquivo de configuração não encontrado (consulte $LOG_FILE)"
    exit 1
fi

source "$CONF_FILE"  # pega a chave de api deepseek

if [ -z "$API_KEY" ]; then 
    log_error "Variável API_KEY não definida no arquivo de configuração"
    echo "Erro: API_KEY não configurada (consulte $LOG_FILE)"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    log_error "jq não está instalado no sistema"
    echo "Erro: jq não instalado (consulte $LOG_FILE)"
    exit 1
fi

PERGUNTA="$*"

if [ -z "$PERGUNTA" ]; then
    log_error "Uso incorreto: mensagem vazia"
    echo "Uso: chat_cobblemon.sh <mensagem>"
    exit 1
fi

log_info "Processando pergunta: $PERGUNTA"

# Montar JSON com jq (seguro contra aspas)
JSON=$(jq -n \
  --arg pergunta "$PERGUNTA" \
  '{
    model: "deepseek-chat",
    messages: [
      {
        role: "system",
        content: "Você é um especialista avançado em Cobblemon (mod de Pokémon para Minecraft). Evite a pula de linhas. Você domina mecânicas de Pokémon como IVs, EVs, natureza, habilidades, breeding, tipos, matchups, estratégias competitivas, builds, movesets e sinergias de time. Também entende como Cobblemon funciona em servidores multiplayer, incluindo spawn por bioma, raridade, evolução, lendários, estruturas e configurações de servidor. Ao responder, seja técnico quando necessário, explique conceitos de forma clara e estruturada, e aprofunde quando a pergunta for complexa. Não use markdown ou formatação especial. Organize a resposta em blocos curtos para facilitar leitura no chat do jogo."
      },
      {
        role: "user",
        content: $pergunta
      }
    ],
    temperature: 0.6
  }')

# Verificar se o JSON foi criado corretamente
if [ $? -ne 0 ] || [ -z "$JSON" ]; then
    log_error "Falha ao criar JSON para a API"
    echo "Erro interno ao processar mensagem"
    exit 1
fi

# Fazer requisição à API
RESPOSTA=$(curl -s https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$JSON" 2>> "$LOG_FILE")

# Verificar se o curl teve sucesso
if [ $? -ne 0 ]; then
    log_error "Falha na requisição curl para a API DeepSeek"
    echo "Erro de comunicação com a API"
    exit 1
fi

# Verificar se a resposta está vazia
if [ -z "$RESPOSTA" ]; then
    log_error "Resposta vazia da API DeepSeek"
    echo "Erro: resposta vazia da API"
    exit 1
fi

# Extrair conteúdo com jq
CONTEUDO=$(echo "$RESPOSTA" | jq -r '.choices[0].message.content' 2>> "$LOG_FILE")

# Verificar se o jq conseguiu extrair o conteúdo
if [ $? -ne 0 ]; then
    log_error "Falha ao processar resposta JSON da API: $RESPOSTA"
    echo "Erro ao processar resposta da API"
    exit 1
fi

# Verificar se o conteúdo não é nulo ou vazio
if [ -z "$CONTEUDO" ] || [ "$CONTEUDO" = "null" ]; then
    # Tentar extrair mensagem de erro da API
    ERRO_MSG=$(echo "$RESPOSTA" | jq -r '.error.message // "Mensagem de erro não disponível"' 2>> "$LOG_FILE")
    log_error "API retornou erro: $ERRO_MSG"
    echo "Erro da API: $ERRO_MSG"
    exit 1
fi

log_info "Resposta recebida com sucesso (${#CONTEUDO} caracteres)"
echo "$CONTEUDO"