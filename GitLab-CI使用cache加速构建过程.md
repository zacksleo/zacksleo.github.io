<!-- --- title: GitLab-CI使用cache加速构建过程 -->

## 背景

在GitLab-CI中，使用`artifacts`可以确保所需要传递的文件可靠性，但由于生成的`artifacts`存在的GitLab上，每次需要远程下载，因此速度相对较慢。
所以，在一些对依赖的准确性要求不高的地方，可以考虑使用`cache`。

## cache 简介

cache 顾名思义为缓存，不同的任务之前，缓存可以进行共享。根据配置中的声明，在需要缓存时，GitLab-CI会自动下载缓存，以供当前任务使用。

cache一旦命中，意味着这部分文件不需要重新生成（编译，下载或构建），这样一来，便省去了不少功夫，从而加速了构建过程。

## 使用

### 生成cache

  ```YAML
  
build-package:
    stage: prepare
    script:
        - composer install --prefer-dist --optimize-autoloader -n --no-interaction -v --no-suggest
        - composer dump-autoload --optimize
    cache:
      key: "$CI_COMMIT_REF_NAME"
      paths:
        - vendor
        
 ```
 
 如上，在build-package任务中，声明了cache，其目录为vendor, 当script执行完之后，vendor目录会生成，该任务最后，cache会自动生成（push）
 

### 使用cache

```YAML

phpcs:
    stage: testing    
    cache:
      key: "$CI_COMMIT_REF_NAME"
      policy: pull
      paths:
        - vendor    
    script:
        - if [ ! -d "vendor" ]; then
        - composer install --prefer-dist --optimize-autoloader -n --no-interaction -v --no-suggest && composer dump-autoload --optimize
        - fi
        - php vendor/bin/phpcs --config-set ignore_warnings_on_exit 1
        - php vendor/bin/phpcs --standard=PSR2 -w --colors ./
    except:
        - docs

```

如上，该过程定义了所要使用的cache, 由于cache并不保证每次都命中（即拿到的cache可能为空），周时在script处进行判断，如果cache为空时，重新生成所需文件


## 对比

以doctor-online为例子，在未使用cache之前 ，使用的是artifacts， 每次构建时间在7分钟左右，

![](https://ws1.sinaimg.cn/large/675eb504gy1fkfvidgbx5j21940f0aes.jpg)

使用cache后，构建时间缩短到了1分钟

![](https://ws1.sinaimg.cn/large/675eb504gy1fkfvk9qofkj21900fkq7z.jpg)


## 参考文档

+ [Configuration](https://docs.gitlab.com/ee/ci/yaml/)


