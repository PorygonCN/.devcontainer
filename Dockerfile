# 基于 Debian 8.4-fpm Bookworm
FROM php:8.4-fpm-bookworm

SHELL ["/bin/bash", "-c"]

# 避免交互式安装提示
ARG DEBIAN_FRONTEND=noninteractive


# 备份原源文件
RUN cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak

# 替换为中科大源
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources


# 安装基础工具
RUN apt-get update && apt-get install -y \
    sudo \
    # 图形处理依赖
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libfreetype6-dev \
    # 压缩依赖
    libzip-dev \
    zlib1g-dev \
    # 数据库依赖
    libpq-dev \
    # ICU 依赖（intl 扩展）
    libicu-dev \
    # XML 处理
    libxml2-dev \
    libxslt1-dev \
    # 其他常用
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libmemcached-dev \
    librabbitmq-dev \
    # 工具
    curl \
    unzip \
    wget \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# 安装 PHP 8.4 常用扩展
RUN docker-php-ext-install \
    pdo_mysql \
    gd \
    mbstring \
    exif \
    bcmath \
    intl \
    zip

# 安装Xdebug
RUN pecl install xdebug

# 安装 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 安装 Node.js 24（通过 NodeSource）
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest yarn

# 创建非 root 用户
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} vscode \
    && useradd --uid  ${USER_UID} --gid  ${USER_GID} -m vscode \
    && mkdir -p /etc/sudoers.d \
    && echo "vscode ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode


# 配置 PHP
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/^;error_log = .*/error_log = \/proc\/self\/fd\/2/' "$PHP_INI_DIR/php.ini"

# 配置 Xdebug
RUN echo "zend_extension=xdebug" > "$PHP_INI_DIR/conf.d/xdebug.ini" \
    && echo "xdebug.mode=develop,debug,coverage" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
    && echo "xdebug.client_host=host.docker.internal" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
    && echo "xdebug.start_with_request=yes" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
    && echo "xdebug.log=/tmp/xdebug.log" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
    && echo "xdebug.client_port=9003" >> "$PHP_INI_DIR/conf.d/xdebug.ini"

# 创建工作目录并设置权限
RUN mkdir -p /var/www/html \
    && chown -R vscode:vscode /var/www/html \
    && chown -R vscode:vscode /home/vscode

# 运行supervisor 以管理员账户运行主进程
RUN service supervisor start

# 切换到非 root 用户
USER vscode

# 设置工作目录
WORKDIR /var/www/html
