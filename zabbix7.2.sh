#!/bin/bash

# 1.1) Обновление системы
echo "Обновление списка пакетов и установка обновлений..."
sudo apt update && sudo apt upgrade -y

# 1.2) Скачиваем Zabbix
echo "Скачиваем Zabbix..."
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb

# Устанавливаем Zabbix
echo "Устанавливаем Zabbix репозиторий..."
sudo dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb

# Обновляем пакеты после установки репозитория
echo "Обновление пакетов..."
sudo apt update

# 1.3) Устанавливаем Zabbix сервер, WEB интерфейс и агент
echo "Устанавливаем Zabbix сервер, веб-интерфейс и агент..."
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# 1.4) Устанавливаем MySQL
echo "Устанавливаем MySQL..."
sudo apt-get install -y mysql-server

# Запускаем MySQL
echo "Запускаем MySQL..."
sudo systemctl start mysql

# Устанавливаем зависимости
echo "Устанавливаем зависимости..."
sudo apt install -y wget apt-transport-https ca-certificates gnupg curl

# Запрашиваем пароль для базы данных
echo "Введите пароль для базы данных Zabbix:"
read -s db_password

# Создаем базу данных
echo "Создаем базу данных Zabbix..."
sudo mysql <<EOF
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
EXIT;
EOF

# 1.5) Импортируем скрипт базы данных Zabbix в MySQL
echo "Импортируем скрипт базы данных Zabbix..."
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p$db_password zabbix

# Заходим в БД и отключаем функцию создания пользователей
echo "Отключаем функцию создания пользователей..."
sudo mysql <<EOF
SET GLOBAL log_bin_trust_function_creators = 0;
EXIT;
EOF

# 1.6) Редактируем файл конфигурации Zabbix
echo "Редактируем файл конфигурации Zabbix..."
sudo sed -i "s/#DBPassword=password/DBPassword=$db_password/" /etc/zabbix/zabbix_server.conf

# 1.7) Перезапускаем службы Zabbix
echo "Перезапускаем службы Zabbix..."
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

echo "Zabbix успешно установлен и настроен!"
