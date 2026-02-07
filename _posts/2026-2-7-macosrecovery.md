---
layout: post
title:  "MacOS SIP does not allow changing问题"
date:   2026-02-07 12:53:30 +0800
categories: 教程
tag: [MacOS]
---

今天在苹果店买AC+，想着先恢复之前通过关闭SIP强开的Apple Intellgence  
于是乎进入recvory，`csrutil disable`一顿操作后恢复完毕，  
重启再次进入rec，却发现`csrutil enable`弹出提示：
>cstutil: The OS environment does not allow changing security configuration options.
>
>Ensure that the system was booted into Recovery OS via the standard user action.

经过一番摸索，发现只要将机器完全关机再长按电源键进入rec即可，**不要直接重启就长按！**
