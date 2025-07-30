# Dtop - RDK系统监控工具

> **基于 [btop++ v1.0.0](https://github.com/aristocratos/btop) 开发**  
> **原作者：Aristocratos (jakob@qvantnet.com)**  
> **许可证：Apache-2.0**

**Dtop是专为D-Robotics地瓜 RDK系列开发板定制的系统监控工具，在btop的基础上增加了BPU监控等RDK独有功能，旨在为RDK平台提供更强大的系统监控工具**

---

## Jetson有Jtop,Linux有Htop,RDK也有Dtop！

> 作者：SkyXZ
>
> CSDN：[SkyXZ～-CSDN博客](https://blog.csdn.net/xiongqi123123?spm=1000.2115.3001.5343)
>
> 博客园：[SkyXZ - 博客园](https://www.cnblogs.com/SkyXZ)


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Linux系统下有Htop可以作为系统监控，英伟达的Jetson也有第三方的Jtop，咱们RDK虽然也提供了`hrut_somstatus`来查看BPU的使用率，但终归不是很方便，超哥也做了一个[Web_RDK_Performance_Node](https://github.com/WuChao-2024/Web_RDK_Performance_Node)：

![image-20250730203240082](https://img2024.cnblogs.com/blog/3505969/202507/3505969-20250730203244517-348834443.png)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**但是在串口环境下无法快速的查看当前系统资源，于是！！！Dtop闪亮出炉！！！！！！！**目前已适配**RDKS100**和**RDKX5**，可以在这个界面快速的查看BPU等系统资源的占用率，以及可以点击右上角快速切换CPU的调度策略！

![image-20250730203625062](https://img2024.cnblogs.com/blog/3505969/202507/3505969-20250730203629184-2144438723.png)

![0c90626861eea121f2499259b82df63](https://img2024.cnblogs.com/blog/3505969/202507/3505969-20250730203556434-1542110161.png)

![7599e76ec72532bddb202492dfc1c97](https://img2024.cnblogs.com/blog/3505969/202507/3505969-20250730203607530-1953197891.png)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;想要体验仅需：

```bash
# 下载预编译文件
wget https://github.com/your-username/dtop/releases/download/v1.0.0/dtop-arm64-ubuntu22.04.tar.gz
# 解压安装
tar -xzf dtop-arm64-ubuntu22.04.tar.gz
sudo cp dtop /usr/local/bin/
# 即可体验
source ~/.bashrc
dtop
```















