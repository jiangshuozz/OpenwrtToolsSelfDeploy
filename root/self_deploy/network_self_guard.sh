#!/bin/bash
source ./env.sh

# 默认计数为0
COUNTER=0
# 连续失败计数大于该数值，则进行 RESTART_INTERVAL 秒等待，再执行重新检测
COUNTER_THRESHOLD=10
# 持续失败，后默认等待时间(秒)，然后再重启
RESTART_INTERVAL=3600

# 检查目录是否存在，不存在则创建
if [ ! -d "$LOG_DIR" ]; then
    echo "Creating directory $LOG_DIR"
    mkdir -p "$LOG_DIR"
fi

# 检查文件是否存在，如果不存在则创建文件
touch $NETWORK_CHECK_LOG_FILE
log_crop_with_size $NETWORK_CHECK_LOG_FILE $NETWORK_CHECK_LOG_SIZE

if [ ! -e $NETWORK_CHECK_COUNTER_FILE ]; then
    touch $NETWORK_CHECK_COUNTER_FILE
    echo "0" > $NETWORK_CHECK_COUNTER_FILE
fi
COUNTER=$(cat $NETWORK_CHECK_COUNTER_FILE)

# 检测网络连接函数
function check_network() {
    # 如果ping 6次至少有2次包未响应，则执行一下代码
    echo $(ping_domain) = "false"
    if [ $(ping_domain) = "false" ]; then
        # 如果无法连接网络，则重启wan口拨号
        echo_log_with_stamp "网络连接失败 重启Wan" $NETWORK_CHECK_LOG_FILE
        /sbin/ifup wan
        sleep 30
        if [ $(ping_domain) = "false" ]; then
            # 如果仍无法连接网络，则重启网络
            echo_log_with_stamp "网络连接仍然失败 重启网络" $NETWORK_CHECK_LOG_FILE
            /etc/init.d/network restart
            echo_log_with_stamp "网路已重启" $NETWORK_CHECK_LOG_FILE
            echo $(($(cat $NETWORK_CHECK_COUNTER_FILE) + 1)) >$NETWORK_CHECK_COUNTER_FILE
            sleep 30

            if [ $(ping_domain) = "false" ]; then
                echo_log_with_stamp "重启网络后，联网失败，准备重启路由器" $NETWORK_CHECK_LOG_FILE
                echo $(($(cat $NETWORK_CHECK_COUNTER_FILE) + 1)) >$NETWORK_CHECK_COUNTER_FILE
                /sbin/reboot
            else
                echo_log_with_stamp "重启网络后，连接已恢复" $NETWORK_CHECK_LOG_FILE
                echo "0" >$NETWORK_CHECK_COUNTER_FILE
            fi
        else
            echo_log_with_stamp "重启Wan，连接已恢复" $NETWORK_CHECK_LOG_FILE
            echo "0" >$NETWORK_CHECK_COUNTER_FILE
        fi
    else
        echo_log_with_stamp "网络连接正常" $NETWORK_CHECK_LOG_FILE
        echo "0" >$NETWORK_CHECK_COUNTER_FILE
    fi
}

# 计数器检查函数
function check_counter() {
    COUNTER=$(cat $NETWORK_CHECK_COUNTER_FILE)
    if [[ $COUNTER -ge $COUNTER_THRESHOLD ]]; then
        echo_log_with_stamp "计数器值大于等于 $COUNTER_THRESHOLD ，等待 $RESTART_INTERVAL 秒后重新检测网络连接" $NETWORK_CHECK_LOG_FILE
        sleep $RESTART_INTERVAL # 等待
        echo_log_with_stamp "等待 $RESTART_INTERVAL 秒后，开始重新检测网络" $NETWORK_CHECK_LOG_FILE
        check_network
    else
        check_network
    fi
}

check_counter

echo_log_with_stamp "network 检查完毕" $NETWORK_CHECK_LOG_FILE