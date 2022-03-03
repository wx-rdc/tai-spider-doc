```
create database taiserver default character set utf8 collate utf8_general_ci;
create user 'taiUser'@'%' identified by 'taiUser!docker';
grant all privileges on taiserver.* to 'taiUser'@'%';
flush privileges;
```

```
create table today (
    id VARCHAR(255),
    _spider_name VARCHAR(255),
    _spider_time DATETIME,
    _spider_uri VARCHAR(255),
    ref VARCHAR(255),
    basename VARCHAR(100),
    type  VARCHAR(16),
    size INT(11),
    fullpath  VARCHAR(255),
    primary key(id)
);
```