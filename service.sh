#!/system/bin/sh
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done

CONFIG_FILE="/data/adb/mihomo/config.yaml"
PKG_CFG="/data/adb/mihomo/package.list.cfg"
FAKE_CFG="/data/adb/mihomo/fake.list.cfg"
CRON_DIR="/data/adb/mihomo/cron"
LOG_FILE="/data/adb/mihomo/run/core.log"
TMP_TUN="/data/adb/mihomo/run/tun_block.tmp"

chcon u:object_r:system_file:s0 $CONFIG_FILE 2>/dev/null
chcon u:object_r:system_file:s0 /data/adb/mihomo/mihomo 2>/dev/null

export PATH="/system/bin:/system/xbin:/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH"

if [ -f "$PKG_CFG" ]; then
    MODE=$(busybox sed -n 's/^mode:\([^ ]*\).*/\1/p' "$PKG_CFG" | busybox tr -d '\r\n')
    
    busybox sed -i 's/exclude-package:.*/exclude-package: []/g' "$CONFIG_FILE"
    busybox sed -i 's/include-package:.*/include-package: []/g' "$CONFIG_FILE"

    INC_LIST=""
    EXC_LIST=""

    if [ "$MODE" = "blacklist" ] || [ "$MODE" = "black" ]; then
        EXC_LIST=$(busybox awk -F':' '!/^mode:/ && !/^#/ && NF==2 {gsub(/[\r\n]/,"",$2); print "\""$2"\""}' "$PKG_CFG" | busybox paste -sd, -)
    
    elif [ "$MODE" = "whitelist" ] || [ "$MODE" = "white" ]; then
        if busybox grep -q 'enhanced-mode: fake-ip' "$CONFIG_FILE" && busybox grep -q '^tun:' "$CONFIG_FILE" && [ -f "$FAKE_CFG" ]; then
            EXC_LIST=$(busybox awk -F':' '!/^mode:/ && !/^#/ && NF==2 {gsub(/[\r\n]/,"",$2); print "\""$2"\""}' "$FAKE_CFG" | busybox paste -sd, -)
        else
            INC_LIST=$(busybox awk -F':' '!/^mode:/ && !/^#/ && NF==2 {gsub(/[\r\n]/,"",$2); print "\""$2"\""}' "$PKG_CFG" | busybox paste -sd, -)
        fi
    fi

    if busybox grep -q '^tun:' "$CONFIG_FILE"; then
        cat > "$TMP_TUN" <<EOF
tun:
  enable: true
  stack: mixed
  mtu: 1500
  strict-route: true
  endpoint-independent-nat: true
  include-android-user: [0, 10, 999]
  auto-route: true
  auto-detect-interface: true
  dns-hijack:
    - 0.0.0.0:53
    - tcp://any:53
    - udp://any:53
  include-package: [${INC_LIST}]
  exclude-package: [${EXC_LIST}]
EOF

        busybox awk '
        BEGIN {
            while ((getline line < "'"$TMP_TUN"'") > 0) {
                new_tun = new_tun line "\n"
            }
        }
        /^tun:/ {
            in_tun = 1
            printf "%s", new_tun
            next
        }
        in_tun == 1 && /^[a-zA-Z0-9_-]+:/ {
            in_tun = 0
        }
        in_tun == 0 { print $0 }
        ' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        
        mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        rm -f "$TMP_TUN"
    fi
fi

mkdir -p /dev/net
[ ! -e /dev/net/tun ] && ln -sf /dev/tun /dev/net/tun

echo "0 4 1 */4 * /system/bin/sh /data/adb/modules/mihomo_ksu_pure/update.sh >> /data/adb/mihomo/run/cron.log 2>&1" > $CRON_DIR/root
chmod 0644 $CRON_DIR/root
killall -9 crond 2>/dev/null
busybox crond -c $CRON_DIR

killall -9 mihomo 2>/dev/null
nohup /data/adb/mihomo/mihomo -d /data/adb/mihomo -f "$CONFIG_FILE" > "$LOG_FILE" 2>&1 &
