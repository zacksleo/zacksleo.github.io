---
title: 服务端实现阿里云OSS直传
date: 2025-07-10 17:03:10
tags: [Python, 阿里云, OSS]
---

## 介绍

阿里云上传 OSS 有两种方式，一种是普通上传，一种是客户端直传。

1. 普通上传，就是需要先将文件上传到服务端，然后调用接口将文件上传到阿里云。

当然这种方案经常出现不合理的使用方式，即客户端充当服务端的角色，在本地直接通过AK/SK，调用阿里云接口上传文件。

不建议客户端直接这样做，一旦AK/SK泄露，存在很大的安全隐患，有可能被盗用。

2. 客户端直传

通过服务器下发上传令牌，客户端通过使用临时令牌，直接上传到阿里云 OSS。

这种是最佳方案，不仅安全，而且不占用服务器带宽，传输速度快。

接下来，本文围绕这种方案介绍如何实现，并以 Python 语言为例，其他语言的实现类似，可以从[参考文档](https://help.aliyun.com/zh/oss/use-cases/obtain-signature-information-from-the-server-and-upload-data-to-oss)下载相应的 Demo

## 配置权限

### 创建用户并生成 AK，SK

这里建议专门为 API 调用创建一个用户，然后生成AK，SK，记录好AK，SK以便后续使用，并授予权限。

点击权限管理，添加 `AliyunSTSAssumeRoleAccess` (调用STS服务AssumeRole接口的权限)

![alt text](/images/2025/07/13/oss-upload.png)

### 创建角色

创建一个角色，创建成功后，记录角色的 ARN，后面代码中会用到，为了方便演示，这里将角色命名为：`ramossuploadonly`

![alt text](image-1.png/images/2025/07/13/oss-upload-1.png)


### 添加权限策略

导航栏找到权限策略，点击创建，点击“脚本编辑”, 在文本框中输入以下内容，将 `<Bucket名称>` 替换成自己的 Bucket 名称，然后点击保存,

例如，bucket 名称为 `oss-upload-demo`，则 Resource 填写为 `"acs:oss:*:*:oss-upload-demo/*"`

```
{
  "Version": "1",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "oss:PutObject",
      "Resource": "acs:oss:*:*:<Bucket名称>/*"
    }
  ]
}
```

点击保存，例如可将名称命名为 `oss-upload-policy`

### 为角色授权

回到刚刚添加的角色 `ramossuploadonly`，点击新增授权，从权限策略中搜索刚刚添加的 `oss-upload-policy`，点击确认新增授权。


这样权限就配置完成了。

## 创建 bucket


打开对象存储 OSS，点击创建 Bucket，在弹窗中输入 bucket 名称

![alt text](/images/2025/07/13/oss-upload-3.png)

需要注意的是，需要记住这里的选择地域，后面代码中会用到，OSS上传需要指定地域，本文中选择`北京`。

## 编写代码


### 安装依赖

主要用到以下的依赖包, requirements.txt 文件内容如下

```
Flask
alibabacloud-credentials
alibabacloud-tea-openapi
alibabacloud-sts20150401
oss2
```

使用 pip 安装：

```
pip install -r requirements.txt
```

### 创建 main.py 文件



基于官方 demo，主要修改以下内容：


```python
access_key_id = '###AK###'
access_key_secret = '###SK###'
role_arn_for_oss_upload = '###acs:ram::19920XXX5721:role/roleoss###'

# 自定义会话名称
role_session_name = 'yourRoleSessionName'

# 替换为实际的bucket名称、region_id、host
bucket = ' oss-upload-demo'
region_id = 'cn-beijing'
host = 'http://oss-upload-demo.oss-cn-beijing.aliyuncs.com'
```


这里 access_key_id, access_key_secret 为最开始创建用户后，拿到的 AK，SK 的值，替换成相应的内容。

role_arn_for_oss_upload 为创建的 RAM 角色`ramossuploadonly`时，拿到的 ARN，可以打开角色详情找到ARN。


bucket 为自己创建的 bucket 名称，本示例中为 oss-upload-demo
region_id 为 bucket 所在的区域，本示例中为 cn-beijing
host 为 bucket 的访问地址，本示例中为 http://oss-upload-demo.oss-cn-beijing.aliyuncs.com, 根据不同的区域，访问地址不同，可以通过[OSS地域和访问域名](https://help.aliyun.com/zh/oss/user-guide/regions-and-endpoints), 找到 bucket 对应地域的访问域名，选择外网 Endpoint

![alt text](imag/images/2025/07/13/oss-upload-2.png)


> 需要注意的是，官方 demo 中，需要全搜索 cn-hangzhou, 替换掉 bucket 地域的 ID

完整内容如下：


```python
from flask import Flask, render_template, jsonify, request
from alibabacloud_tea_openapi.models import Config
from alibabacloud_sts20150401.client import Client as Sts20150401Client
from alibabacloud_sts20150401 import models as sts_20150401_models
import os
import json
import base64
import hmac
import datetime
import time
import hashlib

import oss2

app = Flask(__name__)

# 配置环境变量 OSS_ACCESS_KEY_ID, OSS_ACCESS_KEY_SECRET, OSS_STS_ROLE_ARN
# access_key_id = os.environ.get('OSS_ACCESS_KEY_ID')
# access_key_secret = os.environ.get('OSS_ACCESS_KEY_SECRET')
# role_arn_for_oss_upload = os.environ.get('OSS_STS_ROLE_ARN')

access_key_id = '###AK###'
access_key_secret = '###SK###'
role_arn_for_oss_upload = '###acs:ram::19920XXX5721:role/roleoss###'

# 自定义会话名称
role_session_name = 'yourRoleSessionName'

# 替换为实际的bucket名称、region_id、host
bucket = ' oss-upload-demo'
region_id = 'cn-beijing'
host = 'http://oss-upload-demo.oss-cn-beijing.aliyuncs.com'

# 指定过期时间，单位为秒
expire_time =  1000

# 指定上传到OSS的文件前缀
upload_dir = 'dir'

def hmacsha256(key, data):
    """
    计算HMAC-SHA256哈希值的函数
    :param key: 用于计算哈希的密钥，字节类型
    :param data: 要进行哈希计算的数据，字符串类型
    :return: 计算得到的HMAC-SHA256哈希值，字节类型
    """
    try:
        mac = hmac.new(key, data.encode(), hashlib.sha256)
        hmacBytes = mac.digest()
        return hmacBytes
    except Exception as e:
        raise RuntimeError(f"Failed to calculate HMAC-SHA256 due to {e}")

@app.route("/")
def hello_world():
    return render_template('index.html')

@app.route('/get_post_signature_for_oss_upload', methods=['GET'])
def generate_upload_params():
    # 初始化配置，直接传递凭据
    config = Config(
        region_id=region_id,
        access_key_id=access_key_id,
        access_key_secret=access_key_secret
    )

    # 创建 STS 客户端并获取临时凭证
    sts_client = Sts20150401Client(config=config)
    assume_role_request = sts_20150401_models.AssumeRoleRequest(
        role_arn=role_arn_for_oss_upload,
        role_session_name=role_session_name
    )
    response = sts_client.assume_role(assume_role_request)
    token_data = response.body.credentials.to_map()

    # 使用 STS 返回的临时凭据
    temp_access_key_id = token_data['AccessKeyId']
    temp_access_key_secret = token_data['AccessKeySecret']
    security_token = token_data['SecurityToken']

    now = int(time.time())
    # 将时间戳转换为datetime对象
    dt_obj = datetime.datetime.utcfromtimestamp(now)
    # 在当前时间增加3小时，设置为请求的过期时间
    dt_obj_plus_3h = dt_obj + datetime.timedelta(hours=3)

    # 请求时间
    dt_obj_1 = dt_obj.strftime('%Y%m%dT%H%M%S') + 'Z'
    # 请求日期
    dt_obj_2 = dt_obj.strftime('%Y%m%d')
    # 请求过期时间
    expiration_time = dt_obj_plus_3h.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    # 定义回调参数Base64编码函数。
    def encode_callback(callback_params):
        cb_str = json.dumps(callback_params).strip()
        return oss2.compat.to_string(base64.b64encode(oss2.compat.to_bytes(cb_str)))

    # 构建回调配置并 Base64 编码
    callback_config = {
        "callbackUrl": "http://x.x.x.x/images/callback",  # 替换为您的回调服务器地址
        "callbackBody": "bucket=${bucket}&object=${object}&etag=${etag}&size=${size}",
        "callbackBodyType": "application/x-www-form-urlencoded"
    }
    encoded_callback = encode_callback(callback_config)
    # 构建 Policy 并生成签名
    policy = {
        "expiration": expiration_time,
        "conditions": [
            ["eq", "$success_action_status", "200"],
            {"x-oss-signature-version": "OSS4-HMAC-SHA256"},
            {"x-oss-credential": f"{temp_access_key_id}/{dt_obj_2}/{region_id}/oss/aliyun_v4_request"},
            {"x-oss-security-token": security_token},
            {"x-oss-date": dt_obj_1},
        ]
    }
    policy_str = json.dumps(policy).strip()

    # 步骤2：构造待签名字符串（StringToSign）
    stringToSign = base64.b64encode(policy_str.encode()).decode()

    # 步骤3：计算SigningKey
    dateKey = hmacsha256(("aliyun_v4" + temp_access_key_secret).encode(), dt_obj_2)
    dateRegionKey = hmacsha256(dateKey, region_id)
    dateRegionServiceKey = hmacsha256(dateRegionKey, "oss")
    signingKey = hmacsha256(dateRegionServiceKey, "aliyun_v4_request")

    # 步骤4：计算Signature
    result = hmacsha256(signingKey, stringToSign)
    signature = result.hex()

    # 组织返回数据
    response_data = {
        'policy': stringToSign,  # 表单域
        'x_oss_signature_version': "OSS4-HMAC-SHA256",  # 指定签名的版本和算法，固定值为OSS4-HMAC-SHA256
        'x_oss_credential': f"{temp_access_key_id}/{dt_obj_2}/cn-beijing/oss/aliyun_v4_request",  # 指明派生密钥的参数集
        'x_oss_date': dt_obj_1,  # 请求的时间
        'signature': signature,  # 签名认证描述信息
        'host': host,
        'dir': upload_dir,
        'security_token': security_token,  # 安全令牌
        #'callback': encoded_callback   # 返回 Base64 编码的回调配置
    }

    return jsonify(response_data)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8000)  # 如果需要监听其他地址如0.0.0.0，需要您自行在服务端添加认证机制
```


这里下载好官方给出的 [Demo](https://help-static-aliyun-doc.aliyuncs.com/file-manage-files/zh-CN/20250324/gibqnq/server-signed-direct-upload-python.zip?spm=a2c4g.11186623.0.0.bdc82235x6PMIt&file=server-signed-direct-upload-python.zip)


### 创建 html 页面


在项目中创建目录 templates，然后创建一个 index.html 文件，内容为：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>服务端生成签名上传文件到OSS</title>
</head>
<body>
<div class="container">
    <form>
        <div class="mb-3">
            <label for="file" class="form-label">选择文件:</label>
            <input type="file" class="form-control" id="file" name="file" required />
        </div>
        <button type="submit" class="btn btn-primary">上传</button>
    </form>
    <div id="callback-info" class="mt-3" style="display: none;">
        <h4>回调信息:</h4>
        <pre id="callback-content"></pre>
    </div>
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function () {
    const form = document.querySelector("form");
    const fileInput = document.querySelector("#file");
    const callbackInfo = document.querySelector("#callback-info");
    const callbackContent = document.querySelector("#callback-content");

    form.addEventListener("submit", (event) => {
        event.preventDefault();

        const file = fileInput.files[0];

        if (!file) {
            alert('请选择一个文件再上传。');
            return;
        }

        const filename = file.name;

        fetch("/get_post_signature_for_oss_upload", { method: "GET" })
            .then((response) => {
                if (!response.ok) {
                    throw new Error("获取签名失败");
                }
                return response.json();
            })
            .then((data) => {
                let formData = new FormData();
                formData.append("success_action_status", "200");
                formData.append("policy", data.policy);
                formData.append("x-oss-signature", data.signature);
                formData.append("x-oss-signature-version", "OSS4-HMAC-SHA256");
                formData.append("x-oss-credential", data.x_oss_credential);
                formData.append("x-oss-date", data.x_oss_date);
                formData.append("key", data.dir + file.name); // 文件名
                formData.append("x-oss-security-token", data.security_token);
                formData.append("callback", data.callback);  // 添加回调参数
                formData.append("file", file); // file 必须为最后一个表单域

                return fetch(data.host, {
                    method: "POST",
                    body: formData
                });
            })
            .then((response) => {
                if (response.ok) {
                    console.log("上传成功");
                    alert("文件已上传");
                    return response.json();  // 解析回调信息
                } else {
                    console.log("上传失败", response);
                    alert("上传失败，请稍后再试");
                }
            })
            .then((callbackData) => {
                if (callbackData) {
                    callbackContent.textContent = JSON.stringify(callbackData, null, 2);
                    callbackInfo.style.display = "block";
                }
            })
            .catch((error) => {
                console.error("发生错误:", error);
            });
    });
});
</script>
</body>
</html>
```


代码写好后，运行服务。

```bash
python server.py
```

这将启动服务后，打开浏览器访问 http://127.0.0.1:8000, 将展示一个简单的上传页面，进行测试

![alt text](/images/2025/07/13/oss-upload-4.png)


首先选择文件，然后点击上传，这将先获取临时上传令牌，然后使用令牌，直接将文件上传到阿里云OSS


## 参考资料

- [服务端签名直传](https://help.aliyun.com/zh/oss/use-cases/obtain-signature-information-from-the-server-and-upload-data-to-oss?spm=a2c4g.11186623.0.i1#ae933a0194svk)
- [OSS地域和访问域名](https://help.aliyun.com/zh/oss/user-guide/regions-and-endpoints)