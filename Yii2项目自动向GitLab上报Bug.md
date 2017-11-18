---
title: Yii2项目自动向GitLab上报Bug
date: 2016-10-12 17:47:20
tags: [Yii2, GitLab]
---

# Yii2 项目自动上报Bug

## 原理
  yii2在程序报错时, 会执行指定action, 通过重写ErrorAction, 实现Bug自动提交至GitLab的issue

## 步骤

* 配置SiteController中的actions方法

```
    public function actions()
    {
        return [
            'error' => [
                'class' => 'app\helpers\web\ErrorAction',
            ],
        ];
    }
```
* 重写ErrorAction, 位于app\helpers\web\ErrorAction, 并修改常量URL,PRIVATE_TOKEN和ASSIGNEE_ID

如何获取project_id和assignee_id见 [WIKI](https://zacksleo.github.io/2017/10/12/CI%E9%A1%B9%E7%9B%AE%E8%87%AA%E5%8A%A8%E5%90%91GitLab%E4%B8%8A%E6%8A%A5Bug/) 

```
namespace app\helpers\web;

use yii;
use yii\base\Action;
use yii\base\Exception;
use yii\base\UserException;
use yii\web\HttpException;

class ErrorAction extends \yii\web\ErrorAction
{
    const URL = '{host}/api/v3/projects/{project_id}/issues'; // host替换为主机地址, project_id为项目id
    const PRIVATE_TOKEN = 'tD3Te-ctECeGwEHH7-ec';
    const ASSIGNEE_ID = 21;

    public function run()
    {
        if (($exception = Yii::$app->getErrorHandler()->exception) === null) {
            $exception = new HttpException(404, Yii::t('yii', 'Page not found.'));
        }

        if ($exception instanceof HttpException) {
            $code = $exception->statusCode;
        } else {
            $code = $exception->getCode();
        }
        if ($exception instanceof Exception) {
            $name = $exception->getName();
        } else {
            $name = $this->defaultName ?: Yii::t('yii', 'Error');
        }
        $preCode = $code;
        if ($code) {
            $name .= " (#$code)";
        }

        if ($exception instanceof UserException) {
            $message = $exception->getMessage();
        } else {
            $message = $this->defaultMessage ?: Yii::t('yii', 'An internal server error occurred.');
        }
        if ($code != '404') {
            //自动向GitLab提交Bug
            $url = self::URL;
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                'PRIVATE-TOKEN: '.self::PRIVATE_TOKEN,
            ));

            curl_setopt($ch, CURLOPT_POSTFIELDS, [
                'title' => $message,
                'description' => '<blockquote>'.Yii::$app->request->getReferrer().'</blockquote>'. '<blockquote>' . Yii::$app->request->absoluteUrl . '</blockquote><br/><pre>' . $exception . '</pre>',
                'assignee_id' => self::ASSIGNEE_ID,
                'labels' => '捕虫器,' . $name,
            ]);
            curl_setopt($ch, CURLOPT_HEADER, false);
            // Pass TRUE or 1 if you want to wait for and catch the response against the request made
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            // For Debug mode; shows up any error encountered during the operation
            curl_setopt($ch, CURLOPT_VERBOSE, false);
            $response = curl_exec($ch);
            curl_close($ch);
        }
        if (Yii::$app->getRequest()->getIsAjax() || strpos($_SERVER['REQUEST_URI'], '/api/') > -1) {
            \Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
            return [
                'message' => $message
            ];
        } else {
            return $this->controller->render($this->view ?: $this->id, [
                'name' => $name,
                'message' => $message,
                'exception' => $exception,
            ]);
        }
    }
}
```