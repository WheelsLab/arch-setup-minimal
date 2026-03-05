# My Arch Setup

> https://wiki.archlinuxcn.org/wiki/Arch_Linux

## 我的设备

### ThinkPad T480s

> [!NOTE]
>
> https://wiki.archlinux.org/title/Laptop
>
> https://wiki.archlinux.org/title/Laptop/Lenovo#T_series
>
> https://wiki.archlinux.org/title/Lenovo_ThinkPad_T480s

联想的 ThinkPad 系列通常具有完美支持

### ASUS PC

```
CPU: i5 12600k
GPU: NVIDIA 4070s
Memory: 70 GiB
Disks: 1T + 500G SSD
Display: 2 x 4k monitors
```

## 最小安装

> [!NOTE]
>
> 安装指南：https://wiki.archlinuxcn.org/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97
>
> 建议阅读：
>
> + 安装过程：https://wiki.archlinuxcn.org/wiki/Category:%E5%AE%89%E8%A3%85%E8%BF%87%E7%A8%8B
> + FAQ：https://wiki.archlinuxcn.org/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98
> + Arch 术语：https://wiki.archlinuxcn.org/wiki/Arch_%E6%9C%AF%E8%AF%AD#RTFM
> + Arch Wiki文档的组织结构和格式说明：https://wiki.archlinuxcn.org/wiki/Help:%E9%98%85%E8%AF%BB
> + GNU Core utils（核心工具）：https://wiki.archlinuxcn.org/wiki/%E6%A0%B8%E5%BF%83%E5%B7%A5%E5%85%B7
> + Arch 中文社区：https://wiki.archlinuxcn.org/wiki/Arch_Linux_%E4%B8%AD%E6%96%87%E7%A4%BE%E5%8C%BA
> + Arch 国际社区：https://wiki.archlinuxcn.org/wiki/%E5%9B%BD%E9%99%85%E7%A4%BE%E5%8C%BA
> + GNU：https://wiki.archlinuxcn.org/wiki/GNU#Texinfo
> + 手册
>   + man：https://wiki.archlinuxcn.org/wiki/Man_%E6%89%8B%E5%86%8C
>   + info：https://wiki.archlinux.org/title/GNU#Texinfo

下载 ISO：https://archlinux.org/download/

+ 北京外国语大学大学镜像站：https://mirrors.bfsu.edu.cn/archlinux/iso/
+ 华中科技大学镜像站：https://mirrors.hust.edu.cn/archlinux/iso/
+ 清华大学镜像站：https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso
+ 中国科学技术大学镜像站：https://mirrors.ustc.edu.cn/archlinux/iso/

从 U 盘启动到 Live CD 环境：

+ https://wiki.archlinuxcn.org/wiki/Ventoy
+ https://rufus.ie/zh/
+ U 盘安装介质：https://wiki.archlinuxcn.org/wiki/U_%E7%9B%98%E5%AE%89%E8%A3%85%E4%BB%8B%E8%B4%A8

> 其他启动方法
>
> + 光盘驱动器：https://wiki.archlinuxcn.org/wiki/%E5%85%89%E7%9B%98%E9%A9%B1%E5%8A%A8%E5%99%A8#%E5%88%BB%E5%BD%95
> + 网络引导：https://wiki.archlinuxcn.org/wiki/%E7%BD%91%E7%BB%9C%E5%BC%95%E5%AF%BC#%E4%BB%8EU%E7%9B%98%E5%90%AF%E5%8A%A8

如果 tty 字体太小，可以设置为最大的终端字体：

> 终端字体：https://wiki.archlinuxcn.org/wiki/Linux_%E6%8E%A7%E5%88%B6%E5%8F%B0#%E5%AD%97%E4%BD%93
>
> HiDPI：https://wiki.archlinuxcn.org/wiki/HiDPI#Linux_%E6%8E%A7%E5%88%B6%E5%8F%B0

```
setfont ter-132b
```

连接网络：

> 网络配置：https://wiki.archlinuxcn.org/wiki/%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE#%E7%BD%91%E7%BB%9C%E6%8E%A5%E5%8F%A3
>
> 配置工具：
>
> + netctl：https://wiki.archlinuxcn.org/wiki/Netctl
> + NetworkManager：https://wiki.archlinuxcn.org/wiki/NetworkManager
> + iwd：https://wiki.archlinuxcn.org/wiki/Iwd#iwctl

+ 有线（Ethernet）
  + 静态 IP
  + DHCP
+ 无线（WLAN）

设置 Live CD 环境的 root 密码

```
passwd
```

然后在另一台电脑上，通过 SSH 连接上去（方便粘贴命令）

```
ssh root@192.168.122.96
```

![image-20260303172731545](./my-archlinux-setup.assets/image-20260303172731545.png)

### 分区

关于分区、文件系统、目录结构

> 分区：https://wiki.archlinuxcn.org/wiki/%E5%88%86%E5%8C%BA
>
> + UEFI：https://wiki.archlinuxcn.org/wiki/UEFI
> + GUID 分区表
>
> + EFI 系统分区：https://wiki.archlinuxcn.org/wiki/EFI_%E7%B3%BB%E7%BB%9F%E5%88%86%E5%8C%BA
>
> 分区工具：
>
> + [cfdisk](https://wiki.archlinuxcn.org/wiki/Cfdisk)：TUI 界面的分区工具
> + [parted](https://wiki.archlinuxcn.org/wiki/Parted)：GNU 的分区工具
> + [fdisk](https://wiki.archlinuxcn.org/wiki/Fdisk)：经典分区工具
>
> 查看磁盘信息：
>
> + lsblk
>
> 磁盘在 Linux 是一种块设备文件
>
> + 设备文件：https://wiki.archlinuxcn.org/wiki/%E8%AE%BE%E5%A4%87%E6%96%87%E4%BB%B6

> 文件系统：https://wiki.archlinuxcn.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F
>
> + FAT：https://wiki.archlinux.org/title/FAT
> + Btrfs：https://wiki.archlinuxcn.org/wiki/Btrfs
> + ext4：https://wiki.archlinuxcn.org/wiki/Ext4
>
> Swap：https://wiki.archlinuxcn.org/wiki/Swap
>
> + zram 用作 swap：https://wiki.archlinuxcn.org/wiki/Zram#%E4%BD%9C%E4%B8%BA_swap_%E7%9A%84%E4%BD%BF%E7%94%A8
>

> 目录结构：https://man.archlinux.org/man/file-hierarchy.7.zh_CN
>
> + `/`
> + `/boot`
> + `/etc`
> + `/home`
> + `/root`
> + `/usr`
>   + `/usr/bin`
>   + `/usr/share`
> + `/var`
>   + `/var/cache`
>   + `/var/cache/*package*`
>   + `/var/log/*package*`
> + `/dev/`
> + `/proc`
> + `sys`
> + `/bin`、`/sbin`、`/usr/sbin`
> + `~/.local/bin`
> + `~/.local/share`
> + `~/.config`
> + `~/.cache`

LUKS 加密

+ `dm-crypt`：https://wiki.archlinuxcn.org/wiki/Dm-crypt
+ 加密整个系统：https://wiki.archlinuxcn.org/wiki/Dm-crypt/%E5%8A%A0%E5%AF%86%E6%95%B4%E4%B8%AA%E7%B3%BB%E7%BB%9F

#### 分区方案

先设计一个分区方案（需要适用于 LUKS 全盘加密、Snapper 快照）

现代主板基本都是 **UEFI 固件**，必须使用 **ESP（EFI System Partition）** 来存放引导加载器。ESP 只能使用 FAT 文件系统（通常 FAT32）。

> Wikipedia [ESP system partition](https://en.wikipedia.org/wiki/EFI_system_partition)：EFI 系统分区（ESP）是供 UEFI 固件使用的 FAT 文件系统分区，启动时固件从此处加载引导程序。

随后需要配置**全盘加密**。在本方案中，仅对一个主分区进行 LUKS 加密，然后在该加密容器内部创建 Btrfs 文件系统。借助 Btrfs 的子卷（subvolume）机制，可以将系统中不同用途的目录划分到独立子卷中，从而实现快照隔离和数据分离。

整个磁盘仅划分为两个分区：

- 一个用于 UEFI 启动的 FAT32 格式 ESP 分区
- 一个用于 LUKS 加密的 SYSTEM 分区

分区规划如下：

| 分区        | 类型        | 挂载点  | 说明                |
| ----------- | ----------- | ------- | ------------------- |
| `/dev/vda1` | FAT32 (ESP) | `/boot` | Bootloader + Kernel |
| `/dev/vda2` | LUKS        | Btrfs   | 加密 SYSTEM         |

具体如下

+ `/dev/vda1`（`vfat`）-> `/boot`：用于存放 Bootloader 及内核镜像，不参与加密
+ `/dev/vda2`（LUKS）-> btrfs：在 LUKS 容器内部创建 Btrfs 文件系统，并规划如下子卷结构：
  + `@`-> `/`：系统根目录，用于安装操作系统主体。
  + `@home`-> `/home`：存放普通用户家目录，不纳入系统快照。
  + `@log` -> `/var/log`：存储持久化系统日志，避免快照回滚影响日志完整性。
  + `@pkg` -> `/var/cache/pacman/pkg/`：软件包缓存目录，防止缓存数据污染系统快照。
  + `@snapshots` -> `/.snapshots`：专用于 Snapper 快照存储。
  + `@games` ->  `/mnt/games`：用于存放大型游戏数据（如 Steam、Heroic Games Launcher、minecraft-xmcl 等），避免占用系统子卷空间并减少快照体积。
  + `@vm` ->用于虚拟机数据隔离，对应 QEMU/KVM 虚拟机镜像与状态数据。
    + `/var/lib/libvirt`
    + `/var/lib/qemu`
  + `@container` -> 容器运行时数据目录
    + `/var/lib/docker`（Docker）
    + `/var/lib/containers`（Podman）

#### 进行分区

首先按照之前规划的 Btrfs 子卷结构进行分区与初始化：

```
ESP
Btrfs (LUKS)
├── @               → /
├── @home           → /home
├── @snapshots      → /.snapshots
├── @pkg            → /var/cache/pacman/pkg
├── @log            → /var/log
├── @vm
│   ├── @libvirt    → /var/lib/libvirt
│   └── @qemu       → /var/lib/qemu
├── @container
│   ├── @docker     → /var/lib/docker
│   └── @podman     → /var/lib/containers
└── @games          → /mnt/games
```

首先创建 GPT 分区表：

```
parted -s /dev/vda mklabel gpt
```

创建 **ESP（EFI System Partition）**。这里分配 **8 GiB** 空间，是为了后续与 `limine` 和 `snapper` 集成时可以在 ESP 中备份内核与启动文件。

```
parted -s /dev/vda mkpart ESP fat32 1MiB 8GiB
parted -s /dev/vda set 1 esp on
```

创建 LUKS 加密容器分区：

```
parted -s /dev/vda mkpart crypt 8GiB 100%
```

> 检查分区结果
>
> ```
> parted /dev/vda print
> ```

格式化 ESP：

```
mkfs.fat -F32 /dev/vda1
```

创建 LUKS 加密容器：

```
cryptsetup luksFormat /dev/vda2
cryptsetup open /dev/vda2 cryptsystem
```

在 LUKS 容器中创建 Btrfs 文件系统：

```
mkfs.btrfs /dev/mapper/cryptsystem
```

创建 Btrfs 子卷结构

> [!WARNING]
>
> 必须先挂载 **Btrfs 顶层文件系统**，然后：
>
> 1. 先创建所有 **顶层子卷**
> 2. 再创建 **嵌套子卷**

挂载 Btrfs 顶层：

```
mount /dev/mapper/cryptsystem /mnt
```

创建顶层子卷

```
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@games
btrfs subvolume create /mnt/@vm
btrfs subvolume create /mnt/@container
```

 创建嵌套子卷

```
# @vm 虚拟机子卷
btrfs subvolume create /mnt/@vm/@libvirt
btrfs subvolume create /mnt/@vm/@qemu

# @container 容器子卷
btrfs subvolume create /mnt/@container/@docker
btrfs subvolume create /mnt/@container/@podman
```

创建完成后即可按照规划挂载各个子卷。

首先挂载根目录

```
mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptsystem /mnt
```

挂载各个子卷（使用 `--mkdir` 自动创建挂载目录）：

```
mount --mkdir -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/home
mount --mkdir -o subvol=@log,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/var/log
mount --mkdir -o subvol=@pkg,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/var/cache/pacman/pkg
mount --mkdir -o subvol=@snapshots,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/.snapshots
mount --mkdir -o subvol=@vm/@libvirt,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/var/lib/libvirt
mount --mkdir -o subvol=@vm/@qemu,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/var/lib/qemu
mount --mkdir -o subvol=@container/@docker,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/var/lib/docker
mount --mkdir -o subvol=@container/@podman,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/var/lib/containers
mount --mkdir -o subvol=@games,compress=zstd,noatime /dev/mapper/cryptsystem /mnt/mnt/games
```

最后挂载 EFI 系统分区：

```
mount /dev/vda1 /mnt/boot
```

对于 **虚拟机、容器和大型游戏数据**，通常需要关闭 Btrfs 的 Copy-on-Write，以避免性能下降。

```
chattr +C /mnt/var/lib/libvirt
chattr +C /mnt/var/lib/qemu
chattr +C /mnt/var/lib/docker
chattr +C /mnt/var/lib/containers
chattr +C /mnt/mnt/games
```

### 安装

配置国内镜像站

```
curl -L 'https://archlinux.org/mirrorlist/?country=CN&protocol=https' -o /etc/pacman.d/mirrorlist
```

然后取消 `/etc/pacman.d/mirrorlist` 中的注释（该文件会自动被复制到新系统）

```
##
## Arch Linux repository mirrorlist
## Generated on 2026-03-05
##

## China
#Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
#Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.cqu.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.hit.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.hust.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.jcut.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.jlu.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.jxust.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.nju.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirror.nyist.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.qlu.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.shanghaitech.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.wsyu.edu.cn/archlinux/$repo/os/$arch
#Server = https://mirrors.xjtu.edu.cn/archlinux/$repo/os/$arch
```

安装必要软件包

```
pacstrap -K /mnt base linux linux-firmware intel-ucode btrfs-progs networkmanager vim man-db man-pages texinfo
```

### 配置

生成 fstab 文件

> https://wiki.archlinuxcn.org/wiki/Genfstab

```
genfstab /mnt > /mnt/etc/fstab
```

需要一点小调整，`/boot` 使用 UUID 挂载，手动编辑 `/mnt/etc/fstab`

```
# /dev/vda1
UUID=9839-A1BD          /boot           vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro      0 2
```

chroot 到新系统

> https://wiki.archlinuxcn.org/wiki/Chroot

```
arch-chroot /mnt
```

设置 archlinuxcn 仓库，编辑 `/etc/pacman.conf`，在末尾添加如下行

```
[archlinuxcn]
Server = https://repo.archlinuxcn.org/$arch
```

1. 安装 `archlinuxcn-keyring`

   ```
   pacman -Sy archlinuxcn-keyring
   ```

2. 更新系统并安装镜像列表

   ```
   pacman -Su archlinuxcn-mirrorlist-git
   ```

3. 编辑 `/etc/pacman.conf`，在 `[archlinuxcn]` 一节添加下面内容

   ```
   Include = /etc/pacman.d/archlinuxcn-mirrorlist
   ```

4. 编辑 `/etc/pacman.d/archlinuxcn-mirrorlist` 根据需要取消镜像站点的注释

设置时区

```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

同步硬件时钟

```
hwclock --systohc
```

区域设置，编辑 `/etc/locale.gen`，取消掉 `en_US.UTF-8 UTF-8` 和 `zh_CN.UTF-8` 的注释

> https://wiki.archlinuxcn.org/wiki/Locale

然后生成 locale 文件

```
locale-gen
```

编辑 `/etc/locale.conf` 设置区域，写入以下内容

```
LANG=en_US.UTF-8
```

设置主机名，编辑 `/etc/hostname`

> https://wiki.archlinuxcn.org/wiki/%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE#%E8%AE%BE%E7%BD%AE%E8%AE%A1%E7%AE%97%E6%9C%BA%E5%90%8D

```
archer
```

配置网络连接

> NetworkManager 支持有线和无线网络
>
> https://wiki.archlinuxcn.org/wiki/NetworkManager

```
systemctl enable NetworkManager.service
```

设置 root 密码

```
passwd
```

#### 创建普通用户（管理员账户）

> https://wiki.archlinux.org/title/Users_and_groups#User_management

添加普通用户

```
useradd -m -G wheel -s /bin/bash iclhc
```

并添加到 sudoers

> https://wiki.archlinuxcn.org/wiki/Sudo

安装 sudo

```
pacman -S sudo
```

把 wheel 组赋予 sudo 权限，使用 `visudo` 编辑配置文件 `/etc/sudoers` 取消掉 `%wheel      ALL=(ALL:ALL) ALL` 一行的注释

> 关于 wheel 组：https://wiki.archlinux.org/title/Users_and_groups#User_groups

```
EDITOR=vim visudo
```

修改密码

```
passwd iclhc
```

#### AUR helper

> https://wiki.archlinux.org/title/AUR_helpers
>
> https://github.com/morganamilo/paru

安装 `git`

```
pacman -S git
```

`makepkg` 不允许以超级用户运行，切换到普通用户

```
su - iclhc
cd
```

```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

#### 安装引导加载器

> Arch 的启动流程：https://wiki.archlinuxcn.org/wiki/Arch_%E7%9A%84%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B#%E5%BC%95%E5%AF%BC%E5%8A%A0%E8%BD%BD%E7%A8%8B%E5%BA%8F
>
> Limine：https://wiki.archlinux.org/title/Limine

安装 Limine 引导加载器

```
sudo pacman -S limine
```

把 `/usr/share/limine/BOOTX64.EFI` 复制到 ESP 系统分区

```
sudo mkdir -p /boot/EFI/arch-limine
sudo cp /usr/share/limine/BOOTX64.EFI /boot/EFI/arch-limine/
```

> 引导加载器是一个 EFI 程序，由 UEFI 固件加载。引导条目是存放在固件的 NVRAM 中的。所以要给引导加载器添加引导条目。
>
> https://wiki.archlinux.org/title/Arch_boot_process#System_initialization
>
> UEFI 固件依赖于[非易失性随机访问存储器](https://en.wikipedia.org/wiki/Non-volatile_random-access_memory)中的引导项进行引导。
>
> + 固件读取非易失性随机访问存储器（NVRAM）中的启动项，以确定要启动哪个EFI应用程序以及从何处启动（例如，从哪个磁盘和分区）。
>   + 一个启动项可以只是一个磁盘。在这种情况下，固件会在该磁盘上查找一个[EFI系统分区](https://wiki.archlinux.org/title/EFI_system_partition)，并尝试在后备启动路径`\EFI\BOOT\BOOTx64.EFI`（在[配备IA32（32位）UEFI的系统](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface#UEFI_firmware_bitness)上为`BOOTIA32.EFI`）中找到一个EFI应用程序。这就是UEFI可启动移动介质的工作原理。
> + 固件启动EFI应用程序。
>   + 这可能是一个[引导加载程序](https://wiki.archlinux.org/title/Arch_boot_process#Boot_loader)，或者是使用[EFI引导存根](https://wiki.archlinux.org/title/EFI_boot_stub)的Arch [内核](https://wiki.archlinux.org/title/Kernel)本身。
>   + 它可能是其他一些EFI应用程序，例如[UEFI shell](https://wiki.archlinux.org/title/UEFI_shell)或[启动管理器](https://wiki.archlinux.org/title/Arch_boot_process#Boot_loader)，如[systemd-boot](https://wiki.archlinux.org/title/Systemd-boot)或[rEFInd](https://wiki.archlinux.org/title/REFInd)。

安装 `efibootmgr`，为 Limine 添加启动条目。

> https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface#efibootmgr

安装

```
sudo pacman -S efibootmgr
```

添加引导条目

```
efibootmgr \
      --create \
      --disk /dev/vda \
      --part 1 \
      --label "Arch Linux Limine Boot Loader" \
      --loader '\EFI\arch-limine\BOOTX64.EFI' \
      --unicode
```

##### 手动配置

在开始配置前，需要配置 `mkinitcpio` 钩子以及确定磁盘加密所需的额外内核参数

在 `mkinitcpio.conf` 中添加 `keyboard`和`sd-encrypt`钩子，若要使用非标准键盘布局，或要自定义控制台字体，添加`sd-vconsole`钩子。

编辑 `/etc/mkinitcpio.conf`，修改 `HOOKS` 部分

```
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```

然后重新生成 `initramfs`

> 因为添加了 `sd-vconsole` 钩子，需要新建配置文件。否则会报错
>
> ```
> touch /etc/vconsole.conf
> ```

```
mkinitcpio -P
```

加密磁盘需要以下内核参数

```
rd.luks.name=device-UUID=cryptsystem root=/dev/mapper/cryptsystem
```

`*device-UUID*`指的是LUKS超级块的UUID，这里`/dev/vda2`对应的UUID。

可以用 `blkid` 获取分区 UUID

> 块设备持久化命名：https://wiki.archlinuxcn.org/wiki/%E5%9D%97%E8%AE%BE%E5%A4%87%E6%8C%81%E4%B9%85%E5%8C%96%E5%91%BD%E5%90%8D

```
sudo blkid
/dev/sr0: BLOCK_SIZE="2048" UUID="2026-03-01-10-44-11-00" LABEL="ARCH_202603" TYPE="iso9660" PTUUID="f177ce2f" PTTYPE="dos"
/dev/loop0: BLOCK_SIZE="1048576" TYPE="squashfs"
/dev/mapper/cryptsystem: UUID="41127ad2-097f-4343-89ea-ee483b522830" UUID_SUB="d48b48e6-72a9-4ac9-9c32-a30c9517ec9e" BLOCK_SIZE="4096" TYPE="btrfs"
/dev/vda2: UUID="43e02f28-bc3c-4af6-9b5a-94f7886d63ce" TYPE="crypto_LUKS" PARTUUID="e823e1d8-3909-45ab-bdee-1c553e313199"
/dev/vda1: UUID="9839-A1BD" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="ESP" PARTUUID="3ec5a16c-138d-4c3d-bd59-eb20f8f20c2d"
```

`/dev/vda2` 的 UUID 是 `43e02f28-bc3c-4af6-9b5a-94f7886d63ce`。所以和磁盘加密有关的内核参数是：

```
rd.luks.name=43e02f28-bc3c-4af6-9b5a-94f7886d63ce=cryptsystem root=/dev/mapper/cryptsystem
```

此外由于根文件系统是 Btrfs 子卷，还需要 `rootflags` 和 `rootfstype` 参数：

> Btrfs # 将子卷挂载为 `/`：https://wiki.archlinuxcn.org/wiki/Btrfs#%E5%B0%86%E5%AD%90%E5%8D%B7%E6%8C%82%E8%BD%BD%E4%B8%BA_/
>
> rootflags —— 根文件系统挂载选项。对于无法通过重新挂载应用的选项（例如，由 systemd-remount-fs.service(8) 应用）非常有用。例如，XFS 根卷的 discard 选项或 Btrfs 使用子卷作为根 时的 subvol= 选项。

```
rootflags=subvol=@ rootfstype=btrfs
```

在 ESP 分区根目录创建 Limine 配置，编辑 `/boot/limine.conf`，写入以下配置。添加上面内核参数

> 内核参数：https://wiki.archlinuxcn.org/wiki/%E5%86%85%E6%A0%B8%E5%8F%82%E6%95%B0#Limine

```
timeout: 5

/Arch Linux
    protocol: linux
    path: boot():/vmlinuz-linux
    cmdline: rd.luks.name=43e02f28-bc3c-4af6-9b5a-94f7886d63ce=cryptsystem root=/dev/mapper/cryptsystem rootflags=subvol=@ rootfstype=btrfs rw
    module_path: boot():/initramfs-linux.img
```

自此安装完成，系统可启动

按 `Ctrl+D` 退出 chroot

卸载所有分区

```
umount -R /mnt
```

关闭加密分区

```
 cryptsetup close /dev/mapper/cryptsystem
```

然后重启 `reboot`

##### 自动配置

> https://wiki.archlinux.org/title/Limine#Boot_entry_automation

由于在 Archiso 环境安装 `limine-mkinitcpio-hook` 会报错，所以进入新系统后在安装

```
Picked up NATIVE_IMAGE_OPTIONS: -march=compatibility
Error: Image build request for 'limine-entry-tool' (pid: 60485, path: /home/iclhc/.cache/paru/clone/limine-mkinitcpio-hook/src/limine-entry-tool/build/native/nativeCompile) failed with exit status 30

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':nativeCompile'.
> Process 'command '/home/iclhc/.cache/paru/clone/limine-mkinitcpio-hook/src/graalvm_ce_jdk25/bin/native-image'' finished with non-zero exit value 30

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights from a Build Scan (powered by Develocity).
> Get more help at https://help.gradle.org.

BUILD FAILED in 845ms
5 actionable tasks: 4 executed, 1 up-to-date
==> ERROR: A failure occurred in build().
    Aborting...
error: failed to build 'limine-mkinitcpio-hook-1.30.0-1':
error: packages failed to build: limine-mkinitcpio-hook-1.30.0-1
```

安装 `limine-mkinitcpio-hook`

```
paru -S limine-mkinitcpio-hook
```

复制一份默认配置文件，然后编辑

```
sudo cp /etc/limine-entry-tool.conf /etc/default/limine
```

编辑 `/etc/default/limine`，填入和上面手动配置一样的参数

```
KERNEL_CMDLINE[default]=rd.luks.name=43e02f28-bc3c-4af6-9b5a-94f7886d63ce=cryptsystem root=/dev/mapper/cryptsystem rootflags=subvol=@ rootfstype=btrfs rw splash quiet
```

然后运行 `limine-install` 安装

```
sudo limine-install
```

## 后安装（post-install）

##### 美化启动画面（Plymouth）

安装 Plymouth

> [!NOTE]
>
> https://wiki.archlinux.org/title/Plymouth

```
pacman -S plymouth
```

添加内核参数 `quite splash`

```
KERNEL_CMDLINE[default]+="splash quiet"
```

添加 plymouth 钩子

```
HOOKS=(... plymouth ...)
```

如果你正在使用 `systemd` 钩子，它必须在 `plymouth` 之前。

如果你的系统使用 dm-crypt 加密，请确保在 `encrypt` 或 `sd-encrypt` 钩子之前放置 `plymouth`。

最后，[ 重新生成 initramfs](https://wiki.archlinux.org/title/Regenerate_the_initramfs)。

```
limine-mkinitcpio
```

### 安装 paru（AUR helper）

```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

### 系统快照（Snapper）

> Snapper：https://wiki.archlinux.org/title/Snapper

安装 snapper

```
pacman -S snapper
```

> [!NOTE]
>
> 使用建议的布局
>
> > [!warning]
> >
> > Snapper 默认的行为是当为 `/` 创建配置时，会其下创建一个`.snapshots` 子卷，并将其挂载到 `/.snapshots`。所以需要先卸载之前手动创建的子卷，并删除挂载目录。否则 Snapper 会提示无法创建，因为已经存在子卷。后面只需要删除 Snapper 创建的默认子卷，并将我们手动创建的子卷挂载到 `/.snapshots` 即可。

```
# umount /.snapshots
# rm -r /.snapshots
```

为 `/` 创建一个配置

```
sudo snapper -c root create-config /
```

删除 Snapper 自动创建的子卷

```
sudo btrfs subvolume delete /.snapshots
```

重新创建目录

```
sudo mkdir /.snapshots
```

挂载快照卷

```
sudo mount /.snapshots/
```

安装 cron，自动启用时间线快照

> [!NOTE]
>
> https://wiki.archlinux.org/title/Cron

```
pacman -S cronie
```

快照管理

+ 列出快照配置：`snapper list-configs`
+ 列出配置下的快照：`snapper -c config list`
+ 手动创建快照：`snapper -c config create --description desc`
+ 手动创建快照（并设置自动清理算法 `number`、`timeline`、`pre` 或 `post`）

#### 和 Pcaman 集成

pacman 安装软件前后自动拍摄快照

```
sudo pacman -S snap-pac
```

#### 和 Limine 集成

> https://wiki.archlinux.org/title/Limine#Snapper_snapshot_integration_for_Btrfs

> [!NOTE]
>
> 配置以下内容：
>
> + 指定 ROOT_SUBVOLUME_PATH 为你的根子卷路径。大多数情况下，默认值为 /@。
> + 指定 ROOT_SNAPSHOTS_PATH 为你的根快照路径。 默认值为 /@/.snapshots，这是根子卷 /@ 的标准 Snapper 布局。
> + MAX_SNAPSHOT_ENTRIES 限制快照启动项的数量，或使用`auto`。在`auto`模式下，当创建带有新内核版本的新快照项且达到`LIMIT_USAGE_PERCENT`时，较旧的快照启动项会被移除，且不会发出警告。
>
> 在 `/etc/default/limine` 新增如下配置
>
> ```
> ROOT_SUBVOLUME_PATH=/@
> ROOT_SNAPSHOTS_PATH=/@snapshots
> MAX_SNAPSHOT_ENTRIES=50
> ```

```
paru -S limine-snapper-sync
```

给快照创建启动项

```
sudo limine-snapper-sync
```

自动同步 Snapper 和 Limine 启动项

```
systemctl enable --now limine-snapper-sync.service
```

> [!NOTE]
>
> 使得只读快照可以写，就像 LiveCD 环境
>
> 编辑 `/etc/mkinitcpio.conf` 添加 `sd-btrfs-overlayfs` 钩子（放在 `filesystems` 之后）
>
> ```
> HOOKS=(base systemd autodetect microcode modconf kms keyboard keymap sd-vconsole block sd-encrypt filesystems sd-btrfs-overlayfs fsck)
> ```
>
> 更新 initramfs
>
> ```
> sudo limine-mkinitcpio
> ```

### NVIDIA 显卡驱动

#### 确认显卡型号

> https://wiki.archlinux.org/title/NVIDIA

查看显卡代号和型号

> 这个页面有型号和代号对应的表格：https://nouveau.freedesktop.org/CodeNames.html

```
[arch@archlinux ~]$ lspci -k -d ::03xx
05:00.0 VGA compatible controller: NVIDIA Corporation AD104 [GeForce RTX 4070 SUPER] (rev a1)
	Subsystem: Micro-Star International Co., Ltd. [MSI] Device 5138
	Kernel modules: nouveau
```

然后根据下面表格选择 NVIDIA 驱动，4070s 的代码是 `AD104` 对应表格前两行

|                          GPU family                          |                            Driver                            |                            Status                            |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| [Blackwell (GBXXX)](https://en.wikipedia.org/wiki/Blackwell_(microarchitecture)) and newer | [nvidia-open](https://archlinux.org/packages/?name=nvidia-open) for [linux](https://archlinux.org/packages/?name=linux) [nvidia-open-lts](https://archlinux.org/packages/?name=nvidia-open-lts) for [linux-lts](https://archlinux.org/packages/?name=linux-lts) [nvidia-open-dkms](https://archlinux.org/packages/?name=nvidia-open-dkms) for any kernel(s) | [Recommended by upstream](https://developer.nvidia.com/blog/nvidia-transitions-fully-towards-open-source-gpu-kernel-modules/) Current, supported1 |
| [Turing (NV160/TUXXX)](https://nouveau.freedesktop.org/CodeNames.html#NV160) through [Ada Lovelace (NV190/ADXXX)](https://nouveau.freedesktop.org/CodeNames.html#NV190) | Supported both by:[nvidia-open](https://archlinux.org/packages/?name=nvidia-open) with no [RTD3 Power Management](https://wiki.archlinux.org/title/PRIME#PCI-Express_Runtime_D3_(RTD3)_Power_Management) on Turing2, possible crashes on Ampere-equiped laptops2[nvidia-580xx-dkms](https://aur.archlinux.org/packages/nvidia-580xx-dkms/)AUR |                                                              |
| [Maxwell (NV110/GMXXX)](https://nouveau.freedesktop.org/CodeNames.html#NV110) through [Volta (NV140/GV100)](https://nouveau.freedesktop.org/CodeNames.html#NV140) | [nvidia-580xx-dkms](https://aur.archlinux.org/packages/nvidia-580xx-dkms/)AUR |                      Legacy, supported                       |
| [Kepler (NVE0/GKXXX)](https://nouveau.freedesktop.org/CodeNames.html#NVE0) | [nvidia-470xx-dkms](https://aur.archlinux.org/packages/nvidia-470xx-dkms/)AUR |                    Legacy, unsupported3,4                    |
| [Fermi (NVC0/GF1XX)](https://nouveau.freedesktop.org/CodeNames.html#NVC0) | [nvidia-390xx-dkms](https://aur.archlinux.org/packages/nvidia-390xx-dkms/)AUR |                                                              |
| [Tesla (NV50/G80-90-GT2XX)](https://nouveau.freedesktop.org/CodeNames.html#NV50) | [nvidia-340xx-dkms](https://aur.archlinux.org/packages/nvidia-340xx-dkms/)AUR |                                                              |
| [Curie (NV40/G70)](https://nouveau.freedesktop.org/CodeNames.html#NV40) and older |                      No longer packaged                      |                                                              |

支持的驱动包括 `nvidia-open`（适用于默认 `linux` 内核）、`nvidia-open-lts`（`linux-lts` 内核）、`nvidia-open-dkms`（适用任意内核比如 `linux-zen`）。

`nvidia-utils` （` lib32-nvidia-utils` 是 32 bit 程序所需的，需要启用 `multilib` 仓库）是驱动的用户空间模块，也需要安装。

#### 安装

##### 默认内核（`linux`）

如果是默认 `linux` 内核

```
pacman -S nvidia-open nvidia-utils
```

##### 任意内核（`dkms`）

如果是其他内核，

先安装 `dkms` 和内核头文件（默认内核的头文件 `linux-headers`，`linux-zen` 的头文件 `linux-zen-headers`）

```
pacman -S dkms linux-headers
```

安装驱动

```
pacman -S nvidia-open-dkms nvidia-utils
```

`dkms` 安装，每次升级驱动都要编译内核模块，安装速度会稍慢。

##### Wayland 支持

> https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting
>
> https://wiki.archlinux.org/title/NVIDIA#Wayland_configuration

需要确保开启 KMS（驱动自从 560.35.03-5 默认开启），下面命令需要返回 `Y`

```
[arch@archlinux ~]$ sudo cat /sys/module/nvidia_drm/parameters/modeset
Y
```

## 自动安装脚本（archinstall）

> https://www.reddit.com/r/archlinux/comments/1ludvte/what_are_the_reasons_people_dislike_the/
>
> https://wiki.archlinux.org/title/Archinstall
>
> https://archinstall.archlinux.page/installing/guided.html

## dotfiles/rice（我的桌面环境）

> https://www.reddit.com/r/unixporn/
>
> https://unixporn.github.io/
>
> [What is a "Linux rice"?](https://www.reddit.com/r/linuxquestions/comments/1m72g7s/what_is_a_linux_rice/)
>
> [Why Linux themes are called “rice”?](https://www.reddit.com/r/linux/comments/1h1zud3/why_linux_themes_are_called_rice/)
>
> [A noob’s guide to Linux Ricing...](https://www.reddit.com/r/linuxquestions/comments/kflzb3/a_noobs_guide_to_linux_ricing/)
>
> [Complete Beginner's Guide to Linux Ricing](https://dev.to/nucleofusion/complete-beginners-guide-to-linux-ricing-4i0e)
>
> https://github.com/fosslife/awesome-ricing

安装 Dank Material Shell



### 中文本地化

> [!NOTE]
>
> https://wiki.archlinux.org/title/Localization
>
> https://wiki.archlinux.org/title/Localization/Simplified_Chinese
>
> https://wiki.archlinux.org/title/Locale

需要修改 `/etc/locale.gen` 文件来设定系统中可以使用的 locale（取消对应项前的注释符号“`#`”即可）：

```
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
```

然后执行 `locale-gen` 命令，便可以在系统中使用这些 locale。

在 `/etc/locale.conf` 里可以设置全局的 LANG locale，根据需要可以设置为中文或英文：

```
LANG=zh_CN.UTF-8
```

`LANG` 这个环境变量代表默认的区域设置

#### 输入法（Fcitx5 + Rime）

> [!NOTE]
>
> https://wiki.archlinuxcn.org/wiki/%E8%BE%93%E5%85%A5%E6%B3%95
>
> https://wiki.archlinuxcn.org/wiki/Fcitx5
>
> https://wiki.archlinuxcn.org/wiki/Rime

### 字体

> https://wiki.archlinux.org/title/Fonts#Chinese,_Japanese,_Korean,_Vietnamese
>
> https://wiki.archlinux.org/title/Font_configuration
>

```
sudo pacman -S adobe-source-han-serif-cn-fonts wqy-zenhei 
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
```

编程和终端字体

```
paru -S ttf-maplemono-nf-cn-unhinted ttf-sarasa-gothic-nerd-fonts
```

### KDE

> [!NOTE]
>
> https://wiki.archlinux.org/title/KDE

### niri + DMS

> [!NOTE]
>
> https://wiki.archlinux.org/title/Niri

> Dank Material Shell：https://danklinux.com/
>
> Niri Docs：https://niri-wm.github.io/niri/
>
> https://news.ycombinator.com/item?id=43342178

## 软件包管理

> https://wiki.archlinux.org/title/Arch_User_Repository#Installing_and_upgrading_packages
>
> https://wiki.archlinux.org/title/Unofficial_user_repositories
>
> https://wiki.archlinux.org/title/Official_repositories
>
> https://wiki.archlinux.org/title/Pacman

镜像源

> https://wiki.archlinux.org/title/Mirrors

```
## China
Server = http://mirrors.163.com/archlinux/$repo/os/$arch
Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
Server = http://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.cqu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.cqu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.hit.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.hit.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.hust.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.hust.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.jcut.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.jcut.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.jlu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.jlu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.jxust.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.jxust.edu.cn/archlinux/$repo/os/$arch
Server = http://mirror.lzu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.nju.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.nju.edu.cn/archlinux/$repo/os/$arch
Server = http://mirror.nyist.edu.cn/archlinux/$repo/os/$arch
Server = https://mirror.nyist.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.qlu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.shanghaitech.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.shanghaitech.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.wsyu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.wsyu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.xjtu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.zju.edu.cn/archlinux/$repo/os/$arch
```

### AUR 助手

> https://wiki.archlinux.org/title/AUR_helpers

+ CLI
  + paru
  + yay
+ TUI
  - Pacsea——一款用Rust编写的快速、便于键盘操作的TUI，用于浏览和安装Arch及AUR软件包。
  - pacseek——一个用于搜索和安装Arch Linux软件包的终端用户界面。
+ GUI
  + Pamac——为Manjaro编写的独立GTK 4（或终端）包管理器，使用libalpm(3)</b0，具有托盘集成功能。
  + Octopi — 用C++编写的Qt 5 pacman包装器。

## 系统维护

> https://wiki.archlinux.org/title/General_recommendations
>
> 

## 我的日用软件

### 怎么找软件

> https://wiki.archlinux.org/title/List_of_applications

### RSS（网络信息聚合）

> https://wiki.archlinux.org/title/List_of_applications/Internet#News,_RSS,_and_blogs

[RSS Hub](https://docs.rsshub.app/)：使用 RSS 聚合一切

+ 客户端
  + [Newsboat](https://newsboat.org/)（TUI）——Ncurses RSS聚合器，其布局和按键绑定与[Mutt](https://wiki.archlinux.org/title/Mutt)电子邮件客户端相似。
  + [Fluent Reader](https://hyliu.me/fluent-reader/)——基于React和Fluent UI构建的现代桌面RSS阅读器。
  + [Newsflash](https://apps.gnome.org/zh-CN/NewsFlash/)——为GNOME桌面设计的现代订阅阅读器。是FeedReader的精神继任者。
  + [Raven](https://ravenreader.app/)——使用VueJS制作的简单桌面RSS阅读器。
  + [RSS Guard](https://github.com/martinrotter/rssguard)——一款基于Qt框架开发的超轻量级RSS和ATOM新闻阅读器。
+ Web 客户端
  + [Tiny Tiny RSS](https://tt-rss.org/)
  + [selfoss](https://selfoss.aditu.de/) 

我的订阅：

+ HackerNews：https://news.ycombinator.com/

### 实用小工具

+ [NeoHtop](https://github.com/Abdenasser/neohtop)

### 虚拟机和容器

> [!NOTE]
>
> 虚拟化：https://en.wikipedia.org/wiki/Virtualization

QEMU/KVM 虚拟机

> https://wiki.archlinux.org/title/KVM
>
> https://wiki.archlinux.org/title/QEMU
>
> https://wiki.archlinux.org/title/Libvirt
>
> https://wiki.archlinux.org/title/QEMU/Guest_graphics_acceleration
>
> https://wiki.archlinux.org/title/Open_vSwitch
>
> https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF

容器 podman/docker

> https://wiki.archlinux.org/title/Docker
>
> https://wiki.archlinux.org/title/Distrobox
>
> https://wiki.archlinux.org/title/Podman

### 显卡直通

> 搜索 NVIDIA vfio mode，发现该问题和 PCI 重置有关
>
> + https://forum.level1techs.com/t/do-your-rtx-5090-or-general-rtx-50-series-has-reset-bug-in-vm-passthrough/228549/34
> + https://www.reddit.com/r/VFIO/comments/1mjoren/any_solutions_for_reset_bug_on_nvidia_gpus/
> + https://www.reddit.com/r/linuxquestions/comments/pd2tiy/gpu_pass_though_for_qemu_kvm/?show=original
> + https://forum.level1techs.com/t/vfio-gpu-reset-problem-with-old-nvidia-8600gt/219653/12
> + https://forum.proxmox.com/threads/nvidia-reset-issues-with-gpu-passthrough.85396/
> + https://www.cloudrift.ai/blog/bug-bounty-nvidia-reset-bug

NVIDIA 显卡直通后如果重启虚拟机，不得不重新启动宿主机才能使用显卡。

# 我的安装脚本

```
 .
├──  dotfiles
│   ├──  setup-localization.sh (输入法/中文字体/Nerdfont/区域)
│   ├──  setup-app.sh (安装常用软件)
│   └──  setup-niri-dms.sh （DankMaterialShell + niri 以及桌面环境有关的包）
├──  minimal-install
│   ├──  config-base-system.sh （基本系统设置/fstab/TimeZone/区域/网络）
│   ├──  setup-base-pkg.sh (基础系统包)
│   ├──  setup-bootloader.sh (Limine 手动配置条目)
│   └──  setup-disk.sh （分区/加密/格式化）
├──  my-archlinux-setup.md
├──  post-install
│   ├──  setup-bootloader-automate.sh （引导条目自动化）
│   ├──  setup-nvidia.sh （NVIDIA 驱动）
│   └──  setup-system-snapshot.sh（时间线快照/Pacman快照/可启动只读快照）
├──  README.md
└──  setup.sh（主脚本，可接收参数和环境变量一键非交互式安装最小系统/后安装/dotfile 设置，或者交互式安装）
```

`minimal-install` 的脚本用于 LiveCD 环境，目的是安装最小可启动系统。执行顺序是：

1. `setup-disk.sh`：磁盘分区和加密。
2. `setup-base-pkg.sh`：安装一些基础包（包括 vim、openssh、手册页、驱动、内核、文件系统工具等和系统运行必备的包），主要是设置镜像站并用 `pacstrap` 安装。 
3. `config-base-system.sh`：最基本的系统设置，包括 root 密码、普通用户（管理员）、时间和区域、网络管理器等
4. `setup-bootloader.sh`：安装引导加载器，这里是手动编写引导配置。由于配置了磁盘加密并使用了 btrfs 文件系统，所以需要配置特殊内核参数。

`post-install` 的脚本用于重启后的系统，进行一些需要 AUR，或者特定于机器的配置。

1. `setup-system-snapshot.sh`：配置 `snapper` 快照，并使用 ArchWiki 的推荐布局。以及和 pacman 的集成 `snap-pac`。和引导加载器的集成在后面配置。
2. `setup-bootloader-automate`：安装 AUR 的工具 `limine-mkinitcpio-hook`，这样只需要在 `/etc/default/limine` 添加内核参数，该工具负责生成引导条目。以及 `limine-snapper-sync` ，这样就可以自动给 `snapper` 快照创建启动条目，当然还需要配置 `mkinitcpio` 钩子 `sd-btrfs-overlayfs` 以便让快照像 LiveCD 一样可写。
3. `setup-nvidia.sh`：检测并安装  NVIDIA 显卡驱动。

`dotfile` 用于设置桌面环境和常用应用。
