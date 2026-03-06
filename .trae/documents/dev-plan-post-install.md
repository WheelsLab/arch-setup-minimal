# 开发计划：post-install 脚本实现

## 背景

根据 `my-archlinux-setup.md` 文档规划，`post-install` 目录用于重启后的系统，进行需要 AUR 或特定于机器的配置。

## 目标脚本

### 1. prepare.sh
安装 AUR 助手 `paru`

**功能**:
- 安装 `base-devel`（如果需要）
- 从 archlinuxcn 仓库安装 `paru` 或从源码编译安装

**关键步骤**:
```bash
# 1. 安装 base-devel
pacman -S --needed base-devel

# 2. 安装 paru（从 archlinuxcn 或源码）
pacman -S paru  # 或从 AUR 源码编译
```

---

### 2. setup-system-snapshot.sh
配置 `snapper` 快照系统

**功能**:
- 安装 `snapper`
- 卸载并删除手动创建的 `/.snapshots` 子卷
- 创建 snapper root 配置
- 删除 snapper 自动创建的子卷，重新挂载手动创建的
- 安装 `snap-pac`（pacman 集成）
- 安装 `cronie`（自动时间线快照）

**关键步骤**:
```bash
# 1. 安装 snapper
pacman -S snapper

# 2. 清理现有快照目录
umount /.snapshots
rm -r /.snapshots

# 3. 创建 snapper 配置
snapper -c root create-config /

# 4. 清理并重建
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount /.snapshots/

# 5. 安装 snap-pac
pacman -S snap-pac

# 6. 安装 cronie
pacman -S cronie
```

---

### 3. setup-bootloader-automate.sh
安装引导自动化工具和 Plymouth

**功能**:
- 安装 `limine-mkinitcpio-hook`（自动生成引导条目）
- 复制并配置 `/etc/default/limine`
- 安装 `limine-snapper-sync`（快照启动项同步）
- 配置 `sd-btrfs-overlayfs` hook
- 运行 `limine-install` 和 `limine-mkinitcpio`
- 启用 `limine-snapper-sync.service`
- **安装和配置 plymouth**（在引导自动化之后）

**关键步骤**:
```bash
# === 引导自动化 ===

# 1. 安装 limine-mkinitcpio-hook
paru -S limine-mkinitcpio-hook

# 2. 配置 limine
cp /etc/limine-entry-tool.conf /etc/default/limine
# 编辑 /etc/default/limine 添加:
# KERNEL_CMDLINE[default]=rd.luks.name=... root=...
# ROOT_SUBVOLUME_PATH=/@
# ROOT_SNAPSHOTS_PATH=/@snapshots
# MAX_SNAPSHOT_ENTRIES=50

# 3. 安装 limine-snapper-sync
paru -S limine-snapper-sync

# 4. 配置 mkinitcpio sd-btrfs-overlayfs hook
# HOOKS=(... filesystems sd-btrfs-overlayfs ...)

# 5. 安装 limine
limine-install
limine-mkinitcpio

# 6. 启用自动同步
systemctl enable --now limine-snapper-sync.service

# === Plymouth（引导自动化之后）===

# 7. 安装 plymouth
pacman -S plymouth

# 8. 配置内核参数（需要读取已配置的 limine）
# 编辑 /etc/default/limine 添加 splash quiet

# 9. 配置 mkinitcpio（确保 plymouth 在正确位置）
# HOOKS=(... sd-encrypt plymouth ...)

# 10. 重新生成 initramfs
limine-mkinitcpio
```

---

## 实现顺序

1. **prepare.sh** - 安装 AUR 助手
2. **setup-system-snapshot.sh** - 快照系统
3. **setup-bootloader-automate.sh** - 引导自动化 + Plymouth

## 注意事项

- 需要读取 LUKS UUID 和其他安装时的参数（可从 /tmp 或新系统读取）
- 需要处理已存在配置的情况（跳过或覆盖）
- 需要使用已有的 lib 脚本（constants.sh, logging.sh, utils.sh）
- Plymouth 必须在引导自动化之后配置，因为需要修改 /etc/default/limine
- limine-mkinitcpio 会自动处理 initramfs 重建

## 待定项

- Plymouth 具体配置取决于是否使用加密（sd-encrypt hook 位置）
- limine 配置需要读取安装时保存的参数
- 脚本之间的依赖关系处理
