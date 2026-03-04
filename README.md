# 自动安装脚本

项目结构

```
.
├── dotfiles
│   └── setup-niri-dms.sh        # 配置 Niri 窗口管理器和 DankMaterialShell 的个人 dotfiles
├── minimal-install              # 最小安装阶段脚本目录
│   ├── cleanup.sh               # 清理挂载点、卸载分区和关闭加密容器的脚本
│   ├── config-base-system.sh    # 基础系统配置（时区、语言、网络等）
│   ├── setup-aur-helper.sh      # 安装并配置 AUR 辅助工具（如 paru）
│   ├── setup-base-pkg.sh        # 安装基础软件包（base、linux、firmware 等）
│   ├── setup-bootloader.sh      # 安装和配置引导加载器（Limine）
│   ├── setup-disk.sh            # 磁盘分区、LUKS 加密、Btrfs 子卷创建和挂载
│   └── setup-users.sh           # 创建 root 和普通用户，并设置权限和 sudo
├── my-archlinux-setup.md        # 安装指南文档，记录操作步骤和说明
├── post-install                 # 系统安装后脚本目录
│   ├── setup-bootloader-automate.sh  # 自动化 Limine 与 Snapper 快照集成配置
│   └── setup-system-snapshot.sh      # 配置 Snapper 快照管理与定时任务
├── README.md                    # 项目总览说明，介绍脚本和使用方法
└── setup.sh                     # 总入口脚本，调用 minimal-install 或 post-install 的各个脚本
```

分为三个子模块，

+ `minimal-install`  安装基本系统
+ `post-install` 安装 AUR 包，以及中文本地化
+ `dotfiles` 安装 DankMaterialShell（Niri），并安装日用软件及其配置

