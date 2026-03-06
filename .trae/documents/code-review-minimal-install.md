# Code Review: minimal-install 目录

## 审查范围
- `setup-disk.sh` - 磁盘分区与加密配置
- `setup-base-pkg.sh` - 基础软件包安装
- `config-base-system.sh` - 系统基础配置
- `setup-bootloader.sh` - 引导程序安装

---

## 真正需要关注的问题

### 1. 磁盘设备验证可增强
**文件**: setup-disk.sh (30-33行)

**当前代码**:
```bash
if [[ ! -b "$DISK" ]]; then
    log_error "Disk $DISK does not exist"
    exit 1
fi
```

**建议增强**:
- 检查设备类型是否为磁盘 (`lsblk -d -o TYPE`)
- 显示警告提示当前系统所在磁盘

---

### 2. LUKS 容器名称应与常量统一
**文件**: setup-disk.sh (189行) vs constants.sh (11行)

**问题描述**: 脚本使用 `cryptsystem`，但 constants.sh 定义了 `cryptroot`。

**建议修复**:
- 统一使用 `cryptsystem` 或 `cryptroot`
- 建议统一为 `cryptsystem`（当前脚本实际使用的值）

---

### 3. 变量使用不一致
**文件**: constants.sh vs 脚本实际使用

**问题描述**: constants.sh 定义了很多常量，但脚本中仍然硬编码值。

**示例**:
- constants.sh 定义 `LUKS_CONTAINER_NAME="cryptroot"`，但脚本使用 `cryptsystem`
- `MOUNT_POINT_ROOT` 在 constants.sh 中定义为 `/mnt`，脚本也硬编码了

**建议**: 保持现状即可，功能正常。

---

## 已确认无需修改的项目

| 项目 | 说明 |
|------|------|
| Limine 路径语法 | `boot():/` 是 Limine 特殊语法，正常 |
| 密码明文存储 | LiveCD 环境，安装后自动清除 |
| 中文镜像源硬编码 | 自用脚本，有特定需求 |
| sudoers 配置 | 初始化系统，仅更改一行 |
| locale.gen 重复 | 新系统不存在重复问题 |
| Btrfs 挂载选项 | genfstab 会生成正确选项 |
| ESP 分区大小 | 8GB 为 limine + snapper 预留 |
| 错误处理 | 直接退出并报错，符合预期 |

---

## 总结

经过代码审查，minimal-install 目录的脚本整体质量良好，没有发现功能性错误。

可选的改进项：
1. 磁盘设备验证增强
2. LUKS 容器名称与 constants.sh 统一

其他项目均为自用脚本的合理设计，无需修改。
