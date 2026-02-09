---
layout: post
title:  "用树莓派搭建 Gitea Git 服务器"
date:   2026-02-09 10:00:00 +0800
categories: 教程
tag: [RaspberryPi, Gitea, Git]
---

## 写在前面

搬了新家，看着刚翻出来满是灰的树莓派4B，准备在家里搭一个一直在线的 Git 服务器；鉴于树莓派的性能，这里选用轻量的 Gitea 作为 git 服务器

## 环境准备

- **硬件**：树莓派4B、电源、128GB microSD
- **系统**：Raspberry PI OS Lite
- **网络**：没有公网IP，使用Cloudflare Tunnel做内网穿透

先给树莓派烧录镜像，这里我们使用 Raspberry Pi Imager，选择操作系统的部分要选择 Raspberry PI OS (Other)，然后选择第一个 Raspberry PI OS Lite (64-bit)

![image-20260209225322102](/assets/img/2026-2-9-rpigitserver/image-20260209225322102.png)

> Lite 版本是没有桌面的，如果您不习惯纯终端的操作方式，请选择桌面版
> {: .prompt-info }

## 安装与基础配置

- **系统更新**：`sudo apt update && sudo apt upgrade` 等  

- **创建专用用户**：由于 Gitea 不能以 root 用户运行，所以我们需要单独给 Gitea 创建一个用户（当然如果你为了省事也可以不这么做）：

  ```bash
  sudo useradd -r -m -d /home/gitea gitea
  sudo passwd gitea
  su gitea
  ```

- **安装 Git**：确认 `git` 本体已经就绪  

- **安装数据库**：Gitea支持很多种数据库，这里我们选用轻量的SQLite3数据库

  ```bash
  sudo apt install sqlite3
  ```

## 安装 Gitea

树莓派上我们使用二进制文件安装：

```bash
wget -O gitea https://dl.gitea.com/gitea/main-nightly/gitea-main-nightly-linux-arm64
chmod +x gitea
```

## Web 服务初始化

- **启动 Gitea Web 服务**：

```bash
./gitea
```

如图配置即可，站点名称和网址填你自己的

![9bb625911adf4a1dc6ed0fedb0d2bee0](/assets/img/2026-2-9-rpigitserver/9bb625911adf4a1dc6ed0fedb0d2bee0.png)

> 基础 URL 必须是 https 并且不能带端口号！！这是个大坑
> {: .prompt-warning }

随后注册你的管理员用户，注册完毕后如果在上一步中将基础 URL 改成了https你会发现登不进去，不过这无关紧要

## Cloudflare Tunnel

进入你的 Cloudflare 控制台主页，左边点击 Zero Trust，然后选择 网络，再点击 连接器，选择 创建隧道

![image-20260209234323456](/assets/img/2026-2-9-rpigitserver/image-20260209234323456.png)

然后选择 Cloudflared

![image-20260209234623106](/assets/img/2026-2-9-rpigitserver/image-20260209234623106.png)

随后按照说明，给树莓派安装 Clardflared并启用服务；安装完毕后回到你的连接器页面，应该能看到状态变为正常

![image-20260209235401118](/assets/img/2026-2-9-rpigitserver/image-20260209235401118.png)

点击连接器最右边的三个点，选择配置，选择已发布程序路由，添加新的已发布程序路由

![image-20260209235705924](/assets/img/2026-2-9-rpigitserver/image-20260209235705924.png)

在这里可以顺便创建一个 SSH 规则，注意域名尽量不要和 http 相同

创建完毕后访问一下，应该可以已经访问通了

## HTTPS 访问配置

然后我们再给网站套个经典五秒盾，这个很简单，如图设置就行

![image-20260210001430961](/assets/img/2026-2-9-rpigitserver/image-20260210001430961.png)

## 仓库管理与维护

由于我们套了五秒盾，https 的 git 拉取与推送会失败，不过我们用 SSH 即可

先在后台添加你自己的 SSH 公钥

![image-20260210001838430](/assets/img/2026-2-9-rpigitserver/image-20260210001838430.png)

然后试着使用 SSH 推送，如果能成功，恭喜你，服务器搭建完成🎉

## 开机自启动

放一个`gitea.service`文件到`/etc/systemd/system`下

抄作业配置：

```ini
[Unit]
Description=Anatdx Git Repos
After=network.target
After=syslog.target

[Service]
RestartSec=2s
Type=simple
User=gitea
Group=gitea
WorkingDirectory=/home/gitea/
ExecStart=/home/gitea/gitea web --config /home/gitea/custom/conf/app.ini
Restart=always
Environment=USER=gitea HOME=/home/gitea GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
```

然后注册服务：

```bash
sudo systemctl enable gitea
sudo systemctl start gitea
```

## 一点废话

~~Cloudflare一天到晚改他那面板，这教程说不定过几天位置又变了~~
