# Use uma imagem base que tenha PHP e Composer instalados
FROM php:8.2-fpm

# Defina a variável de ambiente DEBIAN_FRONTEND para noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Atualize o sistema e instale as dependências necessárias
RUN apt-get update && apt-get install -y \
    git \
    supervisor \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Instale o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# define o diretório de trabalho
WORKDIR /var/www/html

# Copie os arquivos da aplicação Laravel para o container
COPY . .

# Instale as dependências do Laravel usando o Composer
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Instale o Nginx
RUN apt-get install -y nginx

# Configure o servidor Nginx
COPY docker/default.conf /etc/nginx/sites-available/default

# Instale o OpenSSL
RUN apt-get install -y openssl

# Crie a pasta /etc/nginx/ssl/ se ela não existir
RUN mkdir -p /etc/nginx/ssl/

# Gere os certificados autoassinados caso não existam
# RUN openssl req -x509 -newkey rsa:4096 -nodes -subj "/C=US/ST=California/L=San Francisco/O=Markware LTDA/CN=localhost" \
#     -days 365 -keyout /etc/nginx/ssl/key.pem -out /etc/nginx/ssl/cert.pem

# Copie o script init.sh
COPY docker/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Configure o PHP
COPY docker/php.ini /usr/local/etc/php/php.ini

# Exponha as portas 80 e 443
EXPOSE 80
EXPOSE 443

# Define o usuário "www-data" para evitar problemas de permissão
RUN chown -R www-data:www-data /var/www/html

# Crie o diretório para os logs do Supervisor
RUN mkdir -p /var/log/supervisor

# Copie o arquivo de configuração do Supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Comando de inicialização usando o Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]