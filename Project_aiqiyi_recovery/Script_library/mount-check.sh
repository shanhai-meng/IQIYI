# Description: 检查挂载点

# 项目配置
Reuse_Function="Reuse-Function.sh"
source $Reuse_Function

function mount-check{ 
    Env_preparation    # 环境准备
    
    echo "配置文件中已加载磁盘："
    grep ssddir /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
    echo
    echo "css文件中已加载磁盘："
    jq '.storage.diskinfo' /opt/soft/ipes/var/db/ipes/css-conf/cssconfig.json | jq -c 'to_entries[]'
    echo
    echo "挂载点异常信息："
    df -Th | awk '/\/data/ && /tmpfs/'
    echo
    echo "无异常挂载点：" 
    df -Th | grep /data | grep -v tmpfs
    echo 
    dmesg -T | grep "I/O error" | grep -q "sd"  && echo "dmesg存在磁盘IO报错" || echo "无磁盘报错信息" 
    echo 
}