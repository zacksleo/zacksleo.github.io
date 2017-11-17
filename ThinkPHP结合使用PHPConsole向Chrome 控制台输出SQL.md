---
title: ThinkPHP结合使用PHP Console向Chrome 控制台输出SQL
date: 2013-12-16 15:16:39
tags: ThinkPHP, Chrome, Console, SQL
---

+ 在Chrome中安装PHP Console 插件
+ 下载PHP Console 服务器端程序包到ThinkPHP的Vendor目录下
例如 `/ThinkPHP/Extend/Vendor/PhpConsole`

+ 编写Behaviour行为类PhpConsoleBehavior.class

```

<?php
/*
 * 程序初始化时，在DEBUG模式下自动导入PHP Console类并进行实例化
 * PHP console for chrome degug tools
 * @author zacksleo
 */
class PhpConsoleBehavior extends Behavior{

  protected $options = array(
      'PHP_CONSOLE' => false,
  );

  public function run(&$params){
    if(C('PHP_CONSOLE')){
      if(APP_DEBUG){
        vendor('PhpConsole.__autoload');  //导入文件
        PhpConsole\Helper::register();  //注册，自动实例化
        $connector = PhpConsole\Connector::getInstance();
        $connector->setPassword('password');
        $handler = PhpConsole\Handler::getInstance();
        // 输出PHP错误和异常            
        $handler->start(); 
        // 配置 eval provider（在Chrome中远程执行PHP），如果不使用，则不配置
        $evalProvider = $connector->getEvalDispatcher()->getEvalProvider();
        $evalProvider->setOpenBaseDirs(array(__DIR__)); 
        // 必须最后调用
        $connector->startEvalRequestsListener(); 
      }
    }
  }
}
?>         
```
              
+ 在/App/Conf/tags.php 中配置标签位:'app_init' => array('PhpConsole'),
+ 在config.php文件中定义标签'PHP_CONSOLE' => true,
+ 修改ThinkPHP的Log.class文件（位于/ThinkPHP/Lib/Core/Log.class.php）中的recode方法如下

```       
  static function record($message, $level = self::ERR, $record = false){
    //zacksleo   
    if($level == self::SQL){
      PC::debug($message, 'SQL');
    }
    //zacksleo
    if($record || false !== strpos(C('LOG_LEVEL'), $level)){
      self::$log[] = "{$level}: {$message}\r\n";
    }
  }
    
```