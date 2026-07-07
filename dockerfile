FROM ubuntu:22.04

# Crear usuario no-root
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Instalar dependencias mínimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    ufw \
    fail2ban \
    rsyslog \
    && rm -rf /var/lib/apt/lists/*

# Configurar SSH
RUN mkdir /var/run/sshd
COPY sshd_config /etc/ssh/sshd_config

# Exponer puerto
EXPOSE 22

# Cambiar a usuario no-root (donde sea posible)
USER appuser

# Comando por defecto
CMD ["sudo", "/usr/sbin/sshd", "-D"]