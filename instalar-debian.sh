#!/bin/bash
CIAN='\033[0;36m'
VERDE='\033[0;32m'
BLANCO='\033[1;37m'
NC='\033[0m'

# Función que borra la carpeta al salir (éxito o fallo)
cleanup() {
    echo -e "\n${VERDE}Finalizando y eliminando carpeta del repo...${NC}"
    cd /tmp
    rm -rf "$REPO_PATH"
    exit
}
# Trap captura el final del script
trap cleanup EXIT

REPO_PATH=$(pwd)

clear
echo -e "${CIAN}====================================================${NC}"
echo -e "${BLANCO}         INSTALADOR DE RESCATE - EZEKINGZOTE        ${NC}"
echo -e "${CIAN}====================================================${NC}"

read -p "Usuario DB: " DB_USER
read -s -p "Contraseña DB: " DB_PASS
echo ""

# 1. Reparar dpkg antes de empezar
sudo dpkg --configure -a
sudo apt update

# 2. Instalar con manejo de errores
sudo apt install -y apache2 mariadb-server php libapache2-mod-php php-mysql || { echo "Error en instalación"; exit 1; }

# 3. Configurar DB
sudo mysql -e "GRANT ALL ON *.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# 4. Configurar PHP (Fix: buscamos el archivo correctamente)
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
PHP_INI="/etc/php/$PHP_VERSION/apache2/php.ini"

if [ -f "$PHP_INI" ]; then
    sudo sed -i 's/display_errors = Off/display_errors = On/' "$PHP_INI"
else
    echo "No se encontró php.ini en $PHP_INI, saltando..."
fi

# 5. Permisos y Apache
sudo chmod -R 777 /var/www/html
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null
sudo systemctl restart apache2

echo -e "${VERDE}¡INSTALACIÓN COMPLETADA!${NC}"