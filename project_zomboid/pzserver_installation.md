# Instalação de um servidor Project Zomboid no Linux

## Pré-requisitos
Adicionae repositórios non-free no sources.list para instalação do steamcmd 

```bash
sudo apt update && sudo apt upgrade -y
sudo echo "deb http://ftp.us.debian.org/debian bookworm main non-free" > /etc/apt/sources.list.d/non-free.list
sudo apt update
``` 

## Criação de Usuário dedicado
```bash
sudo adduser pzuser
sudo usermod -aG sudo pzuser
``` 

## Instalando SteamCMD
```bash
sudo apt install steamcmd -y
``` 
## Diretório do servidor

```bash
sudo mkdir /opt/pzserver
sudo chown pzuser:pzuser /opt/pzserver
```
Trocando para conta dedicada:
```bash
sudo -u pzuser -i
```

## Download Project Zomboid Server
1) Criar script de update para SteamCMD
```bash
cat >$HOME/update_zomboid.txt <<'EOL'
// update_zomboid.txt
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir /opt/pzserver/
login anonymous
app_update 380870 validate
quit
EOL
```
2) Baixando arquivos do servidor (é rapidinho)
```bash
export PATH=$PATH:/usr/games
steamcmd +runscript $HOME/update_zomboid.txt
```

## Configurando servidor
1) abrir portas de conexão
```bash
sudo ufw allow 16261/udp
sudo ufw allow 16262/udp
sudo ufw reload
```
*precisa fazer ipforwarding para tornar acessível na internet*

2) Server Setup
```bash
cd /opt/pzserver
bash start-server.sh
```
etapa necessária para determinar a senha de administrador e baixar arquivos finais

3) Arquivos de configuração
```bash
nano $HOME/Zomboid/Server/servertest.ini
```

- coisas essenciais para mudar
```ini
PublicName=Your Server Name
PublicDescription=Your Server Description
Password=YourPassword
MaxPlayers=32
RCONPassword=YourRCONPassword
```

- É bom criar um serviço para inicializar o servidor automaticamente via systemd.

## Script de inicialização
1. Instale o arquivo via github `start-pzserver.sh`:
   ```bash
    wget https://raw.githubusercontent.com/gabrieldonlopes/config_linux_servers/refs/heads/main/project_zomboid/start-pzserver.sh
    ```
2. Tornar o arquivo executável:
    ```bash
    chmod +x ./start-pzserver.sh
    ```
ele abre o servidor automaticamente, serve para tudo


