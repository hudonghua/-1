# CURSOR_AGENT_MEMORY.md

**Cursor Agent 启动入口**。任何 Cursor / Codex Agent 在本仓库开始工作前，**先按本文件的顺序加载长期记忆与技能**。

> 上游真源：[`hudonghua/codex-personal-toolkit`](https://github.com/hudonghua/codex-personal-toolkit)
> 本目录是该工具集中**与本仓库工作相关的部分镜像**，便于云端 Agent 在 `/workspace` 内直接读到。
> 上游一旦更新（skills、records、SKILL.md 变化），需要**手动同步**到这里（参见 §4）。

---

## 1. 启动加载顺序（强制）

按以下顺序读，每步**只在文件存在时读**：

1. **本文件**（`docs/memory/CURSOR_AGENT_MEMORY.md`）—— 总入口与索引
2. **编程纪律 / 安全协作规约**：
   - `docs/skills/safe-collab-workflow/SKILL.md`  ← 默认行为层
   - `docs/skills/verify-before-answer/SKILL.md`  ← "改完必须验证"
   - `docs/skills/understand-first/SKILL.md`      ← "先理解后执行"
   - `docs/skills/backup-and-edit/SKILL.md`       ← "改前必备份"
   - `docs/skills/safe-restore/SKILL.md`          ← "不经同意不退档"
3. **GBK / 嵌入式硬规则**（涉及 GBK / GB2312 / 嵌入式 C / Keil / HMI 时**必读**）：
   - `docs/skills/safe-edit-gbk/SKILL.md`
   - `docs/skills/embedded-c-safe-edit/SKILL.md`
   - `docs/skills/gbk-garbled-comments/SKILL.md`
   - `docs/skills/fix-braces/SKILL.md`
   - `docs/skills/keil5-embedded-c/SKILL.md`
   - `docs/memory/feedback_gbk_file_modification.md`  ← 2026‑05‑25 新增硬规则
4. **跨电脑 / 工具集同步**：
   - `docs/skills/external-record-continuity/SKILL.md`
   - `docs/skills/multi-computer-toolkit-merge/SKILL.md`
   - `docs/skills/work-continuity-sync/SKILL.md`
   - `docs/skills/chat-transcript-uploader/SKILL.md`
   - `docs/skills/workflow-memory-skillsmith/SKILL.md`
5. **任务相关 project / reference / feedback 记录**（按需读）：
   - `docs/memory/project_qt_camera_calibration_tool.md`
   - `docs/memory/work-record-20260525.md`
   - `docs/memory/memory-backup-20260525-README.md`

文件**不存在**时静默跳过，**绝不伪造内容**。

---

## 2. 用户说"恢复记忆"时

执行 `docs/skills/memory/SKILL.md` 描述的流程：

1. 读本文件（§1）；
2. 读上面 §1.2 全部 + §1.5 中名字含关键词的文件；
3. 读完后在回复里**明确列出已加载的文件**，让用户确认。

不要凭印象总结，**必须真的读过文件**。

---

## 3. 关键硬规则速查（出错点）

这些是**最容易翻车**的几条，浓缩在这里方便快速回忆。完整规则在对应 `SKILL.md` 里。

### GBK / GB2312 C/H 文件
- **绝不**用 `Edit` / `sed` / `ApplyPatch` / `Set-Content` 直接改 GBK 文件。
- **只用** Python：`bytes → decode('gbk') → 修改 → encode('gbk') → bytes`。
- **不要** `errors='ignore'` 写回，会扩大编码破坏。
- **中文内容**不能直接写在 PowerShell/cmd 命令字符串里再传给 Python（2026‑05‑25 硬规则）。
  - 用 Unicode 码点生成：`''.join(chr(x) for x in [0x951a, 0x6746, ...])`
  - 或从可靠 GBK 原文按字节复制
- 改完必须**用 Python 按 GBK 读回 + 扫码点 + Keil 编译验证**。

### 备份策略
- 修改前 `cp file file.bak_$(date +%Y%m%d_%H%M%S)`。
- 同一个文件**只保留一份最新备份**，先 `rm -f file.bak_*` 再创新。
- `safe-collab-workflow` 项目用**单文件 `file.bak`**（不带时间戳），删旧 → 建新 → 改。

### 大括号 `{}` 配对错乱
- **现场修复**，不要退档。
- 用 Python 栈算法定位，根据**函数边界 / if-else / 作用域**判断该在哪一行加/删 `}`。
- **5 分钟现场修复 > 退档重做几小时**。

### 不要凭函数名下结论（嵌入式）
- 看到 `app10ms()` 不代表 10ms 周期。
- 必须**追到定时器中断**：变量在哪累加 → 函数在哪被调 → 调用条件 → 条件在哪触发 → 定时器配置。

### 退档纪律
- **绝不私自退档**，必须先列备份 + 描述各备份内容 + 等用户选择。

### 验证 / 自信表达
- 不说"已修正""完美""已完成""确定"。
- 说"已修改，验证结果：[显示代码]"。
- 用户问"你确定？"= 你可能没改成功 = **重新读取文件检查**。

### 协议文档
- 不靠预期/经验生成协议表。**先读真实代码**（帧 ID、解析函数、setter、输出函数、引脚映射），再写文档。

---

## 4. 上游同步流程

`codex-personal-toolkit` 更新后，把变化同步到本目录：

```bash
# 在云端 VM 或本地
git clone --depth 1 https://github.com/hudonghua/codex-personal-toolkit /tmp/cpt

# 比对 / 拷贝
diff -ruN docs/skills /tmp/cpt/skills | less
cp /tmp/cpt/skills/<skill-name>/SKILL.md docs/skills/<skill-name>/SKILL.md
cp /tmp/cpt/records/memory-backup/<file>.md docs/memory/

# 提交
git add docs/
git commit -m "memory+skills: sync from codex-personal-toolkit@<commit>"
git push
```

未来也可以做一个 `scripts/sync-toolkit.ps1` / `.sh` 自动化此事。

---

## 5. 历史快照

- **2026‑05‑25** 首次从 `hudonghua/codex-personal-toolkit` 镜像 16 个 skill + 4 份 memory record 进来。详见提交历史。
