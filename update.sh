#!/system/bin/sh
WORKDIR="/data/adb/mihomo"
cd "$WORKDIR" || exit 1
UPDATE_FLAG=0

GH_PREFIX=""
if ! busybox wget --no-check-certificate -q -T 3 -O /dev/null https://github.com; then
    GH_PREFIX="https://ghfast.top/"
fi

META_RAW="${GH_PREFIX}https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/release"
ASN_RAW="${GH_PREFIX}https://raw.githubusercontent.com/P3TERX/GeoLite.mmdb/download"

download_db() {
    local url=$1
    local file=$2
    printf "- 正在拉取 %-18s " "$file"
    
    busybox wget --no-check-certificate -q -T 15 "$url" -O "${file}.tmp"
    if [ -s "${file}.tmp" ]; then
        local size=$(busybox wc -c < "${file}.tmp" 2>/dev/null)
        if [ "${size:-0}" -gt 1048576 ]; then
            mv -f "${file}.tmp" "$file"
            UPDATE_FLAG=1
            echo "[成功] ($size bytes)"
        else
            rm -f "${file}.tmp"
            echo "[失败] (文件体积过小)"
        fi
    else
        rm -f "${file}.tmp"
        echo "[失败] (404 或网络阻断)"
    fi
}

echo "========================================="
echo " 开始拉取路由数据库..."

download_db "$META_RAW/geoip.dat" "geoip.dat"
download_db "$META_RAW/geosite.dat" "geosite.dat"
download_db "$META_RAW/country.mmdb" "Country.mmdb"
download_db "$ASN_RAW/GeoLite2-ASN.mmdb" "GeoLite2-ASN.mmdb"

echo "- 开始探测 Mihomo 核心版本..."
API_RESP=$(busybox wget --no-check-certificate -q -T 10 -O - "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest")
[ -z "$API_RESP" ] && API_RESP=$(busybox wget --no-check-certificate -q -T 10 -O - "${GH_PREFIX}https://api.github.com/repos/MetaCubeX/mihomo/releases/latest")

LATEST_CORE=$(echo "$API_RESP" | busybox grep "browser_download_url" | busybox grep "mihomo-android-arm64-v" | busybox grep ".gz" | cut -d '"' -f 4 | head -n 1)

if [ -n "$LATEST_CORE" ]; then
    printf "- 发现最新核心，正在拉取... "
    busybox wget --no-check-certificate -q -T 30 "${GH_PREFIX}${LATEST_CORE}" -O "mihomo.gz"
    if [ -s "mihomo.gz" ]; then
        busybox gunzip -f mihomo.gz
        chmod 755 mihomo
        UPDATE_FLAG=1
        echo "[成功]"
    else
        echo "[失败]"
    fi
else
    echo "- 核心版本探嗅失败。"
fi

if [ "$UPDATE_FLAG" -eq 1 ]; then
    echo "\n- 检测到文件变动，下发指令重载守护进程..."
    killall -9 mihomo 2>/dev/null
    sh /data/adb/modules/mihomo_ksu_pure/service.sh
fi
echo "========================================="