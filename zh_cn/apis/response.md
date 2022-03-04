# Response

## 构造请求

### follow方法

**单链接**

```javascript
yield response.follow(ele.css('a'), cb);
```

**批量链接**

```javascript
yield* response.follow_all(ele.css('a'), cb);
```

**带属性的文件下载请求**

```javascript
yield response.follow(imageEle.attr('src'), cb, {
    download: true,
    options: {
        type: 'jpg',
    },
    extData: {
        title: imageEle.attr('alt'),
    }
});
```

**网页快照请求**

```javascript
yield* response.follow_all(ele.css('a.title'), cb, {
    splash: true,
    download: true,
    options: {
        type: 'png',
    },
    render_all: 0,
    wait: 0,
    // engine: "chromium",
    viewport: '1200x2000',
});
```

### from_request方法

**Post请求**

```javascript
yield response.from_request({
    link: 'https://target.com',
    method: 'POST',
    form: {
        key: value
    },
    headers,
    cb,
});
```

**文件下载请求**

```javascript
yield response.from_request({
    link: 'https://target.com',
    download: true,
    options: {
        type: 'jpg',
    },
    headers,
    cb,
});
```


### 公共参数说明

参数 | 缺省值 | 说明 |
-|-|-|
link | | 链接地址
download | false | 是否需要调用store模块进行数据保存
splash | false | 是否生成Splash请求
skipDuplicates | true | 是否进行URL查重操作，对于某些固定URL，内容却会发生变化的场景，需要将该值设置为false来进行数据二次抓取
direct | false | 是否直接进行抓取，而不是进入排队系统等待

**Splash专用参数**

参数 | 缺省值 | 说明 |
-|-|-|
render_all | 1 | 是否需要进行全网页快照，1表示yes，0表示No
wait | 1 | 快照前是否需要等待，0表示不等待，如果render_all为1，则wait必须大于0
engine | webkit | 渲染引擎，可选值为 `chromium` 和 `webkit`
viewport | | 快照视角大小，例如'1200x2000'

## 网页解析

### css方法

通过css选择器返回 `ItemNodes` 对象

```javascript
for (let ele of response.css('div.quote')) {
    yield {
        'text': ele.css('span.text').extract_first(),
        'href': ele.css('span a').get(0).attr('href')
    };
    yield* response.follow_all(ele.css('span a'), this.parseAuthor);
}
```

### extract方法

对返回body按照文章进行解析，抽取出属性信息，并以json对象方式返回

```javascript
yield response.extract();
```

**抽取的属性信息**

参数 | 说明 |
-|-|
title | The document's title (from the <title> tag)
softTitle | A version of title with less truncation
date | The document's publication date
copyright | The document's copyright line, if present
author | The document's author
publisher | The document's publisher (website name)
text | The main text of the document with all the junk thrown away
image | The main image for the document (what's used by facebook, etc.)
videos | An array of videos that were embedded in the article. Each video has src, width and height.
tags | Any tags or keywords that could be found by checking <rel> tags or by looking at href urls.
canonicalLink | The canonical url of the document, if given.
lang | The language of the document, either detected or supplied by you.
description | The description of the document, from <meta> tags
favicon | The url of the document's favicon.
links | An array of links embedded within the article text. (text and href for each)