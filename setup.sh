#!/bin/bash

# 设置权限
echo "🔐 Setting permissions..."

cd /var/www/html


echo "🚀 Setting up Laravel development environment..."

# 安装 Laravel 如果不存在
if [ ! -f "composer.json" ]; then
    echo "📦 Installing Laravel..."

    composer create-project laravel/laravel tempLaravel --prefer-dist --no-interaction

    mv tempLaravel/* ./
    mv tempLaravel/.* ./ 2>/dev/null
    rm -rf tempLaravel
    cp ./.devcontainer/.env .env
    php artisan migrate --force

fi

echo "📝 Recreate storage:link..."
if [ -f "artisan" ]; then

    php artisan storage:link --force --no-interaction 
    
    chmod -R 775 storage bootstrap/cache
fi

# 如果没有就自动初始化Git仓库
if [ ! -d ".git" ]; then
    echo "📝 Configuring Git..."
    git config --global --add safe.directory /var/www/html && git config --global --add safe.directory '*'
    git config --global pull.rebase false
    echo "📝 Init Git Repository..."
    git init
fi

if [ -d "./.devcontainer/.git" ]; then
    sudo rm -rf ./.devcontainer/.git
fi

su - vsocde

echo "✅ Setup complete! Your Laravel environment is ready."
echo "🌐 Access your app at: http://localhost"
echo "📧 Mailpit at: http://localhost:8025"
