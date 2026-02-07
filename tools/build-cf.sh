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
# 同时将 4096 贴图替换为 2048（由 waifu-override 提供），减少构建产物体积
if [ -d _site/waifu/Resources/model/AnAn ]; then
  echo "> Normalizing AnAn model assets..."
  cd _site/waifu/Resources/model/AnAn
  [ -f "AnAn - model.moc3" ] && mv "AnAn - model.moc3" "AnAn-model.moc3"
  [ -f "AnAn - model.cdi3.json" ] && mv "AnAn - model.cdi3.json" "AnAn-model.cdi3.json"
  [ -f "AnAn - model.physics3.json" ] && mv "AnAn - model.physics3.json" "AnAn-model.physics3.json"
  [ -f "AnAn - model.model3.json" ] && mv "AnAn - model.model3.json" "AnAn-model.model3.json"
  if [ -d "AnAn-model.2048" ]; then
    # 兼容可能被引用的另一份 model3.json：如存在 2048 贴图则强制与 AnAn.model3.json 一致
    [ -f "AnAn.model3.json" ] && cp "AnAn.model3.json" "AnAn-model.model3.json"
    # 删除 4096 贴图目录（2048 贴图位于 AnAn-model.2048）
    rm -rf "AnAn - model.4096" "AnAn-model.4096"
  else
    echo "WARN: AnAn-model.2048 missing; skip removing 4096 textures."
  fi
  cd - > /dev/null
fi
if [ ! -f _site/waifu/live2d-sdk.js ]; then
  echo "ERROR: _site/waifu/live2d-sdk.js missing after copy."
  exit 1
fi
echo "> Waifu assets OK."
