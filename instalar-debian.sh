#!/bin/bash

CIAN='\033[0;36m'
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
BLANCO='\033[1;37m'
NC='\033[0m'

clear

echo -e "${CIAN}====================================================${NC}"
echo -e "${BLANCO}         INSTALADOR DE RESCATE - EZEKINGZOTE        ${NC}"
echo -e "${CIAN}====================================================${NC}"

echo ""
echo -e "${AMARILLO}Se solicitarán permisos de administrador una sola vez.${NC}"
sudo -v || exit 1

while true; do
sudo -n true
sleep 60
kill -0 "$$" || exit
done 2>/dev/null &

instalarLamp() {

```
echo -e "\n${CIAN}Instalando LAMP...${NC}"

sudo dpkg --configure -a

sudo apt update -y

sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    apache2 \
    mariadb-server \
    php \
    libapache2-mod-php \
    php-mysql \
    php-cli \
    php-common \
    php-curl \
    php-mbstring \
    php-xml \
    php-bcmath \
    php-zip \
    unzip \
    curl \
    git

sudo systemctl enable apache2
sudo systemctl enable mariadb

sudo systemctl start apache2
sudo systemctl start mariadb

echo -e "${VERDE}LAMP instalado correctamente.${NC}"
```

}

instalarComposer() {

```
if command -v composer >/dev/null 2>&1; then
    echo -e "${VERDE}Composer ya está instalado.${NC}"
    return
fi

echo -e "\n${CIAN}Instalando Composer...${NC}"

cd /tmp || exit

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

php composer-setup.php

sudo mv composer.phar /usr/local/bin/composer

sudo chmod +x /usr/local/bin/composer

composer --version

echo -e "${VERDE}Composer instalado.${NC}"
```

}

configurarLaravel() {

```
echo ""

read -p "URL del repositorio Git: " REPO_URL

read -p "Nombre de la base de datos: " DB_NAME

read -p "Usuario MySQL: " DB_USER

read -s -p "Contraseña MySQL: " DB_PASS
echo ""

PROJECT_NAME=$(basename "$REPO_URL" .git)

PROJECT_PATH="/var/www/$PROJECT_NAME"

if [ -d "$PROJECT_PATH" ]; then
    echo -e "${AMARILLO}La carpeta ya existe.${NC}"
else
    echo -e "\n${CIAN}Clonando proyecto...${NC}"
    sudo git clone "$REPO_URL" "$PROJECT_PATH" || exit 1
fi

sudo chown -R $USER:$USER "$PROJECT_PATH"

cd "$PROJECT_PATH" || exit 1

if [ ! -f artisan ]; then
    echo -e "${ROJO}El repositorio no parece ser un proyecto Laravel.${NC}"
    exit 1
fi

instalarComposer

echo -e "\n${CIAN}Creando base de datos...${NC}"

sudo mysql <<EOF
```

CREATE DATABASE IF NOT EXISTS `$DB_NAME`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '$DB_USER'@'localhost'
IDENTIFIED BY '$DB_PASS';

GRANT ALL PRIVILEGES ON `$DB_NAME`.* TO '$DB_USER'@'localhost';

FLUSH PRIVILEGES;
EOF

```
if [ ! -f .env ]; then

    if [ -f .env.example ]; then

        cp .env.example .env

    else

        echo -e "${ROJO}No existe .env.example${NC}"
        exit 1

    fi

fi

echo -e "\n${CIAN}Configurando .env...${NC}"

sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env

echo -e "\n${CIAN}Instalando dependencias Laravel...${NC}"

composer install --ignore-platform-reqs

php artisan key:generate

php artisan storage:link

php artisan migrate --seed --force

sudo chown -R www-data:www-data "$PROJECT_PATH"

sudo chmod -R 775 storage
sudo chmod -R 775 bootstrap/cache

echo -e "${VERDE}Proyecto Laravel configurado correctamente.${NC}"

echo ""
echo -e "${VERDE}Ruta:${NC} $PROJECT_PATH"
```

}

levantarLaravel() {

```
read -p "Ruta del proyecto Laravel: " PROJECT_PATH

cd "$PROJECT_PATH" || exit 1

if [ ! -f artisan ]; then
    echo -e "${ROJO}No se encontró artisan.${NC}"
    return
fi

php artisan serve --host=0.0.0.0
```

}

actualizarProyecto() {

```
read -p "Ruta del proyecto: " PROJECT_PATH

cd "$PROJECT_PATH" || exit 1

git pull

composer install --ignore-platform-reqs

php artisan migrate --force

php artisan optimize:clear

echo -e "${VERDE}Proyecto actualizado.${NC}"
```

}

instalarTodo() {

```
instalarLamp

configurarLaravel

echo -e "\n${VERDE}INSTALACIÓN COMPLETADA.${NC}"
```

}

while true
do

```
echo ""
echo "1) Instalar LAMP"
echo "2) Clonar y configurar Laravel"
echo "3) Levantar Laravel"
echo "4) Actualizar proyecto"
echo "5) Instalar TODO"
echo "6) Salir"
echo ""

read -p "Seleccione una opción: " OPCION

case $OPCION in

    1)
        instalarLamp
    ;;

    2)
        configurarLaravel
    ;;

    3)
        levantarLaravel
    ;;

    4)
        actualizarProyecto
    ;;

    5)
        instalarTodo
    ;;

    6)
        exit 0
    ;;

    *)
        echo -e "${ROJO}Opción inválida.${NC}"
    ;;

esac
```

done
