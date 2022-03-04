# 快速上手

### 第一个爬虫

从开发角度来看，爬虫就是用于从网站（或一组网站）中获取信息的类。它必须是`TaiSpider`的子类，并可以根据需要定义要发出的初始请求，可以选择如何跟踪页面中的链接，以及如何解析下载的页面内容以提取数据。

这是我们第一个爬虫的代码。一个名为 `quotes` 的爬虫，用于爬取 `quotes.toscrape.com` 网站中一个特定的页面，并将页面中的内容解析出来，然后打印输出到屏幕上。

```javascript
'use strict'

const { TaiSpider } = require('tai-spider');

class QuotesSpider extends TaiSpider {

    constructor(options = {}) {
        super(options);
        this.name = 'quotes';
        this.debug = true;
        this.start_urls = [
            'https://quotes.toscrape.com/page/1/',
        ];
    }

    *parse(response) {
        for (let ele of response.css('div.quote')) {
            yield {
                'text': ele.css('span.text').extract_first(),
                'href': ele.css('span a').get(0).attr('href')
            };
        }
    }
}

module.exports = QuotesSpider;
```

正如您所见，爬虫类 `QuoteSpider` 继承了 `TaiSpider` 类，并定义了一些属性和方法： 

   - name: 用于识别爬虫，它在项目中必须是唯一的，也就是说，不能为不同的爬虫设置相同的名称。 

   - start_urls: 起始地址数组，爬虫将从该地址组开始爬行，后续请求将从这些初始请求按照用户定义的方式连续生成。

   - parse(): 缺省解析函数，当每个请求完成时，该函数将被调用用于处理返回的数据，该方法通常用于将获取的数据提取为json对象，并查找要跟踪的新URL，并从中创建新请求（Request）。其response参数是 `Response` 类的一个实例，它实现了许多有用的方法来处理返回的数据。 

### 如何运行爬虫

To put our spider to work, go to the project’s top level directory and run:

```
taispider run quotes
```

This command runs the spider with name quotes that we’ve just added, that will send some requests for the `quotes.toscrape.com` domain. You will get an output similar to this:

```
run spider: quotes
start url: https://quotes.toscrape.com/page/1/
[2021-11-06T09:31:44.570] [DEBUG] taispider - seenreq is initialized.
[2021-11-06T09:31:46.991] [DEBUG] taispider - connect to a new https://quotes.toscrape.com
[2021-11-06T09:31:48.027] [DEBUG] taispider - Http2 session https://quotes.toscrape.com connection init
[2021-11-06T09:31:48.675] [DEBUG] taispider - https://quotes.toscrape.com/page/1/ stream ends
[2021-11-06T09:31:48.676] [DEBUG] taispider - Got https://quotes.toscrape.com/page/1/ (11053 bytes)...
[2021-11-06T09:31:48.694] [DEBUG] taispider - Queue size: 0
```
In `parse` function, you can selecting elements using css expression with the response object just as normal. The detail about css expression, you can find in [cheerio](https://cheerio.js.org/).

You can save scrapy data to a file instead of printing in console. Just use the follow command options:
```
taispider run quotes -o result.jl
```

### Follow links in page
Now, after extracting the data, the parse() method looks for the link to the next page, builds a full absolute URL using the urljoin() method (since the links can be relative) and yields a new request to the next page, registering itself as callback to handle the data extraction for the next page and to keep the crawling going through all the pages.

What you see here is the mechanism of following links: when you yield a Request in a callback method, `TaiSpider` will schedule that request to be sent and register a callback method to be executed when that request finishes.

Using this, you can build complex crawlers that follow links according to rules you define, and extract different kinds of data depending on the page it’s visiting.

In our example, it creates a new function named parseAuthor to parse new type author page, following all the author links in start page.

```javascript
'use strict'

const { TaiSpider, ItemLoader } = require('tai-spider');

class QuotesSpider extends TaiSpider {

    constructor(options = {}) {
        super(options);
        this.name = 'quotes';
        this.debug = true;
        this.start_urls = [
            'https://quotes.toscrape.com/page/1/',
        ];
    }

    *parse(response) {
        for (let ele of response.css('div.quote')) {
            yield {
                'text': response.css('span.text', ele).text(),
            };
            yield* response.follow_all(response.css('span a', ele), this.parseAuthor);
        }
    }

    *parseAuthor(response) {
        const extract_with_css = (query) => {
            return _.trim(response.css(query).text());
        }

        yield {
            'name': extract_with_css('h3.author-title'),
            'birthdate': extract_with_css('.author-born-date'),
            'bio': extract_with_css('.author-description'),
        }
    }

}

module.exports = QuotesSpider;
```

### Item loader for model
Item Loaders provide a convenient mechanism for populating scraped items. Even though items can be populated directly, Item Loaders provide a much more convenient API for populating them from a scraping process, by automating some common tasks like parsing the raw extracted data before assigning it.

In other words, items provide the container of scraped data, while Item Loaders provide the mechanism for populating that container.

To use an Item Loader, you must first instantiate it. You can either instantiate it with an item object, in which case an item object is automatically created in the Item Loader using the item class. Then, you can collecting values using the Item Loader.

```javascript
    *parseAuthor(response) {
        const loader = new ItemLoader(response, require('../model/author'));
        yield loader.load_item();
    }
```

`model/author.js`
```javascript
const Item = require('tai-spider').Item;

module.exports = new Item({
    name: 'h3.author-title',
    birthdate: {
        value: '.author-born-date',
        type: 'date',
    },
    bio: '.author-description',
});
```

### Download Images and Other Files
Some of our web scraping tasks involves downloading images or other file types, like grabbing images to train image recognition algorithms. 
With crawler, a few settings will do the trick; simply set `FILE_STORE` to the output path, and yield object return by `response.download` function.

The files are stored using a MD5 hash of their URLs for the file names. You can use `extData` pass some properties to next pipeline, or use `cb` function to build a object.

```javascript
'use strict'

const { TaiSpider } = require('tai-spider');

class MmonlySpider extends TaiSpider {

    constructor(options = {}) {
        super(options);
        this.name = 'mmonly';
        this.debug = true;
        this.start_urls = [
            'https://www.mmonly.cc/gxtp/',
        ];
        this.envs['ECHO'] = false;
        this.envs['FILE_STORE'] = 'output';
        this.addPipeline(require('../pipeline/echo'));
    }

    *parse(response) {
        for (let ele of response.css('div.item')) {
            let imageEle = response.css('img', ele)[0];
            yield response.download(imageEle.attribs['src'], {
                type: 'jpg',
                extData: {
                    title: imageEle.attribs['alt'],
                }
            });
        }
    }
}

module.exports = MmonlySpider;
```

In above example, `extData` will be transfer to next pipeline with some infos of stored file, here is `echo` pipeline.

```javascript
'use strict';

class EchoPipeline {

	process_item(item, spider) {
		console.log(item);
		return item;
	}
}

module.exports = EchoPipeline;
```

Or use `cb` function to build a new object to transfer:

```javascript
    *parse(response) {
        let data = response.getJSON();
        for (let item of data['publishData'].slice(0, 3)) {
            yield response.download(item['bulletinUrl'], {
                type: 'pdf',
                cb: (uid) => {
                    return Object.assign({}, item, { uid });
                }
            })
        };
    }
```
### Use splash to snapshot page

Splash is a standalone server, which provides HTTP api to make page's snapshot. Here is [API Doc](https://splash.readthedocs.io/en/stable/api.html).

You can use script under `docker/splash` to start splash service, just run the below command:

```shell
docker-compose up -d
```

`Tai Spider` add support for splash, you simply set `CAPTURE_STORE` to the output path, `SPLASH_SERVER` to the splash server, and yield object return by `response.capture_all` or `response.capture` function.

```javascript
'use strict'

const { TaiSpider } = require('tai-spider');

class JianshuSpider extends TaiSpider {

    constructor(options = {}) {
        super(options);
        this.name = 'jianshu';
        this.debug = true;
        this.start_urls = [
            'https://www.jianshu.com/',
        ];
        this.envs['SPLASH_SERVER'] = 'http://localhost:8050';
        this.envs['CAPTURE_STORE'] = 'output';
    }

    *parse(response) {
        for (let ele of response.css('div.content')) {
            yield* response.capture_all(response.css('a.title', ele), {
                render_all: 0,
                wait: 0,
                viewport: '1200x2000',
            });
        }
    }

}

module.exports = JianshuSpider;
```