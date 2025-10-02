# Script de Backup Automático do Servidor Minecraft

Este script realiza **backup automático do servidor de Minecraft**, compacta os arquivos principais, envia para o **Google Drive via rclone** e mantém apenas os **2 backups mais recentes** tanto localmente quanto na nuvem.

---

## Requisitos

* Servidor Linux com **tmux**
* `zip` para compactação
* `rclone` configurado com o Google Drive
* Permissões de **root** ou uso de `sudo`

---

## Estrutura

* **minecraft_backup.conf** → Arquivo de configuração
* **backup_minecraft_server.sh** → Script principal

---

## Instalação

1. Baixe o script:

   ```bash
   wget https://raw.githubusercontent.com/gabrieldonlopes/config_linux_servers/main/backup_minecraft_server.sh
   ```

2. Torne-o executável:

   ```bash
   chmod +x ./backup_minecraft_server.sh
   ```

3. Crie o arquivo de configuração `minecraft_backup.conf` no diretório do usuário (`~/minecraft_backup.conf`):

   ```bash
   # Caminho do servidor Minecraft
   SERVER_DIR="/home/gdon/minecraft-server"

   # Pasta local de backups
   BACKUP_DIR="/home/gdon/backups"

   # Sessão tmux do servidor
   TMUX_SESSION="minecraft"
   TMUX_WINDOW=0

   # Remote configurado no rclone
   RCLONE_REMOTE="drive02:minecraft-backups"
   ```

---

## Uso

Execute o script:

```bash
./backup_minecraft_server.sh
```

O processo será:

1. Enviar comandos ao servidor no **tmux**:

   * Avisar jogadores
   * Pausar salvamento
   * Forçar salvamento

2. Compactar arquivos principais:

   * `world/`
   * `server.properties`
   * `ops.json`
   * `whitelist.json`

3. Criar o backup em `~/backups`

4. Enviar para o Google Drive no diretório configurado (`drive02:minecraft-backups`)

5. Manter somente **2 backups locais e remotos** (os mais recentes)

---

## Agendamento com `cron`

Para rodar o backup todo dia ao meio-dia:

```bash
crontab -e
```

Adicione a linha:

```bash
0 12 * * * /home/gdon/backup_minecraft_server.sh >> /home/gdon/backup.log 2>&1
```

---

## Verificação de backups existentes

* Local:

  ```bash
  ls -lh ~/backups
  ```

* Google Drive:

  ```bash
  rclone ls drive02:minecraft-backups
  ```

---

## Logs

Todos os eventos importantes são exibidos no terminal.
Se agendado no cron, salve em um log (`~/backup.log`) para depuração.

---

✅ Com isso, seu servidor Minecraft terá backups automáticos e seguros no Google Drive, sem acumular arquivos desnecessários.

