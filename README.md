# MARLIS (MariaDB & ILIAS)
This docker container provides development environment for ILIAS Learn Management System

## Prerequisites
Ensure that Docker is installed on your host machine.

## What will be installed and configured
This Docker setup will install and configure the following components:
- PHP 8.2
- Required PHP packages:
    - php-gd, php-xml, php-mysql, php-mbstring, php-imagick, php-zip, php-intl
- Apache 2.4.x with mod_php
- OpenJDK 17 
- Node.js
- npm

Additionally, the following settings will be automatically applied in the php.ini file:
- max_execution_time = 600
- memory_limit = 512M
- session.gc_probability = 1
- session.gc_divisor = 100
- session.gc_maxlifetime = 14400
- session.hash_function = 0
- session.cookie_httponly = On

For MariaDB, the following settings are necessary (some of them will not be automatically applied and should be configured manually after installation):
- InnoDB storage engine (default)
- Character Set: utf8
- Collation: utf8_general_ci
- join_buffer_size > 128.0K
- table_open_cache > 400
- innodb_buffer_pool_size > 2G (depending on DB size)

Important: PHP settings will be copied from the php.ini file automatically. However, certain MariaDB settings need to be configured manually after installation. Please verify and adjust them as necessary.


## Getting started
1. Clone this repository to your local machine
```
git clone https://your-repository-url.git
```

2. Build the image
```
docker-compose build --no-cache
```

3. Start the container
```
docker-compose up
```

4. Clone ILIAS and install dependencies
```
cd /var/www/html
git clone https://github.com/ILIAS-eLearning/ILIAS.git . --single-branch
composer install --no-dev
npm clean-install --omit=dev --ignore-scripts
```

5. Check if webserver already up and running
```
service apache2 status
service apache2 start
```

6. Or restart webserver if it is already running
```
service apache2 restart
```

7. Check if MariaDB already running if not fire it up
```
service mariadb status
service mariadb start
```

8. Adjust MariaDB settings and save with control + X then Y enter
```
cd /etc/mysql/mariadb.conf.d
nano 50-server.cnf

// modify these two as followed
character-set-server  = utf8   
collation-server      = utf8_general_ci
// uncomment following line
innodb_buffer_pool_size = 8G
```

9. Restart Mariadb settings
```
service mariadb restart
```

10. Open mariadb and check also the configurations by writing following queries:
```
mariadb -u root -p -h localhost
```
```
SHOW VARIABLES LIKE 'storage_engine'; // default is InnoDB no need to change
```
```
SHOW VARIABLES LIKE 'character_set_server'; // utf8
```
```
SHOW VARIABLES LIKE 'join_buffer_size'; // default is 262144 which means 256K no need to change
```
```
SHOW VARIABLES LIKE 'table_open_cache'; // default is 2000 and if greater than 400 no need to change
select @@table_open_cache; // also works
```
```
SHOW VARIABLES LIKE 'innodb_buffer_pool_size'; // default was 128MB and after changing should be 8GB
```

11. Create databse
```
CREATE DATABASE ilias CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'marlis'@'localhost' IDENTIFIED BY '12345Aa';
GRANT LOCK TABLES on *.* TO 'marlis'@'localhost';
GRANT ALL PRIVILEGES ON ilias.* TO 'marlis'@'localhost';
FLUSH PRIVILEGES;
```

12. Customize your settings in the config.json file located in the workspace, then proceed with the ILIAS installation.
```
mkdir logs
mkdir files
cd /var/www/html
php setup/setup.php install /workspace/config.json
```

13. Create extra directories for files and logs and files Change group ownership to www-data for the following directories
```
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/files
chown -R www-data:www-data /var/www/logs
```

14. Once the container is up and running, you can access the ILIAS on your host machine's web browser by navigating to:
```
http://localhost:3000
```

15. You should then land on the ILIAS login page. Log in using the following credentials:
```
user: root
pass: homer
```
16. After logging in, you will be prompted to set a new password.

## Dockerfile
This Dockerfile creates a container with a development environment featuring:
- Base Image: Starts from the official Ubuntu image.
- Environment Setup: Sets the environment variable to avoid prompts during installation (DEBIAN_FRONTEND=noninteractive).
- PHP 8.2 Installation: Adds a repository for PHP 8.2 and installs PHP along with extensions needed for ILIAS LMS development.
- Apache Setup: Installs Apache, configures it to support PHP, and enables URL rewriting.
- MariaDB: Installs MariaDB for database management.
- Composer: Installs Composer for PHP dependency management.
- Node.js and npm: Installs Node.js and npm requied for installation.
- Java: Installs OpenJDK 17 for Java applications.
- Custom PHP Configuration: Copies a custom php.ini file into the container.

## docker-compose.yml
This part of the docker-compose.yml file defines a service for the Docker container and sets up some additional configurations. Here's what important section does:

- **volumes:**
    - **./src:/var/www/html**  Maps the ./src directory (from the host machine) to /var/www/html inside the container. This is typically where your web application's source code will reside.
    - **db_data:/var/lib/mysql**  Persists MariaDB data by mapping the named volume db_data to the container's MySQL data directory (/var/lib/mysql). This keeps your database data even if the container is destroyed.

- **ports:**
    - **3000:80**  Maps port 80 inside the container (default HTTP port) to port 3000 on the host machine. This means the web server can be accessed at http://localhost:3000 on the host.

- **tty: true**  Keeps the terminal (tty) open for interactive sessions when the container is running.
- **volumes:**
    - **db_data**  Declares a named volume db_data to persist database data across container restarts or recreations.

## php.ini
The following recommended PHP settings will be automatically copied to the php.ini file inside the Docker container during installation.

## src
The src folder contains the ILIAS LMS codebase.