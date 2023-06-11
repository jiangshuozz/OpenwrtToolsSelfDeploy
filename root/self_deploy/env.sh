#!/bin/bash

# Variable
SELF_DEPLOY_DIR="/root/self_deploy"
CRONTAB_FILE="/etc/crontabs/root"
# 日志默认目录
LOG_DIR="${SELF_DEPLOY_DIR}/log"

# NETWORK CHECK RELATED LOG
# 连续计数
NETWORK_CHECK_COUNTER_FILE="${LOG_DIR}/network_check_counter.log"
# 执行日志
NETWORK_CHECK_LOG_FILE="${LOG_DIR}/network_check.log"
NETWORK_CHECK_LOG_SIZE=$((1024*1024)) # 1024k=1M

# DDNS CHECK RELATED LOG
# 执行日志
DDNS_PID_NAME="dynamic_dns_updater"
DDNS_SERVICE="/etc/init.d/ddns"
DDNS_CHECK_LOG_FILE="${LOG_DIR}/ddns_self_guard.log"
DDNS_CHECK_LOG_SIZE=$((1024*1024))

# Functions
## 日志函数
function echo_log_with_stamp() {
    local time_stamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "["$time_stamp"]" $1
    if [ ! -z $2 ]; then
        echo "["$time_stamp"]" $1 >> $2
    else
        echo "["$time_stamp"]" "Wrong use output to log! detail: $1"
    fi
}

function echo_with_stamp() {
    local time_stamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "["$time_stamp"]" $1
}

function log_with_stamp() {
    local time_stamp=$(date '+%Y-%m-%d %H:%M:%S')
    if [ ! -z $2 ]; then
        echo "["$time_stamp"]" $1 >> $2
    else
        echo "["$time_stamp"]" "Wrong use output to log! detail: $1"
    fi
}

# 检测网络是否畅通
function ping_domain() {
    # ping的域名或者DNS
    if [ ! -z $1 ]; then
        local domain=$1
    else
        local domain=(114.114.114.114 baidu.com);
    fi
    local domain_len=$[${#domain[@]}-1]
    # ping的次数
    local tries=3
    # 请求成功次数
    local packets_responded=0

    for i in $(seq 1 $tries); do
        for j in $(seq 0 $domain_len); do
            # echo_with_stamp "ping -c 1 ${domain[j]}"
            if ping -c 1 ${domain[j]} > /dev/null; then
                ((packets_responded++))
            fi 
        done
        sleep 1
    done

    # 如果请求成功总次数大于2，则表示成功
    if [ $packets_responded -ge 2 ]; then
        echo "true"
    else
        echo "false"
    fi
}

# 检测文件大小 如果超过既定大小 则裁剪
function log_crop_with_size() {
    if [ -f $1 ]; then
        filesize=`ls -l $1 | awk '{ print $5 }'`
        if [ $filesize -ge $2 ]; then
            echo_with_stamp "log_size: $filesize >= max_log_size: $2"
            sed -i "1,1001d" $1 # 文件1-1000行的内容删除
        else
            echo_with_stamp "log_size: $filesize < max_log_size: $2"
        fi
    fi
}