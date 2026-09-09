# docs/memory/

**Cursor Agent 的长期记忆目录**。云端 / 本地 Agent 启动时会按 `AGENTS.md` §1 的顺序读取本目录下的文件。

## 建议放进来的文件

| 文件名 | 用途 |
| --- | --- |
| `CURSOR_AGENT_MEMORY.md` | 总入口 / 索引，列出本仓库其他 memory 文件的用途与读取顺序 |
| `编程手册与纪律.md` | 编程纪律（强约束），所有代码改动必须遵守 |
| `MEMORY.md` | 项目长期记忆（架构、关键决策、坑、约定） |
| `project_<name>.md` | 单个项目/模块的专用上下文 |
| `reference_<topic>.md` | 参考资料、协议规格、芯片手册摘录等 |
| `feedback_<topic>.md` | 用户历史反馈、踩过的坑、不要再犯的错 |

## 怎么用

1. 在本地把这些 `.md` 文件丢到 `docs/memory/` 下；
2. `git add docs/memory/ && git commit -m "memory: add ..." && git push`；
3. 云端 Agent 下次启动会自动读到。

> 文件**不存在**时 Agent 会跳过，不会报错。先放一个空骨架也 OK。

## 注意

- **不要**把含有密码 / Token / 私钥的内容放进来——仓库会上 GitHub。
- 涉密信息走 **Cursor Dashboard → Cloud Agents → Secrets**。
