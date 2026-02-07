#!/usr/bin/env bash
# Cloudflare Pages 构建脚本：先拉取子模块，再执行 Jekyll 构建
# waifu 子模块含中文等非 ASCII 路径，已从 Jekyll 排除，构建后手动复制到 _site
set -e
echo "> Initializing git submodules..."
git submodule update --init --recursive
if [ ! -f waifu/live2d-sdk.js ]; then
  echo "ERROR: waifu submodule not populated (waifu/live2d-sdk.js missing). Check submodule clone."
  exit 1
fi
echo "> Building site with Jekyll..."
bundle exec jekyll build
echo "> Copying waifu assets to _site..."
mkdir -p _site/waifu
cp -r waifu/* _site/waifu/
# 覆盖子模块中缺失的文件（如 AnAn 的 config.json）
if [ -d waifu-override ]; then
  echo "> Applying waifu-override..."
  cp -r waifu-override/* _site/waifu/
fi
# AnAn 模型文件名去空格，避免 fetch 与服务器对 URL 处理不一致
if [ -d _site/waifu/Resources/model/AnAn ]; then
  echo "> Renaming AnAn model files (remove spaces)..."
  cd _site/waifu/Resources/model/AnAn
  [ -d "AnAn - model.4096" ] && mv "AnAn - model.4096" "AnAn-model.4096"
  [ -f "AnAn - model.moc3" ] && mv "AnAn - model.moc3" "AnAn-model.moc3"
  [ -f "AnAn - model.cdi3.json" ] && mv "AnAn - model.cdi3.json" "AnAn-model.cdi3.json"
  [ -f "AnAn - model.physics3.json" ] && mv "AnAn - model.physics3.json" "AnAn-model.physics3.json"
  [ -f "AnAn - model.model3.json" ] && mv "AnAn - model.model3.json" "AnAn-model.model3.json"
  cd - > /dev/null
fi
if [ ! -f _site/waifu/live2d-sdk.js ]; then
  echo "ERROR: _site/waifu/live2d-sdk.js missing after copy."
  exit 1
fi
echo "> Waifu assets OK."
