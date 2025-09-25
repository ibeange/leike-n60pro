#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

#!/bin/bash

# ==============================================
# 步骤1：进入 OpenWrt 源码目录（确保脚本在源码根目录执行）
# ==============================================
cd openwrt || { echo "Error: openwrt directory not found!"; exit 1; }

# ==============================================
# 步骤2：替换 feeds.conf.default 为清华源（main 分支开发版）
# ==============================================
cat > feeds.conf.default << EOF
# 官方核心源（清华镜像，main 分支开发版）
src-git packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/feed/packages.git;main
src-git luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/feed/luci.git;main
# src-git routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/feed/routing.git;main  # 可选，注释
# src-git telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/feed/telephony.git;main  # 可选，注释

# 第三方源（PassWall、iStore）
src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main
src-git istore https://github.com/linkease/istore.git;main
EOF

# ==============================================
# 步骤3：更新 feeds（首次拉取第三方源，创建 feeds 目录）
# ==============================================
./scripts/feeds clean  # 清理旧缓存
./scripts/feeds update -a  # 拉取所有源（包括第三方，此时才创建 feeds/passwall 等目录）

# ==============================================
# 步骤4：强制更新第三方源到最新代码（修复 Makefile 错误）
# ==============================================
# 更新 PassWall 依赖包
if [ -d "feeds/passwall_packages" ]; then
    cd feeds/passwall_packages && git pull && cd -
else
    echo "Warning: passwall_packages not found, skip update"
fi

# 更新 PassWall 主程序
if [ -d "feeds/passwall" ]; then
    cd feeds/passwall && git pull && cd -
else
    echo "Warning: passwall not found, skip update"
fi

# 更新 iStore
if [ -d "feeds/istore" ]; then
    cd feeds/istore && git pull && cd -
else
    echo "Warning: istore not found, skip update"
fi

# ==============================================
# 步骤5：安装 feeds（关联所有包到编译目录）
# ==============================================
./scripts/feeds install -a

echo "diy-part1.sh 执行完成！"
