---
title: 使用phpmd对PHP项目进行静态代码分析
date: 2017-08-23 09:48:23
tags:
---
## 简介

PHPMD是与PMD类似的静态代码分析工具, 通过分析可以找出潜在的Bug或设计问题, 从而进一步提高代码质量

## 使用

+ 首先通过composer安装phpmd库

```
composer require phpmd/phpmd --dev --prefer-dist 
 
```

+ 运行phpmd命令

```
vendor/bin/phpmd ./ text phpmd.xml --suffixes php

```

phpmd.xml配置如下:

```
<?xml version="1.0"?>
<ruleset name="PHPMD rule set for Yii 2" xmlns="http://pmd.sf.net/ruleset/1.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://pmd.sf.net/ruleset/1.0.0 http://pmd.sf.net/ruleset_xml_schema.xsd"
         xsi:noNamespaceSchemaLocation="http://pmd.sf.net/ruleset_xml_schema.xsd">
    <description>Custom PHPMD settings for naming, cleancode and controversial rulesets</description>

    <rule ref="rulesets/naming.xml/ConstructorWithNameAsEnclosingClass" />
    <rule ref="rulesets/naming.xml/ConstantNamingConventions" />
    <!-- Long variable names can help with better understanding so we increase the limit a bit -->
    <rule ref="rulesets/naming.xml/LongVariable">
        <properties>
            <property name="maximum" value="25" />
        </properties>
    </rule>
    <!-- method names like up(), gc(), ... are okay. -->
    <rule ref="rulesets/naming.xml/ShortMethodName">
        <properties>
            <property name="minimum" value="2" />
        </properties>
    </rule>

    <rule ref="rulesets/cleancode.xml">
        <!-- else is not always bad. Disabling this as there is no way to differentiate between early return and normal else cases. -->
        <exclude name="ElseExpression" />
        <!-- Static access on Yii::$app is normal in Yii -->
        <exclude name="StaticAccess" />
    </rule>

    <rule ref="rulesets/controversial.xml/Superglobals" />
    <rule ref="rulesets/controversial.xml/CamelCaseClassName" />
    <rule ref="rulesets/controversial.xml/CamelCaseMethodName" />
    <rule ref="rulesets/controversial.xml/CamelCaseParameterName" />
    <rule ref="rulesets/controversial.xml/CamelCaseVariableName" />
    <!-- allow private properties to start with $_ -->
    <rule ref="rulesets/controversial.xml/CamelCasePropertyName">
        <properties>
            <property name="allow-underscore" value="true" />
        </properties>
    </rule>
</ruleset>

```

## GitLab-CI 集成

在.gitlab-ci.yml中添加一个任务, 用于执行静态分析, 一个典型的例子:

```
phpmd:
    stage: testing
    dependencies:
        - installing-dependencies
    script:
        - vendor/bin/phpmd api,backend,common,frontend,console text phpmd.xml --exclude console/migrations/ --suffixes php
```

## 参考资料

[Github](https://github.com/phpmd/phpmd)
