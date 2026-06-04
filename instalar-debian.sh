#!/bin/bash

CIAN='\033[0;36m'
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
BLANCO='\033[1;37m'
NC='\033[0m'

PROJECT_FILE="$HOME/.laravel_project_path"

mostrarTitulo() {
clear
echo -e "${CIAN}====================================================${NC}"
echo -e "${BLANCO}         INSTALADOR DE RESCATE - EZEKINGZOTE        ${NC}"
echo -e "${CIAN}====================================================${NC}"
echo ""
}

solicitarSudo() {
echo -e "${AMARILLO}Se solicitará la contraseña del usuario una sola vez.${NC}"
sudo -v || exit 1

```
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &
```

}

instalarLamp() {

```
echo -e "\n${CIAN}Instalando Apache, MariaDB, PHP, Composer y Git...${NC}"

sudo dpkg --configure -a

sudo apt update -y

sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    apache2 \
    mariadb-server \
    git \
    curl \
    unzip \
    php \
    libapache2-mod-php \
    php-cli \
    php-common \
    php-mysql \
    php-curl \
    php-mbstring \
    php-xml \
    php-bcmath \
    php-zip

sudo systemctl enable apache2
sudo systemctl enable mariadb

sudo systemctl restart apache2
sudo systemctl restart mariadb

if ! command -v composer >/dev/null 2>&1; then

    echo -e "\n${CIAN}Instalando Composer...${NC}"

    cd /tmp || exit

    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

    php composer-setup.php

    sudo mv composer.phar /usr/local/bin/composer

    sudo chmod +x /usr/local/bin/composer

fi

echo -e "${VERDE}LAMP instalado correctamente.${NC}"
```

}

instalarLaravel() {

```
echo ""

read -p "URL del repositorio Git: " REPO_URL

read -p "Nombre de la Base de Datos: " DB_NAME

read -p "Usuario MySQL: " DB_USER

read -s -p "Contraseña MySQL: " DB_PASS
echo ""

PROJECT_NAME=$(basename "$REPO_URL" .git)

PROJECT_PATH="/var/www/html/$PROJECT_NAME"

echo -e "\n${CIAN}Clonando proyecto...${NC}"

if [ -d "$PROJECT_PATH" ]; then
    echo -e "${AMARILLO}La carpeta ya existe. Se utilizará la existente.${NC}"
else
    sudo git clone "$REPO_URL" "$PROJECT_PATH" || exit 1
fi

sudo chown -R "$USER:$USER" "$PROJECT_PATH"

cd "$PROJECT_PATH" || exit 1

if [ ! -f artisan ]; then
    echo -e "${ROJO}El repositorio no parece ser Laravel.${NC}"
    return
fi

echo "$PROJECT_PATH" > "$PROJECT_FILE"

echo -e "\n${CIAN}Creando Base de Datos...${NC}"

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
        return

    fi

fi

echo -e "\n${CIAN}Configurando .env...${NC}"

sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env

echo -e "\n${CIAN}Instalando dependencias Composer...${NC}"

composer install --ignore-platform-reqs

echo -e "\n${CIAN}Generando APP_KEY...${NC}"
php artisan key:generate

echo -e "\n${CIAN}Creando enlace Storage...${NC}"
php artisan storage:link

echo -e "\n${CIAN}Ejecutando Migraciones y Seeders...${NC}"
php artisan migrate --seed --force

echo -e "\n${CIAN}Asignando permisos...${NC}"

sudo chmod -R 777 storage
sudo chmod -R 777 bootstrap/cache

sudo chown -R www-data:www-data "$PROJECT_PATH"

echo -e "\n${VERDE}Proyecto Laravel instalado correctamente.${NC}"

echo ""
echo "Ruta del proyecto:"
echo "$PROJECT_PATH"
```

}

levantarLaravel() {

```
if [ ! -f "$PROJECT_FILE" ]; then
    echo -e "${ROJO}No existe un proyecto Laravel registrado.${NC}"
    return
fi

PROJECT_PATH=$(cat "$PROJECT_FILE")

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${ROJO}La carpeta del proyecto ya no existe.${NC}"
    return
fi

cd "$PROJECT_PATH" || return

echo -e "\n${VERDE}Iniciando servidor Laravel...${NC}\n"

php artisan serve --host=0.0.0.0 --port=8000
```

}

instalarTodo() {

```
instalarLamp

instalarLaravel

echo -e "\n${VERDE}Instalación completada.${NC}"
```

}

solicitarSudo

while true
do

```
mostrarTitulo

echo "1) Instalar LAMP"
echo "   - Apache"
echo "   - MariaDB"
echo "   - PHP"
echo "   - Composer"
echo "   - Git"
echo ""

echo "2) Instalar Proyecto Laravel"
echo "   - Clonar repositorio"
echo "   - Crear Base de Datos"
echo "   - Copiar .env.example"
echo "   - Configurar .env"
echo "   - Composer Install"
echo "   - Key Generate"
echo "   - Storage Link"
echo "   - Migrate Seed"
echo ""

echo "3) Levantar Laravel"
echo "   - php artisan serve"
echo ""

echo "4) Instalar Todo"
echo "   - Ejecuta 1 + 2"
echo ""

echo "5) Salir"
echo ""

read -p "Seleccione una opción: " OPCION

case $OPCION in

    1)
        instalarLamp
    ;;

    2)
        instalarLaravel
    ;;

    3)
        levantarLaravel
    ;;

    4)
        instalarTodo
    ;;

    5)
        exit 0
    ;;

    *)
        echo -e "${ROJO}Opción inválida.${NC}"
    ;;

esac

echo ""
read -p "Presione ENTER para continuar..."
```

done
