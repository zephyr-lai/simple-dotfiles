# tools/blesh — 内置 ble.sh 构建产物（离线兜底）

- 来源：[akinomyoga/ble.sh](https://github.com/akinomyoga/ble.sh)，0.4.0-devel 构建产物（2026-09 收录，未改内容）
- 用途：`install.sh` 的 `require_blesh` 在线安装失败/断网时，直接拷贝本目录到 `~/.local/share/blesh`（无需 git/gawk）
- 已排除运行时目录 `cache.d/`、`run/`，ble.sh 首次启动会自动重建
- 整个目录需保持完整（`ble.sh` 会按需加载 `lib/`、`contrib/` 内的模块），勿删减

## 刷新方法

```bash
git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
make -C /tmp/ble.sh install PREFIX="$HOME/.local"
# 用新的 ~/.local/share/blesh 覆盖本目录（排除 cache.d、run），更新版本号后一并提交
rm -rf /tmp/ble.sh
```
