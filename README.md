Вылодил готовый скрипт по установке
Добавлена строка read -s db_password, которая запрашивает у пользователя пароль для базы данных (флаг -s скрывает ввод).

Так же можете пошагово установить сами Zabbix 7.2 на Ubuntum
Инструкция по установке Zabbix на Ubuntu 24.04
1.1 Обновление системы
Перед установкой Zabbix рекомендуется обновить список пакетов и установить все доступные обновления, чтобы избежать проблем с зависимостями.
sudo apt update && sudo apt upgrade -y

apt update — обновляет список доступных пакетов в системе.
apt upgrade -y — автоматически устанавливает обновления для всех пакетов.

1.2 Установка репозитория Zabbix
Zabbix не включен в стандартные репозитории Ubuntu, поэтому его нужно скачать отдельно.

Скачиваем официальный пакет репозитория Zabbix:
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
wget — утилита для загрузки файлов по URL.
Указываем ссылку на последний релиз репозитория Zabbix.

Устанавливаем загруженный пакет:
sudo dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i — устанавливает пакет в систему.

После установки репозитория обновляем список пакетов:
sudo apt update

1.3 Установка Zabbix сервера, веб-интерфейса и агента
Теперь устанавливаем основные компоненты Zabbix:
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
zabbix-server-mysql — основной сервер Zabbix, использующий MySQL для хранения данных.
zabbix-frontend-php — веб-интерфейс Zabbix, написанный на PHP.
zabbix-apache-conf — конфигурация для веб-сервера Apache.
zabbix-sql-scripts — скрипты для создания структуры базы данных Zabbix.
zabbix-agent — агент Zabbix, собирающий данные с сервера.

1.4 Установка MySQL
Устанавливаем сервер баз данных MySQL:
sudo apt-get install -y mysql-server
mysql-server — пакет, содержащий сервер MySQL.

Запускаем MySQL:
sudo systemctl start mysql
systemctl start mysql — запускает службу MySQL.

Дополнительные зависимости
Для корректной работы Zabbix также необходимо установить несколько утилит:
sudo apt install -y wget apt-transport-https ca-certificates gnupg curl
wget — инструмент для загрузки файлов.
apt-transport-https — поддержка HTTPS в apt.
ca-certificates — сертификаты безопасности для HTTPS.
gnupg — инструменты для работы с GPG-ключами.
curl — инструмент для загрузки данных через HTTP.
1.5 Создание базы данных для Zabbix
Теперь создадим базу данных и пользователя для Zabbix.

Запускаем MySQL:
sudo mysql
Создаем базу данных:
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
Создаем пользователя и задаем пароль (замените МойПароль на свой пароль):

CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'МойПароль';
Выдаем пользователю zabbix полные права на базу данных zabbix:

GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
Включаем поддержку функций в базе данных:

SET GLOBAL log_bin_trust_function_creators = 1;
Выходим из MySQL:

EXIT;
Выходим из БД


1.6 Импорт схемы базы данных Zabbix
Теперь необходимо загрузить в MySQL структуру таблиц Zabbix.

Выполняем импорт SQL-скрипта (если запросят пароль, введите МойПароль):
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
zcat — распаковывает сжатый SQL-файл.
mysql -uzabbix -p — запускает MySQL от имени пользователя zabbix и запрашивает пароль.

После успешного импорта снова заходим в MySQL:
sudo mysql

Отключаем функцию создания пользователей:
SET GLOBAL log_bin_trust_function_creators = 0;
EXIT;


1.7 Настройка Zabbix
Теперь нужно прописать пароль базы данных в конфигурационном файле Zabbix.

Открываем файл в редакторе:
sudo nano /etc/zabbix/zabbix_server.conf

Находим строку:
# DBPassword=
Заменяем ее на:
DBPassword=МойПароль
Сохраняем изменения (Ctrl + X → Y → Enter).

1.8 Перезапуск сервисов Zabbix
После всех настроек необходимо перезапустить службы Zabbix и веб-сервера Apache:

sudo systemctl restart zabbix-server zabbix-agent apache2
Добавляем их в автозапуск, чтобы они запускались при старте системы:

sudo systemctl enable zabbix-server zabbix-agent apache2


1.9 Доступ к веб-интерфейсу Zabbix
После успешной установки и настройки веб-интерфейс Zabbix будет доступен в браузере по адресу:

http://<IP-адрес-сервера>/zabbix
Введите IP-адрес вашего сервера.
Используйте стандартные учетные данные для входа:
Логин: Admin
Пароль: zabbix
