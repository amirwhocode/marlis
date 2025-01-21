# Start from an official Ubuntu base image
FROM ubuntu:latest

# Set environment variables to non-interactive to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Add the PHP PPA repository for PHP 8.2
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update -y


# Update package list and install required dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    ca-certificates \
    unzip \
    git \
    zip \
    wget \
    apache2 \
    libapache2-mod-php8.2\
    imagemagick \
    ssmtp \
    openjdk-17-jdk \
    nano \
    && apt-get clean

# Install PHP 8.2 and extensions
RUN apt-get install -y \
    php8.2 \
    php8.2-cli \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-curl \
    php8.2-zip \
    php8.2-bcmath \
    php8.2-intl \
    php8.2-gd \
    php8.2-imagick \
    php8.2-mysql \
    && apt-get clean

# Copy custom PHP configuration file
COPY ./php.ini /etc/php/8.2/apache2/php.ini

    # Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install MariaDB and dependencies
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js and npm (using NodeSource repository for the latest version)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Verify installations
RUN php -v && \
    composer --version && \
    node -v && \
    npm -v && \
    java -version

# Set up working directory
WORKDIR /workspace

# TODO:
# Start Apache and MariaDB
# CMD ["bash", "-c", "service apache2 start && service mysql start && tail -f /dev/null"] not working stops the container immediately after starting
# also command: ["bash", "-c", "service apache2 start && service mariadb start"] in docker compose file not works