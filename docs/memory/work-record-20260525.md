# 2026-05-25 工作记录

## 1. QtCameraCalibration 相机 K/D 标定工具

工程路径：`C:\Users\DELL\Documents\QtCameraCalibration`

最终 exe：`C:\Users\DELL\Documents\QtCameraCalibration\build-msvc\Release\QtCameraCalibration.exe`

已完成：

- 安装 OpenCV 4.12.0 到 `C:\opencv\opencv`。
- 使用 Qt 6.11.0 MSVC 2022 Kit 编译 Qt + OpenCV 工具。
- 中文界面：相机、棋盘格参数、输出目录、导入、标定、日志。
- 自动采集棋盘格：持续检测视频流，只有完整棋盘格、清晰、区域均衡、不重复时保存。
- 支持递归导入目录图片，自动跳过 `_corners` 检查图。
- 日志底部显示，导入进度和 K/D 状态可见。
- 标定后台线程计算，界面不假死。
- 使用常规 5 参数畸变模型 `k1,k2,p1,p2,k3`，避免 14 参数模型过慢和过拟合。
- 程序自动按九宫格/清晰度均衡抽样最多约 40 张代表图参与标定。
- 自动剔除高重投影误差样本，并打印每轮 RMS、剔除文件、最终结论。

测试图片目录：`C:\Users\DELL\Documents\QtCameraCalibration\build-msvc\Release\pic`

最新结果：`calibration.yml`

- 图像尺寸：1920 x 1080
- 棋盘格：11 x 8
- 单格：25 mm
- 最终样本数：34
- RMS：0.366136
- 平均重投影误差：0.366137
- D 模型：5 参数

已写入本地项目记忆：`project_qt_camera_calibration_tool.md`。

## 2. 小断面遥控器任务

工程路径：`F:\工作\AI模型\q强力\小断面\小断面\遥控器\GMZ_O_XDM_119\FSJ_666(中臂)`

Keil 工程：`HDH_YKQ_SPJ.uvproj`

任务与处理：

- 之前已处理：`F3` 单按不再进入遥控器状态界面，改为 `F1+F3` 同时按进入。
- 之前已处理：状态页返回主界面后强制刷新主界面数据。
- 今日处理：`锚杆自动启动` 出现后消不掉。
  - 根因：`App_lcd.c` 中 `remote_18c.LF == 4` 时在 `(7,217)` 显示“锚杆自动启动”，但 `LF` 回到 `0/1/2/3` 时没有清空该坐标。
  - 修复：`LF == 4` 显示；`LF != 4` 清空 `(7,217)`。
- 同时恢复关键 LCD 显示字符串：启动、停止、高冲、低冲、控制左臂、控制中臂、控制右臂、需要选择系统、锚杆自动启动。
- Keil 编译通过：`0 Error(s), 9 Warning(s)`。

重要提示：该工程是 GBK/中文嵌入式 C 源码，后续修改必须遵守新增 GBK 中文写入硬规则。

## 3. GBK 中文写入事故与规则更新

事故：在修改小断面遥控器 `App_lcd.c` 时，虽然使用 Python，但将中文直接嵌入 PowerShell 命令行传给 Python，导致中文在进入 Python 前被终端代码页转坏，出现“锟/�/乱码”。

新增硬规则：

- 只要涉及中文，不能把中文直接写在 PowerShell/cmd/shell 命令字符串里传给 Python。
- GBK 源码里的中文必须用 Unicode 码点生成，或从可靠 GBK 原文按字节复制。
- 不得用 `errors='ignore'` 读坏后整体写回，避免扩大编码破坏。
- 修改后必须用 Python 按 GBK 读取并检查关键字符串 Unicode 码点，再 Keil 编译验证。

已更新本地记忆：

- `feedback_gbk_file_modification.md`
- `.claude/skills/safe-edit-gbk/SKILL.md`

## 4. 新对话恢复提示

新建对话后，如继续 Qt K/D 标定工具：读取 `project_qt_camera_calibration_tool.md`。

如继续小断面遥控器：读取本记录，并优先检查 `App_lcd.c` 中 `remote_18c.LF` 显示逻辑和 GBK 编码规则。
