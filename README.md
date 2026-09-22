# Pure-Mihomo-for-Magisk
### 📌 项目简介（Repository About / Short Bio）

> **极简、克制且忠于原貌的 Android / Magisk (KernelSU / APatch) `mihomo` 透明代理脚本模块。**
> 支持 TUN 模式 + 黑/白名单 + Fake-IP 混合调度；**零侵入原则，绝不解析、篡改、打乱或阉割你的原生配置文件**。

---

# 🚀 Mihomo-Pure: 纯粹的 Mihomo Magisk / KernelSU / APatch 模块

---

## 💡 为什么写这个模块？（项目初衷）

市面上现存的大多数代理类 Magisk 模块，往往倾向于提供“保姆式”的全套配置代劳方案。这些模块普遍内置了庞杂且黑盒化的配置解析脚本（如滥用 `yq`、`sed` 或粗暴的文本替换），在启动阶段强行注入“标准”的参数，甚至重新序列化你的配置文件：

* ❌ **破坏 YAML 结构**：精心设计的 YAML 锚点（`&` 与 `*` 引用）、自定义缩进与排版被全部打散。
* ❌ **阉割与覆盖特性**：自写的高级服务（自定义规则集、分流策略组、嗅探设置、第三方 Listener、外部控制端口等）频繁被模块脚本覆写或意外截断。
* ❌ **调试地狱**：配置文件在实际运行时变成了模块生成的“拼接怪”，一旦网络异常，根本无法定位到底是配置文件问题还是模块脚本的篡改逻辑出了偏差。

**「我们只是需要一个能安静启动二进制文件、配置好路由表并尊重用户的壳，而不是一个指手画脚的管家。」**

为此，**Mihomo-Pure** 诞生了。它只专注于做好生命周期管理与底层的路由引导，其余一切控制权，全部无条件归还给你的 `config.yaml`。

---

## ✨ 核心特性

* 🛡️ **绝对零篡改（Zero Configuration Modification）**
启动过程仅执行只读检查与链路拉起。不注入规则、不重写端口、不打乱键值对顺序、不破坏 YAML 语法结构与锚点继承。你的文件写成什么样，核心就以什么样跑。
* 🌐 **TUN 模式与 Fake-IP 混合调度**
深度适配 Mihomo 的 Native TUN 引擎与 Fake-IP DNS 劫持机制，消除高延迟解析瓶颈，提供丝滑的透明代理体验。
* 🎯 **精准的 App 级分流控制（黑/白名单机制）**
支持通过 UID 列表或应用包名配置放行/拦截策略：
* **白名单模式**：仅接管指定应用的流量，将其余流量直通宿主系统，极度省电且杜绝流氓应用干扰。
* **黑名单模式**：默认透明代理全局流量，精准剔除银行、国服游戏等高敏感应用。


* ⚡ **纯粹轻量 Shell 脚本驱动**
去除臃肿的 WebUI 全家桶与无意义的冗余依赖，底层直接与 `ip rule`、`iptables` / `nftables` 对话，内存开销微乎其微。
* 🔄 **完善的状态监控与看门狗机制**
自带极简服务守护机制，防范核心异常闪退导致全局断网，支持后台静默检测与开机自启。

---

## 🛠️ 工作原理简述

```text
[ 应用层流量 (Apps) ]
         │
         ▼
[ Linux 路由表 / iptables / nftables ] ──(黑/白名单 UID 过滤)──► [ 直连放行 (Direct) ]
         │ (匹配接管流量)
         ▼
[ TUN 虚拟网卡 (tun0 / meta) ] ◄──► [ Fake-IP DNS 劫持 ]
         │
         ▼
[ Mihomo 核心 (加载你原汁原味的 config.yaml) ]
         │
         ▼
[ 物理网络接口 (WLAN / Mobile Data) ]

```

---



## 🚀 快速上手

1. **环境准备**
* 已获取 Root 权限或越狱权限的 Android 设备（推荐 Magisk 25.0+、KernelSU 0.9.0+ 或 APatch）。
* 系统支持 `CONFIG_NETFILTER` 与 TUN 特性（现代内核均原生满足）。


2. **安装模块**
* 从 [Releases]([https://github.com/waterblue-sea/Pure-Mihomo-for-Magisk/releases/tag/main])页面下载最新版 zip包，在 Magisk / KernelSU / APatch 管理器中刷入，**暂不建议立刻重启**。


3. **安装伴生应用 Pure Mihomo**
* 从 [Releases]([https://github.com/waterblue-sea/Pure-Mihomo-for-Magisk/releases/tag/main])页面下载最新 apk文件，在手机安装，并于 Magisk / KernelSU / APatch 管理器中给予 超级用户(root) 权限，后重启设备。


4. **最后确认**
* 重启设备后，利用 MT管理器 或 模块(mihomo_ksu_pure) 内置脚本将你的 yaml配置文件导入 /data/adb/mihomo ，替换原本占位的 config.yaml，后利用脚本完成重载，并查看 Pure Mihomo 内的日志或执行 `su -c pgrep mihomo`，确认核心是否正常常驻。



---

## ⚠️ 免责声明与硬核风险警告（必读！）

> [!CAUTION]
> **玩机有风险，折腾需谨慎！** 本模块直接操作 Linux 底层网络命名空间、策略路由（`ip rule`）与防火墙过滤表（`iptables` / `nftables`），若使用不当可能引发不可预知的故障。作者对因使用本模块导致的任何软硬件损伤概不负责。

在刷入并激活本模块前，请明确知晓可能存在的以下极端隐患：

1. 🕳️ **网络黑洞与回环风暴（Routing Loop）**
如果你的 `config.yaml` 中配置的代理出站流量未被正确排除（未匹配核心的 `so_mark` 或未通过路由策略忽略 Mihomo 自身的 UID），将导致**流量自身死循环递归代理**。瞬时流量暴增会导致网络彻底瘫痪形成“网络黑洞”，并伴随持续性的 CPU 满载。
2. 🔥 **异常发热、耗电崩塌与电池损耗**
一旦陷入回环风暴或 Fake-IP 缓存失效导致的持续死循环重试，高频唤醒锁与 CPU 单核持续 100% 占满将导致设备在短时间内剧烈发热。极端情况下，高温降频可能引发系统死机，并加速电池老化甚至导致膨胀风险。
3. 📶 **基带卡死与 SIM 卡异常报错**
在双卡或热点共享（Tethering）场景下，底层混乱的 NAT 表可能冲击系统的 RIL（Radio Interface Layer）守护进程，造成移动网络频繁掉网、无法注册 VoLTE、SIM 卡阶段性脱网甚至基带崩溃重启。
4. 🧱 **系统软砖与救砖准备**
错误的脚本逻辑或系统内核特性缺失可能导致开机时网络服务卡死，进而引发 Android 系统框架（System Server）看门狗超时（Watchdog Reboot-Loop）。
**请在刷入前务必确保设备已具备救砖环境**（如已配置音量键安全模式模块、TWRP Recovery 终端环境或拥有 KernelSU/Magisk 的 Bootloop 保护机制）。

---

## 💬 交流反馈与开发者自白

> 🙋‍♂️ **关于作者：**
> 本人技术水平有限（纯粹是一枚爱折腾的小白），写这个脚本主要是为了满足自己对“纯净透明代理”的强迫症需求，免去每次升级第三方模块都被强行格式化 YAML 的痛苦。
> 代码难免有考虑不周、处理粗糙或边界覆盖不全之处。如果您在测试时发现了 Bug、逻辑漏洞或者有更优雅的 Shell 实现思路：
> **还请各位技术大佬口下留情、轻喷指正！** 欢迎直接提 [Issue]或直接提交 [Pull Request] 一起完善打磨。

---

## 📄 开源许可证与致谢

- 本项目基于 [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html) 协议开源分发。
- 模块底层核心完全依赖并致敬 [MetaCubeX 组织](https://github.com/MetaCubeX) 开发的 [Mihomo 核心项目](https://github.com/MetaCubeX/mihomo)。配置详情可参考 [Mihomo 官方文档](https://wiki.metacubex.one/)。
