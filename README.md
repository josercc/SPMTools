---
typora-root-url: ./images
---

# SPMTools

一款基于SwiftUI构建管理Xcode依赖的图形工具

![image-20211109162717174](image-20211109162717174.png)

## 读取 Xcode 的 Swift Package Manager 的依赖配置

![image-20211109162938462](/../image-20211109162938462.png)

![image-20211109162907571](/../image-20211109162907571.png)

## 删除依赖

![image-20211109163009917](/../image-20211109163009917.png)

## 添加依赖

![image-20211109163035866](/../image-20211109163035866.png)

⚠️此操作还需要通过命令行更新依赖

```shell
xcodebuild -resolvePackageDependencies
```

