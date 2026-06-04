#!/bin/bash

CIAN='\033[0;36m'
VERDE='\033[0;32m'
ROJO='\033[0;31m'
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

obtenerPermisos() {

    echo ""
    echo "Este script necesita permisos de administrador."
    echo ""

    sudo -v

    if [ $? -ne 0 ]; then
        echo -e "${ROJO}No se pudieron obtener permisos sudo.${NC}"
        exit 1
    fi
}

instalarLamp() {

    echo ""
    echo "Instalando dependencias..."
    echo ""

    sudo apt update

    sudo apt install -y \
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
        php-zip \
        php-gd \
        php-intl

    sudo systemctl enable apache2
    sudo systemctl enable mariadb

    sudo systemctl restart apache2
    sudo systemctl restart mariadb

    if ! command -v composer >/dev/null 2>&1; then

        echo ""
        echo "Instalando Composer..."
        echo ""

        cd /tmp || exit

        curl -sS https://getcomposer.org/installer -o composer-setup.php

        php composer-setup.php

        sudo mv composer.phar /usr/local/bin/composer

        sudo chmod +x /usr/local/bin/composer

    fi

    echo ""
    echo -e "${VERDE}LAMP instalado correctamente.${NC}"
}

instalarLaravel() {

    echo ""

    read -p "URL del repositorio Git: " REPO_URL

    echo ""

    read -p "Nombre de la base de datos: " DB_NAME

    read -p "Usuario MySQL: " DB_USER

    read -s -p "Contraseña MySQL: " DB_PASS

    echo ""
    echo ""

    PROJECT_NAME=$(basename "$REPO_URL" .git)

    PROJECT_PATH="/var/www/html/$PROJECT_NAME"

    if [ ! -d "$PROJECT_PATH" ]; then

        echo "Clonando proyecto..."

        sudo git clone "$REPO_URL" "$PROJECT_PATH"

    else

        echo "La carpeta ya existe."
        echo "Actualizando repositorio..."

        cd "$PROJECT_PATH" || exit

        sudo git pull

    fi

    sudo chown -R "$USER:$USER" "$PROJECT_PATH"

    cd "$PROJECT_PATH" || exit

    if [ ! -f artisan ]; then

        echo -e "${ROJO}No parece ser un proyecto Laravel.${NC}"
        return

    fi

    echo "$PROJECT_PATH" > "$PROJECT_FILE"

    echo ""
    echo "Creando base de datos..."
    echo ""

    sudo mysql -e "
        CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_unicode_ci;
    "

    sudo mysql -e "
        CREATE USER IF NOT EXISTS '$DB_USER'@'localhost'
        IDENTIFIED BY '$DB_PASS';
    "

    sudo mysql -e "
        GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
    "

    sudo mysql -e "FLUSH PRIVILEGES;"

    if [ ! -f .env ]; then

        if [ -f .env.example ]; then

            cp .env.example .env

        else

            echo -e "${ROJO}No existe .env.example${NC}"
            return

        fi

    fi

    sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
    sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
    sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env

    echo ""
    echo "Instalando dependencias Composer..."
    echo ""

    composer install --ignore-platform-reqs

    echo ""
    echo "Generando APP_KEY..."
    php artisan key:generate

    echo ""
    echo "Creando Storage Link..."
    php artisan storage:link

    echo ""
    echo "Ejecutando migraciones..."
    php artisan migrate --seed --force

    sudo chown -R www-data:www-data "$PROJECT_PATH"

    sudo chmod -R 775 storage
    sudo chmod -R 775 bootstrap/cache

    echo ""
    echo -e "${VERDE}Proyecto instalado correctamente.${NC}"

    echo ""
    echo "Ruta:"
    echo "$PROJECT_PATH"
}

levantarLaravel() {

    if [ ! -f "$PROJECT_FILE" ]; then

        echo ""
        echo -e "${ROJO}No existe un proyecto registrado.${NC}"
        return

    fi

    PROJECT_PATH=$(cat "$PROJECT_FILE")

    cd "$PROJECT_PATH" || return

    echo ""
    echo "Iniciando Laravel..."
    echo ""

    php artisan serve --host=0.0.0.0 --port=8000
}

instalarTodo() {

    instalarLamp

    instalarLaravel
}

obtenerPermisos

while true
do

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
    echo "   - Configurar .env"
    echo "   - Composer Install"
    echo "   - Key Generate"
    echo "   - Storage Link"
    echo "   - Migrate Seed"
    echo ""

    echo "3) Levantar Laravel"
    echo ""

    echo "4) Instalar Todo"
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
            echo "Opción inválida"
        ;;

    esac

    echo ""
    read -p "Presione ENTER para continuar..."

done