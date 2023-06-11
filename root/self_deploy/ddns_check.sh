#!/bin/bash

if [ -f ./env.sh ]; then
    source ./env.sh
else
    source /root/self_deploy/env.sh
fi

# 检查目录是否存在，不存在则创建
if [ ! -d "$LOG_DIR" ]; then
    echo "Creating directory $LOG_DIR"
    mkdir -p "$LOG_DIR"
fi
# 检查LOG文件是否存在，如果不存在则创建文件
touch $DDNS_CHECK_LOG_FILE

log_crop_with_size $DDNS_CHECK_LOG_FILE $DDNS_CHECK_LOG_SIZE

if test -z $(pgrep -f $DDNS_PID_NAME); then
    echo_log_with_stamp "-----------------------" $DDNS_CHECK_LOG_FILE
    echo_log_with_stamp "$DDNS_PID_NAME 已停止运行，开始重启" $DDNS_CHECK_LOG_FILE
    $DDNS_SERVICE restart
    echo_log_with_stamp "$DDNS_PID_NAME 已重启，PID: $(pgrep -f $DDNS_PID_NAME)" $DDNS_CHECK_LOG_FILE
fi
