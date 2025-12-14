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


# 安装 PHP 依赖
if [ -f "composer.json" ]; then
    if [ -f "artisan" ]; then
        echo "🔧 Setting up Laravel..."
        php artisan key:generate --no-interaction
        
        if [ ! -f "./public/storage" ]; then
            php artisan storage:link --no-interaction
        fi
        
        chmod -R 775 storage bootstrap/cache
    fi
fi


# 安装 Node.js 依赖
if [ -f "package.json" ]; then
    echo "📦 Installing Node.js dependencies..."
    npm install --no-audit --prefer-offline
    
    # 如果是 Laravel 9+ 有 Vite
    if [ -f "vite.config.js" ]; then
        echo "⚡ Setting up Vite..."
        npm run build
    fi
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
    rm -rf ./.devcontainer/.git
fi



echo "✅ Setup complete! Your Laravel environment is ready."
echo "🌐 Access your app at: http://localhost"
echo "📧 Mailpit at: http://localhost:8025"
