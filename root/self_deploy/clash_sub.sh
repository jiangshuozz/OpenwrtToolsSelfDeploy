#!/bin/sh
path=/root/littlepanda

funLogParam(){
  log_time=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$log_time]" "$1" "$2" "$3" "$4">> $path/subscribe.log
}

year=$(date +%Y)
month=$(date +%m)
filename=$(date '+%Y%m%d.yaml')
link=https://oneclash.cc/wp-content/uploads/$year/$month/$filename

funLogParam Link   : $link
funLogParam Compose: $year/$month/$filename

if curl -sL --fail $link -o /dev/null; then
  funLogParam "Clash subscribe/root/littlepanda/ success!"
  cp $path/config.yaml $path/config.yaml.bak
  curl -o $path/config.yaml $link
  export LANG=zh_CN.gbk
 #sed -i "s/rules:/&\r\n - DOMAIN-SUFFIX,oneclash.cc,?? ¹úÄÚÍøÂç/" $path/config.yaml
else
  funLogParam "Clash subscribe fail!"
fi