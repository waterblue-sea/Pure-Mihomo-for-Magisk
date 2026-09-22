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
ui_print "- 检查系统底层..."

if [ -d "/data/adb/mihomo" ]; then
    rm -f /data/adb/mihomo/mihomo
    rm -rf /data/adb/mihomo/ui
    rm -rf /data/adb/mihomo/ui_temp
    rm -rf /data/adb/mihomo/run
    rm -rf /data/adb/mihomo/cron
    rm -f /data/adb/mihomo/*.tmp /data/adb/mihomo/*.zip /data/adb/mihomo/*.gz
else
    mkdir -p /data/adb/mihomo
fi

mkdir -p /data/adb/mihomo/ui
mkdir -p /data/adb/mihomo/run
mkdir -p /data/adb/mihomo/cron
[ ! -f /data/adb/mihomo/package.list.cfg ] && echo "mode:blacklist\n" > /data/adb/mihomo/package.list.cfg

GH_PREFIX="https://ghfast.top/"

if [ ! -f /data/adb/mihomo/mihomo ]; then
    ui_print "- 未检测到 Mihomo 核心！"
    API_RESP=$(wget --no-check-certificate -q -T 10 -O - "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest")
    [ -z "$API_RESP" ] && API_RESP=$(wget --no-check-certificate -q -T 10 -O - "${GH_PREFIX}https://api.github.com/repos/MetaCubeX/mihomo/releases/latest")
    
    LATEST_CORE_URL=$(echo "$API_RESP" | grep "browser_download_url" | grep "mihomo-android-arm64-v" | grep ".gz" | cut -d '"' -f 4 | head -n 1)

    if [ -n "$LATEST_CORE_URL" ]; then
        ui_print "- 拉取 Mihomo 核心 (预计10-30秒)..."
        wget --no-check-certificate -q -T 30 "${GH_PREFIX}${LATEST_CORE_URL}" -O /data/adb/mihomo/mihomo.gz
        if [ -s /data/adb/mihomo/mihomo.gz ]; then
            gunzip -f /data/adb/mihomo/mihomo.gz
            chmod 755 /data/adb/mihomo/mihomo
            ui_print "- Mihomo Core 部署成功！"
        else
            ui_print "- 核心拉取失败！"
        fi
    fi
fi

ui_print "- 预下载 Geo 路由数据库..."
GEO_URL="${GH_PREFIX}https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest"
wget --no-check-certificate -q -T 15 "$GEO_URL/geoip.dat" -O /data/adb/mihomo/geoip.dat
wget --no-check-certificate -q -T 15 "$GEO_URL/geosite.dat" -O /data/adb/mihomo/geosite.dat
wget --no-check-certificate -q -T 15 "${GH_PREFIX}https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb" -O /data/adb/mihomo/GeoLite2-ASN.mmdb

ui_print "- 开始拉取 Yacd-meta 控制面板..."
UI_URL="${GH_PREFIX}https://github.com/MetaCubeX/Yacd-meta/archive/refs/heads/gh-pages.zip"
wget --no-check-certificate -q -T 30 "$UI_URL" -O /data/adb/mihomo/ui.zip

if [ -s /data/adb/mihomo/ui.zip ]; then
    unzip -qo /data/adb/mihomo/ui.zip -d /data/adb/mihomo/ui_temp
    rm -rf /data/adb/mihomo/ui/*
    mv -f /data/adb/mihomo/ui_temp/Yacd-meta-gh-pages/* /data/adb/mihomo/ui/
    rm -rf /data/adb/mihomo/ui.zip /data/adb/mihomo/ui_temp
    ui_print "- Mihomo 控制面板部署成功！"
fi

ui_print "- 正在执行底层字符清洗，抹除 Windows 格式残留..."
sed -i 's/\r$//' $MODPATH/service.sh
sed -i 's/\r$//' $MODPATH/update.sh
sed -i 's/\r$//' $MODPATH/menu.sh

set_perm_recursive $MODPATH 0 0 0755 0755
ui_print "- 模块刷入已完成，请重启设备以激活 Mihomo 守护进程。"
