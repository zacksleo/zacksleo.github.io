---
title: Codeception中如何使用Fixtures优化测试
subtitle: how-to-use-fixtures-in-codeception
date: 2017-08-22 09:25:26
tags: [codeception]
---

## 简介

Fixtures 是测试中非常重要的一部分。主要目的是建立一个固定/已知的环境状态以确保 测试可重复并且按照预期方式运行。

简答说就是Fixtures提供一种预填充数据的方式，即在测试前需要准备好哪些数据，以便测试可以正常展开，不受其他测试的影响。


一个 Fixture 可能依赖于其他的 Fixtures ，所定义的依赖会自动加载。

该方法相比于`dump.sql`的填充方法更加灵活, 且不会出去填充的冲突问题.

## 配置


### 定义一个Fixtures


通过继成`yii\test\ActiveFixture`, 并声明 `modelClass` 来定义一个Fixtures , `depends`为要依赖的Fixtures, 可选。

Fixtures通常放置于`tests`目录中的`fixtures`目录下.

```
<?php
namespace tests\fixtures;

use yii\test\ActiveFixture;

class UserFixture extends ActiveFixture
{
    public $modelClass = 'app\models\User';
    public $depends = ['app\tests\fixtures\UserFixture'];
}

```

### 设置填充数据

在 `@tests/fixtures/data`目录中,每个Fixtures添加一个数据文档

在位置 `@tests/fixtures/data/user.php` 中, 设置以下数据, 为要被插入用户表中的数据文件, `user1`和`user2`为别名, 方便调用

```
<?php
return [
    'user1' => [
        'username' => 'lmayert',
        'email' => 'strosin.vernice@jerde.com',
        'auth_key' => 'K3nF70it7tzNsHddEiq0BZ0i-OU8S3xV',
        'password' => '$2y$13$WSyE5hHsG1rWN2jV8LRHzubilrCLI5Ev/iK0r3jRuwQEs2ldRu.a2',
    ],
    'user2' => [
        'username' => 'napoleon69',
        'email' => 'aileen.barton@heaneyschumm.com',
        'auth_key' => 'dZlXsVnIDgIzFgX4EduAqkEPuphhOh9q',
        'password' => '$2y$13$kkgpvJ8lnjKo8RuoR30ay.RjDf15bMcHIF7Vz1zz/6viYG5xJExU6',
    ],
];
```


## 使用


在测试用例中, 通过定义`_fixtures方法`, 声明需要使用的Fixtures及填充数据文件

```

    /**
     * @var \UnitTester
     */
    protected $tester;

    public function _fixtures()
    {
        return [
            'users' => [
                'class' => UserFixture::className(),
                'dataFile' => '@tests/fixtures/data/user.php'
            ],
            'profiles' => [
                'class' => UserProfileFixture::className(),
                'dataFile' => '@tests/fixtures/data/user_profile.php'
            ],
        ];
    }

```

通过如下方法, 可以获取插入的记录, 返回值为该Fixture类中对应的`modelClass`的一个实例

```
$user = $this->tester->grabFixture('users', 'default');

```


## 参考资料

[Fixtures](http://www.yiichina.com/doc/guide/2.0/test-fixtures)
[Fixtures](http://www.yiiframework.com/doc-2.0/guide-test-fixtures.html)

