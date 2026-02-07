#!/usr/bin/env bash
# Cloudflare Pages 构建脚本：先拉取子模块，再执行 Jekyll 构建
# waifu 子模块含中文等非 ASCII 路径，已从 Jekyll 排除，构建后手动复制到 _site
set -e
echo "> Initializing git submodules..."
git submodule update --init --recursive
echo "> Building site with Jekyll..."
bundle exec jekyll build
echo "> Copying waifu assets to _site..."
cp -r waifu _site/waifu
# 覆盖子模块中缺失的文件（如 AnAn 的 config.json）
if [ -d waifu-override ]; then
  echo "> Applying waifu-override..."
  cp -r waifu-override/* _site/waifu/
fi
