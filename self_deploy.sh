#!/bin/bash

if [ -f $(pwd)/root/self_deploy/env.sh ]; then
    source $(pwd)/root/self_deploy/env.sh
else
    source /root/self_deploy/env.sh
fi

# 检查目录是否存在，不存在则创建
if [ ! -d "$SELF_DEPLOY_DIR" ]; then
    echo "Creating directory $SELF_DEPLOY_DIR"
    mkdir -p "$SELF_DEPLOY_DIR"
fi

cp -r ./root/self_deploy/* $SELF_DEPLOY_DIR
chmod +x $SELF_DEPLOY_DIR/*.sh # 添加执行权限

# 加入定时任务
sed -i "/ddns_check/d" $CRONTAB_FILE
echo "10 * * * * $SELF_DEPLOY_DIR/ddns_check.sh" >> $CRONTAB_FILE

sed -i "/network_self_guard/d" $CRONTAB_FILE
echo "5 * * * * $SELF_DEPLOY_DIR/network_self_guard.sh" >> $CRONTAB_FILE
