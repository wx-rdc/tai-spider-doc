# TaiSpider

**数组方式的起始链接**

```javascript
constructor(options = {}) {
    super(options);
    this.name = 'quotes';
    this.debug = true;
    this.start_urls = [
        'https://quotes.toscrape.com/page/1/',
    ];
}
```

**函数方式的起始链接**

```javascript
start_urls() {
    return [{
        link: 'https://target.com',
        download: true,
        options: {
            type: 'zip',
        },
        direct: true,
    }]
}
```