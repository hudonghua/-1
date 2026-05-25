# scripts/ — 本地无感同步工具

让 **Cursor 云端 Agent 干的活** 自动同步到你 **本地 Windows 仓库**。

## 整体闭环

```
我（云端 Agent）        生成文件
  └─► git push ──► GitHub
                     │
                     │ 你本地脚本 / Cursor Autofetch 自动拉
                     ▼
              你的 Windows 仓库
                │
                │ install-skills-locally.ps1 （可选）
                ▼
          ~/.codex/skills, ~/.claude/skills, ~/.cursor/skills-cursor
              （所有本地 Agent 跨项目都能用）
```

云端这边 push + PR 全自动（见 `AGENTS.md`）。本地这边需要**一次性配置**下面任一方式即可。

如果你不仅想让**本仓库内**的 Agent 知道这些 skill，还想让**所有本地 Agent（Codex CLI、Claude Code、Cursor 本地 Agent）跨项目都能用**，看下面的 [方案 D](#方案-d把-skills--memory-装到所有本地-agent-的全局目录)。

---

## 三种本地自动同步方式，挑一种

### 方式 A：Cursor / VS Code 自带 Autofetch（最省事）

1. 在 Cursor 客户端用 **File → Open Folder** 打开你本地这个仓库。
2. 打开设置：`Ctrl + ,`，搜索 **`git.autofetch`**。
3. 把 **Git: Autofetch** 设为 `true`（或 `"all"`），间隔 `git.autofetchPeriod` 默认 180 秒。
4. 看到远端有更新，IDE 状态栏会出现拉取按钮，点一下；或开启 **`git.pullOnFocus`**（如可用）。

> 优点：零脚本、零权限。缺点：默认只是 fetch，不会自动 pull，要点一下才落到工作区。

---

### 方式 B：PowerShell 后台脚本（真·自动 pull）

在本地 PowerShell（不需要管理员）跑：

```powershell
cd C:\path\to\your\repo
powershell -ExecutionPolicy Bypass -File .\scripts\auto-pull.ps1
```

它会**常驻**，每 30 秒：

- `git fetch --prune`
- 工作区干净时 `git pull --ff-only` 当前分支
- 工作区有未提交改动 → 只 fetch，不动你的本地改动
- 分支分叉 → 只提示，不自动 merge

参数：

```powershell
.\scripts\auto-pull.ps1 -RepoPath "C:\path\to\repo" -IntervalSec 30 -FetchAll
```

日志默认写到仓库根的 `.auto-pull.log`（已通过 `.gitignore` 屏蔽）。

> 关掉 PowerShell 窗口脚本就停。想后台常驻，用方式 C。

---

### 方式 C：注册成 Windows 任务计划程序（开机自启 + 定时跑）

用**管理员 PowerShell**执行：

```powershell
cd C:\path\to\your\repo
powershell -ExecutionPolicy Bypass -File .\scripts\install-auto-pull-task.ps1
```

会创建任务 `CursorRepoAutoPull`：

- 登录时自动跑一次
- 之后**每 1 分钟**触发一次 `auto-pull.ps1 -Once`
- 静默后台，无窗口
- 日志写到 `.auto-pull.log`

自定义：

```powershell
.\scripts\install-auto-pull-task.ps1 -RepoPath "D:\code\proj" -IntervalMin 2
```

卸载：

```powershell
.\scripts\install-auto-pull-task.ps1 -Uninstall
```

> 优点：开机即同步，体感最接近"无感"。缺点：要管理员权限注册一次。

---

---

### 方案 D：把 skills + memory 装到所有本地 Agent 的**全局目录**

让 `docs/skills/` 和 `docs/memory/` 不仅在本仓库内有效，还能被 **Codex CLI**、**Claude Code**、**Cursor 本地 Agent**（跨任意项目）直接读到。

脚本：[`scripts/install-skills-locally.ps1`](./install-skills-locally.ps1)

会把内容**非破坏性合并**到三个全局目录：

| 目标 | Skills 写到 | Memory 写到 |
| --- | --- | --- |
| **Codex CLI** | `%USERPROFILE%\.codex\skills\` | `%USERPROFILE%\.codex\memory\` |
| **Claude Code** | `%USERPROFILE%\.claude\skills\` | `%USERPROFILE%\.claude\projects\C--Users-<user>\memory\` |
| **Cursor 本地 Agent** | `%USERPROFILE%\.cursor\skills-cursor\` | `%USERPROFILE%\.cursor\memory\` |

#### 使用

```powershell
cd C:\path\to\your\repo

# 1. 先 DRY-RUN 预览（不动磁盘，只打印将做什么）
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills-locally.ps1

# 2. 看过没问题，再真正安装
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills-locally.ps1 -Apply

# 3. 只装某一两个目标
.\scripts\install-skills-locally.ps1 -Apply -Targets Codex,Claude

# 4. 跳过 memory，只装 skills
.\scripts\install-skills-locally.ps1 -Apply -SkipMemory

# 5. 同名且内容不同时强制覆盖（仍会保留 .incoming-<ts> 备份）
.\scripts\install-skills-locally.ps1 -Apply -Force
```

> **默认是 DRY-RUN**——你跑第一次只会看到预览，**不会动你的本地文件**。确认后再加 `-Apply` 才真正写入。

#### 合并规则（非破坏性）

| 情况 | 默认行为 | `-Force` 行为 |
| --- | --- | --- |
| 目标不存在 | ✅ 新增 | ✅ 新增 |
| 目标存在 + 内容一致 | ⏭ 跳过 | ⏭ 跳过 |
| 目标存在 + 内容不同 | 🟡 **保留本地**，源文件存为 `<name>.incoming-<ts>.md` | 🟡 覆盖本地，**先备份旧内容到** `<name>.incoming-<ts>.md` |

任何情况下都**不会删除本地文件**，**不会无声覆盖**。

#### 报告

每次 `-Apply` 运行后会写一份合并报告到：

```
<repo>/merge-reports/install-skills-locally-YYYYMMDD-HHMMSS.md
```

里面有所有 added / updated / kept-local / unchanged 文件的明细。

> `merge-reports/` 已被 `.gitignore` 忽略，是本地产物，不会污染仓库。

#### 推荐工作流

```
1. 一次性：拉仓库 → 跑 install-auto-pull-task.ps1（方案 C）+ install-skills-locally.ps1 -Apply（方案 D）
2. 之后：
   - 我（云端 Agent）改 skill / 改 memory → push 到 GitHub
   - 你本地分钟级自动 git pull（方案 C）
   - 想把新 skill 立刻同步到全局 Agent 目录 → 再跑一次 install-skills-locally.ps1 -Apply
```

#### 卸载

脚本只是复制文件，不创建注册项。**想撤回**：

- 删除目标目录里你不想要的 `.md` 即可。
- 用 `.incoming-<ts>.md` 恢复被覆盖的旧版本：手动改名回去。

---

## 验证整个闭环是否打通

1. 让我（云端 Agent）做一个**小改动**，比如往 `docs/memory/` 里加一个空文件；
2. 我会自动 push 到分支 + 开 PR；
3. 你本地按方式 B / C 配好后，等几十秒；
4. 本地 `git log --oneline -5` 看是否多了那条提交；
   或者在 IDE 的 Source Control 面板里能看到新分支。

如果文件没出现：

- 检查 `.auto-pull.log`，看 fetch / pull 有没有失败
- 检查本地是不是 checkout 到我推的那个分支（默认只 pull 当前分支）
- 跨分支同步要么手动 `git fetch --all` 看其他分支，要么用 `-FetchAll` 参数

---

## 安全说明

- 脚本**只做读取与快进合并**（`--ff-only`），不会强制覆盖你本地未提交的改动。
- 工作区脏的时候自动跳过 pull。
- 不上传任何东西到外部——只跟你自己的 GitHub 仓库通信。
