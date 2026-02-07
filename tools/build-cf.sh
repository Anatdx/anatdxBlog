#!/usr/bin/env bash
# Cloudflare Pages 构建脚本：先拉取子模块，再执行 Jekyll 构建
set -e
echo "> Initializing git submodules..."
git submodule update --init --recursive
echo "> Building site with Jekyll..."
bundle exec jekyll build
