# 快速上手

### 创建项目

按照通常方法创建一个Nodejs项目，例如：

```bash
mkdir spider-demos
cd spider-demos
npm init
```

然后安装 `tai-spider` 组件：

```bash
npm install tai-spider -g
```

至此，您可以开始使用您熟悉的IDE来开发您的第一个爬虫了！

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

要让爬虫正常工作，请转到项目的根目录并运行如下命令：

```
taispider run quotes
```

这个命令将运行我们刚刚写好的爬虫，爬虫的名字就是 `quotes`，它将发出访问 `https://quotes.toscrape.com/page/1/` 页面的请求。您将获得类似于以下内容的输出： 

```bash
run spider: quotes
start url: https://quotes.toscrape.com/page/1/
[2021-11-06T09:31:44.570] [DEBUG] taispider - seenreq is initialized.
[2021-11-06T09:31:46.991] [DEBUG] taispider - connect to a new https://quotes.toscrape.com
[2021-11-06T09:31:48.027] [DEBUG] taispider - Http2 session https://quotes.toscrape.com connection init
[2021-11-06T09:31:48.675] [DEBUG] taispider - https://quotes.toscrape.com/page/1/ stream ends
[2021-11-06T09:31:48.676] [DEBUG] taispider - Got https://quotes.toscrape.com/page/1/ (11053 bytes)...
[2021-11-06T09:31:48.694] [DEBUG] taispider - Queue size: 0
```

在 `parse` 函数中，您可以使用css表达式来选择元素，有关css表达式的详细信息，请参见[cheerio](https://cheerio.js.org/)文档。

您可以将解析得到的数据保存到文件中，而不是在控制台中打印。只需使用以下命令选项：

```
taispider run quotes -o result.jl
```

命令执行结束后，将在当前目录下生成一个名为 `result.jl` 的文件，其中包含了所有解析得到的结果。

### 跟踪页面链接

除了提取数据，`parse` 方法还承担了跟踪页面链接的功能，通过使用 `follow` 或 `follow_all` 方法就可以生成到下一页的新请求。

缺省情况下，`parse` 函数将自身注册为回调函数，用以继续处理下一页的数据提取。

这里您看到的是以下链接的机制：

-- 当您在回调方法中生成一个请求时，`TaiSpider` 将安排发送该请求，并注册一个回调方法，在该请求完成时执行。使用这种方法，您可以构建复杂的爬虫程序，根据您定义的规则跟踪链接，并根据访问的页面提取不同类型的数据。

在我们接下来的示例中，将会创建一个名为 `parseAuthor` 的新函数来解析新类型的author页面，该函数将处理从起始页面中获取的所有author链接。

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
            yield* response.follow_all(response.css('span a', ele), this.parseAuthor);
        }
    }

    *parseAuthor(response) {
        const extract_with_css = (query) => {
            return response.css(query).extract().join();
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

### 加载对象模型

对象模型加载机制提供了一种便利的方法来解析抓取的页面。尽管可以直接使用css函数来进行数据解析，但对象模型加载器通过自动化一些常见任务（如数据类型转换等），为从数据处理过程中填充对象提供了一个更方便的手段。

换句话说，对象模型定义了收集数据的容器，而对象模型加载器提供了填充该容器的机制。

要使用对象模型加载器，必须首先定义对象模型，您可以使用 `Item` 对象对其进行实例化，然后，可以使用 `ItemLoader` 来根据对象模型生成实际解析后的数据。

首先定义对象模型：`model/author.js`

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

然后使用加载器对实际页面进行加载，并得到最终结果数据

```javascript
    *parseAuthor(response) {
        const loader = new ItemLoader(response, require('../model/author'));
        yield loader.load_item();
    }
```

这里您可能会注意到，在之前的例子里，`birthdate` 输出的是字符串，而在对象模型加载的例子中，该属性已经被自动转换为了 `Date` 类型。

### 下载图片和文件

在一些网络抓取任务中涉及下载图像或其他文件类型，比如抓取图像以训练图像识别算法。

使用 `TaiSpider`，这个任务就变得非常简单，只需要进行一些设置就可以了：在配置文件中将 `FILE_STORE` 设置为输出路径，然后在 `follow` 调用过程中加上 `download` 属性就可以了。

下载的文件将自动使用其URL的MD5散列作为文件名，`type` 属性作为文件后缀进行存储，当然用户也可以通过传递 `filename` 来覆盖缺省文件名。

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
        this.envs['FILE_STORE'] = 'output';
    }

    *parse(response) {
        for (let ele of response.css('div.item')) {
            let imageEle = ele.css('img').get(0);
            yield response.follow(imageEle.attr('src'), this.parseImage, {
                download: true,
                options: {
                    type: 'jpg',
                },
                extData: {
                    title: imageEle.attr('alt'),
                }
            });
        }
    }

    *parseImage(response) {
        yield {
            ...response.options.extData,
        }
    }
}

module.exports = MmonlySpider;
```

运行该爬虫，可以得到输出如下：

```bash
[2022-03-04T10:32:45.303] [DEBUG] taispider - Queue size: 2
[2022-03-04T10:32:45.558] [DEBUG] taispider - Got [c98019b3ada4afda8cea3bfe71ed930f] https://t1.huishahe.com/uploads/tu/202111/49/1c39a07c34.jpg (116938 bytes)...
[2022-03-04T10:32:45.559] [DEBUG] taispider - write to  c98019b3ada4afda8cea3bfe71ed930f.jpg
{"title":"与广告图宣传一模一样的红烧肉爆笑囧图","file":{"ref":"https://t1.huishahe.com/uploads/tu/202111/49/1c39a07c34.jpg","basename":"c98019b3ada4afda8cea3bfe71ed930f","type":"jpg","size":116938,"fullpath":"/home/zhu/git/tai-spider-example/output/c98019b3ada4afda8cea3bfe71ed930f.jpg"}}
[2022-03-04T10:32:45.560] [DEBUG] taispider - Queue size: 1
[2022-03-04T10:32:46.066] [DEBUG] taispider - Got [fee3d0ae3296423a687e8108e14bf3b9] https://t1.huishahe.com/uploads/tu/202111/24/d232af0917_%E5%89%AF%E6%9C%AC.png (287708 bytes)...
[2022-03-04T10:32:46.068] [DEBUG] taispider - write to  fee3d0ae3296423a687e8108e14bf3b9.jpg
{"title":"将头伸出栏杆外的机智小鹿爆笑囧图","file":{"ref":"https://t1.huishahe.com/uploads/tu/202111/24/d232af0917_%E5%89%AF%E6%9C%AC.png","basename":"fee3d0ae3296423a687e8108e14bf3b9","type":"jpg","size":287708,"fullpath":"/home/zhu/git/tai-spider-example/output/fee3d0ae3296423a687e8108e14bf3b9.jpg"}}
[2022-03-04T10:32:46.069] [DEBUG] taispider - Queue size: 0
[2022-03-04T10:32:47.071] [DEBUG] taispider - Crawler clear all 0 http2 connections
[2022-03-04T10:32:47.072] [DEBUG] taispider - on drain
```

在上面的例子中, `extData` 属性作为前一次页面解析的结果被传递到了新的页面解析函数中，这种方法可以在很多场合下得到使用。

### 抓取页面快照

`Splash` 是一个无头浏览器服务，它提供了HTTP api来制作页面的快照。这里是[API文档](https://splash.readthedocs.io/en/stable/api.html)。

您可以使用 `tai-spider-example` 项目中的 `docker/splash` 下脚本启动 `splash` 服务，只需运行以下命令：

```bash
docker-compose up -d
```

`TaiSpider` 内置支持了 `splash` API，您只需要设置以下变量即可：

```
SPLASH_SERVER ： 指定 splash 服务器地址和端口
```

同时在 `follow` 调用过程中加上 `splash` 属性就可以了。快照制作完成后，仍然使用下载文件的模式进行快照的保存。

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
        this.envs['FILE_STORE'] = 'output';
    }

    *parse(response) {
        for (let ele of response.css('div.content')) {
            yield* response.follow_all(ele.css('a.title'), this.snapshot, {
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
        }
    }

    *snapshot(response) {
        yield {}
    }
}

module.exports = JianshuSpider;
```