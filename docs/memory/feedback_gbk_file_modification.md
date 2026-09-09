---
name: GBK编码文件修改方法
description: 修改GBK/ANSI老中文源码的正确方法，避免编码破坏
type: feedback
originSessionId: d8c8bca8-41bf-4deb-ad20-b134d6f6da2a
---
# GBK编码文件修改方法

**规则：GBK编码的中文源码不能用sed/Edit工具，必须用Python保持原编码**

**Why:** 2026-05-01多次发生编码破坏：用sed添加中文文本后，文件从GBK变成UTF-8，导致全文乱码。老C/H文件编码坏了，注释、花括号、声明区都可能一起坏。

**How to apply:**

## 1. 文件分类

### UTF-8文件（可以直接修改）：
- 现代项目的源码
- 能稳定识别编码的文件
- 可以用Edit工具或sed

### GBK/ANSI/Default文件（必须特殊处理）：
- 老中文源码（如本项目的C文件）
- 包含中文注释的嵌入式代码
- **绝对不能用Edit工具或sed直接修改**

## 2. GBK文件修改流程

### 步骤1：先备份
```bash
cp file.c file.c.bak_$(date +%Y%m%d_%H%M%S)
```

### 步骤2：用Python修改（保持GBK编码）
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# 读取GBK文件
with open('file.c', 'rb') as f:
    content = f.read().decode('gbk', errors='ignore')

# 修改内容
content = content.replace('old_text', 'new_text')

# 用GBK编码写回
with open('file.c', 'wb') as f:
    f.write(content.encode('gbk'))
```

### 步骤3：验证关键函数边界
- 读取修改后的文件
- 检查函数头、结束大括号是否完整
- 确认中文注释没有乱码

## 3. 禁止的操作

❌ **绝对不能做：**
- 用sed添加中文文本到GBK文件
- 用Edit工具修改GBK文件
- 用文本编辑器"另存为"改变编码
- 用UTF-8编码写入GBK文件

## 4. 编码检测

### 检测文件编码：
```python
with open('file.c', 'rb') as f:
    data = f.read()

# 尝试GBK解码
try:
    content = data.decode('gbk')
    print("文件是GBK编码")
except:
    print("文件不是GBK编码")
```

### 修复编码破坏：
```python
# 如果文件被错误地转成UTF-8
with open('file.c', 'rb') as f:
    data = f.read()

# 先用UTF-8解码
content = data.decode('utf-8', errors='ignore')

# 再用GBK编码写回
with open('file.c', 'wb') as f:
    f.write(content.encode('gbk'))
```

## 5. PowerShell方法（备选）

对于Windows环境，也可以用PowerShell：
```powershell
# 读取（保持原编码）
$content = Get-Content file.c -Encoding Default

# 修改
$content = $content -replace 'old', 'new'

# 写回（保持原编码）
$content | Out-File file.c -Encoding Default
```

## 6. 实际案例

### 错误案例（2026-05-01）：
```bash
# ❌ 用sed添加中文，导致编码破坏
sed -i '249a\系统状态' App_lcd.c
# 结果：整个文件变成UTF-8，全文乱码
```

### 正确做法：
```python
# ✅ 用Python保持GBK编码
with open('App_lcd.c', 'rb') as f:
    content = f.read().decode('gbk')

lines = content.split('\n')
lines.insert(249, '\t\tLCD_Disp_Txt(FONT_24, 120, 1, "系统状态");')

content = '\n'.join(lines)
with open('App_lcd.c', 'wb') as f:
    f.write(content.encode('gbk'))
```

## 7. 快速检查清单

修改GBK文件前：
- [ ] 已备份文件（带时间戳）
- [ ] 确认文件是GBK编码
- [ ] 准备用Python脚本修改
- [ ] 不使用sed/Edit工具

修改GBK文件后：
- [ ] 验证中文没有乱码
- [ ] 检查函数边界完整
- [ ] 确认可以编译通过
- [ ] 如果乱码，立即用Python修复编码

## 8. 记住

**一句话总结：GBK文件只能用Python改，读取用decode('gbk')，写入用encode('gbk')，绝对不能用sed/Edit！**


## 7. 2026-05-25 新增硬规则：中文不能经过终端命令行直接传递

**事故：** 在小断面遥控器 GBK 源码 `App_lcd.c` 中，虽然使用了 Python 修改，但把包含中文的脚本文本直接嵌入 PowerShell 命令行，中文在进入 Python 前已被终端/代码页转坏，产生“锟/�/乱码”，并扩大到多个 LCD 显示字符串。

**硬规则：只要涉及中文内容，就不能用这种方式。**

❌ 禁止：
- 在 PowerShell/cmd/shell 命令字符串里直接写中文，再传给 Python 修改 GBK 文件。
- 用 `Set-Content` / here-string / `python -c "...中文..."` 直接携带中文去写 GBK C/H 源码。
- 用 `errors='ignore'` 读坏后再整体写回，掩盖并扩大编码破坏。

✅ 正确做法：
- 中文必须用 Unicode 码点生成，例如 `''.join(chr(x) for x in [0x951a, 0x6746, ...])`。
- 或者从可靠的 GBK 原文件按字节复制原文，不让中文经过终端代码页。
- 修改后必须用 Python 读取 GBK 并检查关键字符串的 Unicode 码点，而不是只看终端显示。
- 最后必须 Keil 编译验证。
