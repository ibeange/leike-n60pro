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
# P3TERX 项目专用：diy-part1.sh（在项目根目录执行）
# 功能：修改 feeds.conf.default（清华源）+ 准备第三方源
# ==============================================

# 步骤1：等待 OpenWrt 源码克隆完成（P3TERX 项目会自动克隆到 openwrt 目录）
# 注意：P3TERX 项目中，diy-part1.sh 在源码克隆后执行，此时 openwrt 目录已存在
if [ ! -d "openwrt" ]; then
    echo "Error: P3TERX 项目未自动克隆 openwrt 源码！请检查 workflow 配置。"
    exit 1
fi

# 步骤2：替换 openwrt/feeds.conf.default 为清华源（main 分支开发版）
cat > openwrt/feeds.conf.default << EOF
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

# 步骤3：进入 openwrt 目录，更新 feeds（拉取第三方源）
cd openwrt || { echo "Error: openwrt 目录创建失败！"; exit 1; }

# 清理旧 feeds 缓存
./scripts/feeds clean

# 更新所有 feeds（此时会拉取 feeds.conf.default 中的第三方源，创建 feeds/xxx 目录）
./scripts/feeds update -a

# 步骤4：更新第三方源到最新代码（修复 Makefile 错误）
# PassWall 依赖包
if [ -d "feeds/passwall_packages" ]; then
    cd feeds/passwall_packages && git pull && cd -
else
    echo "Warning: passwall_packages 源未拉取成功，跳过更新"
fi

# PassWall 主程序
if [ -d "feeds/passwall" ]; then
    cd feeds/passwall && git pull && cd -
else
    echo "Warning: passwall 源未拉取成功，跳过更新"
fi

# iStore 应用商店
if [ -d "feeds/istore" ]; then
    cd feeds/istore && git pull && cd -
else
    echo "Warning: istore 源未拉取成功，跳过更新"
fi

# 步骤5：安装所有 feeds 包（关联依赖到编译目录）
./scripts/feeds install -a

echo "diy-part1.sh 执行完成！"
