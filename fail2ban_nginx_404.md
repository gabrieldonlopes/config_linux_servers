
# Configurando Fail2ban para Bloquear IPs com Muitos Erros 404 no Nginx

Este guia ensina como configurar o **fail2ban** para monitorar o **Nginx** e bloquear IPs que geram muitos erros **404 (Not Found)**, o que pode indicar scanners, bots ou tentativas de descoberta de endpoints.

---

## 🧱 Pré-requisitos

- Fail2ban instalado no **host Linux**.
- Nginx rodando em um **container Docker**, com os logs expostos para o host via volume.
- Logs do Nginx devem estar no formato padrão e disponíveis no host (ex: `./frontend/nginx-logs/access.log`).

---

## 📦 Expondo os Logs do Nginx com Docker Compose

No seu `docker-compose.yml`, monte um volume para expor os logs:

```yaml
version: "3.9"

services:
  frontend:
    build:
      context: ./frontend
    ports:
      - "8080:8080"
    depends_on:
      - backend
    restart: unless-stopped
    volumes:
      - ./frontend/nginx-logs:/var/log/nginx

  backend:
    build:
      context: ./backend
    ports:
      - "8000:8000"
    env_file:
      - ./backend/.env
    restart: unless-stopped
    volumes:
      - ./backend/test.db:/app/test.db
```

---

## 🔍 Criando o Filtro Fail2ban para 404

Crie o arquivo `/etc/fail2ban/filter.d/nginx-404.conf` com o conteúdo:

```ini
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*(HTTP/1\.1|HTTP/2\.0)" 404
ignoreregex =
```

Este filtro detecta requisições que resultam em código 404 feitas por GET ou POST.

Outro exemplo de filtro usado para bloquear 404 em servers uvicorn (fastapi)
```ini
[Definition]
failregex = ^INFO:\s+<HOST>:\d+\s+-\s+".*"\s+404
ignoreregex =
```
---

## 🛡️ Criando a Jail do Fail2ban

Edite (ou crie) o arquivo `/etc/fail2ban/jail.local` e adicione:

```ini
[nginx-404]
enabled = true
filter = nginx-404
logpath = /caminho/absoluto/para/seu/projeto/frontend/nginx-logs/access.log
maxretry = 10
bantime = 3600
findtime = 600
```

- **logpath**: Substitua com o caminho absoluto no seu host para os logs.
- **maxretry**: Número de erros 404 permitidos antes do ban.
- **bantime**: Tempo em segundos que o IP ficará banido.
- **findtime**: Janela de tempo em que os erros são contados.

---

## 🔁 Reiniciando o Fail2ban

```bash
sudo systemctl restart fail2ban
```

---

## ✅ Verificando se está funcionando

Execute:

```bash
sudo fail2ban-client status nginx-404
```

Você verá quantos IPs foram banidos e se a jail está ativa.

---

## 🧪 Teste

Tente acessar várias URLs inválidas no seu domínio:

```bash
curl http://seu-site.com/naoexiste1
curl http://seu-site.com/naoexiste2
```

Após ultrapassar o `maxretry`, o IP será bloqueado.

---

## ✅ Conclusão

Com isso, seu servidor estará protegido contra acessos repetidos a páginas inexistentes, o que ajuda a mitigar scanners automáticos, bots e tentativas de invasão.
