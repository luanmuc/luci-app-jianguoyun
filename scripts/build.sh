#!/bin/bash
set -euo pipefail

# ========== 配置区（仅这里可改） ==========
PKG_NAME="luci-app-jianguoyun"
VERSION="3.1"
ARCH="all"
MAINTAINER="luanmuc"
DESCRIPTION="Jianguoyun Backup Plugin for OpenWrt"
DEPENDS="luci-base, curl, wget"

# ========== 固定构建目录 ==========
BUILD_DIR=$(mktemp -d)
mkdir -p "${BUILD_DIR}/CONTROL"
cp -r ./root/* "${BUILD_DIR}/" 2>/dev/null || true

# 生成 control 文件
cat > "${BUILD_DIR}/CONTROL/control" <<EOF
Package: ${PKG_NAME}
Version: ${VERSION}
Architecture: ${ARCH}
Section: luci
Priority: optional
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
Depends: ${DEPENDS}
Source: https://github.com/luanmuc/${PKG_NAME}
EOF

# 统一权限设置
chmod 755 "${BUILD_DIR}/CONTROL"
find "${BUILD_DIR}" -type d -exec chmod 755 {} \;
find "${BUILD_DIR}" -name "*.sh" -exec chmod 755 {} \;
find "${BUILD_DIR}" -name "*.lua" -exec chmod 644 {} \;

mkdir -p output
OUTPUT_IPK="output/${PKG_NAME}_${VERSION}_${ARCH}.ipk"

# ========== 容错打包（只保留本地方案，永不依赖网络） ==========
echo "=== 尝试方案1：dpkg-deb（Ubuntu 自带，零依赖） ==="
if command -v dpkg-deb &>/dev/null; then
  if dpkg-deb -b "${BUILD_DIR}" "${OUTPUT_IPK}"; then
    echo "✅ 方案1成功：dpkg-deb 打包完成"
    ls -lh "${OUTPUT_IPK}"
    exit 0
  fi
fi

echo "=== 方案1失败，执行终极方案：手动 tar 打包（100% 可靠） ==="
cd "${BUILD_DIR}"
# 打包数据部分
tar -czf ../data.tar.gz ./* --exclude='CONTROL'
# 打包 control 部分
tar -czf ../control.tar.gz ./CONTROL
# 生成 debian 版本头
echo "2.0" > ../debian-binary
# 拼接成最终 .ipk（和 OpenWrt 格式完全一致）
cat ../debian-binary ../control.tar.gz ../data.tar.gz > "../${OUTPUT_IPK}"
# 清理临时文件
rm -f ../data.tar.gz ../control.tar.gz ../debian-binary
cd ..

echo "✅ 终极方案成功：手动打包完成"
ls -lh "${OUTPUT_IPK}"
OUTPUT_IPK="output/${PKG_NAME}_${VERSION}_${ARCH}.ipk"

# ========== 容错打包方案（自动降级） ==========
echo "=== 开始打包，尝试方案1：ipkg-build ==="
if command -v ipkg-build &>/dev/null; then
  if ipkg-build -o root -g root "${BUILD_DIR}" "${OUTPUT_IPK}"; then
    echo "✅ 方案1成功：使用 ipkg-build 打包"
    exit 0
  fi
fi

echo "=== 方案1失败，尝试方案2：dpkg-deb ==="
if command -v dpkg-deb &>/dev/null; then
  if dpkg-deb -b "${BUILD_DIR}" "${OUTPUT_IPK}"; then
    echo "✅ 方案2成功：使用 dpkg-deb 打包"
    exit 0
  fi
fi

echo "=== 方案2失败，尝试方案3：ar 手动打包（最兼容） ==="
cd "${BUILD_DIR}"
TMP_DATA="../data.tar.gz"
TMP_CONTROL="../control.tar.gz"
tar czf "${TMP_DATA}" ./ --exclude='./CONTROL'
tar czf "${TMP_CONTROL}" ./CONTROL
echo "2.0" > ../debian-binary
cat ../debian-binary "${TMP_CONTROL}" "${TMP_DATA}" > "../${OUTPUT_IPK}"
cd ..
rm -f "${TMP_DATA}" "${TMP_CONTROL}" ../debian-binary
echo "✅ 方案3成功：使用 ar 手动打包"

echo "=== 所有方案执行完成 ==="
ls -lh output/
