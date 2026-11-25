#!/usr/bin/env bash
# 跑通 scripts/ 下的两个真实音源脚本（端到端集成测试）：
#   - xinghai-music-source-qs-v1.3.0.js  (MusicFree 插件：搜索 + 取播放地址)
#   - xinghai-music-sourcev2.3.19.js     (LX UserApi 脚本：musicUrl 解析)
#
# quickjs_engine 的 JS 引擎是原生库，flutter test 在 host（Linux/macOS/Windows）
# 上不会自动编译它，需要先构建出本机可加载的 .so/.dylib/.dll，再用
# LIBQUICKJSC_TEST_PATH 指给测试进程。本脚本自动完成这一步。
#
# 用法：source ./env.sh && bash scripts/run_real_scripts_test.sh
set -e

cd "$(dirname "$0")/.."

# 定位 quickjs_engine 包根目录（pub-cache 里由 pub 生成的软链路径）。
PKG_DIR="$(dart pub cache list 2>/dev/null | python3 -c '
import sys, json
d = json.load(sys.stdin)
print(d["packages"]["quickjs_engine"]["location"])
' 2>/dev/null || true)"

if [ -z "$PKG_DIR" ] || [ ! -d "$PKG_DIR" ]; then
  # 回退：从 .dart_tool/package_config.json 解析
  PKG_DIR="$(python3 - <<'PY'
import json
cfg = json.load(open('.dart_tool/package_config.json'))
for p in cfg['packages']:
    if p['name'] == 'quickjs_engine':
        root = p['rootUri']
        if root.startswith('file://'):
            print(root[len('file://'):])
        else:
            import os
            print(os.path.normpath(os.path.join('.dart_tool', root)))
        break
PY
)"
fi

case "$(uname -s)" in
  Darwin*) LIB_NAME="libquickjs_c_bridge_plugin.dylib" ;;
  *)       LIB_NAME="libquickjs_c_bridge_plugin.so" ;;
esac

LIB="$PKG_DIR/native/build/$LIB_NAME"
if [ ! -f "$LIB" ]; then
  echo "[run] 构建 quickjs_engine 原生库…"
  ( cd "$PKG_DIR" && sh tool/build_native.sh )
fi

echo "[run] 使用原生库: $LIB"
export LIBQUICKJSC_TEST_PATH="$LIB"

flutter test test/scripts/real_scripts_test.dart "$@"
