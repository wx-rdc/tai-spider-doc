# ItemNodes

## 构造

ItemNodes不能直接进行实例化，需要使用 `response` 或 `ItemNode` 的css方法生成。

## Iterator

ItemNodes实现了Iterator接口，因此可以使用ES6的循环方式进行遍历

```javascript
for (let ele of response.css('div.quote')) {
    ...
}
```