#!/bin/bash

set -e

apt-get update && apt-get upgrade -y

# === Проверка и установка git ===
echo "🔍 Проверка git..."
if ! command -v git &> /dev/null; then
    echo "📦 Установка git..."
    apt-get install -y git
else
    echo "✅ Git уже установлен"
fi
# curl -fsSL https://get.docker.com | sh
# sudo usermod -aG docker $USER
# === Проверка и установка docker compose ===
echo "🔍 Проверка docker compose..."
if ! docker compose version &> /dev/null; then
    echo "📦 Установка Docker и Docker Compose..."

    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        apt-get remove -y $pkg || true
    done

    apt-get install -y ca-certificates curl

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin tmux
else
    echo "✅ Docker Compose уже установлен"
fi

# === Создание конфигурации Docker с кастомными DNS ===
echo "📄 Настройка /etc/docker/daemon.json с кастомными DNS..."
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "dns": ["8.8.8.8", "1.1.1.1"]
}
EOF

echo "🔁 Перезапуск Docker для применения DNS..."
systemctl restart docker
