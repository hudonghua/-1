---
name: gbk-garbled-comments
description: Fixes garbled Chinese comments in GBK/GB2312 legacy embedded C/H files, including comments shown as ??, ???, or mojibake. Use when the user says "把??改成中文", "清理乱码注释", "GBK注释恢复", or asks to restore unreadable comments in Keil/embedded/HMI source files.
---

# GBK 乱码注释修复

## 适用场景

用于老旧嵌入式 C/H 工程，特别是 Keil、工业 HMI、CAN 协议、硬件项目中，源码是 GBK/GB2312 编码，中文注释显示成 `??`、 `???` 或不可读乱码时。

## 铁律

1. 修改前必须备份，备份名用 `原文件名.bak_YYYYMMDD_HHMMSS`.
2. 不用 Edit/ApplyPatch/sed/Set-Content 直接改 GBK C/H 文件。
3. 用 Python 按字节读取： `decode('gbk', errors='ignore')`，写回： `encode('gbk')`.
4. 只改注释和说明文字，不改业务逻辑、宏、变量、协议 ID、函数调用顺序。
5. 如果要在命令或脚本里写中文，优先用 Unicode 码点或转义生成中文，避免 PowerShell/终端编码把中文变成 `?`.
6. 修改后必须验证：GBK 解码扫描、关键行打印、能编译就跑 Keil 编译。

## 推荐流程

1. 先用 Python 按 GBK 解码扫描 `??` / `???` / mojibake，不要完全相信终端显示。
2. 根据函数名、变量名、CAN ID、协议含义推断注释；不确定就删掉无意义乱码，不要凭空写错协议说明。
3. 备份目标文件。
4. 用 Python 按字节修改： read bytes -> decode GBK -> replace comments only -> encode GBK -> write bytes.
5. 写完后用 `unicode_escape` 打印关键行，确认文件里是真中文，不是问号。
6. 嵌入式工程尽量跑 Keil build；如果 `fromelf.exe` 找不到，把 `C:\Keil_v5\ARM\ARMCC\Bin` 加到 PATH 再跑。

## Python 验证模板

```python
from pathlib import Path

files = [Path('Src/App_Can.c'), Path('Src/pwm.c')]
for p in files:
    text = p.read_bytes().decode('gbk', errors='ignore')
    bad = []
    for i, line in enumerate(text.splitlines(), 1):
        if '??' in line or '???' in line:
            bad.append((i, line))
    print(p, 'bad_count=', len(bad))
    for i, line in bad[:20]:
        print(i, line.encode('unicode_escape').decode('ascii'))
```

## 汇报格式

- 修改文件和备份文件名。
- 关键注释修复点。
- 验证结果：GBK 扫描是否还有 `??` / `???`，Keil 编译 error/warning 数量。
- 如果有 warning，说明是否与本次注释修改无关。
