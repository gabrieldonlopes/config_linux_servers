#!/bin/bash

# ------------------------------------------------------
# tmux-cmd.sh
#
# Descrição: Script para enviar comandos para sessao tmux
# Autor: gdon - gabriellopes.zip@gmail.com
# Versão: 1.0v
# Data: 2026-02-16 11:03:00
# ------------------------------------------------------

CONF_FILE="/home/gdon/minecraft-config/minecraft-cobblemon-server.conf"


if [ ! -f "$CONF_FILE" ]; then
	echo "Erro: arquivo de configuração nao encontrado!"
	exit 1
fi
source "$CONF_FILE"

sudo -u "$USER_TO_RUN" tmux send-keys -t "${TMUX_SESSION}:${TMUX_WINDOW}" "$1" C-m

sleep 1

tail -n 10 /var/log/minecraft/minecraft.log
