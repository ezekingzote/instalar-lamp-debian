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
echo ""

# Solicitar datos al usuario
read -p "Introduce el nombre del nuevo usuario DB: " DB_USER
read -s -p "Introduce la contraseña para $DB_USER: " DB_PASS
echo -e "\n"

# 1. Actualización
echo -e "${BLANCO}[1/6]${NC} Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalación de paquetes
echo -e "${BLANCO}[2/6]${NC} Instalando Apache y MariaDB..."
sudo apt install -y apache2 mariadb-server mariadb-client-compat

# 3. Configuración de MariaDB
echo -e "${BLANCO}[3/6]${NC} Limpiando instalación de MariaDB..."
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "FLUSH PRIVILEGES;"

# 4. Crear el usuario personalizado
echo -e "${BLANCO}[4/6]${NC} Creando usuario '${DB_USER}'..."
sudo mariadb -e "GRANT ALL ON *.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;"
sudo mariadb -e "FLUSH PRIVILEGES;"

# 5. PHP e Info
echo -e "${BLANCO}[5/6]${NC} Instalando PHP..."
sudo apt install -y php libapache2-mod-php php-mysql
sudo chmod -R 777 /var/www/
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null

# 6. Errores y Reinicio
echo -e "${BLANCO}[6/6]${NC} Activando errores y reiniciando Apache..."
PHP_INI=$(php -i | grep "Loaded Configuration File" | awk '{print $5}')
sudo sed -i 's/display_errors = Off/display_errors = On/' "$PHP_INI"
sudo service apache2 restart

echo ""
echo -e "${CIAN}====================================================${NC}"
echo -e "${VERDE}    ¡INSTALACIÓN COMPLETADA POR EZEKINGZOTE!    ${NC}"
echo -e "${BLANCO}    Usuario DB: ${DB_USER}${NC}"
echo -e "${BLANCO}    URL: http://localhost/info.php              ${NC}"
echo -e "${CIAN}====================================================${NC}"