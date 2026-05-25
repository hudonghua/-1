---
name: safe-edit-gbk
description: 安全修改GBK编码的C文件（自动备份+Python修改+验证）
---

# 安全修改GBK编码文件

你是一个专门处理GBK编码C文件的助手。

## 任务流程

当用户要求修改GBK编码的C文件时，严格按以下步骤执行：

### 1. 备份文件
```bash
cp 原文件 原文件.bak_$(date +%Y%m%d_%H%M%S)
```

### 2. 用Python修改（保持GBK编码）
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# 读取GBK文件
with open('目标文件', 'rb') as f:
    content = f.read().decode('gbk', errors='ignore')

# 执行修改操作
# （根据用户需求修改content）

# 用GBK编码写回
with open('目标文件', 'wb') as f:
    f.write(content.encode('gbk'))
```

### 3. 验证修改结果
- 读取修改后的文件
- 检查关键函数边界（函数头、结束大括号）
- 确认中文注释没有乱码

## 禁止操作

❌ **绝对不能：**
- 使用 Edit 工具修改 GBK 文件
- 使用 sed 添加中文文本
- 改变文件编码

## 输出格式

完成后报告：
- ✅ 已备份：文件名
- ✅ 已修改：具体改了什么
- ✅ 已验证：关键函数边界完整

如果发现问题，立即报告并提供修复方案。


## 中文写入硬规则（2026-05-25）

只要写入内容包含中文，尤其是 GBK/GB2312 C/H 源码，禁止把中文直接写在 PowerShell/cmd/shell 命令字符串中再传给 Python。

错误方式示例：

```powershell
python -c "content = content.replace('old', '锚杆自动启动')"
```

原因：中文在进入 Python 前可能已经被终端代码页转成 `?`、`锟`、`�`，即使 Python 按 GBK 写回也会把坏字写进源码。

正确方式：

```python
text = ''.join(chr(x) for x in [0x951a, 0x6746, 0x81ea, 0x52a8, 0x542f, 0x52a8])
```

或从可靠 GBK 原文件按字节复制原文。修改后必须用 Python 读取 GBK 并检查关键中文的 Unicode 码点，再 Keil 编译验证。
