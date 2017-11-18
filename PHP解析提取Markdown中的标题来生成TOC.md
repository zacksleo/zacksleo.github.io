---
title: PHP解析提取Markdown中的标题来生成TOC
date: 2016-10-12 16:46:48
tags: [php, markdown, TOC]
---

## 原理
先解析markdown为HTML, 然后解析出h1-h10标签, 根据h标签的前后大小, 决定ul的层级, 以此生成ul序列的嵌套

* 如果当前H标签和前面H标签相同, 则生成`<li></li>`,
* 如果比前面的大, 则生成`<ul>`
 * 如果比前面的小, 生成` </ul><ul><li></li>`

## 上手

*  选择一个markdown Parser库, 将markdown解析

$file为文件路径, $docs为解析后的html字串

```
       $content = file_get_contents($file);
        require_once('/var/www/html/vendor/erusev/parsedown/Parsedown.php');
        $parsedown = new \Parsedown();
        $docs = $parsedown->text($content);        
```
* 解析DOM, 根据H标签的前后顺序, 生成TOC

```
       $dom = new \DOMDocument();
        $docs = mb_convert_encoding($docs, 'HTML-ENTITIES', "UTF-8");
        $dom->loadHTML($docs);

        // The toc being generated.
        $toc = '';
        $curr = $last = 0;
        $type = "ul";
        $xpath = new \DomXPath($dom);
        $t = $xpath->query('//h1|//h2|//h3|//h4|//h5|//h6');
        foreach ($t as $key => $item) {
            $level = ltrim($item->nodeName, 'h');
            sscanf($item->nodeName, 'h%u', $curr);
            // If the current level is greater than the last level indent one level
            if ($curr > $last) {
                if ($last == 0) {
                    $toc .= '<' . $type . " class='nav doc-menu affix-top' id='doc-menu' data-spy='affix'>\n";
                } else {
                    $toc .= '<' . $type . " class='nav doc-sub-menu'>\n";
                }
            } // If the current level is less than the last level go up appropriate amount.
            elseif ($curr < $last) {
                $toc .= str_repeat('</li></' . $type . ">\n", $last - $curr) . "</li>\n";
            } // If the current level is equal to the last.
            else {
                $toc .= "</li>\n";
            }
            // Get and/or set an id
            if ($item->hasAttribute('id')) {
                $id = $item->getAttribute('id');
            } else {
               //auto generate id for the tag
                $id = uniqid();
                $t[$key]->setAttribute('id', $id);
            }
            if ($last == 0) {
                $toc .= '<li class="active"><a class="scrollto" href="#' . $id . '">' . $item->nodeValue . "</a>\n";
            } else {
                $toc .= '<li><a class="scrollto" href="#' . $id . '">' . $item->nodeValue . "</a>\n";
            }
            $last = $curr;
        }
       // 将修改后的DOM 赋值为docs
        $docs = $dom->saveHTML();
```

*  渲染页面
$docs为html主体内容
$toc为生成的目录, 形如
```
<ul>
  <li></li>
    <ul>
      <li></li>
      <li></li>
    </ul>
  <li></li>
  <li></li>
 </ul>
```