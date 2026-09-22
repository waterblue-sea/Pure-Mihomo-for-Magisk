#
# Copyright (C) 2026 <waterblue-sea> <https://github.com/waterblue-sea>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

#!/system/bin/sh
while true; do
    clear
    echo "========================================="
    echo "       Mihomo 物理核心调度台             "
    echo "========================================="
    echo " 当前进程状态:"
    if pidof mihomo > /dev/null; then
        echo " [运行中] Mihomo PID: $(pidof mihomo)"
    else
        echo " [已死亡] 进程未启动"
    fi
    echo "========================================="
    echo " 1. 替换yaml文件"
    echo " 2. 启动 / 重载 Mihomo 守护进程"
    echo " 3. 抹除进程 (Killall)"
    echo " 4. 更新 Geo 数据库与内核"
    echo " 5. 退出控制台"
    echo "========================================="
    printf " 请输入指令序号 [1-5]: "
    read choice

    case "$choice" in
        1)
            printf "\n- 请输入目标 yaml 文件的绝对路径: "
            read -r yaml_path
            
            case "$yaml_path" in
                *.yaml|*.yml)
                    if [ -f "$yaml_path" ]; then
                        echo "- 正在替换文件..."
                        cp -f "$yaml_path" /data/adb/mihomo/config.yaml
                        
                        chown 0:0 /data/adb/mihomo/config.yaml
                        chmod 644 /data/adb/mihomo/config.yaml
                        
                        echo "- 配置已成功覆盖至 /data/adb/mihomo/config.yaml"
                    else
                        echo "- 路径无效，该文件不存在！: $yaml_path"
                    fi
                    ;;
                *)
                    echo "- 后缀名异常！只允许注入 .yaml 或 .yml 文件。"
                    ;;
            esac
            printf "\n按回车键返回菜单..."
            read -r dummy
            ;;
        2)
            echo "\n- 下发重载指令..."
            sh /data/adb/modules/mihomo_ksu_pure/service.sh
            sleep 2
            ;;
        3)
            echo "\n- 发射抹除信号..."
            killall -9 mihomo crond 2>/dev/null
            echo "- 物理内存已净空。"
            sleep 1
            ;;
        4)
            echo "\n- 开始探测链路并拉取文件..."
            sh /data/adb/modules/mihomo_ksu_pure/update.sh
            printf "\n按回车键返回菜单..."
            read -r dummy
            ;;
        5)
            echo "\n- 退出。"
            exit 0
            ;;
        *)
            echo "\n- 错误指令，请重新输入。"
            sleep 1
            ;;
    esac
done
