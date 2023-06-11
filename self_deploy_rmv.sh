#!/bin/bash

if [ -f ./env.sh ]; then
    source ./root/self_deploy/env.sh
else
    source /root/self_deploy/env.sh
fi

# 检查目录是否存在，不存在则说明未安装或者安装已被移动
if [ ! -d "$SELF_DEPLOY_DIR" ]; then
    echo "No need uninstall! The files has been moved or not install!"
    exit 0
fi

# 清除定时任务
sed -i "/ddns_self_guard/d" $CRONTAB_FILE
sed -i "/network_self_guard/d" $CRONTAB_FILE
# 清除安装目录及文件
rm -rf $SELF_DEPLOY_DIR
