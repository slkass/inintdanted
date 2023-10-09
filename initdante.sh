#!/bin/bash

# 第一步：安装dante-server
sudo apt update
sudo apt install dante-server

# 第二步：覆盖/etc/danted.conf配置
PORT=$((RANDOM % 3000 + 10001))  # 产生一个范围在10001到13000之间的随机数

cat <<EOL | sudo tee /etc/danted.conf
logoutput: syslog
user.privileged: root
user.unprivileged: nobody

internal: 0.0.0.0 port=$PORT
external: ens4

socksmethod: username
clientmethod: none

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}
EOL

# 第三步：创建用户名为warocket的用户
PASSWORD="warocket$((RANDOM % 99 + 1))"  # 产生一个范围在01到99之间的随机数作为密码
sudo useradd -M -s /sbin/nologin warocket
echo "warocket:$PASSWORD" | sudo chpasswd

# 第四步：打印socks5链接信息
EXTERNAL_IP=$(curl -s ifconfig.me)  # 获取本机外部IP地址
echo "socks5://warocket:$PASSWORD@$EXTERNAL_IP:$PORT"

