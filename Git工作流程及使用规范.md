---
title: Git工作流程及使用规范
date: 2017-03-07 23:17:17
tags: [git]
---

## Git工作流程

### 分支
+ tags: 用于于生产环境
+ master: 用于测试环境/预演环境, 一般只接受合并请求, 不直接提交
+ testing: 用于测试环境测试 （可选）
+ develop: 用于日常开发主线, 其他分支只能合并到 develop 分支 （可选）
+ feature-xxx: 用于增加一个新功能
+ hotfix-xxx: 用于修复一个紧急bug
+ refact-xxx: 代码重构
+ docs-xxx: 文档修改
+ 每次开发新功能，都应该新建一个单独的分支

### 工作流

+ 贡献代码时,如果项目存在贡献指南，需阅读并遵守**贡献指南**
+ Fork对应的项目, 然后基于develop/master分支, 新建一个分支, 在这个分支上进行开发
+ 开发时应遵守相应的编码规范和Git日志规范, 提交日志应当给出完整扼要的提交信息
+ 开发完毕后, 先在本项目库上合并到develop/master分支, 合并完成之后再PR到原项目库

### Commit message 和 Change log 编写指南

+ Git 每次提交代码，都要写 Commit message（提交说明），否则就不允许提交
+Commit message 遵从 [Angular 规范](http://blog.cheenwe.cn/2016-04-18/git-commit-message/)

#### 安装 Commitizen 来格式化 commit , 使其遵循以上规范
+ 首先注意将`package.json`和`node_modules`加入`.gitignore`文件
+ 全局安装commitizen:  `npm install -g commitizen`
+ 在项目根目录初始化package.json:  `npm init --yes`
+ 项目根目录运行 `commitizen init cz-conventional-changelog --save --save-exact`
+ 每次提交代码时, 用 `git cz` 代替 `git commit`

### Tag

+ 打 tag 时，需要遵守**语义化版本**规范

## 参考资料
+ [Git 使用规范流程](http://www.ruanyifeng.com/blog/2015/08/git-use-process.html)
+ [Commit message 和 Change log 编写指南](http://www.ruanyifeng.com/blog/2016/01/commit_message_change_log.html)
+ [Git commit message 规范](http://blog.cheenwe.cn/2016-04-18/git-commit-message/)
+ [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)
