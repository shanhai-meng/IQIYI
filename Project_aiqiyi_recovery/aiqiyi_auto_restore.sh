#!/bin/bash
## 该脚本主要用爱奇艺为定时检查跑量，自动更换端口
project_conf="/Project_aiqiyi_recovery/etc/conf.sh"
source $config_file
dos2unix aiqiyi_auto_restore.sh > /dev/null 2>&1
# 更换端口模块
# function iqiyi_change_prot() {
# 		   wget -O /tmp/iqiyi_change_prot.sh http://tw06d0006.onething.net/mengrun/iqiyi_change_prot.sh && sh /tmp/iqiyi_change_prot.sh
# }
# 检测跑量模块
function send_detection() {
    ## 收集10s内上传数据量计算均值
    # 运行 dstat 命令并提取 send 列的数据
    number=10
    while [ $number -gt 0 ]; do
        dstat -n 1 1 | awk '/^ / {send = $2} END {print send}' >> $send_record
        number=$((number - 1))
    done
    # 消除单位并转换为数字
    sed -i 's/k/000/' $send_record
    sed -i 's/M/000000/' $send_record
    # 读取数据并计算均值
    sum=0
    count=0
    while read -r line; do
        sum=$((sum + line))
        count=$((count + 1))
    done < $send_record

    # 计算上传数据量send
    average=$((sum / count))
    if [ $average -gt 10000000 ];then
        average2=$(($average/1000000))
    # 输出均值
        echo -e "$(date +"%Y-%m-%d %H:%M:%S")\t当前上传数据量均值为：$average2 M"
    else
        average2=$(($average/1000))
        echo -e "$(date +"%Y-%m-%d %H:%M:%S")\t当前上传数据量均值为：$average2 k"
    fi
    # 当上传数据量小于5MB/s时更换端口
    if [ $average -le 5000000 ];then
		echo -e "$(date +"%Y-%m-%d %H:%M:%S")\t当前小于5MB/s,尝试更换端口中..."
		iqiyi_change_prot
	else
		echo -e "$(date +"%Y-%m-%d %H:%M:%S")\t业务正常运行中!"
	fi
    # 清理临时文件
    rm $send_record
}
# 日志清理
function clean_log() {
    log_lines=$(wc -l < "$project_log")
    # 判断日志条数是否大于 50
    if [ "$log_lines" -ge 50 ]; then
        # 使用 tail 保留最后 50 行，并覆盖原文件
        tail -n 50 "$project_log" > "$project_log.tmp" && mv -f "$project_log.tmp" "$project_log"
    else
        ture
    fi
}
send_detection >> $project_log
clean_log