---
title: CodeIgniter项目自动向GitLab上报Bug
date: 2016-10-12 17:48:25
tags: CodeIgniter, GitLab, Bug, 自动化
---

## CI项目自动上报Bug

## 原理

通过重写CI_Exceptions, 当程序出错时, 通过调用GitLab中提交issue的API, 将相关信息自动提交

如果是Yii2项目,见 [Yii自动上报Bug](https://zacksleo.github.io/2016/10/12/Yii2%E9%A1%B9%E7%9B%AE%E8%87%AA%E5%8A%A8%E5%90%91GitLab%E4%B8%8A%E6%8A%A5Bug/)

## 步骤
* 获取项目id和自己的id
可以通过GitLab的project接口, 从中拿到project_id和assignee_id

在此提供一个方法, 给自己提交一个issue, 提交时审查HTML, 可以找到 issue_assignee_id和 data-project-id 

![](http://ww3.sinaimg.cn/large/675eb504gw1fbtdv1gcjcj20oq0d543f.jpg)

* 创建配置文件 config/gitlab.php

```
// to enable, set this to true
$config['gitlab'] = true;
$config['gitlab_project_id'] =xx; //找到项目的id
$config['gitlab_assignee_id'] = xx; //找到自己的id
$config['gitlab_api'] = 'http://demo.com/api/v3/projects/'.$config['gitlab_project_id'].'/issues';
$config['gitlab_private_token'] = 'xxx';
```
* 在项目中添加core/MY_Exceptions

```
<?php if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}

/**
 * Extend exceptions to email me on exception
 *
 * @author Mike Funk
 * @email mfunk@christianpublishing.com
 *
 * @file MY_Exceptions.php
 */

/**
 * MY_Exceptions class.
 *
 * @extends CI_Exceptions
 */
class MY_Exceptions extends CI_Exceptions
{

    // --------------------------------------------------------------------------

    /**
     * extend log_exception to add emailing of php errors.
     *
     * @access public
     * @param string $severity
     * @param string $message
     * @param string $filepath
     * @param int $line
     * @return void
     */
    function log_exception($severity, $message, $filepath, $line)
    {
        $ci =& get_instance();
        $ci->config->load('gitlab');
        if (config_item('gitlab')) {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, config_item('gitlab_api'));
            curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                'PRIVATE-TOKEN: ' . config_item('gitlab_private_token'),
            ));
            curl_setopt($ch, CURLOPT_POSTFIELDS, [
                'title' => $message,
                'description' => '<pre>' . $message . '</pre>',
                'assignee_id' => config_item('gitlab_assignee_id'),
                'labels' => '捕虫器,错误',
            ]);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_VERBOSE, false);
            $response = curl_exec($ch);
            curl_close($ch);
        }

        // do the rest of the codeigniter stuff
        parent::log_exception($severity, $message, $filepath, $line);
    }

    // --------------------------------------------------------------------------

    /**
     * replace short tags with values.
     *
     * @access private
     * @param string $content
     * @param string $severity
     * @param string $message
     * @param string $filepath
     * @param int $line
     * @return string
     */
    private function _replace_short_tags($content, $severity, $message, $filepath, $line)
    {
        $content = str_replace('{{severity}}', $severity, $content);
        $content = str_replace('{{message}}', $message, $content);
        $content = str_replace('{{filepath}}', $filepath, $content);
        $content = str_replace('{{line}}', $line, $content);

        return $content;
    }

    // --------------------------------------------------------------------------
}

```
