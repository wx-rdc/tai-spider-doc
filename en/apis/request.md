# request

## Normal

**Single Url**

```javascript
yield response.follow(ele.css('a'), cb);
```

**Batch Urls**

```javascript
yield* response.follow_all(ele.css('a'), cb);
```

**Start Urls**
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

## Post data

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

## Download file

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

another way

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

## Capture snapshot

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

### Common options

option | default | comment |
-|-|-|
skipDuplicates | true | If duplicate skipping is true, avoid queueing entirely for URLs we already crawled
direct | false | If this option is true, use direct method instead of queue, it will cause system is always waiting for anothor request

