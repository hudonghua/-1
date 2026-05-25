---
name: backup-and-edit
description: 修改文件前自动备份，并删除上一次备份（只保留最新一份）。适用于所有需要修改的文件，特别是C/H源码文件。
---

# 备份并修改文件

修改文件前自动备份，并删除上一次的备份，只保留最新一份。

## 核心原则

**修改文件前必须备份，但只保留最新一份备份**

## 备份策略

### 备份文件命名规则
```
原文件名.bak_YYYYMMDD_HHMMSS
```

例如：
- `App_lcd.c.bak_20260503_140530`
- `Arm200A_Kine.c.bak_20260503_141205`

### 备份流程

#### 1. 删除旧备份
```bash
# 删除该文件的所有旧备份
rm -f 原文件.bak_*
```

#### 2. 创建新备份
```bash
# 创建带时间戳的新备份
cp 原文件 原文件.bak_$(date +%Y%m%d_%H%M%S)
```

#### 3. 修改文件
```python
# 对于GBK编码的C文件
with open('原文件', 'rb') as f:
    content = f.read().decode('gbk', errors='ignore')

# 执行修改
# ...

# 写回
with open('原文件', 'wb') as f:
    f.write(content.encode('gbk'))
```

## 完整示例

### 修改 GBK 编码的 C 文件

```bash
# 1. 删除旧备份
rm -f App_lcd.c.bak_*

# 2. 创建新备份
cp App_lcd.c App_lcd.c.bak_$(date +%Y%m%d_%H%M%S)

# 3. 用Python修改
python3 << 'EOF'
with open('App_lcd.c', 'rb') as f:
    content = f.read().decode('gbk', errors='ignore')

# 执行修改
content = content.replace('old_text', 'new_text')

with open('App_lcd.c', 'wb') as f:
    f.write(content.encode('gbk'))
EOF
```

### 修改 UTF-8 编码的文件

```bash
# 1. 删除旧备份
rm -f config.json.bak_*

# 2. 创建新备份
cp config.json config.json.bak_$(date +%Y%m%d_%H%M%S)

# 3. 修改文件（可以用Edit工具）
# ...
```

## 报告格式

```
🗑️ 已删除旧备份：App_lcd.c.bak_20260503_120000
✅ 已创建新备份：App_lcd.c.bak_20260503_140530
✅ 已修改文件：App_lcd.c
✅ 已验证：[显示修改后的关键内容]
```

## 特殊情况

### 第一次修改（没有旧备份）

```bash
# rm 命令不会报错，继续执行
rm -f App_lcd.c.bak_*  # 没有文件被删除
cp App_lcd.c App_lcd.c.bak_$(date +%Y%m%d_%H%M%S)
```

报告：
```
ℹ️ 没有旧备份
✅ 已创建新备份：App_lcd.c.bak_20260503_140530
✅ 已修改文件：App_lcd.c
```

### 需要保留多个备份时

如果用户明确要求保留多个备份，询问：
```
❓ 检测到已有备份：
- App_lcd.c.bak_20260503_120000
- App_lcd.c.bak_20260503_130000

是否删除旧备份？（默认：是）
```

## 禁止的操作

❌ **不要：**
- 不备份就修改文件
- 保留过多备份导致混乱
- 删除备份时误删原文件

## 安全检查

删除旧备份前，确认：
- [ ] 删除的是 `.bak_*` 文件，不是原文件
- [ ] 使用 `rm -f 原文件.bak_*` 格式（带通配符）
- [ ] 新备份创建成功后才修改原文件

## 记住

**一个文件只保留一份最新备份，避免备份堆积**
