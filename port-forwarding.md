# Script de Redirecionamento de Portas com iptables

Este script permite redirecionar portas do seu **VPS** para ou outro servidor na rede usando `iptables`.  
Ele funciona tanto para **TCP** quanto para **UDP**, e você pode especificar a porta local e a porta de destino.

---

## Requisitos

- Linux com `iptables` instalado (normal em distribuições baseadas em Debian, Ubuntu, Fedora, etc.)
- Permissões de **root** ou uso de `sudo`
- Um servidor acessível via IP (exemplo: Tailscale, VPN ou rede local)

---

## Estrutura

- **port-forward.sh** → Script principal  

---

## Instalação

1. Instale o arquivo via github `port-forward.sh`:
   ```bash
    wget https://raw.githubusercontent.com/gabrieldonlopes/config_linux_servers/refs/heads/main/port-forwarding.sh
    ```
2. Tornar o arquivo executável:
    ```bash
    chmod +x ./port-forward.sh
    ```
---
## Uso

A sintaxe geral é:
```bash
./port-forward.sh <SERVER_IP> <PROTOCOLO> <PORTA_LOCAL> <PORTA_DESTINO>
```
- SERVER_IP → IP do seu home-server (exemplo: 100.69.2.25)
- PROTOCOLO → tcp ou udp
- PORTA_LOCAL → porta exposta no VPS
- PORTA_DESTINO → porta no servidor destino
---
## Listar regras aplicadas
Para verificar regras aplicadas:

```bash
sudo iptables -t nat -L -n -v
sudo iptables -L INPUT -n -v # apenas regras de INPUT
```
---
## Remover regras
Se precisar reiniciar e limpar todas as regras:

```bash
sudo iptables -F
sudo iptables -t nat -F
```
⚠️ Atenção: isso limpa todas as regras do iptables, não apenas as criadas pelo script.

---
## Persistência do `iptables`
Para manter regras após reboot:
```bash
sudo apt install iptables-persistent
sudo netfilter-persistent save
```
Se preicsar desativar a persistência:
```bash
sudo systemctl disable netfilter-persistent
sudo systemctl stop netfilter-persistent
```
---
☁️ Google Cloud VPS: liberar portas no Cloud Console

Se você estiver usando uma VPS no Google Cloud (Compute Engine), mesmo aplicando o redirecionamento, é necessário abrir as portas no firewall da VPC:

1. Acesse o Console do Google Cloud
2. Navegue em: **VPC network**->**Firewall**->**Create Firewall rule**
3. Configure:

- **Name:** algo como allow-minecraft
- **Network:** sua rede VPC
- **Targets:** All instances ou instâncias específicas
- **Source IP ranges:** 0.0.0.0/0 (abre para todo mundo) ou restrinja IPs confiáveis
- **Protocols and ports:** selecione TCP/UDP e informe a porta desejada (ex: 25565)

Salve a regra. Agora o tráfego externo conseguirá alcançar sua VPS.

⚠️ Sem essa configuração, o redirecionamento local no VPS não terá efeito, pois o firewall da Google Cloud bloqueia a porta.
