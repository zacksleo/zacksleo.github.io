---
title: 使用Taro和Typescript进行小程序开发
subtitle: mini-program-develop-by-taro-and-typescript
date: 2018-06-16 22:03:25
tags: Taro, TypeScript, MiniProgram, 小程序
---

## 使用Taro和Typescript进行小程序开发

## 使用指南

在使用 taro 生成 Typescript 模板以后，需要做以下修改：

### 配置 .eslintrc

+ 加入 `"no-undef": 0,` 以解决变量`undefined`的问题
+ 加入 `"react/jsx-filename-extension": [1, { "extensions": [".js", ".jsx"] }]` 以解决 `JSX not allowed in files with extension '.tsx`

### 增加配置文件

+ tsconfig.json
+ tslint 文件

### 增加依赖库

+ yarn add --dev tslint
+ yarn add --dev tslint-react
+ yarn add --dev ptypescript-eslint-parser

## 开始使用

```bash

yarn install

```

## 代码静态检查

```bash
yarn run lint

```

## 参考文档

+ [Taro官方文档](https://taro.aotu.io/)
