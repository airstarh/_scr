FROM php:8.2-fpm AS imag_php82health
USER root

RUN ln -sf /bin/bash /bin/sh

COPY soft/composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iputils-ping \
        dnsutils \
        curl \
        libmagickwand-dev \
        pkg-config \
        git \
        unzip \
        libzip-dev \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Imagick via PECL
RUN pecl install imagick && \
    docker-php-ext-enable imagick

# PDO and PDO_mysql are built‑in to PHP 8.2 FPM — no need to enable; just verify they’re present
RUN php -m | grep -E 'imagick|pdo|pdo_mysql' || exit 1

RUN echo "=== NETWORK DEBUG ===" && \
    echo "" && \
    echo "--- DNS Configuration ---" && \
    cat /etc/resolv.conf && \
    echo "" && \
    echo "--- DNS Resolution Test ---" && \
    (getent hosts deb.debian.org 2>&1 || echo "DNS resolution failed") && \
    echo "" && \
    echo "--- Connectivity Test (8.8.8.8) ---" && \
    (curl -s --connect-timeout 3 -o /dev/null -w "HTTP Status: %{http_code}\n" http://8.8.8.8 2>&1 || echo "Connectivity failed") && \
    echo "" && \
    echo "--- HTTP Test (deb.debian.org) ---" && \
    (curl -s --connect-timeout 3 -o /dev/null -w "HTTP Status: %{http_code}\n" http://deb.debian.org 2>&1 || echo "HTTP test failed")

CMD ["php-fpm"]
