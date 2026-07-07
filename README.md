# 🔒 DevSecOps Lab - Blue Team Fundamentals

**Autor:** [Dairo Delgadillo]  
**Objetivo:** Demostrar habilidades en hardening de servidores Linux, detección de intrusiones y respuesta a incidentes.  
**Stack:** Ubuntu Server 22.04, UFW, Fail2ban, Docker, SSH Hardening  
**Fecha:** Julio 2026

---

## 📋 Índice

1. [Arquitectura del Lab](#arquitectura-del-lab)
2. [Hardening del Servidor](#hardening-del-servidor)
3. [Firewall (UFW)](#firewall-ufw)
4. [Detección de Intrusos (Fail2ban)](#detección-de-intrusos-fail2ban)
5. [Logs de Autenticación](#logs-de-autenticación)
6. [Simulación de Ataque](#simulación-de-ataque)
7. [Limitaciones del Entorno](#limitaciones-del-entorno)
8. [Screenshots](#screenshots)
9. [Certificaciones](#certificaciones)
10. [Próximos Pasos](#próximos-pasos)

---

## 🏗️ Arquitectura del Lab

```
         SSH (puerto 2222)
┌─────────────────┐         ┌─────────────────┐
│   Kali Linux    │ ──────► │  Ubuntu Server  │
│   (Atacante)    │         │  (Objetivo)     │
│   172.17.0.1    │         │  Docker Cont.   │
└─────────────────┘         └─────────────────┘
         │
         ▼
    ┌─────────────┐
    │  UFW        │
    │  Fail2ban   │
    │  rsyslog    │
    └─────────────┘
```

- **Host:** Kali Linux en VirtualBox
- **Objetivo:** Contenedor Docker Ubuntu 22.04 con SSH expuesto en puerto 2222
- **Vector de ataque:** Brute force SSH desde Kali

---

## 🛡️ Hardening del Servidor

### Configuración SSH (`/etc/ssh/sshd_config`)

```bash
# Desactivar login como root (recomendado en producción)
# PermitRootLogin no

# Usar solo autenticación por clave pública (recomendado en producción)
# PasswordAuthentication no
# PubkeyAuthentication yes

# Logging detallado para detección de ataques
SyslogFacility AUTH
LogLevel INFO
service ssh restart
```

## 🔥 Firewall (UFW)

### Instalación y configuración

```bash
apt update && apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw enable
```

### Estado del firewall

```bash
ufw status verbose
```

Output:
```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
```

## 🚨 Detección de Intrusos (Fail2ban)

### Instalación y configuración

```bash
apt update && apt install -y fail2ban
```

### Configuración del jail SSH (/etc/fail2ban/jail.d/sshd.conf)

```bash
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

### Inicio del servicio

```bash
fail2ban-server -xb start
```

### Estado del jail

```bash
fail2ban-client status sshd
```

Output esperado en servidor completo:
```
Status for the jail: sshd
|- Filter
|  |- Currently failed: 5
|  |- Total failed: 5
|  `- File list: /var/log/auth.log
`- Actions
   |- Currently banned: 1
   |- Total banned: 1
   `- Banned IP list: 172.17.0.1
```

## 📜 Logs de Autenticación

### Configuración de rsyslog

```bash
apt update && apt install -y rsyslog
rsyslogd
```

### Verificación de logs

```bash
cat /var/log/auth.log
```

### Ejemplo de log con intentos fallidos:

```
Jul  7 20:08:54 47e5a34e4f9e sshd[5096]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=172.17.0.1 user=root
Jul  7 20:08:54 47e5a34e4f9e sshd[5096]: Failed password for root from 172.17.0.1 port 38868 ssh2
Jul  7 20:09:07 47e5a34e4f9e sshd[5096]: message repeated 2 times: [ Failed password for root from 172.17.0.1 port 38868 ssh2 ]
Jul  7 20:09:08 47e5a34e4f9e sshd[5096]: Connection closed by authenticating user root 172.17.0.1 port 38868 [preauth]
Jul  7 20:09:08 47e5a34e4f9e sshd[5096]: PAM 2 more authentication failures; logname= uid=0 euid=0 tty=ssh ruser= rhost=172.17.0.1 user=root
```

## ⚔️ Simulación de Ataque

### Desde Kali Linux (atacante)

```bash
# Limpieza de known_hosts por recreación del contenedor
ssh-keygen -f '/home/kali/.ssh/known_hosts' -R '[127.0.0.1]:2222'

# Intento de conexión SSH
ssh -p 2222 root@127.0.0.1

# Generación de múltiples intentos fallidos
for i in {1..6}; do ssh -p 2222 root@127.0.0.1; done
```

Contraseñas incorrectas usadas: 123456, password, admin, root, qwerty, test

## ⚠️ Limitaciones del Entorno

Este lab fue construido dentro de un contenedor Docker por limitaciones de recursos (no se pudo activar Azure Free Tier). Esto implica ciertas restricciones:

| Funcionalidad          | Estado         | Nota                                                              |
| ---------------------- | -------------- | ----------------------------------------------------------------- |
| UFW                    | ✅ Funcional    | Firewall activo y configurado                                     |
| SSH Logging            | ✅ Funcional    | Logs en `/var/log/auth.log`                                       |
| Fail2ban configuración | ✅ Funcional    | Jail sshd activo y monitoreando                                   |
| Fail2ban bloqueo       | ⚠️ Limitado    | El contenedor Docker no tiene acceso a iptables para bloquear IPs |
| Auditd                 | ❌ No funcional | Requiere acceso al kernel del host                                |

En un servidor físico o VM completa, fail2ban bloquearía la IP atacante automáticamente después de maxretry intentos fallidos.

## 📸 Screenshots

| # | Descripción                                 | Archivo                         |
| - | ------------------------------------------- | ------------------------------- |
| 1 | UFW status active                           | `screenshots/ufw-status.png`    |
| 2 | Fail2ban jail configurado                   | `screenshots/fail2ban-jail.png` |
| 3 | Logs de autenticación con intentos fallidos | `screenshots/auth-log.png`      |
| 4 | Intento de conexión SSH desde Kali          | `screenshots/ssh-attempt.png`   |

## 🏆 Certificaciones

-

## 🚀 Próximos Pasos

- [ ] Migrar lab a VM completa (VirtualBox) para funcionalidad 100% de fail2ban
- [ ] Implementar autenticación por clave SSH (deshabilitar password)
- [ ] Configurar auditd en servidor completo
- [ ] Integrar con SIEM (Splunk o Microsoft Sentinel)
- [ ] Pipeline CI/CD con GitHub Actions + escaneos de seguridad

## 📚 Recursos Utilizados

- HTB Academy - Linux Fundamentals
- TryHackMe - Pre-Security Path
- Microsoft Learn - SC-900
- LetsDefend - SOC Analyst Training

## 🤝 Contacto

- LinkedIn: https://www.linkedin.com/in/dairo-delgadillo-dev/
- GitHub: https://github.com/Dairo-Delgadillo-DEv/
- Email: dairodelgadillo302@gmail.com
