---
title: 优雅的Java：01.数据更新如何更优雅
date: 2025-07-10 17:03:10
tags: [Java, SpringBoot, 优雅的Java]
---

编者按：如何写出更优雅的代码？这是一个恒久的问题，

在 Java 的世界里，SpringBoot 框架最为流程，几乎已经成为事实标准。本系列将围绕 SpringBoot 实战案例进行，介绍如何写出更优雅的 Java 代码。
笔者试图通过一个个的实际案例，抽丝剥茧，探讨 Spring 的设计哲学，探讨 Java 美学。

## 数据更新案例

数据更新的业务逻辑，很常见，举例例子，这里有一个更新发票信息的业务逻辑，按常规的思路，很容易写出这样的代码：

```java
public function updateInvoice(UpdateInvoiceForm form) {
    Invoice updateInvoice = new Invoice();
    updateInvoice.setId(form.getId());
    // 更新发票号
    if(StringUtils.isNotBlank(form.getInvoiceTaxNumber())) {
        updateInvoice.setInvoiceTaxNumber(form.getInvoiceTaxNumber());
    }
    // 税额
    if(form.getTaxAmount() != null) {
        updateInvoice.setTaxAmount(form.getTaxAmount());
    }
    //  税前金额
    if(form.getTotalAmountPreTax() != null) {
        updateInvoice.setTotalAmountPreTax(form.getTotalAmountPreTax());
    }

    invoiceMapper.updateByPrimaryKeySelective(updateInvoice);
}
```

上面的逻辑也简单清晰，只有当某个上传的字段不为空时，才会更新数据库中相应的字段。那么，如果字段很多时，这样的代码就看起来非常冗余，那么，如何优化呢？

我们知道，Java 8 的 Optional 类，有着这样的用户：

```java
  optionalVal.ifPresent(value -> xxx);
```

当前我们可以直接使用 Optional 类，将字段的更新逻辑封装在 Optional 类中，这样，代码就显得非常简洁，就像这样：

```java
  Optional.ofNullable(form.getTaxAmount()).ifPresent(taxAmount -> {updateInvoice.setTaxAmount(taxAmount);})
```

不过这也有个问题，ifPresent 只支持判断对象是否为 null，无法过滤字符串为空的情况，基于这样的需要，我们可以仿照 Optional 类，自己实现一个封装


其核心代码像这样：

```java
    public OptionalUtil<T> ifNotNull(Consumer<T> action) {
        if (value != null) {
            action.accept(value);
        }
        return this;
    }

    public OptionalUtil<T> ifNotBlank(Consumer<String> action) {
        if (value instanceof String && StringUtils.isNotBlank((String) value)) {
            action.accept((String) value);
        }
        return this;
    }
```

上面定义了两个核心方法，ifNotNull 和 ifNotBlank，分别用于判断对象是否为 null 和字符串是否为空，当满足条件时，再执行闭包里面的操作。

以下是完整的代码：


```java
import java.util.function.Consumer;

import org.apache.commons.lang3.StringUtils;

public class OptionalUtil<T> {

    private final T value;

    private OptionalUtil(T value) {
        this.value = value;
    }

    public static <T> OptionalUtil<T> valueOf(T value) {
        return new OptionalUtil<>(value);
    }

    public OptionalUtil<T> ifBlank(Consumer<String> action) {
        if (value instanceof String && StringUtils.isBlank((String) value)) {
            action.accept((String) value);
        }
        return this;
    }

    public OptionalUtil<T> ifNotBlank(Consumer<String> action) {
        if (value instanceof String && StringUtils.isNotBlank((String) value)) {
            action.accept((String) value);
        }
        return this;
    }

    public OptionalUtil<T> ifNull(Consumer<T> action) {
        if (value == null) {
            action.accept(value);
        }
        return this;
    }

    public OptionalUtil<T> ifNotNull(Consumer<T> action) {
        if (value != null) {
            action.accept(value);
        }
        return this;
    }

    public OptionalUtil<T> ifZero(Consumer<T> action) {
        if (isZeroValue(value)) {
            action.accept(value);
        }
        return this;
    }

    private boolean isZeroValue(Object value) {
        if (value instanceof Number && ((Number) value).doubleValue() == 0.0d) {
            return true;
        }
        if (value instanceof java.util.Date && ((java.util.Date) value).getTime() <= 0) {
            return true;
        }
        return false;
    }

    public OptionalUtil<T> ifNotZero(Consumer<T> action) {
        if (!isZeroValue(value)) {
            action.accept(value);
        }
        return this;
    }

    public void execute() {
        // 可以用于触发链式调用的结束，也可以扩展为执行某些默认操作
    }
}
```

可以看到，这里面封装了一个 OptionalUtil 类，用于处理 Optional 类的链式调用。里面包括一个静态构造方法 valueOf, 同时支持各类不同的类型，
不论是 String，还是继承 Number 的类，如 Integer，Long，BigDecimal 等，进行判断。

时间 ifZero 也支持时间类型，如果传的时间为 1970-01-01 00:00:00 及以前的时间，也视做零值。

这样，我们的更新代码就可以写成这样：

```java
public function updateInvoice(UpdateInvoiceForm form) {
    Invoice updateInvoice = new Invoice();
    updateInvoice.setId(form.getId());
    // 更新发票号
    OptionalUtil.valueOf(form.getInvoiceTaxNumber()).ifNotBlank(updateInvoice::setInvoiceTaxNumber);
    // 税额
    OptionalUtil.valueOf(form.getTaxPreAmount()).ifNotBlank(updateInvoice::setTaxPreAmount);
    //  税前金额
    OptionalUtil.valueOf(form.getTotalAmountPreTax()).ifNotBlank(updateInvoice::setTotalAmountPreTax);

    invoiceMapper.updateByPrimaryKeySelective(updateInvoice);
}
```

这样，优雅的数据更新就实现了，你觉得怎么样呢，欢迎在评论区交流。