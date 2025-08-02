# Jetson有Jtop,Linux有Htop,RDK也有Dtop！

> 作者：SkyXZ
>
> CSDN：[SkyXZ～-CSDN博客](https://blog.csdn.net/xiongqi123123?spm=1000.2115.3001.5343)
>
> 博客园：[SkyXZ - 博客园](https://www.cnblogs.com/SkyXZ)
>
> 本项目基于[btop](https://github.com/aristocratos/btop)开源项目进行二次开发，旨在为RDK平台提供更强大的系统监控工具。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Linux系统下有Htop可以作为系统监控，英伟达的Jetson也有第三方的Jtop，咱们RDK虽然也提供了`hrut_somstatus`来查看BPU的使用率，但终归不是很方便，超哥也做了一个[Web_RDK_Performance_Node](https://github.com/WuChao-2024/Web_RDK_Performance_Node)：

![image-20250730203240082](https://img2024.cnblogs.com/blog/3505969/202507/3505969-20250730203244517-348834443.png)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**但是在串口环境下无法快速的查看当前系统资源，于是！！！Dtop闪亮出炉！！！！！！！**目前已适配**RDKS100**和**RDKX5**，可以在这个界面快速的查看BPU等系统资源的占用率，以及可以点击右上角快速切换CPU的调度策略！

![image-20250730203625062](https://img2024.cnblogs.com/blog/3505969/202507/3505969-20250730203629184-2144438723.png)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;想要体验仅需如下命令：

```bash
# 下载预编译文件
wget https://github.com/xiongqi123123/dtop/releases/download/v1.1.0/dtop-arm64-ubuntu22.04.tar.gz
# 解压安装
tar -xzf dtop-arm64-ubuntu22.04.tar.gz
sudo cp dtop /usr/local/bin/
# 即可体验
source ~/.bashrc
dtop
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;目前V1.1.0版本已实现RDKS100和RDKX5上BPU、GPU、VPU、JPU的使用率监控，以及S100Main和MCU域的温度监控；下一个版本将实现完整的内存分配显示以及RDK信息的展示

![image-20250802204402978](https://img2024.cnblogs.com/blog/3505969/202508/3505969-20250802204405140-1529566624.png)

![image-20250802204636895](https://img2024.cnblogs.com/blog/3505969/202508/3505969-20250802204638778-230886562.png)









