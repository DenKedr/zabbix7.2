Вылодил готовый скрипт по установке</br>
Добавлена строка read -s db_password, которая запрашивает у пользователя пароль для базы данных (флаг -s скрывает ввод).</br>

Так же можете пошагово установить сами Zabbix 7.2 на Ubuntum</br>
Инструкция по установке Zabbix на Ubuntu 24.04</br>
</br>
1.1 Обновление системы</br>
Перед установкой Zabbix рекомендуется обновить список пакетов и установить все доступные обновления, чтобы избежать проблем с зависимостями.</br>
<code>sudo apt update && sudo apt upgrade -y</code></br>
</br>
apt update — обновляет список доступных пакетов в системе.</br>
apt upgrade -y — автоматически устанавливает обновления для всех пакетов.
</br></br>
1.2 Установка репозитория Zabbix</br>
Zabbix не включен в стандартные репозитории Ubuntu, поэтому его нужно скачать отдельно.</br>
</br>
Скачиваем официальный пакет репозитория Zabbix: </br>
<code>wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb</code></br>
wget — утилита для загрузки файлов по URL.</br>
Указываем ссылку на последний релиз репозитория Zabbix.</br>
</br>
Устанавливаем загруженный пакет:</br>
<code>sudo dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb</code></br>
dpkg -i — устанавливает пакет в систему.</br>

После установки репозитория обновляем список пакетов:</br>
sudo apt update</br>
</br></br>
1.3 Установка Zabbix сервера, веб-интерфейса и агента</br>
Теперь устанавливаем основные компоненты Zabbix:</br>
<code>sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent </code></br>
zabbix-server-mysql — основной сервер Zabbix, использующий MySQL для хранения данных.</br>
zabbix-frontend-php — веб-интерфейс Zabbix, написанный на PHP.</br>
zabbix-apache-conf — конфигурация для веб-сервера Apache.</br>
zabbix-sql-scripts — скрипты для создания структуры базы данных Zabbix.</br>
zabbix-agent — агент Zabbix, собирающий данные с сервера.</br>
</br></br>
1.4 Установка MySQL</br>
Устанавливаем сервер баз данных MySQL:</br>
<code>sudo apt-get install -y mysql-server</code></br>
mysql-server — пакет, содержащий сервер MySQL.</br>
</br>
Запускаем MySQL:</br>
<code>sudo systemctl start mysql</code></br>
<code>systemctl start mysql</code> — запускает службу MySQL.</br>
</br>
Дополнительные зависимости</br>
Для корректной работы Zabbix также необходимо установить несколько утилит:</br>
<code>sudo apt install -y wget apt-transport-https ca-certificates gnupg curl</code></br>
wget — инструмент для загрузки файлов.</br>
apt-transport-https — поддержка HTTPS в apt.</br>
ca-certificates — сертификаты безопасности для HTTPS.</br>
gnupg — инструменты для работы с GPG-ключами.</br>
curl — инструмент для загрузки данных через HTTP.</br>
</br></br>
1.5 Создание базы данных для Zabbix</br>
Теперь создадим базу данных и пользователя для Zabbix.</br>
Запускаем MySQL:</br>
<code>sudo mysql</code></code></br>
Создаем базу данных:</br>
<code>CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;</code></br>
Создаем пользователя и задаем пароль (замените МойПароль на свой пароль):</br>
</br>
<code>CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'МойПароль';</code></br>
Выдаем пользователю zabbix полные права на базу данных zabbix:</br>
</br>
<code>GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';</code></br>
Включаем поддержку функций в базе данных:</br>
</br>
<code>SET GLOBAL log_bin_trust_function_creators = 1;</code></br>
Выходим из MySQL:</br>
</br>
<code>EXIT;</code></br>
Выходим из БД</br>
</br></br>
1.6 Импорт схемы базы данных Zabbix</br>
Теперь необходимо загрузить в MySQL структуру таблиц Zabbix.</br>
</br>
Выполняем импорт SQL-скрипта (если запросят пароль, введите МойПароль):</br>
<code>zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix</code></br>
zcat — распаковывает сжатый SQL-файл.</br>
<code>mysql -uzabbix -p</code> — запускает MySQL от имени пользователя zabbix и запрашивает пароль.</br>
</br>
После успешного импорта снова заходим в MySQL:</br>
<code>sudo mysql</code></br>
</br>
Отключаем функцию создания пользователей:</br>
<code>SET GLOBAL log_bin_trust_function_creators = 0;</code></br>
<code>EXIT;</code></br>
</br>

1.7 Настройка Zabbix</br>
Теперь нужно прописать пароль базы данных в конфигурационном файле Zabbix.</br>
</br>
Открываем файл в редакторе:</br>
<code>sudo nano /etc/zabbix/zabbix_server.conf</code></br>
</br>
Находим строку:</br>
# DBPassword=</br>
Заменяем ее на:</br>
DBPassword=МойПароль</br>
Сохраняем изменения (Ctrl + X → Y → Enter).</br>
</br></br>
1.8 Перезапуск сервисов Zabbix</br>
После всех настроек необходимо перезапустить службы Zabbix и веб-сервера Apache:</br>
</br>
<code>sudo systemctl restart zabbix-server zabbix-agent apache2</code></br>
Добавляем их в автозапуск, чтобы они запускались при старте системы:</br>
</br>
<code>sudo systemctl enable zabbix-server zabbix-agent apache2</code></br>
</br></br>
1.9 Доступ к веб-интерфейсу Zabbix</br>
После успешной установки и настройки веб-интерфейс Zabbix будет доступен в браузере по адресу:</br>
</br>
http://<IP-адрес-сервера>/zabbix</br>
Введите IP-адрес вашего сервера.</br>
Используйте стандартные учетные данные для входа:</br>
Логин: Admin</br>
Пароль: zabbix</br>
