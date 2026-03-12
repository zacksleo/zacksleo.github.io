

找到 PowerShell ，以管理员身份运行

 ![alt text](/images/2026/03/image-3.png)


输入以下命令，允许脚本执行

```Powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

输入以下命令，安装 OpenClaw：

```Powershell
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -Tag beta
```

![alt text](/images/2026/03/image-2.png)