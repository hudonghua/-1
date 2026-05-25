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
                （文件就出现了）
```

云端这边 push + PR 全自动（见 `AGENTS.md`）。本地这边需要**一次性配置**下面任一方式即可。

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
