---
title: Python-使用openpyxl操作Excel表格
date: 2018-03-31 21:05:25
tags: Python, openpyxl, Excel, requests, 自动化
---

## 起因

  前两天收到跨境电商事业部同事发来的一个需求，说有一个表格，里面只有产品ID和其他一些信息，但是没有其他信息，诸如产品中文名和发货地，这些信息需要通过调取API获得。希望我们帮忙导出合并到Excel中
  
## 分析及实现

+ 首先需要读取Excel中，每个产品的ID
+ 然后调用产品查询API，该API通过GET+ID参数方式进行查询
+ 查询到信息后，将需要的信息追加到对应行的后面列中


##  openpyxl

Python 中操作 Excel 的库有许多，例如 xlrd、xlwt、xlsxwriter、openpyxl 等，openpyxl是其中一个，该库主要有几个特点：支持xlsx，支持对现有文档读写，被[Python-Excel](http://www.python-excel.org/)优先推荐。
几经对比调研，最终选择 openpyxl。

### 使用方法

```
# 打开excel
wb = load_workbook('files/file.xlsx')
# 拿到打开的sheet
sheet = wb.active
for index in range(0, sheet.max_row):
    # load_data 通过requests调用API方法，拿到name和ship_from
    name, ship_from = load_data(sheet['A' + str(index + 1)].value)
    # 产品中文名称
    sheet['D' + str(index + 1)] = name
    # 发货地信息
    sheet['E' + str(index + 1)] = ship_from
    print("同步第" + str(index + 1) + "行")
# 将数据保存到另外一表格中，注意也可以保存到原来表格中    
wb.save("files/file-export.xlsx")

```

在上述代码中，首先加载原始文件`files/file.xlsx`，然后对默认sheet进行行遍历，每一行第一列A<sub>n</sub>代表产品ID, 
load_data方法通过调用API, 查询到该产品的中文名称和发货地，然后再写入后面的列中，如D<sub>n</sub>和E<sub>n</sub>

最后全部遍历完后，再保存表格，这样整个需求就实现了

