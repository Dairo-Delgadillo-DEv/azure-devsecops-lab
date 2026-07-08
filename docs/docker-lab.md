# 🐳 Lab Docker - Servidor Ubuntu Hardened

## Fecha
Julio 2026

## Objetivo
Crear un contenedor Docker con Ubuntu Server 22.04, configurado con seguridad básica (UFW, SSH, Fail2ban) para simular un entorno de producción vulnerable a ataques de fuerza bruta.

---

## 🏗️ Arquitectura
┌─────────────────┐         SSH (puerto 2222)         ┌─────────────────┐
│   Kali Linux    │  ─────────────────────────────►  │  Ubuntu Docker  │
│   (Atacante)    │                                 │  (Objetivo)     │
│   172.17.0.1    │                                 │  172.17.0.2     │
└─────────────────┘                                 └─────────────────┘
│
▼
┌─────────────┐
│  UFW        │
│  Fail2ban   │
│  rsyslog    │
│  SSH        │
└─────────────┘

---

## 🚀 Despliegue del Contenedor

### Crear contenedor con privilegios

```bash
sudo docker run -d --name ubuntu-lab --privileged -p 2222:22 ubuntu:22.04 sleep infinity
sudo docker exec -it ubuntu-lab bash