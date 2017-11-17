---
title: 使用Composer创建公共类库
date: 2017-07-20 09:33:12
tags:
---

## 概述

如果多个项目中存在使用相同类库、模块的情况，此时可以考虑将类库或者模块单独抽取出来，形成独立类库，通过composer
来进行依赖管理，这样可以更方便维护，大大提升开发效率。

## 优势

+ 可以对特定模块进行统一维护和升级
+ 特定的类库可由专人进行维护，保证稳定性和可靠性
+ 避免了重复开发的情况

## 步骤

### 本地开发

为了方便调试，可先在本地现有项目中开发类库，等到开发完成后，再将相关代码单独抽取出来。

+  首先在项目中创建一个存放类库的目录，如`packages/zacksleo/my-libs`,

其中`packages`是类库总目录， `zacksleo`是用户名，相当于命名空间的第一级，`my-libs`是类库存放目录。

+  在目录中创建`composer.json` 文件，并添加形如以下的内容：

```
{
  "name": "zacksleo/my-libs",
  "description": "my libs",
  "type": "library",
  "license": "MIT",
  "authors": [
    {
      "name": "zacksleo",
      "email": "zacksleo@gmail.com"
    }
  ],
  "minimum-stability": "stable",
  "autoload": {
    "psr-4": {
      "zacksleo\\my\\libs\\": "src"
    }
  }
}

```
其中，`name`是类库名称，`descrption`是详细说明，`type`是类别，`license`是使用的协议，`authers`是作者信息，

`minimum-stability` 用来声明最小依赖，通常有`dev`和 `stable`可选，`autoload`中的`psr-4`声明了

命名空间和对应的目录，注意命名空间就当使用双反斜杠，目录使用相对路径，此外声明了目录为`src``目录

+  在`src`目录中添加相关代码，其中的类使用命名空间`zacksleo\\my\\libs`

+  在项目的`composer.json`中，通过`path`方式引入本地类库，如可在`repositories`中添加如下信息：

```
  "repositories": {
    "my-libs": {
      "type": "path",
      "url": "packages/zacksleo/my-libs"
    }
  }

```
其中`my-libs`是别名，可任意填写，`type`设置成`path`, `url`为类库所在的相对路径（与composer.json文件相对）

+  通过`composer require`命令或者在`composer.json`中的`require`部分添加声音，来实现依赖加载，如

`composer require zacksleo/my-libs`


### 在Github上创建库并上传代码

当在本地开发完成后，可将类库独立抽取出来（此处的`my-libs`目录下的内容），并提交到Github上新建的仓库中

### 配置packagist并发布

1. 先在packagist.org中注册好账号，以便发布包。
2. 在Github的仓库中，点击`settings`，找到 `Intergrations & services`, 点击`Add servies`, 选择`Packagist`,

填写在packagist.org注册的用户名和Token(在[Profile](https://packagist.org/profile/)中找到Your API Token)

点击确定添加，这样，每次Github的变动，都会自动更新到packagist上，免去了手动更新的麻烦

### 本地依赖改成线上版本, 并清除开发代码

类库一经发布到packagist上后，就可将本地项目`composer.json`添加的`repositories`移除，重新运行`composer install`，

来安装packagist上的版本，同时`packages` 目录亦可删除。

## 版本问题说明

composer使用语义化的版本进行依赖管理，因此类库在更新和发布时，所标记的版本号，也就当遵循[语义化的版本规范](http://semver.org/lang/zh-CN/)。

基主要有以下几个内容：

版本格式：主版本号.次版本号.修订号，版本号递增规则如下：

1. 主版本号：当你做了不兼容的 API 修改，
2. 次版本号：当你做了向下兼容的功能性新增，
3. 修订号：当你做了向下兼容的问题修正。
4. 先行版本号及版本编译信息可以加到“主版本号.次版本号.修订号”的后面，作为延伸。

## 参考资料

+ [Composer中文文档](http://docs.phpcomposer.com/)
+ [语义化的版本规范](http://semver.org/lang/zh-CN/)