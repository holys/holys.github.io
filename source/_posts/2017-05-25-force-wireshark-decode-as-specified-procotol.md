title: Force wireshark decode as specified protocol
date: 2017-05-25 23:09:57
tags:
- wireshark
---

Wireshark 默认支持识别 MySQL 协议，但是当 MySQL 端口不是 3306 时，Wireshark 就不会自动识别了。只需要需要手动选择解析协议。话不多说，见下图。

![5028CC64-8089-438C-9ADD-023EEC48CB16](/images/5028CC64-8089-438C-9ADD-023EEC48CB16.png)

这里我的 MySQL 端口是 20393，选择协议为 MySQL，确定后即可。支持多条规则识别。

![4D70CCF3-5CD9-40D2-AA59-4D8440EAD9A5](/images/4D70CCF3-5CD9-40D2-AA59-4D8440EAD9A5.png)

识别后的效果如下：

![73E734E3-4983-4F5E-B9AE-F3BFC8C490A5](/images/73E734E3-4983-4F5E-B9AE-F3BFC8C490A5-1.png)





