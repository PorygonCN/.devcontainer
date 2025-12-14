这是一个为 laravel 项目快速启动基于 vscode 和 docker 的 devcontainer 开发容器的配置文件
项目使用的是 php8.4 较老的项目可能会有一些冲突 可自行修改配置

## 使用镜像

- php:8.4-fpm-bookworm 基础镜像
- nginx:1.25-alpine 以网站部署形式进行开发预览
- mariadb 作为 mysql 使用
- redis 缓存
- axllent/mailpit 用于测试发出去的邮件

具体情况查看 docker-compose.yml

php 扩展额外安装了 `pdo_mysql` `gd` `mbstring` `exif` `bcmath` `intl` `zip` `xdebug` 修改及查看详细信息自行查看`Dockerfile`

容器中安装了`nodejs24`(Dockerfile) `git`(devcontainer.json)

## 使用方式

1. 新建文件夹 `eg. demo` 或 打开已有项目 以下简称 项目目录
2. 克隆本项目到项目目录中 完成本步骤后应该是项目目录中有一个`.devcontainer` 目录
3. 通过 vscode 打开项目目录 并确保已安装[Dev Container](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)扩展
4. 点击右下角提示 “在容器中重新打开” 没有也可以点左下角打开远程窗口选择 “在容器中重新打开”
5. 等待启动完成
6. 当项目目录是空项目启动时 容器会自动创建一个最新的 laravel 项目
7. 当项目目录是已有项目时 容器启动后则正常显示已有项目
8. 启动项目完成后 容器会尝试初始化 git 仓库（已有则跳过）并删除 `.devcontainer`目录下的`.git`目录 以方便项目目录的 git 仓库正确识别并添加`.devcontainer`到仓库中
9. enjoy it！
