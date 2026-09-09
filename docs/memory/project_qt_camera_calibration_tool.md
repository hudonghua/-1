---
name: Qt 相机 K/D 标定工具
description: Qt + OpenCV 相机内参 K/D 标定工具，支持棋盘格采集、导入目录图片、自动筛选、自动剔除高误差样本。
type: project
updated: 2026-05-25
---

# Qt 相机 K/D 标定工具

## 路径

- 工程目录：`C:\Users\DELL\Documents\QtCameraCalibration`
- 最新 exe：`C:\Users\DELL\Documents\QtCameraCalibration\build-msvc\Release\QtCameraCalibration.exe`
- 默认采集目录：`C:\Users\DELL\Documents\QtCameraCalibration\build-msvc\Release\samples`
- 用户测试图片目录：`C:\Users\DELL\Documents\QtCameraCalibration\build-msvc\Release\pic`
- 最新测试结果：`C:\Users\DELL\Documents\QtCameraCalibration\build-msvc\Release\pic\calibration.yml`

## 环境

- Qt：`C:\Qt\6.11.0\msvc2022_64`
- OpenCV：`C:\opencv\opencv`
- OpenCV CMake：`C:\opencv\opencv\build\x64\vc16\lib`
- 编译器：Visual Studio 2022 MSVC x64
- 构建目录：`C:\Users\DELL\Documents\QtCameraCalibration\build-msvc`

## 已实现功能

- 中文 Qt Widgets 界面。
- 打开相机实时预览。
- 检测棋盘格内角点。
- 手动采集样本。
- 自动筛选采集：持续检测视频流，只有检测到完整棋盘格、清晰度达标、样本不太重复、九宫格区域均衡时才保存。
- 自动保存原图和角点检查图。
- 支持递归导入目录图片：扫描当前保存目录和子目录的 `png/jpg/jpeg/bmp/tif/tiff`，跳过 `_corners` 检查图。
- 导入时打印进度、成功数、未识别数、尺寸不一致数。
- 标定时后台线程计算，界面不假死。
- 标定区有忙碌进度条和 K/D 状态文字。
- 日志打印当前阶段、每轮 RMS、每张图误差、自动剔除样本、最终结论。
- 程序自动均衡抽样参与标定：从导入样本中按九宫格和清晰度选择最多约 40 张代表图，避免 100 多张全量标定太慢。
- 使用常规 5 参数畸变模型 `k1,k2,p1,p2,k3`，不使用 14 参数模型，避免过慢和过拟合。
- 程序自动判断并剔除高误差样本：单张重投影误差超过约 2 像素时自动剔除并重算，至少保留 15 张，避免删过头。
- 保存 `calibration.yml`，包含 `K`、`D`、图像尺寸、棋盘格参数、RMS、平均重投影误差、每张图误差、保存时间。

## 当前验证结果

用户目录 `pic` 下有 138 张 jpg，程序可导入 109 张棋盘格有效图片。最新生成的 `calibration.yml`：

- 图像尺寸：`1920 x 1080`
- 棋盘格内角点：`11 x 8`
- 单格边长：`25 mm`
- 最终样本数：`34`
- RMS：`0.366136`
- 平均重投影误差：`0.366137`
- D 模型：5 参数
- 保存时间：`2026-05-25T12:48:57`

该结果比早期 14 参数/全量样本结果 `RMS≈2.156` 明显更好，适合当前全电脑项目的普通工业相机 K/D 标定。若后续使用超广角/鱼眼镜头，再考虑专门的鱼眼或更复杂畸变模型。

## 使用流程

1. 打开 `QtCameraCalibration.exe`。
2. 设置棋盘格参数，默认 `11 x 8` 内角点、`25 mm` 单格。
3. 新相机可直接打开相机并勾选 `自动筛选采集`，手持棋盘格覆盖中心、四角、四边、远近、旋转、倾斜。
4. 程序不是每 100ms 固定保存，而是持续检测视频流，合格才保存。
5. 如果已有图片，把图片放入保存目录或其子目录，点击 `导入目录图片`。
6. 点击 `标定 K/D`，等待后台计算完成。
7. 日志确认最终 RMS 和剔除结论后，点击 `保存 YAML`。

## 注意

- 该工具当前是棋盘格 K/D 标定工具，不是 AprilTag/ArUco/tag 码识别工具。
- 全电脑项目后续四点 LED / solvePnP 定位可以使用这里保存的 K/D。
- 新对话继续处理此工具时，应先读取本记忆，并检查 exe 与 `calibration.yml` 的最新时间。
