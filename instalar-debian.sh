#!/bin/bash
CIAN='\033[0;36m'
VERDE='\033[0;32m'
BLANCO='\033[1;37m'
NC='\033[0m'

clear
echo -e "${CIAN}====================================================${NC}"
echo -e "${BLANCO}         INSTALADOR AUTOMÁTICO DE STACK LAMP        ${NC}"
echo -e "${VERDE}              Creado por: EZEKINGZOTE               ${NC}"
echo -e "${CIAN}====================================================${NC}"

# Pedir datos
read -p "Introduce el nombre del nuevo usuario DB: " DB_USER
read -s -p "Introduce la contraseña para $DB_USER: " DB_PASS
echo -e "\n"

# Reparación de errores previos de dpkg
echo -e "${BLANCO}[1/7]${NC} Reparando posibles errores de instalaciones previas..."
sudo dpkg --configure -a
sudo apt --fix-broken install -y

echo -e "${BLANCO}[2/7]${NC} Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

echo -e "${BLANCO}[3/7]${NC} Instalando Apache y MariaDB..."
sudo apt install -y apache2 mariadb-server mariadb-client

echo -e "${BLANCO}[4/7]${NC} Configurando MariaDB..."
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "FLUSH PRIVILEGES;"

echo -e "${BLANCO}[5/7]${NC} Creando usuario '${DB_USER}'..."
sudo mariadb -e "GRANT ALL ON *.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;"
sudo mariadb -e "FLUSH PRIVILEGES;"

echo -e "${BLANCO}[6/7]${NC} Instalando PHP..."
sudo apt install -y php libapache2-mod-php php-mysql
sudo chmod -R 777 /var/www/
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null

echo -e "${BLANCO}[7/7]${NC} Configurando errores y reiniciando Apache..."
PHP_INI=$(php -i | grep "Loaded Configuration File" | awk '{print $5}')
sudo sed -i 's/display_errors = Off/display_errors = On/' "$PHP_INI"
sudo service apache2 restart

echo -e "${CIAN}====================================================${NC}"
echo -e "${VERDE}    ¡INSTALACIÓN REPARADA POR EZEKINGZOTE!      ${NC}"
echo -e "${CIAN}====================================================${NC}"