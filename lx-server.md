---
title: 默认模块
language_tabs:
  - shell: Shell
  - http: HTTP
  - javascript: JavaScript
  - ruby: Ruby
  - python: Python
  - php: PHP
  - java: Java
  - go: Go
toc_footers: []
includes: []
search: true
code_clipboard: true
highlight_theme: darkula
headingLevel: 2
generator: "@tarslib/widdershins v4.0.30"

---

# 默认模块

Base URLs:

# Authentication

# lx-server

## GET 状态

GET /api/status

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|x-frontend-auth|header|string| 否 |none|

> 返回示例

> 200 Response

```json
{"users":3,"devices":0,"uptime":345237.270149703,"memory":140320768,"totalMemory":33050525696,"freeMemory":25273167872,"systemMemoryUsage":"23.53","processMemoryUsage":"0.42","cpuUsage":"6.84","processCpuUsage":"0.09","osUptime":910728,"cpus":4,"cpuModel":"Intel(R) Core(TM) i3-8100T CPU @ 3.10GHz","cpuSpeed":799,"isWebDAVConfigured":true}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## POST 登录获取 Token

POST /api/user/login

> Body 请求参数

```json
{"username": "rang", "password": "rdl.+0317"}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|

> 返回示例

```json
{"success":true,"token":"647323dc765e5a8ca82863814d16724d0ab4b2ab78cbe0bcf760913997a5cb13","username":"rang"}
```

```json
{
    "success": true,
    "token": "0be946075ee8b3eed6dd5ce6215e2bce56fa6b687446651bf8d368dca730558c",
    "username": "rang"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 认证有效性检查

GET /api/user/auth/verify

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|x-user-token|header|string| 否 |none|

> 返回示例

```json
{"valid":true,"username":"rang"}
```

```json
{
    "valid": true,
    "username": "rang"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取歌单分类标签

GET /api/music/songList/tags

> Body 请求参数

```json
{}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|source|query|string| 否 |none|
|body|body|object| 是 |none|

#### 枚举值

|属性|值|
|---|---|
|source|kg|
|source|kw|
|source|tx|
|source|mg|
|source|wy|

> 返回示例

```json
{"hotTag":[{"id":"12","name":"经典","source":"kg"},{"id":"20","name":"英语","source":"kg"},{"id":"571","name":"00后","source":"kg"},{"id":"76","name":"90后","source":"kg"},{"id":"19","name":"粤语","source":"kg"},{"id":"578","name":"伤感","source":"kg"},{"id":"13","name":"70后","source":"kg"},{"id":"587","name":"学习","source":"kg"},{"id":"68","name":"情歌对唱","source":"kg"},{"id":"50","name":"兴奋","source":"kg"},{"id":"10","name":"舞曲","source":"kg"},{"id":"44","name":"安静","source":"kg"},{"id":"49","name":"快乐","source":"kg"},{"id":"64","name":"夜店","source":"kg"}],"tags":[{"name":"主题","list":[{"parent_id":1,"parent_name":"主题","id":1084,"name":"精选","source":"kg"},{"parent_id":1,"parent_name":"主题","id":12,"name":"经典","source":"kg"},{"parent_id":1,"parent_name":"主题","id":35,"name":"网络","source":"kg"},{"parent_id":1,"parent_name":"主题","id":17,"name":"DJ热碟","source":"kg"},{"parent_id":1,"parent_name":"主题","id":68,"name":"情歌对唱","source":"kg"},{"parent_id":1,"parent_name":"主题","id":74,"name":"游戏","source":"kg"},{"parent_id":1,"parent_name":"主题","id":10,"name":"舞曲","source":"kg"},{"parent_id":1,"parent_name":"主题","id":72,"name":"KTV","source":"kg"},{"parent_id":1,"parent_name":"主题","id":79,"name":"影视","source":"kg"},{"parent_id":1,"parent_name":"主题","id":638,"name":"翻唱","source":"kg"},{"parent_id":1,"parent_name":"主题","id":77,"name":"ACG","source":"kg"},{"parent_id":1,"parent_name":"主题","id":680,"name":"现场","source":"kg"},{"parent_id":1,"parent_name":"主题","id":80,"name":"综艺","source":"kg"},{"parent_id":1,"parent_name":"主题","id":1111,"name":"厂牌音乐","source":"kg"},{"parent_id":1,"parent_name":"主题","id":1112,"name":"BGM","source":"kg"},{"parent_id":1,"parent_name":"主题","id":1110,"name":"儿童","source":"kg"},{"parent_id":1,"parent_name":"主题","id":682,"name":"器乐演奏","source":"kg"},{"parent_id":1,"parent_name":"主题","id":1085,"name":"官方歌单","source":"kg"},{"parent_id":1,"parent_name":"主题","id":605,"name":"草原风","source":"kg"},{"parent_id":1,"parent_name":"主题","id":628,"name":"广场舞","source":"kg"}]},{"name":"语种","list":[{"parent_id":2,"parent_name":"语种","id":84,"name":"国语","source":"kg"},{"parent_id":2,"parent_name":"语种","id":20,"name":"英语","source":"kg"},{"parent_id":2,"parent_name":"语种","id":19,"name":"粤语","source":"kg"},{"parent_id":2,"parent_name":"语种","id":21,"name":"日语","source":"kg"},{"parent_id":2,"parent_name":"语种","id":23,"name":"韩语","source":"kg"},{"parent_id":2,"parent_name":"语种","id":22,"name":"闽南语","source":"kg"},{"parent_id":2,"parent_name":"语种","id":24,"name":"小语种","source":"kg"},{"parent_id":2,"parent_name":"语种","id":570,"name":"法语","source":"kg"}]},{"name":"风格","list":[{"parent_id":8,"parent_name":"风格","id":9,"name":"流行","source":"kg"},{"parent_id":8,"parent_name":"风格","id":574,"name":"古风","source":"kg"},{"parent_id":8,"parent_name":"风格","id":33,"name":"电子","source":"kg"},{"parent_id":8,"parent_name":"风格","id":83,"name":"民谣","source":"kg"},{"parent_id":8,"parent_name":"风格","id":27,"name":"摇滚","source":"kg"},{"parent_id":8,"parent_name":"风格","id":31,"name":"嘻哈","source":"kg"},{"parent_id":8,"parent_name":"风格","id":1079,"name":"后摇","source":"kg"},{"parent_id":8,"parent_name":"风格","id":11,"name":"中国风","source":"kg"},{"parent_id":8,"parent_name":"风格","id":30,"name":"R&B","source":"kg"},{"parent_id":8,"parent_name":"风格","id":28,"name":"古典","source":"kg"},{"parent_id":8,"parent_name":"风格","id":15,"name":"乡村","source":"kg"},{"parent_id":8,"parent_name":"风格","id":32,"name":"爵士","source":"kg"},{"parent_id":8,"parent_name":"风格","id":650,"name":"新世纪","source":"kg"},{"parent_id":8,"parent_name":"风格","id":94,"name":"布鲁斯","source":"kg"},{"parent_id":8,"parent_name":"风格","id":1057,"name":"拉丁","source":"kg"},{"parent_id":8,"parent_name":"风格","id":34,"name":"轻音乐","source":"kg"},{"parent_id":8,"parent_name":"风格","id":1108,"name":"中国传统","source":"kg"},{"parent_id":8,"parent_name":"风格","id":29,"name":"金属","source":"kg"},{"parent_id":8,"parent_name":"风格","id":92,"name":"雷鬼","source":"kg"}]},{"name":"年代","list":[{"parent_id":7,"parent_name":"年代","id":13,"name":"70后","source":"kg"},{"parent_id":7,"parent_name":"年代","id":14,"name":"80后","source":"kg"},{"parent_id":7,"parent_name":"年代","id":76,"name":"90后","source":"kg"},{"parent_id":7,"parent_name":"年代","id":571,"name":"00后","source":"kg"}]},{"name":"心情","list":[{"parent_id":4,"parent_name":"心情","id":1107,"name":"怀旧","source":"kg"},{"parent_id":4,"parent_name":"心情","id":578,"name":"伤感","source":"kg"},{"parent_id":4,"parent_name":"心情","id":44,"name":"安静","source":"kg"},{"parent_id":4,"parent_name":"心情","id":50,"name":"兴奋","source":"kg"},{"parent_id":4,"parent_name":"心情","id":577,"name":"轻松","source":"kg"},{"parent_id":4,"parent_name":"心情","id":780,"name":"治愈","source":"kg"},{"parent_id":4,"parent_name":"心情","id":49,"name":"快乐","source":"kg"},{"parent_id":4,"parent_name":"心情","id":47,"name":"甜蜜","source":"kg"},{"parent_id":4,"parent_name":"心情","id":42,"name":"寂寞","source":"kg"},{"parent_id":4,"parent_name":"心情","id":48,"name":"感动","source":"kg"},{"parent_id":4,"parent_name":"心情","id":642,"name":"小清新","source":"kg"},{"parent_id":4,"parent_name":"心情","id":81,"name":"励志","source":"kg"},{"parent_id":4,"parent_name":"心情","id":643,"name":"减压","source":"kg"},{"parent_id":4,"parent_name":"心情","id":684,"name":"失恋","source":"kg"}]},{"name":"场景","list":[{"parent_id":5,"parent_name":"场景","id":587,"name":"学习","source":"kg"},{"parent_id":5,"parent_name":"场景","id":660,"name":"工作","source":"kg"},{"parent_id":5,"parent_name":"场景","id":1104,"name":"通勤","source":"kg"},{"parent_id":5,"parent_name":"场景","id":69,"name":"运动","source":"kg"},{"parent_id":5,"parent_name":"场景","id":67,"name":"校园","source":"kg"},{"parent_id":5,"parent_name":"场景","id":585,"name":"旅途","source":"kg"},{"parent_id":5,"parent_name":"场景","id":61,"name":"咖啡厅","source":"kg"},{"parent_id":5,"parent_name":"场景","id":581,"name":"店铺","source":"kg"},{"parent_id":5,"parent_name":"场景","id":668,"name":"清晨","source":"kg"},{"parent_id":5,"parent_name":"场景","id":670,"name":"下午茶","source":"kg"},{"parent_id":5,"parent_name":"场景","id":1105,"name":"夜晚","source":"kg"},{"parent_id":5,"parent_name":"场景","id":583,"name":"睡前","source":"kg"},{"parent_id":5,"parent_name":"场景","id":586,"name":"派对","source":"kg"},{"parent_id":5,"parent_name":"场景","id":1106,"name":"宅家","source":"kg"},{"parent_id":5,"parent_name":"场景","id":63,"name":"车载","source":"kg"},{"parent_id":5,"parent_name":"场景","id":64,"name":"夜店","source":"kg"},{"parent_id":5,"parent_name":"场景","id":88,"name":"婚礼","source":"kg"}]}],"source":"kg","sortList":[{"name":"推荐","id":"5"},{"name":"最热","id":"6"},{"name":"最新","id":"7"},{"name":"热藏","id":"3"},{"name":"飙升","id":"8"}]}
```

```json
{
    "hotTag": [
        {
            "id": "12",
            "name": "经典",
            "source": "kg"
        },
        {
            "id": "20",
            "name": "英语",
            "source": "kg"
        },
        {
            "id": "571",
            "name": "00后",
            "source": "kg"
        },
        {
            "id": "76",
            "name": "90后",
            "source": "kg"
        },
        {
            "id": "19",
            "name": "粤语",
            "source": "kg"
        },
        {
            "id": "578",
            "name": "伤感",
            "source": "kg"
        },
        {
            "id": "13",
            "name": "70后",
            "source": "kg"
        },
        {
            "id": "587",
            "name": "学习",
            "source": "kg"
        },
        {
            "id": "68",
            "name": "情歌对唱",
            "source": "kg"
        },
        {
            "id": "50",
            "name": "兴奋",
            "source": "kg"
        },
        {
            "id": "10",
            "name": "舞曲",
            "source": "kg"
        },
        {
            "id": "44",
            "name": "安静",
            "source": "kg"
        },
        {
            "id": "49",
            "name": "快乐",
            "source": "kg"
        },
        {
            "id": "64",
            "name": "夜店",
            "source": "kg"
        }
    ],
    "tags": [
        {
            "name": "主题",
            "list": [
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 1084,
                    "name": "精选",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 12,
                    "name": "经典",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 35,
                    "name": "网络",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 17,
                    "name": "DJ热碟",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 68,
                    "name": "情歌对唱",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 74,
                    "name": "游戏",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 10,
                    "name": "舞曲",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 72,
                    "name": "KTV",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 79,
                    "name": "影视",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 638,
                    "name": "翻唱",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 77,
                    "name": "ACG",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 680,
                    "name": "现场",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 80,
                    "name": "综艺",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 1111,
                    "name": "厂牌音乐",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 1112,
                    "name": "BGM",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 1110,
                    "name": "儿童",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 682,
                    "name": "器乐演奏",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 1085,
                    "name": "官方歌单",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 605,
                    "name": "草原风",
                    "source": "kg"
                },
                {
                    "parent_id": 1,
                    "parent_name": "主题",
                    "id": 628,
                    "name": "广场舞",
                    "source": "kg"
                }
            ]
        },
        {
            "name": "语种",
            "list": [
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 84,
                    "name": "国语",
                    "source": "kg"
                },
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 20,
                    "name": "英语",
                    "source": "kg"
                },
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 19,
                    "name": "粤语",
                    "source": "kg"
                },
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 21,
                    "name": "日语",
                    "source": "kg"
                },
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 23,
                    "name": "韩语",
                    "source": "kg"
                },
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 22,
                    "name": "闽南语",
                    "source": "kg"
                },
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 24,
                    "name": "小语种",
                    "source": "kg"
                },
                {
                    "parent_id": 2,
                    "parent_name": "语种",
                    "id": 570,
                    "name": "法语",
                    "source": "kg"
                }
            ]
        },
        {
            "name": "风格",
            "list": [
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 9,
                    "name": "流行",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 574,
                    "name": "古风",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 33,
                    "name": "电子",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 83,
                    "name": "民谣",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 27,
                    "name": "摇滚",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 31,
                    "name": "嘻哈",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 1079,
                    "name": "后摇",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 11,
                    "name": "中国风",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 30,
                    "name": "R&B",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 28,
                    "name": "古典",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 15,
                    "name": "乡村",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 32,
                    "name": "爵士",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 650,
                    "name": "新世纪",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 94,
                    "name": "布鲁斯",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 1057,
                    "name": "拉丁",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 34,
                    "name": "轻音乐",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 1108,
                    "name": "中国传统",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 29,
                    "name": "金属",
                    "source": "kg"
                },
                {
                    "parent_id": 8,
                    "parent_name": "风格",
                    "id": 92,
                    "name": "雷鬼",
                    "source": "kg"
                }
            ]
        },
        {
            "name": "年代",
            "list": [
                {
                    "parent_id": 7,
                    "parent_name": "年代",
                    "id": 13,
                    "name": "70后",
                    "source": "kg"
                },
                {
                    "parent_id": 7,
                    "parent_name": "年代",
                    "id": 14,
                    "name": "80后",
                    "source": "kg"
                },
                {
                    "parent_id": 7,
                    "parent_name": "年代",
                    "id": 76,
                    "name": "90后",
                    "source": "kg"
                },
                {
                    "parent_id": 7,
                    "parent_name": "年代",
                    "id": 571,
                    "name": "00后",
                    "source": "kg"
                }
            ]
        },
        {
            "name": "心情",
            "list": [
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 1107,
                    "name": "怀旧",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 578,
                    "name": "伤感",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 44,
                    "name": "安静",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 50,
                    "name": "兴奋",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 577,
                    "name": "轻松",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 780,
                    "name": "治愈",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 49,
                    "name": "快乐",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 47,
                    "name": "甜蜜",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 42,
                    "name": "寂寞",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 48,
                    "name": "感动",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 642,
                    "name": "小清新",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 81,
                    "name": "励志",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 643,
                    "name": "减压",
                    "source": "kg"
                },
                {
                    "parent_id": 4,
                    "parent_name": "心情",
                    "id": 684,
                    "name": "失恋",
                    "source": "kg"
                }
            ]
        },
        {
            "name": "场景",
            "list": [
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 587,
                    "name": "学习",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 660,
                    "name": "工作",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 1104,
                    "name": "通勤",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 69,
                    "name": "运动",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 67,
                    "name": "校园",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 585,
                    "name": "旅途",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 61,
                    "name": "咖啡厅",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 581,
                    "name": "店铺",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 668,
                    "name": "清晨",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 670,
                    "name": "下午茶",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 1105,
                    "name": "夜晚",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 583,
                    "name": "睡前",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 586,
                    "name": "派对",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 1106,
                    "name": "宅家",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 63,
                    "name": "车载",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 64,
                    "name": "夜店",
                    "source": "kg"
                },
                {
                    "parent_id": 5,
                    "parent_name": "场景",
                    "id": 88,
                    "name": "婚礼",
                    "source": "kg"
                }
            ]
        }
    ],
    "source": "kg",
    "sortList": [
        {
            "name": "推荐",
            "id": "5"
        },
        {
            "name": "最热",
            "id": "6"
        },
        {
            "name": "最新",
            "id": "7"
        },
        {
            "name": "热藏",
            "id": "3"
        },
        {
            "name": "飙升",
            "id": "8"
        }
    ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取指定标签的精选歌单列表。

GET /api/music/songList/list

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|source|query|string| 否 |none|
|tagId|query|string| 否 |none|
|sortId|query|string| 否 |none|
|page|query|string| 否 |none|

> 返回示例

```json
Not Found
```

```json
{
    "list": [
        {
            "play_count": "6952.2万",
            "id": "id_3280341",
            "author": "不二",
            "name": "青春记忆丨那些年我们循环的歌",
            "time": "2020-11-20",
            "img": "http://c1.kgimg.com/custom/240/20250923/20250923092206204920.jpg",
            "grade": 0,
            "desc": "有些歌，一听就像打开了时光机。那些年循环的每一句，藏着我们的欢笑、遗憾，还有再也回不去的旧时光。\n\n歌单整理：不二臣",
            "source": "kg"
        },
        {
            "play_count": "10288.5万",
            "id": "id_3208532",
            "author": "咸鱼大饼干",
            "name": "8090后经典老歌丨怀旧金曲唤醒青春记忆",
            "time": "2020-10-26",
            "img": "http://c1.kgimg.com/custom/240/20260223/20260223174958787645.jpg",
            "grade": 0,
            "desc": "在一个安静的夜晚，无意间点放了一首老歌，很久没有听老歌的我，想要切换歌曲，但瞬间又不想换歌了，歌声仿佛让从前又呈现在眼前。那时的一切依然历历在目，那些曾让自己开怀大笑的人、那些让自己烦恼何其多的事、那些如此熟悉的地方。\n一切如此熟悉又陌生，那个阳光明媚的午后，在学校教室里，广播放着歌，你与我讨论这这首歌，这首歌很好听，你知道叫什么名字吗？我也不知道，啊哈哈哈.......\n\n那些笑声越来越远，那些人脸越来越模糊，那些时光不会回来了，只有那时候听的歌，像个老朋友在回忆陪着我们，告诉我们别忘记那些回忆。.",
            "source": "kg"
        },
        {
            "play_count": "777.2万",
            "id": "id_3083027",
            "author": "ACG小编-蘑菇娘",
            "name": "那些陪着你长大的动画歌曲",
            "time": "2020-09-17",
            "img": "http://imge.kugou.com/soft/collection/240/20200917/20200917165326473064.jpg",
            "grade": 0,
            "desc": "即使再忙，也愿你闲暇时可以倾耳聆听这些曾经陪着你的声音，哪怕找回一点点当时的回忆也便满足了。",
            "source": "kg"
        },
        {
            "play_count": "2157.2万",
            "id": "id_2623899",
            "author": "嗜粤成瘾Tony",
            "name": "张国荣甄选：怀念你那风华绝代的美",
            "time": "2020-06-07",
            "img": "http://c1.kgimg.com/custom/240/20200801/20200801173908635484.jpg",
            "grade": 0,
            "desc": "张国荣甄选粤语金曲，怀念远去的旧事。",
            "source": "kg"
        },
        {
            "play_count": "2914.8万",
            "id": "id_2928868",
            "author": "予你情诗百首",
            "name": "老歌最有味！我们永远18岁",
            "time": "2020-08-19",
            "img": "http://c1.kgimg.com/custom/240/20200819/20200819082456522725.jpg",
            "grade": 0,
            "desc": "老歌除了给人以愉悦之外，也叫人愈发觉得生活的可贵与不易。歌词里的爱情，歌词里的往事，像是一种冥冥之中注定的情愫给我们不一样的情境。如果时光可以倒回，听着歌的我们是否内心会更惬意，就如回不去的18岁。\n \n可是当音乐响起，仿佛觉得自己又是18岁，\n老歌最动情，我们永远18岁。\n ",
            "source": "kg"
        },
        {
            "play_count": "1209.8万",
            "id": "id_2860428",
            "author": "清水蓝",
            "name": "备胎金曲‖不甘做朋友，不敢做恋人",
            "time": "2020-08-01",
            "img": "http://c1.kgimg.com/custom/240/20200801/20200801203358207860.jpg",
            "grade": 0,
            "desc": "我有一万种想见你的理由，却少了一种能见你的身份。",
            "source": "kg"
        },
        {
            "play_count": "797.4万",
            "id": "id_2825660",
            "author": "蝶影丛虫",
            "name": "电影美人，生若浮云流光飞舞",
            "time": "2020-07-25",
            "img": "http://c1.kgimg.com/custom/240/20200725/20200725180519802921.jpg",
            "grade": 0,
            "desc": "封面电影：《青蛇》/ 王祖贤\n\n华语电影里的她们，流光四溢风情万种，倾倒众生一生不羁；\n\n她们浮生如云，不知何时停下何时飘走，因她们只为风而动。\n\n1—2青蛇/小青：张曼玉，白蛇:王祖贤\n\n3—4倩女幽魂/小倩:王祖贤\n\n5大话西游/紫霞：朱茵  白晶晶：莫文蔚\n\n6-7笑傲江湖之东方不败/东方不败：林青霞\n\n8-9笑傲江湖之风云再起/雪千寻：王祖贤\n\n10新天龙八部之天山童姥/李秋水：林青霞\n\n11-12白发魔女传/练霓裳:林青霞\n\n13-14东邪西毒/慕容嫣：林青霞，西毒之嫂：张曼玉\n\n15海上花/黄翠凤：李嘉欣\n\n16—17阮玲玉／张曼玉\n\n18—19／游园惊梦/翠花：宫泽里惠    荣兰：王祖贤\n\n20胭脂扣/如花：梅艳芳\n\n21夜半歌声/杜云嫣：吴倩莲\n\n22和平饭店/阿曼：叶童\n\n23色.戒/王佳芝：汤唯\n\n24长恨歌/王琦瑶：郑秀文\n\n25滚滚红尘/沈韶华：林青霞\n\n26黄金时代/萧红:汤唯\n\n27一代宗师/宫二：章子怡\n\n28-29花样年华/苏丽珍：张曼玉\n\n30—33阿飞正传/苏丽珍：张曼玉  咪咪：刘嘉玲\n\n34—35.2046/章子怡、王菲、刘嘉玲\n\n36流金岁月/朱锁锁：钟楚红\n\n37秋天的童话/李琪：钟楚红\n\n38英雄本色3.夕阳之歌/英杰：梅艳芳\n\n39喋血街头/甄秀清：甄楚倩\n\n40旺角卡门/阿娥：张曼玉\n\n41天若有情/Jojo：吴倩莲\n\n42—43玻璃之城/韵文：舒淇\n\n44—45星月童话/瞳：常盘贵子\n\n46—47重庆森林/阿菲:王菲\n\n48-49堕落天使/天使二号：李嘉欣\n\n50恋战冲绳/Jenny：王菲\n\n51偷偷爱你/东东：邱淑贞\n\n52喜剧之王/柳飘飘：张柏芝\n\n53千禧曼波/Vicky:舒淇\n\n54前度/周怡:钟欣桐\n\n55颐和园/余虹:郝蕾",
            "source": "kg"
        },
        {
            "play_count": "1147.2万",
            "id": "id_2657566",
            "author": "华语杂货铺",
            "name": "丰华唱片官方精选歌单",
            "time": "2020-06-16",
            "img": "http://imge.kugou.com/soft/collection/240/20200619/20200619214455489636.jpg",
            "grade": 0,
            "desc": "酷狗音乐 × 丰华唱片达成独家版权合作！华语流行乐黄金记忆回归，唤醒你的独家记忆。",
            "source": "kg"
        },
        {
            "play_count": "1107.3万",
            "id": "id_2549193",
            "author": "予你情诗百首",
            "name": "音乐早班车！行走在路上的CD",
            "time": "2020-05-21",
            "img": "http://c1.kgimg.com/custom/240/20200521/20200521085840747541.jpg",
            "grade": 0,
            "desc": "行走在路上的CD，顾名思义是我们时常挂在嘴边哼唱的歌，又或者时你的歌单红心曲目，再或者是你KTV里经常点播的歌曲。无论是上学路上还是上班路上，总有那么一首歌，让你慢慢融入其中，从而不知不觉就到了目的地。\n \n今天的歌曲全部是我喜欢的，也是我一直收录在手机里的歌。希望这些分享能够带给你不一样的氛围。至少从某种意义上来说，听这些歌，能让你感受到一个场景，可以是同学、父母，也可以是多年前发生的事情。\n \n听歌吧！记得收藏，记得关注。我是情诗，爱音乐的情诗。",
            "source": "kg"
        },
        {
            "play_count": "7661.9万",
            "id": "id_2491680",
            "author": "咸鱼大饼干",
            "name": "歌声飘过二十年，悲伤依可感同身受",
            "time": "2020-05-07",
            "img": "http://c1.kgimg.com/custom/240/20200507/20200507212502152290.jpg",
            "grade": 0,
            "desc": "这些歌声飘过二十年，悲伤依可感同身受\n\n\n有没有一首歌跨越多年代，让人们为此感同身受呢？\n\n答案是：是有的，有些歌，无论多久了，依然让年轻人与当年的人一样为此感同身受。\n人们，总是说不同年代人们会有隔阂，特别是年轻人与当年代的人。但我想说，在音乐世界了，人们没有隔阂，特别是对于情感认知上。\n\n对于”悲伤”，相对于欢乐，人们对于悲伤会更刻苦铭心。那些一开始初听不识歌者，如今或已是歌中人了，才会更加明白歌曲，原来是那么让人感同身受的。才会明白，对于以前，那些为感情伤心沉沦的人，是如此的难受与痛苦。\n如刘若英的歌曲《后来》，这首歌到如今已有二十年了，一样还在被人们唱着。因为感同身受，无论跨越多长年代，二十年过后，总有人像歌里故事一样，悲情电影又重新上映了。\n\n又轮到谁？伤心沉沦呢？\n\n一代人青春将离去，但总有人正年轻，又重复着上代人的故事，又重复听着上代人的歌。",
            "source": "kg"
        },
        {
            "play_count": "561.5万",
            "id": "id_2326187",
            "author": "日语小编-小樱",
            "name": "回忆经典：平成怀旧日语金曲",
            "time": "2020-04-07",
            "img": "http://imge.kugou.com/soft/collection/240/20200407/20200407180828843157.jpg",
            "grade": 0,
            "desc": "平成过去了，我很怀念它，那些记忆中的日语歌，都是青春中不可磨灭的记忆。",
            "source": "kg"
        },
        {
            "play_count": "7393.7万",
            "id": "id_2297061",
            "author": "秋月如霜qyrs",
            "name": "怀旧华语：老情歌里的青春往事",
            "time": "2020-04-01",
            "img": "http://c1.kgimg.com/custom/240/20200401/20200401153757691055.jpg",
            "grade": 0,
            "desc": "我记得学生时代，是不愿意跟同学交流歌曲的，因为我听的都是老歌，跟不上大家的潮流，怕被人嘲笑。我都是回家之后，偷偷地一个人听。\n当时家里，唯一能与我讨论歌曲的是我的奶奶。我从奶奶的口中，知道了毛宁、蔡国庆、蒋大为等很多歌唱家。\n以前我听歌，都是从电视上听。我从电视上知道了张信哲、辛晓琪、许茹芸……他们的歌也进了我的歌单。\n后来，我学会了上网，用各种播放器听歌曲。从各种推荐列表里知道了王杰、Beyond、张国荣……他们的歌我也非常喜欢。\n我喜欢听老歌，也想通过歌单的方式，把我喜欢的老歌推荐给大家。",
            "source": "kg"
        },
        {
            "play_count": "6322.9万",
            "id": "id_2300296",
            "author": "☆冰雨欣☆🎸",
            "name": "华语老歌：唯有经典长留心间",
            "time": "2020-04-02",
            "img": "http://c1.kgimg.com/custom/240/20200402/20200402145028646759.jpg",
            "grade": 0,
            "desc": "无情的岁月总是在悄悄的流逝，不会为你停下片刻的脚步，唯有经典的老歌总是在你心中回荡。",
            "source": "kg"
        },
        {
            "play_count": "294.6万",
            "id": "id_2287118",
            "author": "ACG小编-蘑菇娘",
            "name": "永远的坂井泉水|ZARD歌曲精选集",
            "time": "2020-03-30",
            "img": "http://imge.kugou.com/soft/collection/240/20200330/20200330165418513291.jpg",
            "grade": 0,
            "desc": "负けないで,永远的坂井泉水，永远的ZARD。",
            "source": "kg"
        },
        {
            "play_count": "2172.7万",
            "id": "id_2266640",
            "author": "梅雨西子",
            "name": "回顾经典：怀念哥哥张国荣，思念永相随",
            "time": "2020-03-26",
            "img": "http://c1.kgimg.com/custom/240/20200326/20200326092225796947.jpg",
            "grade": 0,
            "desc": "又是4月1日。自2003年4月1日至2020年4月1日,哥哥已逝世17周年。\n对于最好的哥哥来说，世界永远不会忘记他，重温他的经典作品，再见亦是怀念。愿他在那边一切安好，今日只为你停留。\n\n哥哥是一位成功的演员，歌手，音乐人，他是一位善良，宽容，坚强，热诚，一个具有共生美德的人，他温暖有力，却又柔和持久。\n\n自尔离去方识君\n从中感韵渐觉深\n世上再无张国荣\n人间惟念四月天\n与君一别十七载\n从此再无愚人节\n怀念哥哥张国荣\n思念永相随",
            "source": "kg"
        },
        {
            "play_count": "4272.1万",
            "id": "id_2110902",
            "author": "咸鱼大饼干",
            "name": "怀念青涩纯真岁月，好时光一去不复返",
            "time": "2020-02-24",
            "img": "http://imge.kugou.com/soft/collection/240/20200224/20200224171805245387.jpg",
            "grade": 0,
            "desc": "那一年，有一个人的名字，被写在书本上。那一年，有一首歌，被我轻轻唱，想温柔地献唱给你。那一年，有一段漫长的思念，想一直在你身边永远陪伴。那一年，有一个人在你身后，发着呆深情注视着。那一年，还有抄写在本子上的情歌，尽管一直唱跑调，但会不厌其烦反复练习。\n\n时光瞬间眨眼而过，如今对于那年那段回忆也有些模糊了，但是有个声音一直留记在心里，就那时候与你一起唱的情歌。那时候点爱情简单单纯，以为我与你唱着这首情歌，以后会在一起天长地久。\n\n你是否还记得那段美好回忆，简单快乐青涩觉得漫长的时光。\n\n回不去的回忆叫做美好，永远被刻在泛黄书本上闪耀。当某天你再次翻看当年词抄本时，再次唱起跑调的情歌时，你的心是否还会再次紧张跳动？",
            "source": "kg"
        },
        {
            "play_count": "2255.5万",
            "id": "id_2058529",
            "author": "李呀",
            "name": "『时光机』藏在MP3里闪闪发光的记忆",
            "time": "2020-01-14",
            "img": "http://c1.kgimg.com/custom/240/20200211/20200211225157524444.jpg",
            "grade": 0,
            "desc": "那时候没有电脑，很多歌还是要去外面找卖mp3的老板花钱下载，而且是千千静听下载，很多歌都找不到。\n\n现在不行了，随时可以听国内外所有的专辑，但很少有哪一首新歌可以让我有下载的冲动，大多也只是听听就算了。",
            "source": "kg"
        },
        {
            "play_count": "580.9万",
            "id": "id_1916687",
            "author": "Ru花一般绽放",
            "name": "@所有人！送你一张重返2000年的车票",
            "time": "2020-01-16",
            "img": "http://c1.kgimg.com/custom/240/20200116/20200116092300367769.jpg",
            "grade": 0,
            "desc": "2000年，你读几年级？\n2000年，你的梦想是什么？\n2000年，你是否心存遗憾？\n2000年，你在听什么歌？\n \n今天的歌单收录了2000年，华语乐坛较为好听的曲目。也许会有你的记忆，也许这些歌曾留下你的故事。在听歌的同时，也欢迎大家给我留言，分享你的故事。一起听歌吧！",
            "source": "kg"
        },
        {
            "play_count": "717.5万",
            "id": "id_1871311",
            "author": "蝶影丛虫",
            "name": "香港经典贺岁片：新春电影非你莫鼠",
            "time": "2020-01-12",
            "img": "http://imge.kugou.com/soft/collection/240/20200427/20200427160707318503.jpg",
            "grade": 0,
            "desc": "上世纪八十至九十年代是香港影片驰骋亚洲的时期，香港电影的繁荣程度迄今无法超越。因为繁荣的电影市场，让香港电影诞生了“贺岁片“这一概念。贺岁片，顾名思义，就是为了“贺岁”祝贺新年的意思。这些影片都集中在元旦或者春节期间播出，一般都是轻松幽默的，同时具有强烈的娱乐性的喜剧片。\n\n本期歌单主题就是1981-2010香港三十年经典贺岁片，祝大家新春愉快，吉祥如意！\n\n具体片单在歌单评论回复里。",
            "source": "kg"
        },
        {
            "play_count": "3535.1万",
            "id": "id_1855630",
            "author": "念安娜",
            "name": "经典英文歌：脑海里行走的留声机",
            "time": "2020-01-03",
            "img": "http://c1.kgimg.com/custom/240/20200103/20200103170323880786.jpg",
            "grade": 0,
            "desc": "很多英文歌，初听时，或许是来自歌手的名气，又或许是一首真正意义上的好歌，但是很少有歌从一开始就火，而后经历几十年依然红火，乃至现今被人称为经典。今天推荐的歌曲，像是一台留声机，时刻在脑海里回响，故而毫无缘由便喜欢上，一年又一年。\n \n希望在听这些歌曲的同时，你的内心是火热的，因为好在还有那么多人，不被网络的推波助澜而忽略这些经典的存在，这本身就是一件幸事。\n \n一起听歌，喜欢的话请关注我！",
            "source": "kg"
        }
    ],
    "limit": 20,
    "page": 1,
    "total": 2000,
    "source": "kg"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取歌单详情（完整歌曲列表）

GET /api/music/songList/detail

> Body 请求参数

```json
{}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|source|query|string| 否 |none|
|id|query|string| 否 |none|
|page|query|string| 否 |none|
|body|body|object| 是 |none|

> 返回示例

> 200 Response

```json
{
    "list": [
        {
            "singer": "水木年华",
            "name": "一生有你",
            "albumName": "一生有你",
            "albumId": "961898",
            "songmid": "341213",
            "source": "kg",
            "interval": "04:18",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909135529532401.jpg",
            "lrc": null,
            "hash": "B296619A5A37920C595FA5954CB7AA60",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.94 MB",
                    "hash": "B296619A5A37920C595FA5954CB7AA60"
                },
                {
                    "type": "320k",
                    "size": "9.85 MB",
                    "hash": "E4303506FFA1757A3D1C91DA945EFCCB"
                },
                {
                    "type": "flac",
                    "size": "26.00 MB",
                    "hash": "74AC7E376ABBCA2E6C59D7AE0A2D5B2B"
                },
                {
                    "type": "flac24bit",
                    "size": "47.44 MB",
                    "hash": "49D1A436078A43BFA2E5EB059E28A451"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.94 MB",
                    "hash": "B296619A5A37920C595FA5954CB7AA60"
                },
                "320k": {
                    "size": "9.85 MB",
                    "hash": "E4303506FFA1757A3D1C91DA945EFCCB"
                },
                "flac": {
                    "size": "26.00 MB",
                    "hash": "74AC7E376ABBCA2E6C59D7AE0A2D5B2B"
                },
                "flac24bit": {
                    "size": "47.44 MB",
                    "hash": "49D1A436078A43BFA2E5EB059E28A451"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张韶涵",
            "name": "隐形的翅膀",
            "albumName": "潘朵拉",
            "albumId": "8874253",
            "songmid": "338130",
            "source": "kg",
            "interval": "03:44",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121722931394.jpg",
            "lrc": null,
            "hash": "4D97C65307F81E2A34EA13F9ECB27F5A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.42 MB",
                    "hash": "4D97C65307F81E2A34EA13F9ECB27F5A"
                },
                {
                    "type": "320k",
                    "size": "8.55 MB",
                    "hash": "827D05E945158DC7052AF7D176B452DE"
                },
                {
                    "type": "flac",
                    "size": "23.33 MB",
                    "hash": "310F9C7BB5C390E0CB6F14A98521614F"
                },
                {
                    "type": "flac24bit",
                    "size": "23.80 MB",
                    "hash": "8F8D983DFE4A78A79BE9E53FB14E9EF7"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.42 MB",
                    "hash": "4D97C65307F81E2A34EA13F9ECB27F5A"
                },
                "320k": {
                    "size": "8.55 MB",
                    "hash": "827D05E945158DC7052AF7D176B452DE"
                },
                "flac": {
                    "size": "23.33 MB",
                    "hash": "310F9C7BB5C390E0CB6F14A98521614F"
                },
                "flac24bit": {
                    "size": "23.80 MB",
                    "hash": "8F8D983DFE4A78A79BE9E53FB14E9EF7"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张信哲",
            "name": "爱就一个字",
            "albumName": "从开始到现在",
            "albumId": "962841",
            "songmid": "1082843970",
            "source": "kg",
            "interval": "04:34",
            "img": "http://imge.kugou.com/stdmusic/400/20220815/20220815125805983524.jpg",
            "lrc": null,
            "hash": "E1FA88F0478687958B0FBA77F85817BB",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.18 MB",
                    "hash": "E1FA88F0478687958B0FBA77F85817BB"
                },
                {
                    "type": "320k",
                    "size": "10.45 MB",
                    "hash": "0285BFF3AB4D8725EF1BE0C371154F6F"
                },
                {
                    "type": "flac",
                    "size": "30.56 MB",
                    "hash": "CE21F43CC35ACE06B10E8F703457AC48"
                },
                {
                    "type": "flac24bit",
                    "size": "31.50 MB",
                    "hash": "1E02257D9B7009D81FB12F23A3C432D5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.18 MB",
                    "hash": "E1FA88F0478687958B0FBA77F85817BB"
                },
                "320k": {
                    "size": "10.45 MB",
                    "hash": "0285BFF3AB4D8725EF1BE0C371154F6F"
                },
                "flac": {
                    "size": "30.56 MB",
                    "hash": "CE21F43CC35ACE06B10E8F703457AC48"
                },
                "flac24bit": {
                    "size": "31.50 MB",
                    "hash": "1E02257D9B7009D81FB12F23A3C432D5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周杰伦",
            "name": "一路向北",
            "albumName": "十一月的萧邦",
            "albumId": "958909",
            "songmid": "327803",
            "source": "kg",
            "interval": "04:55",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121901851911.jpg",
            "lrc": null,
            "hash": "FAF6B9ADBB45D17D7B00DA79A16BB333",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.51 MB",
                    "hash": "FAF6B9ADBB45D17D7B00DA79A16BB333"
                },
                {
                    "type": "320k",
                    "size": "11.28 MB",
                    "hash": "574A5756D7A56C20E0706CD5D03C45EA"
                },
                {
                    "type": "flac",
                    "size": "33.69 MB",
                    "hash": "FA93F363E0EB0A2CAB430760E19B8A97"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.51 MB",
                    "hash": "FAF6B9ADBB45D17D7B00DA79A16BB333"
                },
                "320k": {
                    "size": "11.28 MB",
                    "hash": "574A5756D7A56C20E0706CD5D03C45EA"
                },
                "flac": {
                    "size": "33.69 MB",
                    "hash": "FA93F363E0EB0A2CAB430760E19B8A97"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张韶涵",
            "name": "不想懂得",
            "albumName": "Ang 5.0",
            "albumId": "961838",
            "songmid": "221028",
            "source": "kg",
            "interval": "04:36",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121738697554.jpg",
            "lrc": null,
            "hash": "C869AF6A143327FF002069049064504C",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.22 MB",
                    "hash": "C869AF6A143327FF002069049064504C"
                },
                {
                    "type": "320k",
                    "size": "10.55 MB",
                    "hash": "0D22A591324C04629CE35CDE3888BA6B"
                },
                {
                    "type": "flac",
                    "size": "30.97 MB",
                    "hash": "BCEEDCF4A15CFC3E003A9DA69185C524"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.22 MB",
                    "hash": "C869AF6A143327FF002069049064504C"
                },
                "320k": {
                    "size": "10.55 MB",
                    "hash": "0D22A591324C04629CE35CDE3888BA6B"
                },
                "flac": {
                    "size": "30.97 MB",
                    "hash": "BCEEDCF4A15CFC3E003A9DA69185C524"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张宇",
            "name": "雨一直下",
            "albumName": "雨一直下",
            "albumId": "982663",
            "songmid": "339102",
            "source": "kg",
            "interval": "04:50",
            "img": "http://imge.kugou.com/stdmusic/400/20251114/20251114044031114515.jpg",
            "lrc": null,
            "hash": "34FE2E947618E8EC4B9C7DB0366043A7",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.43 MB",
                    "hash": "34FE2E947618E8EC4B9C7DB0366043A7"
                },
                {
                    "type": "320k",
                    "size": "11.08 MB",
                    "hash": "9FB3431E3C028B34998DA35767A59555"
                },
                {
                    "type": "flac",
                    "size": "35.69 MB",
                    "hash": "EF4631A53A392FF315DA9D4DA6CB26A1"
                },
                {
                    "type": "flac24bit",
                    "size": "36.63 MB",
                    "hash": "CCF161D3A3E1B7A736059DA43F70CDC5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.43 MB",
                    "hash": "34FE2E947618E8EC4B9C7DB0366043A7"
                },
                "320k": {
                    "size": "11.08 MB",
                    "hash": "9FB3431E3C028B34998DA35767A59555"
                },
                "flac": {
                    "size": "35.69 MB",
                    "hash": "EF4631A53A392FF315DA9D4DA6CB26A1"
                },
                "flac24bit": {
                    "size": "36.63 MB",
                    "hash": "CCF161D3A3E1B7A736059DA43F70CDC5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "水木年华",
            "name": "在他乡 (乡村摇滚版)",
            "albumName": "水木年华3 新歌+精选",
            "albumId": "18743994",
            "songmid": "302418333",
            "source": "kg",
            "interval": "03:33",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909135946618021.jpg",
            "lrc": null,
            "hash": "3EA5053AA48F9CBF9CFA93A6479EF1E0",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.26 MB",
                    "hash": "3EA5053AA48F9CBF9CFA93A6479EF1E0"
                },
                {
                    "type": "320k",
                    "size": "8.14 MB",
                    "hash": "2215407B0002CD0C0D38568E9686318F"
                },
                {
                    "type": "flac",
                    "size": "27.17 MB",
                    "hash": "1F9C5FC690E15CEF475E298756693E04"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.26 MB",
                    "hash": "3EA5053AA48F9CBF9CFA93A6479EF1E0"
                },
                "320k": {
                    "size": "8.14 MB",
                    "hash": "2215407B0002CD0C0D38568E9686318F"
                },
                "flac": {
                    "size": "27.17 MB",
                    "hash": "1F9C5FC690E15CEF475E298756693E04"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "那英",
            "name": "出卖",
            "albumName": "知英情歌 那英精选",
            "albumId": "2997270",
            "songmid": "304954584",
            "source": "kg",
            "interval": "04:21",
            "img": "http://imge.kugou.com/stdmusic/400/20250101/20250101065516234909.jpg",
            "lrc": null,
            "hash": "95148A24AF08C7AB93C24A618D8233FB",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.00 MB",
                    "hash": "95148A24AF08C7AB93C24A618D8233FB"
                },
                {
                    "type": "320k",
                    "size": "10.00 MB",
                    "hash": "35EA4FDB618359DFDFC13C43665DD42B"
                },
                {
                    "type": "flac",
                    "size": "26.08 MB",
                    "hash": "407A128FE76560FD405B2749781294E0"
                },
                {
                    "type": "flac24bit",
                    "size": "26.62 MB",
                    "hash": "A24DA3EDEAE4971E8D1085F3CEAF9FA9"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.00 MB",
                    "hash": "95148A24AF08C7AB93C24A618D8233FB"
                },
                "320k": {
                    "size": "10.00 MB",
                    "hash": "35EA4FDB618359DFDFC13C43665DD42B"
                },
                "flac": {
                    "size": "26.08 MB",
                    "hash": "407A128FE76560FD405B2749781294E0"
                },
                "flac24bit": {
                    "size": "26.62 MB",
                    "hash": "A24DA3EDEAE4971E8D1085F3CEAF9FA9"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "蔡依林、周杰伦",
            "name": "布拉格广场",
            "albumName": "看我72变",
            "albumId": "976104",
            "songmid": "344934",
            "source": "kg",
            "interval": "04:54",
            "img": "http://imge.kugou.com/stdmusic/400/20250121/20250121105102268944.jpg",
            "lrc": null,
            "hash": "11ED7139CB728E806E9CFFEA8BF736CC",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.50 MB",
                    "hash": "11ED7139CB728E806E9CFFEA8BF736CC"
                },
                {
                    "type": "320k",
                    "size": "11.24 MB",
                    "hash": "37CDA403FBFEF940E41486EF79D0057A"
                },
                {
                    "type": "flac",
                    "size": "33.13 MB",
                    "hash": "152BEAE531571D79E0785E93209B2DA3"
                },
                {
                    "type": "flac24bit",
                    "size": "33.69 MB",
                    "hash": "4A07580FB707281801A6CCC413F8145F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.50 MB",
                    "hash": "11ED7139CB728E806E9CFFEA8BF736CC"
                },
                "320k": {
                    "size": "11.24 MB",
                    "hash": "37CDA403FBFEF940E41486EF79D0057A"
                },
                "flac": {
                    "size": "33.13 MB",
                    "hash": "152BEAE531571D79E0785E93209B2DA3"
                },
                "flac24bit": {
                    "size": "33.69 MB",
                    "hash": "4A07580FB707281801A6CCC413F8145F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张学友",
            "name": "慢慢",
            "albumName": "BLACK & WHITE(DISC 2)",
            "albumId": "18161807",
            "songmid": "302501051",
            "source": "kg",
            "interval": "04:44",
            "img": "http://imge.kugou.com/stdmusic/400/20190320/20190320094225241647.jpg",
            "lrc": null,
            "hash": "83760CA591F129C959F146335301136B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.35 MB",
                    "hash": "83760CA591F129C959F146335301136B"
                },
                {
                    "type": "320k",
                    "size": "10.87 MB",
                    "hash": "E82E31A73EA7C4C5461F24D34E7208C8"
                },
                {
                    "type": "flac",
                    "size": "28.10 MB",
                    "hash": "8B964E69311B293C4C6D2A2A6C3CDEA7"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.35 MB",
                    "hash": "83760CA591F129C959F146335301136B"
                },
                "320k": {
                    "size": "10.87 MB",
                    "hash": "E82E31A73EA7C4C5461F24D34E7208C8"
                },
                "flac": {
                    "size": "28.10 MB",
                    "hash": "8B964E69311B293C4C6D2A2A6C3CDEA7"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周传雄",
            "name": "末班车",
            "albumName": "transfer",
            "albumId": "964612",
            "songmid": "7985",
            "source": "kg",
            "interval": "05:13",
            "img": "http://imge.kugou.com/stdmusic/400/20200210/20200210112815395310.jpg",
            "lrc": null,
            "hash": "0F7259E118304F07D98D3C97EF4AE9EB",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.78 MB",
                    "hash": "0F7259E118304F07D98D3C97EF4AE9EB"
                },
                {
                    "type": "320k",
                    "size": "11.96 MB",
                    "hash": "4D476819FBDE0F775E6FE064F7056002"
                },
                {
                    "type": "flac",
                    "size": "35.54 MB",
                    "hash": "B21EC5C8F91742E4617225C74390DF43"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.78 MB",
                    "hash": "0F7259E118304F07D98D3C97EF4AE9EB"
                },
                "320k": {
                    "size": "11.96 MB",
                    "hash": "4D476819FBDE0F775E6FE064F7056002"
                },
                "flac": {
                    "size": "35.54 MB",
                    "hash": "B21EC5C8F91742E4617225C74390DF43"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "那英",
            "name": "白天不懂夜的黑",
            "albumName": "K情歌2",
            "albumId": "555864",
            "songmid": "1082943333",
            "source": "kg",
            "interval": "04:01",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909123847297611.jpg",
            "lrc": null,
            "hash": "6C20FCDD16C25E4FF6918B1771376FF1",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.69 MB",
                    "hash": "6C20FCDD16C25E4FF6918B1771376FF1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.69 MB",
                    "hash": "6C20FCDD16C25E4FF6918B1771376FF1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王菲",
            "name": "我愿意",
            "albumName": "失物招领Lost & Found - 王菲精选",
            "albumId": "1963051",
            "songmid": "61641152",
            "source": "kg",
            "interval": "04:30",
            "img": "http://imge.kugou.com/stdmusic/400/20250101/20250101065913946073.jpg",
            "lrc": null,
            "hash": "9854AA5C338E01AC64BCAA3C369F30FE",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.13 MB",
                    "hash": "9854AA5C338E01AC64BCAA3C369F30FE"
                },
                {
                    "type": "320k",
                    "size": "10.33 MB",
                    "hash": "32403392BED78F3197D75A6C7E863BB4"
                },
                {
                    "type": "flac",
                    "size": "25.38 MB",
                    "hash": "8898797A554464761616ADEF21EE7C55"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.13 MB",
                    "hash": "9854AA5C338E01AC64BCAA3C369F30FE"
                },
                "320k": {
                    "size": "10.33 MB",
                    "hash": "32403392BED78F3197D75A6C7E863BB4"
                },
                "flac": {
                    "size": "25.38 MB",
                    "hash": "8898797A554464761616ADEF21EE7C55"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张学友",
            "name": "一路上有你",
            "albumName": "Black & White",
            "albumId": "973142",
            "songmid": "302435701",
            "source": "kg",
            "interval": "04:47",
            "img": "http://imge.kugou.com/stdmusic/400/20250521/20250521224818514539.jpg",
            "lrc": null,
            "hash": "F3507BD41A6A3D216C2829D95AC7B9AA",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.38 MB",
                    "hash": "F3507BD41A6A3D216C2829D95AC7B9AA"
                },
                {
                    "type": "320k",
                    "size": "10.96 MB",
                    "hash": "55A12BC5B0B08AFA68AA9972B3AFB34D"
                },
                {
                    "type": "flac",
                    "size": "28.56 MB",
                    "hash": "E71E1A8B392B037EC9510A132E10C730"
                },
                {
                    "type": "flac24bit",
                    "size": "29.55 MB",
                    "hash": "2E989B8F49919B089CD02273AB2386D2"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.38 MB",
                    "hash": "F3507BD41A6A3D216C2829D95AC7B9AA"
                },
                "320k": {
                    "size": "10.96 MB",
                    "hash": "55A12BC5B0B08AFA68AA9972B3AFB34D"
                },
                "flac": {
                    "size": "28.56 MB",
                    "hash": "E71E1A8B392B037EC9510A132E10C730"
                },
                "flac24bit": {
                    "size": "29.55 MB",
                    "hash": "2E989B8F49919B089CD02273AB2386D2"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "末路豪强",
            "name": "0190__那一天",
            "albumName": "随车音乐",
            "albumId": "55416760",
            "songmid": "1049464467",
            "source": "kg",
            "interval": "05:03",
            "img": "http://imge.kugou.com/stdmusic/400/20210829/20210829131603703379.jpg",
            "lrc": null,
            "hash": "B961CD5E496775C275F0942315E5FC06",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.64 MB",
                    "hash": "B961CD5E496775C275F0942315E5FC06"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.64 MB",
                    "hash": "B961CD5E496775C275F0942315E5FC06"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陶喆",
            "name": "爱我还是他",
            "albumName": "太平盛世",
            "albumId": "7547427",
            "songmid": "254449",
            "source": "kg",
            "interval": "04:52",
            "img": "http://imge.kugou.com/stdmusic/400/20220722/20220722102806542994.jpg",
            "lrc": null,
            "hash": "004A93C3A157D825B92A91EEB17DA36A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.47 MB",
                    "hash": "004A93C3A157D825B92A91EEB17DA36A"
                },
                {
                    "type": "320k",
                    "size": "11.17 MB",
                    "hash": "8E1DD5064E9D5DF71AD1FFC5F1D2C1C0"
                },
                {
                    "type": "flac",
                    "size": "27.93 MB",
                    "hash": "B12D7F2A73687E00C79E35470FB01845"
                },
                {
                    "type": "flac24bit",
                    "size": "29.19 MB",
                    "hash": "DE0947365D986F2F92171D8B56D14366"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.47 MB",
                    "hash": "004A93C3A157D825B92A91EEB17DA36A"
                },
                "320k": {
                    "size": "11.17 MB",
                    "hash": "8E1DD5064E9D5DF71AD1FFC5F1D2C1C0"
                },
                "flac": {
                    "size": "27.93 MB",
                    "hash": "B12D7F2A73687E00C79E35470FB01845"
                },
                "flac24bit": {
                    "size": "29.19 MB",
                    "hash": "DE0947365D986F2F92171D8B56D14366"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "阿杜",
            "name": "他一定很爱你",
            "albumName": "醇情歌",
            "albumId": "966803",
            "songmid": "1082899666",
            "source": "kg",
            "interval": "03:34",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121750220384.jpg",
            "lrc": null,
            "hash": "DB8A7B9D3B5ACF582CE55E9F23648DF3",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.28 MB",
                    "hash": "DB8A7B9D3B5ACF582CE55E9F23648DF3"
                },
                {
                    "type": "320k",
                    "size": "8.20 MB",
                    "hash": "7BD727726E810E866355AB48BE202758"
                },
                {
                    "type": "flac",
                    "size": "22.23 MB",
                    "hash": "2165FBC4E4EF4A8EF8C946FC6B2F4127"
                },
                {
                    "type": "flac24bit",
                    "size": "22.87 MB",
                    "hash": "4EA27AED8E48FD02C5194161F0666B51"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.28 MB",
                    "hash": "DB8A7B9D3B5ACF582CE55E9F23648DF3"
                },
                "320k": {
                    "size": "8.20 MB",
                    "hash": "7BD727726E810E866355AB48BE202758"
                },
                "flac": {
                    "size": "22.23 MB",
                    "hash": "2165FBC4E4EF4A8EF8C946FC6B2F4127"
                },
                "flac24bit": {
                    "size": "22.87 MB",
                    "hash": "4EA27AED8E48FD02C5194161F0666B51"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "吴奇隆",
            "name": "烟火",
            "albumName": "一天一天等下去",
            "albumId": "565338",
            "songmid": "302512774",
            "source": "kg",
            "interval": "05:02",
            "img": "http://imge.kugou.com/stdmusic/400/20200927/20200927210722867771.jpg",
            "lrc": null,
            "hash": "A6D3F9CE25E5E497DDEBD3B5DD72E853",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.61 MB",
                    "hash": "A6D3F9CE25E5E497DDEBD3B5DD72E853"
                },
                {
                    "type": "320k",
                    "size": "11.54 MB",
                    "hash": "667882B40DDBCF054636535825B9338E"
                },
                {
                    "type": "flac",
                    "size": "30.95 MB",
                    "hash": "37A6B0644FFF47542C5342665100CB35"
                },
                {
                    "type": "flac24bit",
                    "size": "124.68 MB",
                    "hash": "0FB86783ED8F4801B2B820D4FD48A407"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.61 MB",
                    "hash": "A6D3F9CE25E5E497DDEBD3B5DD72E853"
                },
                "320k": {
                    "size": "11.54 MB",
                    "hash": "667882B40DDBCF054636535825B9338E"
                },
                "flac": {
                    "size": "30.95 MB",
                    "hash": "37A6B0644FFF47542C5342665100CB35"
                },
                "flac24bit": {
                    "size": "124.68 MB",
                    "hash": "0FB86783ED8F4801B2B820D4FD48A407"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "F4",
            "name": "绝不能失去你",
            "albumName": "烟火的季节",
            "albumId": "957262",
            "songmid": "205137",
            "source": "kg",
            "interval": "04:42",
            "img": "http://imge.kugou.com/stdmusic/400/20250722/20250722194955686674.jpg",
            "lrc": null,
            "hash": "B9193D5D5BF203FF4DFBF56F7C60090B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.31 MB",
                    "hash": "B9193D5D5BF203FF4DFBF56F7C60090B"
                },
                {
                    "type": "320k",
                    "size": "10.77 MB",
                    "hash": "C7557A4DF32219F2D540E70299736DE5"
                },
                {
                    "type": "flac",
                    "size": "32.91 MB",
                    "hash": "FA13CD89D225016349484F86A6D50577"
                },
                {
                    "type": "flac24bit",
                    "size": "34.01 MB",
                    "hash": "A8EC5BDCB273575B9E0082C05AF5ECCF"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.31 MB",
                    "hash": "B9193D5D5BF203FF4DFBF56F7C60090B"
                },
                "320k": {
                    "size": "10.77 MB",
                    "hash": "C7557A4DF32219F2D540E70299736DE5"
                },
                "flac": {
                    "size": "32.91 MB",
                    "hash": "FA13CD89D225016349484F86A6D50577"
                },
                "flac24bit": {
                    "size": "34.01 MB",
                    "hash": "A8EC5BDCB273575B9E0082C05AF5ECCF"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "刘若英",
            "name": "当爱在靠近",
            "albumName": "Love & the City",
            "albumId": "978209",
            "songmid": "275106",
            "source": "kg",
            "interval": "04:10",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121911260178.jpg",
            "lrc": null,
            "hash": "D988B9B4B769D979279D4AC9E84907F1",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.83 MB",
                    "hash": "D988B9B4B769D979279D4AC9E84907F1"
                },
                {
                    "type": "320k",
                    "size": "9.57 MB",
                    "hash": "49674204AC0B95E66D5ABCFB9A4FB687"
                },
                {
                    "type": "flac",
                    "size": "26.12 MB",
                    "hash": "5C93154968C871F28850FB5F7E3C2BD5"
                },
                {
                    "type": "flac24bit",
                    "size": "26.86 MB",
                    "hash": "B9DDA0688B44FA740724C622A5C1C0F2"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.83 MB",
                    "hash": "D988B9B4B769D979279D4AC9E84907F1"
                },
                "320k": {
                    "size": "9.57 MB",
                    "hash": "49674204AC0B95E66D5ABCFB9A4FB687"
                },
                "flac": {
                    "size": "26.12 MB",
                    "hash": "5C93154968C871F28850FB5F7E3C2BD5"
                },
                "flac24bit": {
                    "size": "26.86 MB",
                    "hash": "B9DDA0688B44FA740724C622A5C1C0F2"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "郭富城",
            "name": "我是不是该安静的走开 (单曲)",
            "albumName": "由零开始",
            "albumId": "56932622",
            "songmid": "302434655",
            "source": "kg",
            "interval": "03:59",
            "img": "http://imge.kugou.com/stdmusic/400/20200922/20200922070610271159.jpg",
            "lrc": null,
            "hash": "4DB897AFEEEB36C83F70E91846EDB019",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.66 MB",
                    "hash": "4DB897AFEEEB36C83F70E91846EDB019"
                },
                {
                    "type": "320k",
                    "size": "9.14 MB",
                    "hash": "ED6FF8AACD707B41349CE17E09F8FAC1"
                },
                {
                    "type": "flac",
                    "size": "28.14 MB",
                    "hash": "4AC0A260E221DD9E19EDD38026662D6C"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.66 MB",
                    "hash": "4DB897AFEEEB36C83F70E91846EDB019"
                },
                "320k": {
                    "size": "9.14 MB",
                    "hash": "ED6FF8AACD707B41349CE17E09F8FAC1"
                },
                "flac": {
                    "size": "28.14 MB",
                    "hash": "4AC0A260E221DD9E19EDD38026662D6C"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "蔡健雅",
            "name": "陌生人",
            "albumName": "华语女生",
            "albumId": "3751960",
            "songmid": "304641887",
            "source": "kg",
            "interval": "03:51",
            "img": "http://imge.kugou.com/stdmusic/400/20250207/20250207161147396987.jpg",
            "lrc": null,
            "hash": "FEB77D16FBA96BA5F27989B27BAD4612",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.54 MB",
                    "hash": "FEB77D16FBA96BA5F27989B27BAD4612"
                },
                {
                    "type": "320k",
                    "size": "8.85 MB",
                    "hash": "1EC8D2864903B754639E192B1169D982"
                },
                {
                    "type": "flac",
                    "size": "22.41 MB",
                    "hash": "A52D13228E3AB3921401057AB929B647"
                },
                {
                    "type": "flac24bit",
                    "size": "23.36 MB",
                    "hash": "230EA09046A08738847E8DA922692891"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.54 MB",
                    "hash": "FEB77D16FBA96BA5F27989B27BAD4612"
                },
                "320k": {
                    "size": "8.85 MB",
                    "hash": "1EC8D2864903B754639E192B1169D982"
                },
                "flac": {
                    "size": "22.41 MB",
                    "hash": "A52D13228E3AB3921401057AB929B647"
                },
                "flac24bit": {
                    "size": "23.36 MB",
                    "hash": "230EA09046A08738847E8DA922692891"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "范玮琪、张韶涵",
            "name": "如果的事",
            "albumName": "2006韩剧超强情歌精选No.1",
            "albumId": "8339107",
            "songmid": "302455461",
            "source": "kg",
            "interval": "03:49",
            "img": "http://imge.kugou.com/stdmusic/400/20160908/20160908063639697857.jpg",
            "lrc": null,
            "hash": "67B535E82573A5B5FC237C7ED161D725",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.50 MB",
                    "hash": "67B535E82573A5B5FC237C7ED161D725"
                },
                {
                    "type": "320k",
                    "size": "8.74 MB",
                    "hash": "0C52055D6E7DB7772C0C99B6821B6A03"
                },
                {
                    "type": "flac",
                    "size": "24.73 MB",
                    "hash": "2820735BA0DE1C3CA37EBEF5153F2AE5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.50 MB",
                    "hash": "67B535E82573A5B5FC237C7ED161D725"
                },
                "320k": {
                    "size": "8.74 MB",
                    "hash": "0C52055D6E7DB7772C0C99B6821B6A03"
                },
                "flac": {
                    "size": "24.73 MB",
                    "hash": "2820735BA0DE1C3CA37EBEF5153F2AE5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "孙楠",
            "name": "你快回来",
            "albumName": "南极光",
            "albumId": "960695",
            "songmid": "1095837652",
            "source": "kg",
            "interval": "04:27",
            "img": "http://imge.kugou.com/stdmusic/400/20250526/20250526100104853660.jpg",
            "lrc": null,
            "hash": "55D450A03A795A10E2C6C0AF37A062C3",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.09 MB",
                    "hash": "55D450A03A795A10E2C6C0AF37A062C3"
                },
                {
                    "type": "320k",
                    "size": "10.22 MB",
                    "hash": "CAF0D1DB22C9ABB4DD6123E015FF2ADC"
                },
                {
                    "type": "flac",
                    "size": "27.55 MB",
                    "hash": "0DAFDF9C591B6A3B18AC6B29D4AFF22F"
                },
                {
                    "type": "flac24bit",
                    "size": "28.28 MB",
                    "hash": "42E60F0BCB9053D9A53C17B5EC948289"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.09 MB",
                    "hash": "55D450A03A795A10E2C6C0AF37A062C3"
                },
                "320k": {
                    "size": "10.22 MB",
                    "hash": "CAF0D1DB22C9ABB4DD6123E015FF2ADC"
                },
                "flac": {
                    "size": "27.55 MB",
                    "hash": "0DAFDF9C591B6A3B18AC6B29D4AFF22F"
                },
                "flac24bit": {
                    "size": "28.28 MB",
                    "hash": "42E60F0BCB9053D9A53C17B5EC948289"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "孙楠、韩红",
            "name": "美丽的神话",
            "albumName": "忘不了你",
            "albumId": "964166",
            "songmid": "177995",
            "source": "kg",
            "interval": "04:52",
            "img": "http://imge.kugou.com/stdmusic/400/20201125/20201125125531615984.jpg",
            "lrc": null,
            "hash": "877281C8E094A848F022BCAAA76945CB",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.46 MB",
                    "hash": "877281C8E094A848F022BCAAA76945CB"
                },
                {
                    "type": "320k",
                    "size": "11.14 MB",
                    "hash": "96A2727C6E234F8B45AE71AD06B1FF82"
                },
                {
                    "type": "flac",
                    "size": "32.63 MB",
                    "hash": "B2075EEE1992A403F2C012C7725DE27A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.46 MB",
                    "hash": "877281C8E094A848F022BCAAA76945CB"
                },
                "320k": {
                    "size": "11.14 MB",
                    "hash": "96A2727C6E234F8B45AE71AD06B1FF82"
                },
                "flac": {
                    "size": "32.63 MB",
                    "hash": "B2075EEE1992A403F2C012C7725DE27A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王菲",
            "name": "执迷不悔 (普通话版)",
            "albumName": "王菲的故事",
            "albumId": "2520482",
            "songmid": "304522825",
            "source": "kg",
            "interval": "04:29",
            "img": "http://imge.kugou.com/stdmusic/400/20250101/20250101065943939662.jpg",
            "lrc": null,
            "hash": "D3C32046E5556B2B25FB884FA889E7E4",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.11 MB",
                    "hash": "D3C32046E5556B2B25FB884FA889E7E4"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.11 MB",
                    "hash": "D3C32046E5556B2B25FB884FA889E7E4"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张惠妹",
            "name": "哭砂",
            "albumName": "A-mei Acoustic Best",
            "albumId": "18763558",
            "songmid": "304565708",
            "source": "kg",
            "interval": "06:06",
            "img": "http://imge.kugou.com/stdmusic/400/20190318/20190318184055952159.jpg",
            "lrc": null,
            "hash": "5718038B06CBA2633B9AE1BB2D8CCFF8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "5.60 MB",
                    "hash": "5718038B06CBA2633B9AE1BB2D8CCFF8"
                },
                {
                    "type": "320k",
                    "size": "13.99 MB",
                    "hash": "1FE0FA1F424CC97479AFDAF091E1403E"
                }
            ],
            "_types": {
                "128k": {
                    "size": "5.60 MB",
                    "hash": "5718038B06CBA2633B9AE1BB2D8CCFF8"
                },
                "320k": {
                    "size": "13.99 MB",
                    "hash": "1FE0FA1F424CC97479AFDAF091E1403E"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张惠妹",
            "name": "听海",
            "albumName": "我最亲爱的张惠妹 - 给自己的精选（2015 Edition）",
            "albumId": "535156",
            "songmid": "302424718",
            "source": "kg",
            "interval": "05:19",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909114939574577.jpg",
            "lrc": null,
            "hash": "90DD140EB43F2062A7B08DDDA74388A5",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.88 MB",
                    "hash": "90DD140EB43F2062A7B08DDDA74388A5"
                },
                {
                    "type": "320k",
                    "size": "12.19 MB",
                    "hash": "53550BF7245A17C2AC39F13919BFF999"
                },
                {
                    "type": "flac",
                    "size": "32.15 MB",
                    "hash": "0A95195A6910CD3D4463CF59542B658D"
                },
                {
                    "type": "flac24bit",
                    "size": "32.65 MB",
                    "hash": "3D4B2797681974438515C70B3389BE6F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.88 MB",
                    "hash": "90DD140EB43F2062A7B08DDDA74388A5"
                },
                "320k": {
                    "size": "12.19 MB",
                    "hash": "53550BF7245A17C2AC39F13919BFF999"
                },
                "flac": {
                    "size": "32.15 MB",
                    "hash": "0A95195A6910CD3D4463CF59542B658D"
                },
                "flac24bit": {
                    "size": "32.65 MB",
                    "hash": "3D4B2797681974438515C70B3389BE6F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "光良",
            "name": "童话",
            "albumName": "2005年TVB8金曲榜颁奖典礼",
            "albumId": "1076788",
            "songmid": "301303011",
            "source": "kg",
            "interval": "04:06",
            "img": "http://imge.kugou.com/stdmusic/400/20160309/20160309183221706206.jpg",
            "lrc": null,
            "hash": "AD4C78C668FF7E76E5B0DC64EE4B5FFB",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.76 MB",
                    "hash": "AD4C78C668FF7E76E5B0DC64EE4B5FFB"
                },
                {
                    "type": "320k",
                    "size": "9.39 MB",
                    "hash": "12A9E7E62038930292338BA49F643D22"
                },
                {
                    "type": "flac",
                    "size": "26.77 MB",
                    "hash": "3A2312F02873A56089949F8845AE3A98"
                },
                {
                    "type": "flac24bit",
                    "size": "27.15 MB",
                    "hash": "CE7067E70206C3F779899F8DA2B9793D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.76 MB",
                    "hash": "AD4C78C668FF7E76E5B0DC64EE4B5FFB"
                },
                "320k": {
                    "size": "9.39 MB",
                    "hash": "12A9E7E62038930292338BA49F643D22"
                },
                "flac": {
                    "size": "26.77 MB",
                    "hash": "3A2312F02873A56089949F8845AE3A98"
                },
                "flac24bit": {
                    "size": "27.15 MB",
                    "hash": "CE7067E70206C3F779899F8DA2B9793D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "品冠、梁静茹",
            "name": "明明很爱你",
            "albumName": "K歌情人雅座",
            "albumId": "1737525",
            "songmid": "304484162",
            "source": "kg",
            "interval": "04:07",
            "img": "http://imge.kugou.com/stdmusic/400/20230711/20230711140601550661.jpg",
            "lrc": null,
            "hash": "C2F9DC39F0EB0044D674BFD2A308B375",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.77 MB",
                    "hash": "C2F9DC39F0EB0044D674BFD2A308B375"
                },
                {
                    "type": "320k",
                    "size": "9.43 MB",
                    "hash": "B5642468424A02DAC0C9074B4A3136E9"
                },
                {
                    "type": "flac",
                    "size": "26.86 MB",
                    "hash": "E325A3FA74246623F29E35DBA495702D"
                },
                {
                    "type": "flac24bit",
                    "size": "27.91 MB",
                    "hash": "39D25F4C603F227BDDEEBBF1988E1147"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.77 MB",
                    "hash": "C2F9DC39F0EB0044D674BFD2A308B375"
                },
                "320k": {
                    "size": "9.43 MB",
                    "hash": "B5642468424A02DAC0C9074B4A3136E9"
                },
                "flac": {
                    "size": "26.86 MB",
                    "hash": "E325A3FA74246623F29E35DBA495702D"
                },
                "flac24bit": {
                    "size": "27.91 MB",
                    "hash": "39D25F4C603F227BDDEEBBF1988E1147"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张震岳",
            "name": "再见",
            "albumName": "再见",
            "albumId": "969234",
            "songmid": "313871",
            "source": "kg",
            "interval": "03:03",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121857291550.jpg",
            "lrc": null,
            "hash": "13B04C6FA7B92D747534CD88718CADAC",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.81 MB",
                    "hash": "13B04C6FA7B92D747534CD88718CADAC"
                },
                {
                    "type": "320k",
                    "size": "7.02 MB",
                    "hash": "EE25AAAC82417CE290C0F7995627A3B7"
                },
                {
                    "type": "flac",
                    "size": "20.00 MB",
                    "hash": "2412D88E823469D589441353F8EE985A"
                },
                {
                    "type": "flac24bit",
                    "size": "35.82 MB",
                    "hash": "D27DE0C41EE1EF2BF7BBC228B5F976F2"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.81 MB",
                    "hash": "13B04C6FA7B92D747534CD88718CADAC"
                },
                "320k": {
                    "size": "7.02 MB",
                    "hash": "EE25AAAC82417CE290C0F7995627A3B7"
                },
                "flac": {
                    "size": "20.00 MB",
                    "hash": "2412D88E823469D589441353F8EE985A"
                },
                "flac24bit": {
                    "size": "35.82 MB",
                    "hash": "D27DE0C41EE1EF2BF7BBC228B5F976F2"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "五月天",
            "name": "倔强",
            "albumName": "步步 自选作品辑 the Best of 1999-2013",
            "albumId": "960532",
            "songmid": "297346",
            "source": "kg",
            "interval": "04:23",
            "img": "http://imge.kugou.com/stdmusic/400/20150717/20150717144205367312.jpg",
            "lrc": null,
            "hash": "20CA52F0A3F249A4BE7D04E65F1F5C90",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.02 MB",
                    "hash": "20CA52F0A3F249A4BE7D04E65F1F5C90"
                },
                {
                    "type": "320k",
                    "size": "10.05 MB",
                    "hash": "669363B20CB420EBF006DAEC96F03186"
                },
                {
                    "type": "flac",
                    "size": "31.51 MB",
                    "hash": "96C61A636600293D17A9DE004EFF8D2F"
                },
                {
                    "type": "flac24bit",
                    "size": "32.48 MB",
                    "hash": "D2FD618D657DFAB80F827249B02C10AC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.02 MB",
                    "hash": "20CA52F0A3F249A4BE7D04E65F1F5C90"
                },
                "320k": {
                    "size": "10.05 MB",
                    "hash": "669363B20CB420EBF006DAEC96F03186"
                },
                "flac": {
                    "size": "31.51 MB",
                    "hash": "96C61A636600293D17A9DE004EFF8D2F"
                },
                "flac24bit": {
                    "size": "32.48 MB",
                    "hash": "D2FD618D657DFAB80F827249B02C10AC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "任贤齐",
            "name": "死不了",
            "albumName": "为爱走天涯",
            "albumId": "5301013",
            "songmid": "63004",
            "source": "kg",
            "interval": "04:29",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121935193475.jpg",
            "lrc": null,
            "hash": "AB5EEAC20A7976C82CAF48A3B60AB1D7",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.12 MB",
                    "hash": "AB5EEAC20A7976C82CAF48A3B60AB1D7"
                },
                {
                    "type": "320k",
                    "size": "10.29 MB",
                    "hash": "BF558E1FF7D765AD7C556C5131901E68"
                },
                {
                    "type": "flac",
                    "size": "29.39 MB",
                    "hash": "46D8AC268971673A423D55BD8BD7FB39"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.12 MB",
                    "hash": "AB5EEAC20A7976C82CAF48A3B60AB1D7"
                },
                "320k": {
                    "size": "10.29 MB",
                    "hash": "BF558E1FF7D765AD7C556C5131901E68"
                },
                "flac": {
                    "size": "29.39 MB",
                    "hash": "46D8AC268971673A423D55BD8BD7FB39"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "赵传",
            "name": "我很丑，可是我很温柔",
            "albumName": "滚石香港黄金十年 赵传精选",
            "albumId": "2996932",
            "songmid": "304621451",
            "source": "kg",
            "interval": "03:57",
            "img": "http://imge.kugou.com/stdmusic/400/20251120/20251120173221373426.jpg",
            "lrc": null,
            "hash": "E2F17A6CF1AE52F49B6B51739B944F8B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.63 MB",
                    "hash": "E2F17A6CF1AE52F49B6B51739B944F8B"
                },
                {
                    "type": "320k",
                    "size": "9.07 MB",
                    "hash": "794F697CEDB565FAD65B57727CBDAA9B"
                },
                {
                    "type": "flac",
                    "size": "24.51 MB",
                    "hash": "89667431241B592F009B971090D67DD8"
                },
                {
                    "type": "flac24bit",
                    "size": "24.75 MB",
                    "hash": "650D6C5E612E273432E7640545EDCB06"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.63 MB",
                    "hash": "E2F17A6CF1AE52F49B6B51739B944F8B"
                },
                "320k": {
                    "size": "9.07 MB",
                    "hash": "794F697CEDB565FAD65B57727CBDAA9B"
                },
                "flac": {
                    "size": "24.51 MB",
                    "hash": "89667431241B592F009B971090D67DD8"
                },
                "flac24bit": {
                    "size": "24.75 MB",
                    "hash": "650D6C5E612E273432E7640545EDCB06"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "高胜美",
            "name": "千年等一回",
            "albumName": "戏剧经典 第2回",
            "albumId": "885137",
            "songmid": "302418918",
            "source": "kg",
            "interval": "03:36",
            "img": "http://imge.kugou.com/stdmusic/400/20190822/20190822121317272603.jpg",
            "lrc": null,
            "hash": "99A485FDDF129C1B38B57471BD9A0273",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.30 MB",
                    "hash": "99A485FDDF129C1B38B57471BD9A0273"
                },
                {
                    "type": "320k",
                    "size": "8.26 MB",
                    "hash": "FE4466FC8C79EE5DCA604DE70B09FCD7"
                },
                {
                    "type": "flac",
                    "size": "22.95 MB",
                    "hash": "B8AA34BFEF149232D32F07EBEEAEEF98"
                },
                {
                    "type": "flac24bit",
                    "size": "23.99 MB",
                    "hash": "0833CECA592A51C390F290D5C97B9B0F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.30 MB",
                    "hash": "99A485FDDF129C1B38B57471BD9A0273"
                },
                "320k": {
                    "size": "8.26 MB",
                    "hash": "FE4466FC8C79EE5DCA604DE70B09FCD7"
                },
                "flac": {
                    "size": "22.95 MB",
                    "hash": "B8AA34BFEF149232D32F07EBEEAEEF98"
                },
                "flac24bit": {
                    "size": "23.99 MB",
                    "hash": "0833CECA592A51C390F290D5C97B9B0F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张惠妹、张雨生",
            "name": "最爱的人伤我最深",
            "albumName": "两伊战争",
            "albumId": "559237",
            "songmid": "302505957",
            "source": "kg",
            "interval": "05:04",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909124500250494.jpg",
            "lrc": null,
            "hash": "A9CCFC9598CAA254B5969DF12A46C691",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.65 MB",
                    "hash": "A9CCFC9598CAA254B5969DF12A46C691"
                },
                {
                    "type": "320k",
                    "size": "11.70 MB",
                    "hash": "3C50C1277778B9D34BAFDCA42C6BC2C3"
                },
                {
                    "type": "flac",
                    "size": "31.21 MB",
                    "hash": "B39A50F64FA4A5EBAD700C273B56B77E"
                },
                {
                    "type": "flac24bit",
                    "size": "31.86 MB",
                    "hash": "81CA4715652A37D660BC543ABDD817D1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.65 MB",
                    "hash": "A9CCFC9598CAA254B5969DF12A46C691"
                },
                "320k": {
                    "size": "11.70 MB",
                    "hash": "3C50C1277778B9D34BAFDCA42C6BC2C3"
                },
                "flac": {
                    "size": "31.21 MB",
                    "hash": "B39A50F64FA4A5EBAD700C273B56B77E"
                },
                "flac24bit": {
                    "size": "31.86 MB",
                    "hash": "81CA4715652A37D660BC543ABDD817D1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "李宗盛",
            "name": "鬼迷心窍",
            "albumName": "爱情论",
            "albumId": "536174",
            "songmid": "152761",
            "source": "kg",
            "interval": "04:19",
            "img": "http://imge.kugou.com/stdmusic/400/20140424/20140424102546880058.jpg",
            "lrc": null,
            "hash": "58A19C8D361230FFAFC1D673E55F2101",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.96 MB",
                    "hash": "58A19C8D361230FFAFC1D673E55F2101"
                },
                {
                    "type": "320k",
                    "size": "9.91 MB",
                    "hash": "AA5C2894968F9322A6F789445DD95270"
                },
                {
                    "type": "flac",
                    "size": "28.73 MB",
                    "hash": "7DF6E3DD1D10B7B05163E0F24ED228D1"
                },
                {
                    "type": "flac24bit",
                    "size": "29.44 MB",
                    "hash": "55F03C33CC563135F2B405F890663AAA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.96 MB",
                    "hash": "58A19C8D361230FFAFC1D673E55F2101"
                },
                "320k": {
                    "size": "9.91 MB",
                    "hash": "AA5C2894968F9322A6F789445DD95270"
                },
                "flac": {
                    "size": "28.73 MB",
                    "hash": "7DF6E3DD1D10B7B05163E0F24ED228D1"
                },
                "flac24bit": {
                    "size": "29.44 MB",
                    "hash": "55F03C33CC563135F2B405F890663AAA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张雨生",
            "name": "大海",
            "albumName": "大海",
            "albumId": "967705",
            "songmid": "323461",
            "source": "kg",
            "interval": "04:40",
            "img": "http://imge.kugou.com/stdmusic/400/20201125/20201125103505920689.jpg",
            "lrc": null,
            "hash": "BF8252BEAE57AEB53490145CA8E81BB4",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.27 MB",
                    "hash": "BF8252BEAE57AEB53490145CA8E81BB4"
                },
                {
                    "type": "320k",
                    "size": "10.69 MB",
                    "hash": "96A386BAFF8AA2BDA940A1A6E98BF000"
                },
                {
                    "type": "flac",
                    "size": "26.66 MB",
                    "hash": "A565CBAA725053E898AA13A424B897AD"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.27 MB",
                    "hash": "BF8252BEAE57AEB53490145CA8E81BB4"
                },
                "320k": {
                    "size": "10.69 MB",
                    "hash": "96A386BAFF8AA2BDA940A1A6E98BF000"
                },
                "flac": {
                    "size": "26.66 MB",
                    "hash": "A565CBAA725053E898AA13A424B897AD"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "刘德华",
            "name": "忘情水",
            "albumName": "最孤单的人是我",
            "albumId": "526990",
            "songmid": "302413120",
            "source": "kg",
            "interval": "04:24",
            "img": "http://imge.kugou.com/stdmusic/400/20200924/20200924054206605970.jpg",
            "lrc": null,
            "hash": "50E737B0747A0114CD6CF36122A59AD9",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.03 MB",
                    "hash": "50E737B0747A0114CD6CF36122A59AD9"
                },
                {
                    "type": "320k",
                    "size": "10.09 MB",
                    "hash": "B537E0794977685E43C339374A917B99"
                },
                {
                    "type": "flac",
                    "size": "25.57 MB",
                    "hash": "4E99EDF0028F72CEA15AD713D901DECC"
                },
                {
                    "type": "flac24bit",
                    "size": "26.30 MB",
                    "hash": "984076BB6826DAFAAFA5601B688DE7F1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.03 MB",
                    "hash": "50E737B0747A0114CD6CF36122A59AD9"
                },
                "320k": {
                    "size": "10.09 MB",
                    "hash": "B537E0794977685E43C339374A917B99"
                },
                "flac": {
                    "size": "25.57 MB",
                    "hash": "4E99EDF0028F72CEA15AD713D901DECC"
                },
                "flac24bit": {
                    "size": "26.30 MB",
                    "hash": "984076BB6826DAFAAFA5601B688DE7F1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周蕙",
            "name": "约定",
            "albumName": "一人一首成名曲第三辑（港台版）",
            "albumId": "1739100",
            "songmid": "302415102",
            "source": "kg",
            "interval": "04:19",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620053838742776.jpg",
            "lrc": null,
            "hash": "5157BD9F88F9FEA1664C7F9CD0CE371F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.95 MB",
                    "hash": "5157BD9F88F9FEA1664C7F9CD0CE371F"
                },
                {
                    "type": "320k",
                    "size": "9.88 MB",
                    "hash": "E62DF3234A80570E37F0E0DADEE48D10"
                },
                {
                    "type": "flac",
                    "size": "11.61 MB",
                    "hash": "E1C3449441DEF944FE27DDD6C74E77B2"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.95 MB",
                    "hash": "5157BD9F88F9FEA1664C7F9CD0CE371F"
                },
                "320k": {
                    "size": "9.88 MB",
                    "hash": "E62DF3234A80570E37F0E0DADEE48D10"
                },
                "flac": {
                    "size": "11.61 MB",
                    "hash": "E1C3449441DEF944FE27DDD6C74E77B2"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "蔡依林",
            "name": "倒带",
            "albumName": "城堡",
            "albumId": "976925",
            "songmid": "335415",
            "source": "kg",
            "interval": "04:26",
            "img": "http://imge.kugou.com/stdmusic/400/20241220/20241220211703386137.jpg",
            "lrc": null,
            "hash": "446507D2332BC3F263596363A97C6E95",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.06 MB",
                    "hash": "446507D2332BC3F263596363A97C6E95"
                },
                {
                    "type": "320k",
                    "size": "10.16 MB",
                    "hash": "0E895492CBC460BFF09328A8F69A2046"
                },
                {
                    "type": "flac",
                    "size": "31.62 MB",
                    "hash": "785046B5F8C0887C07DD6FC4F9A5427E"
                },
                {
                    "type": "flac24bit",
                    "size": "32.62 MB",
                    "hash": "B70BFD0F356595CB7F94B02E7B7AF14F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.06 MB",
                    "hash": "446507D2332BC3F263596363A97C6E95"
                },
                "320k": {
                    "size": "10.16 MB",
                    "hash": "0E895492CBC460BFF09328A8F69A2046"
                },
                "flac": {
                    "size": "31.62 MB",
                    "hash": "785046B5F8C0887C07DD6FC4F9A5427E"
                },
                "flac24bit": {
                    "size": "32.62 MB",
                    "hash": "B70BFD0F356595CB7F94B02E7B7AF14F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "朴树",
            "name": "那些花儿",
            "albumName": "那时花开 电影原声带",
            "albumId": "19317414",
            "songmid": "302513126",
            "source": "kg",
            "interval": "04:54",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909105023499633.jpg",
            "lrc": null,
            "hash": "61716A852B800DDFE4A3879FE53CB9A7",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.50 MB",
                    "hash": "61716A852B800DDFE4A3879FE53CB9A7"
                },
                {
                    "type": "320k",
                    "size": "11.55 MB",
                    "hash": "DB5A948BA2F0E3A1932A94D1B2939FDB"
                },
                {
                    "type": "flac",
                    "size": "33.19 MB",
                    "hash": "199A9DC5F54D8A6824A52874EB46BDBE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.50 MB",
                    "hash": "61716A852B800DDFE4A3879FE53CB9A7"
                },
                "320k": {
                    "size": "11.55 MB",
                    "hash": "DB5A948BA2F0E3A1932A94D1B2939FDB"
                },
                "flac": {
                    "size": "33.19 MB",
                    "hash": "199A9DC5F54D8A6824A52874EB46BDBE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周杰伦",
            "name": "搁浅",
            "albumName": "七里香",
            "albumId": "971783",
            "songmid": "254112",
            "source": "kg",
            "interval": "04:00",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121745628430.jpg",
            "lrc": null,
            "hash": "FBC234520FED713C30C1C026E7352770",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.67 MB",
                    "hash": "FBC234520FED713C30C1C026E7352770"
                },
                {
                    "type": "320k",
                    "size": "9.16 MB",
                    "hash": "581C52E119C8F25A965C7C2F3FB73DBD"
                },
                {
                    "type": "flac",
                    "size": "24.96 MB",
                    "hash": "D1D7835F9BED257E613A2C854333667B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.67 MB",
                    "hash": "FBC234520FED713C30C1C026E7352770"
                },
                "320k": {
                    "size": "9.16 MB",
                    "hash": "581C52E119C8F25A965C7C2F3FB73DBD"
                },
                "flac": {
                    "size": "24.96 MB",
                    "hash": "D1D7835F9BED257E613A2C854333667B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "阿杜",
            "name": "离别",
            "albumName": "The Very Best of A-Do 阿杜诚意跨厂牌超级精选",
            "albumId": "1076205",
            "songmid": "302419784",
            "source": "kg",
            "interval": "03:50",
            "img": "http://imge.kugou.com/stdmusic/400/20250217/20250217144300441268.jpg",
            "lrc": null,
            "hash": "DB92FFAD0AB58B405C4F472D3C442710",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.52 MB",
                    "hash": "DB92FFAD0AB58B405C4F472D3C442710"
                },
                {
                    "type": "320k",
                    "size": "8.79 MB",
                    "hash": "D5869CD49C41ECF23BD39935984FA2BE"
                },
                {
                    "type": "flac",
                    "size": "25.39 MB",
                    "hash": "C4179D22EB4C4436C38D4E0377CA70C5"
                },
                {
                    "type": "flac24bit",
                    "size": "44.69 MB",
                    "hash": "638334D1740C287AC2626DFA2719E120"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.52 MB",
                    "hash": "DB92FFAD0AB58B405C4F472D3C442710"
                },
                "320k": {
                    "size": "8.79 MB",
                    "hash": "D5869CD49C41ECF23BD39935984FA2BE"
                },
                "flac": {
                    "size": "25.39 MB",
                    "hash": "C4179D22EB4C4436C38D4E0377CA70C5"
                },
                "flac24bit": {
                    "size": "44.69 MB",
                    "hash": "638334D1740C287AC2626DFA2719E120"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林忆莲",
            "name": "至少还有你",
            "albumName": "一人一首成名曲第四辑(港台版)",
            "albumId": "1076583",
            "songmid": "301351557",
            "source": "kg",
            "interval": "04:32",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620074616870498.jpg",
            "lrc": null,
            "hash": "4D73836D553ACCA35AFAC39934C0FC98",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.16 MB",
                    "hash": "4D73836D553ACCA35AFAC39934C0FC98"
                },
                {
                    "type": "320k",
                    "size": "10.39 MB",
                    "hash": "9CDC18B6BC02092E26E1CBE6A027E51B"
                },
                {
                    "type": "flac",
                    "size": "30.35 MB",
                    "hash": "F94754FE908DD390BA4DB83F57BF419E"
                },
                {
                    "type": "flac24bit",
                    "size": "31.17 MB",
                    "hash": "637C719821B9471181A4583E05D7F175"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.16 MB",
                    "hash": "4D73836D553ACCA35AFAC39934C0FC98"
                },
                "320k": {
                    "size": "10.39 MB",
                    "hash": "9CDC18B6BC02092E26E1CBE6A027E51B"
                },
                "flac": {
                    "size": "30.35 MB",
                    "hash": "F94754FE908DD390BA4DB83F57BF419E"
                },
                "flac24bit": {
                    "size": "31.17 MB",
                    "hash": "637C719821B9471181A4583E05D7F175"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "潘玮柏",
            "name": "壁虎漫步",
            "albumName": "壁虎漫步",
            "albumId": "979041",
            "songmid": "6664",
            "source": "kg",
            "interval": "03:36",
            "img": "http://imge.kugou.com/stdmusic/400/20240124/20240124105401753565.jpg",
            "lrc": null,
            "hash": "2BB9BAD12D9B7B62A191ED0D8D1B2361",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.31 MB",
                    "hash": "2BB9BAD12D9B7B62A191ED0D8D1B2361"
                },
                {
                    "type": "320k",
                    "size": "8.28 MB",
                    "hash": "25FC801B0404E62EF6802D474C0EB789"
                },
                {
                    "type": "flac",
                    "size": "25.90 MB",
                    "hash": "14BBB5648B3154DA9B2A7801BEF580DB"
                },
                {
                    "type": "flac24bit",
                    "size": "26.25 MB",
                    "hash": "B2041BE2388EB23E95707EECC6F479EB"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.31 MB",
                    "hash": "2BB9BAD12D9B7B62A191ED0D8D1B2361"
                },
                "320k": {
                    "size": "8.28 MB",
                    "hash": "25FC801B0404E62EF6802D474C0EB789"
                },
                "flac": {
                    "size": "25.90 MB",
                    "hash": "14BBB5648B3154DA9B2A7801BEF580DB"
                },
                "flac24bit": {
                    "size": "26.25 MB",
                    "hash": "B2041BE2388EB23E95707EECC6F479EB"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "李健",
            "name": "传奇",
            "albumName": "流行发烧极品 男声发烧",
            "albumId": "1990059",
            "songmid": "302436363",
            "source": "kg",
            "interval": "04:54",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620061717924200.jpg",
            "lrc": null,
            "hash": "A31C3036128E0FB9FE2BB97306215B66",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.50 MB",
                    "hash": "A31C3036128E0FB9FE2BB97306215B66"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.50 MB",
                    "hash": "A31C3036128E0FB9FE2BB97306215B66"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "F4",
            "name": "第一时间",
            "albumName": "360度定番精选 辉煌五年全记录",
            "albumId": "960721",
            "songmid": "304503870",
            "source": "kg",
            "interval": "04:38",
            "img": "http://imge.kugou.com/stdmusic/400/20190507/20190507062805800084.jpg",
            "lrc": null,
            "hash": "BC31618D36E4FC0B869B88FA57B9A61B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.25 MB",
                    "hash": "BC31618D36E4FC0B869B88FA57B9A61B"
                },
                {
                    "type": "320k",
                    "size": "10.62 MB",
                    "hash": "0A6D329F19F64256EE991E90D2C37BC7"
                },
                {
                    "type": "flac",
                    "size": "31.12 MB",
                    "hash": "7A0B0718152FC71B6CCADDDAF3B63ED6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.25 MB",
                    "hash": "BC31618D36E4FC0B869B88FA57B9A61B"
                },
                "320k": {
                    "size": "10.62 MB",
                    "hash": "0A6D329F19F64256EE991E90D2C37BC7"
                },
                "flac": {
                    "size": "31.12 MB",
                    "hash": "7A0B0718152FC71B6CCADDDAF3B63ED6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "F.I.R.飞儿乐团",
            "name": "你的微笑",
            "albumName": "飞儿乐团",
            "albumId": "509214",
            "songmid": "148416",
            "source": "kg",
            "interval": "04:21",
            "img": "http://imge.kugou.com/stdmusic/400/20250618/20250618021410314148.jpg",
            "lrc": null,
            "hash": "92BA6BE5C89EF5836DB5A40DBFE12E98",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.99 MB",
                    "hash": "92BA6BE5C89EF5836DB5A40DBFE12E98"
                },
                {
                    "type": "320k",
                    "size": "9.98 MB",
                    "hash": "335723BEFE18EC808573760B4B1586AA"
                },
                {
                    "type": "flac",
                    "size": "32.28 MB",
                    "hash": "0854750AB36BF21211E410EDABD5A691"
                },
                {
                    "type": "flac24bit",
                    "size": "32.67 MB",
                    "hash": "371CED947B97A9FD95DB9C43A4DCB9D6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.99 MB",
                    "hash": "92BA6BE5C89EF5836DB5A40DBFE12E98"
                },
                "320k": {
                    "size": "9.98 MB",
                    "hash": "335723BEFE18EC808573760B4B1586AA"
                },
                "flac": {
                    "size": "32.28 MB",
                    "hash": "0854750AB36BF21211E410EDABD5A691"
                },
                "flac24bit": {
                    "size": "32.67 MB",
                    "hash": "371CED947B97A9FD95DB9C43A4DCB9D6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "巫启贤",
            "name": "太傻",
            "albumName": "璀璨百分百",
            "albumId": "2300669",
            "songmid": "302423179",
            "source": "kg",
            "interval": "05:21",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121756798323.jpg",
            "lrc": null,
            "hash": "2DC866A9A949D6BFF4FA3CD371578B75",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.91 MB",
                    "hash": "2DC866A9A949D6BFF4FA3CD371578B75"
                },
                {
                    "type": "320k",
                    "size": "12.26 MB",
                    "hash": "7598E49F5E93884B0C0046652B0AFF7D"
                },
                {
                    "type": "flac",
                    "size": "35.75 MB",
                    "hash": "8B5CE696D8BC47BA630B5E7BB54A7513"
                },
                {
                    "type": "flac24bit",
                    "size": "36.70 MB",
                    "hash": "4A370023B6EA0A392CAD35C2E60F43A1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.91 MB",
                    "hash": "2DC866A9A949D6BFF4FA3CD371578B75"
                },
                "320k": {
                    "size": "12.26 MB",
                    "hash": "7598E49F5E93884B0C0046652B0AFF7D"
                },
                "flac": {
                    "size": "35.75 MB",
                    "hash": "8B5CE696D8BC47BA630B5E7BB54A7513"
                },
                "flac24bit": {
                    "size": "36.70 MB",
                    "hash": "4A370023B6EA0A392CAD35C2E60F43A1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周传雄",
            "name": "有没有一首歌会让你想起我",
            "albumName": "Dubbing 情歌教父周传雄1987-2003",
            "albumId": "961130",
            "songmid": "302435566",
            "source": "kg",
            "interval": "03:55",
            "img": "http://imge.kugou.com/stdmusic/400/20240329/20240329112848236870.jpg",
            "lrc": null,
            "hash": "BDB78E3D23E369653CAC97A6A18F8011",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.60 MB",
                    "hash": "BDB78E3D23E369653CAC97A6A18F8011"
                },
                {
                    "type": "320k",
                    "size": "9.00 MB",
                    "hash": "EEDD1D6B67B3DCDD770D7043C96539FE"
                },
                {
                    "type": "flac",
                    "size": "29.21 MB",
                    "hash": "9F999E79839105DD7CB18F9EF7627C30"
                },
                {
                    "type": "flac24bit",
                    "size": "29.93 MB",
                    "hash": "902F22E68E7053485C426657FB34FD04"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.60 MB",
                    "hash": "BDB78E3D23E369653CAC97A6A18F8011"
                },
                "320k": {
                    "size": "9.00 MB",
                    "hash": "EEDD1D6B67B3DCDD770D7043C96539FE"
                },
                "flac": {
                    "size": "29.21 MB",
                    "hash": "9F999E79839105DD7CB18F9EF7627C30"
                },
                "flac24bit": {
                    "size": "29.93 MB",
                    "hash": "902F22E68E7053485C426657FB34FD04"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Twins",
            "name": "莫斯科没有眼泪",
            "albumName": "见习爱神",
            "albumId": "2997020",
            "songmid": "258486",
            "source": "kg",
            "interval": "03:31",
            "img": "http://imge.kugou.com/stdmusic/400/20160907/20160907214040307026.jpg",
            "lrc": null,
            "hash": "A12E305A501616CDBFC4264D250594E2",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.22 MB",
                    "hash": "A12E305A501616CDBFC4264D250594E2"
                },
                {
                    "type": "320k",
                    "size": "8.06 MB",
                    "hash": "AB4196A77B52D8F2048FCEFF639BF292"
                },
                {
                    "type": "flac",
                    "size": "23.28 MB",
                    "hash": "6EB755F52B77B0630BF6F63CC0B3CCDD"
                },
                {
                    "type": "flac24bit",
                    "size": "23.91 MB",
                    "hash": "AF4697F8D3D38E95C71D53DCD9A14502"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.22 MB",
                    "hash": "A12E305A501616CDBFC4264D250594E2"
                },
                "320k": {
                    "size": "8.06 MB",
                    "hash": "AB4196A77B52D8F2048FCEFF639BF292"
                },
                "flac": {
                    "size": "23.28 MB",
                    "hash": "6EB755F52B77B0630BF6F63CC0B3CCDD"
                },
                "flac24bit": {
                    "size": "23.91 MB",
                    "hash": "AF4697F8D3D38E95C71D53DCD9A14502"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "羽泉",
            "name": "冷酷到底",
            "albumName": "一人一首成名曲第四辑(港台版)",
            "albumId": "1076583",
            "songmid": "332223",
            "source": "kg",
            "interval": "04:01",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620074616870498.jpg",
            "lrc": null,
            "hash": "C0C4CAE9554614F6E2F3C7524FDE9F83",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.77 MB",
                    "hash": "C0C4CAE9554614F6E2F3C7524FDE9F83"
                },
                {
                    "type": "320k",
                    "size": "9.20 MB",
                    "hash": "ADF494449BCC88A8CE60584D3AC12477"
                },
                {
                    "type": "flac",
                    "size": "29.91 MB",
                    "hash": "1AC08CB7ABCEFD6AF8BCC4E498BFDCD4"
                },
                {
                    "type": "flac24bit",
                    "size": "28.96 MB",
                    "hash": "F19051ADFE7A52B68BF19CA3602C6B81"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.77 MB",
                    "hash": "C0C4CAE9554614F6E2F3C7524FDE9F83"
                },
                "320k": {
                    "size": "9.20 MB",
                    "hash": "ADF494449BCC88A8CE60584D3AC12477"
                },
                "flac": {
                    "size": "29.91 MB",
                    "hash": "1AC08CB7ABCEFD6AF8BCC4E498BFDCD4"
                },
                "flac24bit": {
                    "size": "28.96 MB",
                    "hash": "F19051ADFE7A52B68BF19CA3602C6B81"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林俊杰",
            "name": "就是我",
            "albumName": "期待爱 新歌+精选",
            "albumId": "526378",
            "songmid": "303201309",
            "source": "kg",
            "interval": "03:14",
            "img": "http://imge.kugou.com/stdmusic/400/20200922/20200922063702445527.jpg",
            "lrc": null,
            "hash": "498BB21930156BF8916B13E262186EEC",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.97 MB",
                    "hash": "498BB21930156BF8916B13E262186EEC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.97 MB",
                    "hash": "498BB21930156BF8916B13E262186EEC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "游鸿明",
            "name": "下沙",
            "albumName": "游式情歌1993-2006游鸿明经典全记录",
            "albumId": "1599031",
            "songmid": "302453399",
            "source": "kg",
            "interval": "05:51",
            "img": "http://imge.kugou.com/stdmusic/400/20250101/20250101071037938935.jpg",
            "lrc": null,
            "hash": "614645E67465D8016C95B67FC9AA8AC7",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "5.37 MB",
                    "hash": "614645E67465D8016C95B67FC9AA8AC7"
                },
                {
                    "type": "320k",
                    "size": "13.42 MB",
                    "hash": "B949E44E5EEDC348790ED1E0520581C7"
                },
                {
                    "type": "flac",
                    "size": "38.89 MB",
                    "hash": "D17E90CA873C7482C42B3EB7B28B2E6D"
                },
                {
                    "type": "flac24bit",
                    "size": "39.90 MB",
                    "hash": "C7AB3BE94C946C6FBC2AD3651ECB0E16"
                }
            ],
            "_types": {
                "128k": {
                    "size": "5.37 MB",
                    "hash": "614645E67465D8016C95B67FC9AA8AC7"
                },
                "320k": {
                    "size": "13.42 MB",
                    "hash": "B949E44E5EEDC348790ED1E0520581C7"
                },
                "flac": {
                    "size": "38.89 MB",
                    "hash": "D17E90CA873C7482C42B3EB7B28B2E6D"
                },
                "flac24bit": {
                    "size": "39.90 MB",
                    "hash": "C7AB3BE94C946C6FBC2AD3651ECB0E16"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "蓝又时",
            "name": "孤单心事",
            "albumName": "终极一班 电视剧原声带",
            "albumId": "555591",
            "songmid": "268581",
            "source": "kg",
            "interval": "04:28",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121818883140.jpg",
            "lrc": null,
            "hash": "B97DE9A26F441D631C1BE050AC2C54B1",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.09 MB",
                    "hash": "B97DE9A26F441D631C1BE050AC2C54B1"
                },
                {
                    "type": "320k",
                    "size": "10.24 MB",
                    "hash": "31CC86149B21DA661FA7AE1D33C8F267"
                },
                {
                    "type": "flac",
                    "size": "30.49 MB",
                    "hash": "DC5F341179BD7E00743FB39CA0C78670"
                },
                {
                    "type": "flac24bit",
                    "size": "31.01 MB",
                    "hash": "96B7FF69A1FD5691166AED9DE52FE2AA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.09 MB",
                    "hash": "B97DE9A26F441D631C1BE050AC2C54B1"
                },
                "320k": {
                    "size": "10.24 MB",
                    "hash": "31CC86149B21DA661FA7AE1D33C8F267"
                },
                "flac": {
                    "size": "30.49 MB",
                    "hash": "DC5F341179BD7E00743FB39CA0C78670"
                },
                "flac24bit": {
                    "size": "31.01 MB",
                    "hash": "96B7FF69A1FD5691166AED9DE52FE2AA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "范玮琪",
            "name": "到不了",
            "albumName": "范范的世界",
            "albumId": "975022",
            "songmid": "173456",
            "source": "kg",
            "interval": "05:11",
            "img": "http://imge.kugou.com/stdmusic/400/20201125/20201125130341948948.jpg",
            "lrc": null,
            "hash": "7BB28E48919D788356E90B0DA6F486E1",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.75 MB",
                    "hash": "7BB28E48919D788356E90B0DA6F486E1"
                },
                {
                    "type": "320k",
                    "size": "11.87 MB",
                    "hash": "AFF95C2B7F32FA8D2D2805F02D19EA52"
                },
                {
                    "type": "flac",
                    "size": "30.94 MB",
                    "hash": "ED8CB59E500BCF4AD763706A4DCAB39C"
                },
                {
                    "type": "flac24bit",
                    "size": "31.78 MB",
                    "hash": "BD4DEBE3B1F7F0FEF808D71BE30BE18D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.75 MB",
                    "hash": "7BB28E48919D788356E90B0DA6F486E1"
                },
                "320k": {
                    "size": "11.87 MB",
                    "hash": "AFF95C2B7F32FA8D2D2805F02D19EA52"
                },
                "flac": {
                    "size": "30.94 MB",
                    "hash": "ED8CB59E500BCF4AD763706A4DCAB39C"
                },
                "flac24bit": {
                    "size": "31.78 MB",
                    "hash": "BD4DEBE3B1F7F0FEF808D71BE30BE18D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张韶涵",
            "name": "遗失的美好",
            "albumName": "海豚湾恋人 电视剧原声带",
            "albumId": "8378258",
            "songmid": "303160308",
            "source": "kg",
            "interval": "04:20",
            "img": "http://imge.kugou.com/stdmusic/400/20210112/20210112201832145968.jpg",
            "lrc": null,
            "hash": "4978ED88B3D70DDD6A5A38CB2563A26A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.98 MB",
                    "hash": "4978ED88B3D70DDD6A5A38CB2563A26A"
                },
                {
                    "type": "320k",
                    "size": "9.96 MB",
                    "hash": "6E11AF89BC1ED3FA1131ECC03350391E"
                },
                {
                    "type": "flac",
                    "size": "23.74 MB",
                    "hash": "7280D48654109D116DB92226C941D069"
                },
                {
                    "type": "flac24bit",
                    "size": "24.56 MB",
                    "hash": "D89DEE38BAE948C535E4FD637830A457"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.98 MB",
                    "hash": "4978ED88B3D70DDD6A5A38CB2563A26A"
                },
                "320k": {
                    "size": "9.96 MB",
                    "hash": "6E11AF89BC1ED3FA1131ECC03350391E"
                },
                "flac": {
                    "size": "23.74 MB",
                    "hash": "7280D48654109D116DB92226C941D069"
                },
                "flac24bit": {
                    "size": "24.56 MB",
                    "hash": "D89DEE38BAE948C535E4FD637830A457"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "许巍",
            "name": "时光",
            "albumName": "曾经的你",
            "albumId": "15247919",
            "songmid": "348641",
            "source": "kg",
            "interval": "05:05",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620091543452757.jpg",
            "lrc": null,
            "hash": "1CAD8068A64D928B4ACA262F29FB05A4",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.66 MB",
                    "hash": "1CAD8068A64D928B4ACA262F29FB05A4"
                },
                {
                    "type": "320k",
                    "size": "11.66 MB",
                    "hash": "FE314EB589BE4C3E3BC9755877DA4D31"
                },
                {
                    "type": "flac",
                    "size": "34.73 MB",
                    "hash": "6397A2335AB0A6D4ABCBA033FFAB5D64"
                },
                {
                    "type": "flac24bit",
                    "size": "59.93 MB",
                    "hash": "C443514DD7A635D2F79BFADBE35DC23D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.66 MB",
                    "hash": "1CAD8068A64D928B4ACA262F29FB05A4"
                },
                "320k": {
                    "size": "11.66 MB",
                    "hash": "FE314EB589BE4C3E3BC9755877DA4D31"
                },
                "flac": {
                    "size": "34.73 MB",
                    "hash": "6397A2335AB0A6D4ABCBA033FFAB5D64"
                },
                "flac24bit": {
                    "size": "59.93 MB",
                    "hash": "C443514DD7A635D2F79BFADBE35DC23D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "潘玮柏、张韶涵",
            "name": "快乐崇拜",
            "albumName": "我们的主打歌2",
            "albumId": "8437324",
            "songmid": "243697",
            "source": "kg",
            "interval": "03:30",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121727890819.jpg",
            "lrc": null,
            "hash": "CA937F42CE9AACC3CDDB2516DAEE55D4",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.21 MB",
                    "hash": "CA937F42CE9AACC3CDDB2516DAEE55D4"
                },
                {
                    "type": "320k",
                    "size": "8.01 MB",
                    "hash": "9D1B8927105F9C5B68C5E50314A42320"
                },
                {
                    "type": "flac",
                    "size": "24.66 MB",
                    "hash": "C94A60F8700639EB8EC623D7F40DCC99"
                },
                {
                    "type": "flac24bit",
                    "size": "25.56 MB",
                    "hash": "1BD0D50C0D90EFDAB6499FF4FF6B5222"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.21 MB",
                    "hash": "CA937F42CE9AACC3CDDB2516DAEE55D4"
                },
                "320k": {
                    "size": "8.01 MB",
                    "hash": "9D1B8927105F9C5B68C5E50314A42320"
                },
                "flac": {
                    "size": "24.66 MB",
                    "hash": "C94A60F8700639EB8EC623D7F40DCC99"
                },
                "flac24bit": {
                    "size": "25.56 MB",
                    "hash": "1BD0D50C0D90EFDAB6499FF4FF6B5222"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "江美琪",
            "name": "亲爱的你怎么不在我身边",
            "albumName": "十七岁的天空 电影原声带",
            "albumId": "885125",
            "songmid": "1082906499",
            "source": "kg",
            "interval": "04:10",
            "img": "http://imge.kugou.com/stdmusic/400/20190808/20190808122307245950.jpg",
            "lrc": null,
            "hash": "81787C85E56334F40F49C1781D4D86E8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.83 MB",
                    "hash": "81787C85E56334F40F49C1781D4D86E8"
                },
                {
                    "type": "320k",
                    "size": "9.57 MB",
                    "hash": "4132B410C1493142C755151C0BE8450E"
                },
                {
                    "type": "flac",
                    "size": "23.27 MB",
                    "hash": "DDED94D2A28C0542A3E76F69EBB483C2"
                },
                {
                    "type": "flac24bit",
                    "size": "23.36 MB",
                    "hash": "EE688345EAA8E30CDF88B3DD99000654"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.83 MB",
                    "hash": "81787C85E56334F40F49C1781D4D86E8"
                },
                "320k": {
                    "size": "9.57 MB",
                    "hash": "4132B410C1493142C755151C0BE8450E"
                },
                "flac": {
                    "size": "23.27 MB",
                    "hash": "DDED94D2A28C0542A3E76F69EBB483C2"
                },
                "flac24bit": {
                    "size": "23.36 MB",
                    "hash": "EE688345EAA8E30CDF88B3DD99000654"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "萧亚轩",
            "name": "最熟悉的陌生人",
            "albumName": "超级女声 华语篇",
            "albumId": "555942",
            "songmid": "301375213",
            "source": "kg",
            "interval": "04:23",
            "img": "http://imge.kugou.com/stdmusic/400/20201111/20201111035050347341.jpg",
            "lrc": null,
            "hash": "88A12B95BC7F15C2A436C09BB7F0E01F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.03 MB",
                    "hash": "88A12B95BC7F15C2A436C09BB7F0E01F"
                },
                {
                    "type": "320k",
                    "size": "10.07 MB",
                    "hash": "F33FB2796302E52009E1E5FC709506EF"
                },
                {
                    "type": "flac",
                    "size": "30.18 MB",
                    "hash": "D805A3CD26AF92616364785A73CFDE6F"
                },
                {
                    "type": "flac24bit",
                    "size": "31.39 MB",
                    "hash": "C319260477FB71DECEE1641DFAAB0052"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.03 MB",
                    "hash": "88A12B95BC7F15C2A436C09BB7F0E01F"
                },
                "320k": {
                    "size": "10.07 MB",
                    "hash": "F33FB2796302E52009E1E5FC709506EF"
                },
                "flac": {
                    "size": "30.18 MB",
                    "hash": "D805A3CD26AF92616364785A73CFDE6F"
                },
                "flac24bit": {
                    "size": "31.39 MB",
                    "hash": "C319260477FB71DECEE1641DFAAB0052"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "蔡依林",
            "name": "我知道你很难过",
            "albumName": "J女神 影音典藏精选",
            "albumId": "9040249",
            "songmid": "149134",
            "source": "kg",
            "interval": "04:27",
            "img": "http://imge.kugou.com/stdmusic/400/20250207/20250207161153278803.jpg",
            "lrc": null,
            "hash": "4471A034CC5FAD1EAE07453226AAEA44",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.08 MB",
                    "hash": "4471A034CC5FAD1EAE07453226AAEA44"
                },
                {
                    "type": "320k",
                    "size": "10.20 MB",
                    "hash": "B25CB7E9E1556747669BA6FB0A5589CB"
                },
                {
                    "type": "flac",
                    "size": "27.88 MB",
                    "hash": "F8CA19D71CE70A24A49E1A3C985D4A75"
                },
                {
                    "type": "flac24bit",
                    "size": "28.87 MB",
                    "hash": "910CA44B4733331E36FB217063C9585C"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.08 MB",
                    "hash": "4471A034CC5FAD1EAE07453226AAEA44"
                },
                "320k": {
                    "size": "10.20 MB",
                    "hash": "B25CB7E9E1556747669BA6FB0A5589CB"
                },
                "flac": {
                    "size": "27.88 MB",
                    "hash": "F8CA19D71CE70A24A49E1A3C985D4A75"
                },
                "flac24bit": {
                    "size": "28.87 MB",
                    "hash": "910CA44B4733331E36FB217063C9585C"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "刘德华",
            "name": "男人哭吧不是罪",
            "albumName": "男人的爱",
            "albumId": "976179",
            "songmid": "273990",
            "source": "kg",
            "interval": "05:11",
            "img": "http://imge.kugou.com/stdmusic/400/20250812/20250812210402419543.jpg",
            "lrc": null,
            "hash": "518B9C5F6E7725619DA6C6B478C56179",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.75 MB",
                    "hash": "518B9C5F6E7725619DA6C6B478C56179"
                },
                {
                    "type": "320k",
                    "size": "11.87 MB",
                    "hash": "73252948197F5E0DA86EF84CA54FFCB2"
                },
                {
                    "type": "flac",
                    "size": "35.68 MB",
                    "hash": "F1148045917991640A7517FCE9CF1923"
                },
                {
                    "type": "flac24bit",
                    "size": "36.70 MB",
                    "hash": "4CB2BD64CA323E0EF33B5F9390BB1084"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.75 MB",
                    "hash": "518B9C5F6E7725619DA6C6B478C56179"
                },
                "320k": {
                    "size": "11.87 MB",
                    "hash": "73252948197F5E0DA86EF84CA54FFCB2"
                },
                "flac": {
                    "size": "35.68 MB",
                    "hash": "F1148045917991640A7517FCE9CF1923"
                },
                "flac24bit": {
                    "size": "36.70 MB",
                    "hash": "4CB2BD64CA323E0EF33B5F9390BB1084"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周蕙",
            "name": "好想好好爱你",
            "albumName": "蕙儿绝版",
            "albumId": "972044",
            "songmid": "305003366",
            "source": "kg",
            "interval": "04:15",
            "img": "http://imge.kugou.com/stdmusic/400/20150715/20150715222637968057.jpg",
            "lrc": null,
            "hash": "79443A12694560502FC65CAFF1CC204D",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.91 MB",
                    "hash": "79443A12694560502FC65CAFF1CC204D"
                },
                {
                    "type": "320k",
                    "size": "9.77 MB",
                    "hash": "0EC7A18144AC3F40D9B35529D0ECF42D"
                },
                {
                    "type": "flac",
                    "size": "25.45 MB",
                    "hash": "1605BDAA298ADF456F6F37C515326FD4"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.91 MB",
                    "hash": "79443A12694560502FC65CAFF1CC204D"
                },
                "320k": {
                    "size": "9.77 MB",
                    "hash": "0EC7A18144AC3F40D9B35529D0ECF42D"
                },
                "flac": {
                    "size": "25.45 MB",
                    "hash": "1605BDAA298ADF456F6F37C515326FD4"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "五月天",
            "name": "温柔",
            "albumName": "爱情万岁",
            "albumId": "929528",
            "songmid": "293695",
            "source": "kg",
            "interval": "04:29",
            "img": "http://imge.kugou.com/stdmusic/400/20240108/20240108141801169434.jpg",
            "lrc": null,
            "hash": "5B67B37FC9EA407D942018FB8D0B2F39",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.11 MB",
                    "hash": "5B67B37FC9EA407D942018FB8D0B2F39"
                },
                {
                    "type": "320k",
                    "size": "10.28 MB",
                    "hash": "7425A51F58464B7D4A1D6BAB631A85A9"
                },
                {
                    "type": "flac",
                    "size": "32.95 MB",
                    "hash": "2EE2798ADAC460D7ED207AB918F3DFF2"
                },
                {
                    "type": "flac24bit",
                    "size": "33.72 MB",
                    "hash": "8A374A95AA85A775F33BE43ED189F1F1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.11 MB",
                    "hash": "5B67B37FC9EA407D942018FB8D0B2F39"
                },
                "320k": {
                    "size": "10.28 MB",
                    "hash": "7425A51F58464B7D4A1D6BAB631A85A9"
                },
                "flac": {
                    "size": "32.95 MB",
                    "hash": "2EE2798ADAC460D7ED207AB918F3DFF2"
                },
                "flac24bit": {
                    "size": "33.72 MB",
                    "hash": "8A374A95AA85A775F33BE43ED189F1F1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张国荣",
            "name": "月亮代表我的心",
            "albumName": "钟情张国荣",
            "albumId": "962814",
            "songmid": "305018417",
            "source": "kg",
            "interval": "04:10",
            "img": "http://imge.kugou.com/stdmusic/400/20150720/20150720194719176436.jpg",
            "lrc": null,
            "hash": "EE6AD3F5AA75BEA7FF983BF15740CCE6",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.82 MB",
                    "hash": "EE6AD3F5AA75BEA7FF983BF15740CCE6"
                },
                {
                    "type": "320k",
                    "size": "9.54 MB",
                    "hash": "137804F8E7E83437B99F18DAF0245DC6"
                },
                {
                    "type": "flac",
                    "size": "22.52 MB",
                    "hash": "D8972B0FB6757B6B7C3409639AFBA0A5"
                },
                {
                    "type": "flac24bit",
                    "size": "82.40 MB",
                    "hash": "BEC88E75074152E8EA91C3BD5372CF50"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.82 MB",
                    "hash": "EE6AD3F5AA75BEA7FF983BF15740CCE6"
                },
                "320k": {
                    "size": "9.54 MB",
                    "hash": "137804F8E7E83437B99F18DAF0245DC6"
                },
                "flac": {
                    "size": "22.52 MB",
                    "hash": "D8972B0FB6757B6B7C3409639AFBA0A5"
                },
                "flac24bit": {
                    "size": "82.40 MB",
                    "hash": "BEC88E75074152E8EA91C3BD5372CF50"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁静茹",
            "name": "爱你不是两三天",
            "albumName": "恋爱的力量",
            "albumId": "973299",
            "songmid": "304569682",
            "source": "kg",
            "interval": "04:59",
            "img": "http://imge.kugou.com/stdmusic/400/20241205/20241205192457266564.jpg",
            "lrc": null,
            "hash": "68739D18578BB00444F6BDAEC98E7775",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.57 MB",
                    "hash": "68739D18578BB00444F6BDAEC98E7775"
                },
                {
                    "type": "320k",
                    "size": "11.43 MB",
                    "hash": "411AC645D33147916EBC2B1469C76BEC"
                },
                {
                    "type": "flac",
                    "size": "31.25 MB",
                    "hash": "AD593012F2CC29E84DCBE87608CD87C8"
                },
                {
                    "type": "flac24bit",
                    "size": "32.32 MB",
                    "hash": "A9D598E6ED4B3038CADBD6796419556B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.57 MB",
                    "hash": "68739D18578BB00444F6BDAEC98E7775"
                },
                "320k": {
                    "size": "11.43 MB",
                    "hash": "411AC645D33147916EBC2B1469C76BEC"
                },
                "flac": {
                    "size": "31.25 MB",
                    "hash": "AD593012F2CC29E84DCBE87608CD87C8"
                },
                "flac24bit": {
                    "size": "32.32 MB",
                    "hash": "A9D598E6ED4B3038CADBD6796419556B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张学友",
            "name": "她来听我的演唱会",
            "albumName": "Black & White",
            "albumId": "973142",
            "songmid": "303202400",
            "source": "kg",
            "interval": "04:51",
            "img": "http://imge.kugou.com/stdmusic/400/20250521/20250521224818514539.jpg",
            "lrc": null,
            "hash": "F7C71DF8DBD98187E1AF1823F9A8B8A4",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.44 MB",
                    "hash": "F7C71DF8DBD98187E1AF1823F9A8B8A4"
                },
                {
                    "type": "320k",
                    "size": "11.11 MB",
                    "hash": "B471FE811A36813A06479A9858FE775B"
                },
                {
                    "type": "flac",
                    "size": "27.48 MB",
                    "hash": "735E025F0568D2B4D67EBFDD1E1A28AF"
                },
                {
                    "type": "flac24bit",
                    "size": "28.91 MB",
                    "hash": "1D3D0E3AF70968261BD6E1A1C3D4364B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.44 MB",
                    "hash": "F7C71DF8DBD98187E1AF1823F9A8B8A4"
                },
                "320k": {
                    "size": "11.11 MB",
                    "hash": "B471FE811A36813A06479A9858FE775B"
                },
                "flac": {
                    "size": "27.48 MB",
                    "hash": "735E025F0568D2B4D67EBFDD1E1A28AF"
                },
                "flac24bit": {
                    "size": "28.91 MB",
                    "hash": "1D3D0E3AF70968261BD6E1A1C3D4364B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林志炫",
            "name": "蒙娜丽莎的眼泪",
            "albumName": "蒙娜丽莎的眼泪 豪华典藏版",
            "albumId": "527266",
            "songmid": "303178717",
            "source": "kg",
            "interval": "04:27",
            "img": "http://imge.kugou.com/stdmusic/400/20210114/20210114140425504543.jpg",
            "lrc": null,
            "hash": "97A80DCE89C0586CBC506C1A63629F5A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.09 MB",
                    "hash": "97A80DCE89C0586CBC506C1A63629F5A"
                },
                {
                    "type": "320k",
                    "size": "10.21 MB",
                    "hash": "AEE30C268D52E9F6438B59B681DA50F9"
                },
                {
                    "type": "flac",
                    "size": "26.76 MB",
                    "hash": "FF48AC1DF9BC9396E76A7E96097D0F2E"
                },
                {
                    "type": "flac24bit",
                    "size": "144.52 MB",
                    "hash": "3C070B028DF50757F2C63223CAB82573"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.09 MB",
                    "hash": "97A80DCE89C0586CBC506C1A63629F5A"
                },
                "320k": {
                    "size": "10.21 MB",
                    "hash": "AEE30C268D52E9F6438B59B681DA50F9"
                },
                "flac": {
                    "size": "26.76 MB",
                    "hash": "FF48AC1DF9BC9396E76A7E96097D0F2E"
                },
                "flac24bit": {
                    "size": "144.52 MB",
                    "hash": "3C070B028DF50757F2C63223CAB82573"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林志炫",
            "name": "单身情歌",
            "albumName": "最爱美声-影音典藏精选",
            "albumId": "524608",
            "songmid": "301312263",
            "source": "kg",
            "interval": "04:37",
            "img": "http://imge.kugou.com/stdmusic/400/20250101/20250101081355189622.jpg",
            "lrc": null,
            "hash": "083BA9244D514816B574EB02C77381A3",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.23 MB",
                    "hash": "083BA9244D514816B574EB02C77381A3"
                },
                {
                    "type": "320k",
                    "size": "10.58 MB",
                    "hash": "56820EAD75C4CC0703ECFA484ACE3710"
                },
                {
                    "type": "flac",
                    "size": "31.90 MB",
                    "hash": "FDB9B063DCC42C58374485F304BFF99A"
                },
                {
                    "type": "flac24bit",
                    "size": "32.54 MB",
                    "hash": "A5C1BDFB1F087AE7D8357947C147E1FB"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.23 MB",
                    "hash": "083BA9244D514816B574EB02C77381A3"
                },
                "320k": {
                    "size": "10.58 MB",
                    "hash": "56820EAD75C4CC0703ECFA484ACE3710"
                },
                "flac": {
                    "size": "31.90 MB",
                    "hash": "FDB9B063DCC42C58374485F304BFF99A"
                },
                "flac24bit": {
                    "size": "32.54 MB",
                    "hash": "A5C1BDFB1F087AE7D8357947C147E1FB"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王菲",
            "name": "容易受伤的女人",
            "albumName": "国语经典101",
            "albumId": "1738328",
            "songmid": "303085531",
            "source": "kg",
            "interval": "04:20",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909124243938637.jpg",
            "lrc": null,
            "hash": "C6FD196F0FD0C032A70173450EFE11C5",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.97 MB",
                    "hash": "C6FD196F0FD0C032A70173450EFE11C5"
                },
                {
                    "type": "320k",
                    "size": "9.92 MB",
                    "hash": "594E6133625A8D69A5E2ACC933C26FD3"
                },
                {
                    "type": "flac",
                    "size": "26.48 MB",
                    "hash": "A1AFACACD729C057C488C19FC0461B80"
                },
                {
                    "type": "flac24bit",
                    "size": "27.52 MB",
                    "hash": "08A7369FA18B3411994FE3E2C99D0B5B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.97 MB",
                    "hash": "C6FD196F0FD0C032A70173450EFE11C5"
                },
                "320k": {
                    "size": "9.92 MB",
                    "hash": "594E6133625A8D69A5E2ACC933C26FD3"
                },
                "flac": {
                    "size": "26.48 MB",
                    "hash": "A1AFACACD729C057C488C19FC0461B80"
                },
                "flac24bit": {
                    "size": "27.52 MB",
                    "hash": "08A7369FA18B3411994FE3E2C99D0B5B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张惠妹",
            "name": "原来你什么都不要",
            "albumName": "我最亲爱的张惠妹 - 给自己的精选（2015 Edition）",
            "albumId": "535156",
            "songmid": "304580273",
            "source": "kg",
            "interval": "04:47",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909114939574577.jpg",
            "lrc": null,
            "hash": "DB2983639546862A3086D953D85BC9D3",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.38 MB",
                    "hash": "DB2983639546862A3086D953D85BC9D3"
                },
                {
                    "type": "320k",
                    "size": "10.96 MB",
                    "hash": "6B21D877901FB16DA036F146DACA84D2"
                },
                {
                    "type": "flac",
                    "size": "26.13 MB",
                    "hash": "6B0BC45C3CE84BE5446C55104BF2EF18"
                },
                {
                    "type": "flac24bit",
                    "size": "50.08 MB",
                    "hash": "703805F0F7B8B0F529D430C66EB7BE45"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.38 MB",
                    "hash": "DB2983639546862A3086D953D85BC9D3"
                },
                "320k": {
                    "size": "10.96 MB",
                    "hash": "6B21D877901FB16DA036F146DACA84D2"
                },
                "flac": {
                    "size": "26.13 MB",
                    "hash": "6B0BC45C3CE84BE5446C55104BF2EF18"
                },
                "flac24bit": {
                    "size": "50.08 MB",
                    "hash": "703805F0F7B8B0F529D430C66EB7BE45"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张学友",
            "name": "心如刀割",
            "albumName": "走过1999",
            "albumId": "963037",
            "songmid": "322290",
            "source": "kg",
            "interval": "05:04",
            "img": "http://imge.kugou.com/stdmusic/400/20241118/20241118143702193213.jpg",
            "lrc": null,
            "hash": "5269B0B55E44C502291BA38A34C2AAF7",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.65 MB",
                    "hash": "5269B0B55E44C502291BA38A34C2AAF7"
                },
                {
                    "type": "320k",
                    "size": "11.62 MB",
                    "hash": "BEAB46231D8841AC304E2E56B196FD2F"
                },
                {
                    "type": "flac",
                    "size": "29.87 MB",
                    "hash": "84DC0325BB17A33203F027C8EA99A5CC"
                },
                {
                    "type": "flac24bit",
                    "size": "31.03 MB",
                    "hash": "0E381DF2D6B9D94CD95B9061C8E7D994"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.65 MB",
                    "hash": "5269B0B55E44C502291BA38A34C2AAF7"
                },
                "320k": {
                    "size": "11.62 MB",
                    "hash": "BEAB46231D8841AC304E2E56B196FD2F"
                },
                "flac": {
                    "size": "29.87 MB",
                    "hash": "84DC0325BB17A33203F027C8EA99A5CC"
                },
                "flac24bit": {
                    "size": "31.03 MB",
                    "hash": "0E381DF2D6B9D94CD95B9061C8E7D994"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "光良",
            "name": "如果你还爱我",
            "albumName": "第1次个人创作专辑",
            "albumId": "930386",
            "songmid": "706788",
            "source": "kg",
            "interval": "04:43",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121809247297.jpg",
            "lrc": null,
            "hash": "40F671FAF0F8675EDA71540E526702A1",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.33 MB",
                    "hash": "40F671FAF0F8675EDA71540E526702A1"
                },
                {
                    "type": "320k",
                    "size": "10.82 MB",
                    "hash": "071B66C477484DB8E43E5D3C9AA9A250"
                },
                {
                    "type": "flac",
                    "size": "28.02 MB",
                    "hash": "AD8489D0060ECB9BE462D558D4B27FE2"
                },
                {
                    "type": "flac24bit",
                    "size": "28.98 MB",
                    "hash": "8DC8A95A3099F2D44DFCBBB9B15F2A6E"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.33 MB",
                    "hash": "40F671FAF0F8675EDA71540E526702A1"
                },
                "320k": {
                    "size": "10.82 MB",
                    "hash": "071B66C477484DB8E43E5D3C9AA9A250"
                },
                "flac": {
                    "size": "28.02 MB",
                    "hash": "AD8489D0060ECB9BE462D558D4B27FE2"
                },
                "flac24bit": {
                    "size": "28.98 MB",
                    "hash": "8DC8A95A3099F2D44DFCBBB9B15F2A6E"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁静茹",
            "name": "如果有一天",
            "albumName": "勇气",
            "albumId": "970586",
            "songmid": "340355",
            "source": "kg",
            "interval": "04:42",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121749937380.jpg",
            "lrc": null,
            "hash": "4CC6E71092C3D76B55C2173EA84CC949",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.31 MB",
                    "hash": "4CC6E71092C3D76B55C2173EA84CC949"
                },
                {
                    "type": "320k",
                    "size": "10.78 MB",
                    "hash": "F42B4491D46CE2582519251FB0BE1052"
                },
                {
                    "type": "flac",
                    "size": "27.90 MB",
                    "hash": "F3A7AC885EB6FA896F6923806AB242DF"
                },
                {
                    "type": "flac24bit",
                    "size": "29.13 MB",
                    "hash": "C6A5A67BF2D084FBFB4E9B49DB7338FC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.31 MB",
                    "hash": "4CC6E71092C3D76B55C2173EA84CC949"
                },
                "320k": {
                    "size": "10.78 MB",
                    "hash": "F42B4491D46CE2582519251FB0BE1052"
                },
                "flac": {
                    "size": "27.90 MB",
                    "hash": "F3A7AC885EB6FA896F6923806AB242DF"
                },
                "flac24bit": {
                    "size": "29.13 MB",
                    "hash": "C6A5A67BF2D084FBFB4E9B49DB7338FC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周华健",
            "name": "花心",
            "albumName": "花心",
            "albumId": "36856462",
            "songmid": "254010",
            "source": "kg",
            "interval": "03:50",
            "img": "http://imge.kugou.com/stdmusic/400/20241118/20241118160628194024.jpg",
            "lrc": null,
            "hash": "DE1A1DD3DCFCA538FA762588B00A7D6E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.51 MB",
                    "hash": "DE1A1DD3DCFCA538FA762588B00A7D6E"
                },
                {
                    "type": "320k",
                    "size": "8.78 MB",
                    "hash": "443F260DCC996219483BBE9D26E0F7B3"
                },
                {
                    "type": "flac",
                    "size": "25.77 MB",
                    "hash": "07F018F7AE24354AF1C09A70A691DB97"
                },
                {
                    "type": "flac24bit",
                    "size": "95.29 MB",
                    "hash": "4234D2EA931F5BB9399588396C5A058B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.51 MB",
                    "hash": "DE1A1DD3DCFCA538FA762588B00A7D6E"
                },
                "320k": {
                    "size": "8.78 MB",
                    "hash": "443F260DCC996219483BBE9D26E0F7B3"
                },
                "flac": {
                    "size": "25.77 MB",
                    "hash": "07F018F7AE24354AF1C09A70A691DB97"
                },
                "flac24bit": {
                    "size": "95.29 MB",
                    "hash": "4234D2EA931F5BB9399588396C5A058B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "许绍洋",
            "name": "花香",
            "albumName": "薰衣草 电视原声带",
            "albumId": "1747081",
            "songmid": "153463",
            "source": "kg",
            "interval": "04:28",
            "img": "http://imge.kugou.com/stdmusic/400/20231018/20231018142402272514.jpg",
            "lrc": null,
            "hash": "C93FA275B1BD63473A488586024D5C97",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.09 MB",
                    "hash": "C93FA275B1BD63473A488586024D5C97"
                },
                {
                    "type": "320k",
                    "size": "10.24 MB",
                    "hash": "2DBDBE6A7C6E72DD3CDFD8529F7EFE84"
                },
                {
                    "type": "flac",
                    "size": "30.85 MB",
                    "hash": "79831378B50517EFDA2AB5E6326ED18E"
                },
                {
                    "type": "flac24bit",
                    "size": "31.72 MB",
                    "hash": "C43CD9C0FC24E0646E3E13F070DBDB36"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.09 MB",
                    "hash": "C93FA275B1BD63473A488586024D5C97"
                },
                "320k": {
                    "size": "10.24 MB",
                    "hash": "2DBDBE6A7C6E72DD3CDFD8529F7EFE84"
                },
                "flac": {
                    "size": "30.85 MB",
                    "hash": "79831378B50517EFDA2AB5E6326ED18E"
                },
                "flac24bit": {
                    "size": "31.72 MB",
                    "hash": "C43CD9C0FC24E0646E3E13F070DBDB36"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "许美静",
            "name": "遗憾",
            "albumName": "静听精彩十三首",
            "albumId": "963225",
            "songmid": "304548486",
            "source": "kg",
            "interval": "04:39",
            "img": "http://imge.kugou.com/stdmusic/400/20220331/20220331101210841993.jpg",
            "lrc": null,
            "hash": "01CB741FA45AE902AD1CBC0AB938E6D5",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.27 MB",
                    "hash": "01CB741FA45AE902AD1CBC0AB938E6D5"
                },
                {
                    "type": "320k",
                    "size": "10.67 MB",
                    "hash": "E98E00CAA120488B5B7714896FE82947"
                },
                {
                    "type": "flac",
                    "size": "27.19 MB",
                    "hash": "2BA4C746E4E1F022FE20212D6DE67325"
                },
                {
                    "type": "flac24bit",
                    "size": "28.13 MB",
                    "hash": "FF2046E3809DAD9B479922A9D3B90D7B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.27 MB",
                    "hash": "01CB741FA45AE902AD1CBC0AB938E6D5"
                },
                "320k": {
                    "size": "10.67 MB",
                    "hash": "E98E00CAA120488B5B7714896FE82947"
                },
                "flac": {
                    "size": "27.19 MB",
                    "hash": "2BA4C746E4E1F022FE20212D6DE67325"
                },
                "flac24bit": {
                    "size": "28.13 MB",
                    "hash": "FF2046E3809DAD9B479922A9D3B90D7B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "五月天",
            "name": "拥抱",
            "albumName": "Call Me No.1!",
            "albumId": "526442",
            "songmid": "304849706",
            "source": "kg",
            "interval": "04:12",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909113526521066.jpg",
            "lrc": null,
            "hash": "4575DF998C2358C21294A824879BEC5C",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.86 MB",
                    "hash": "4575DF998C2358C21294A824879BEC5C"
                },
                {
                    "type": "320k",
                    "size": "9.64 MB",
                    "hash": "F4D5BED40AD285ABC53BD38BF8D23CE5"
                },
                {
                    "type": "flac",
                    "size": "25.40 MB",
                    "hash": "08AD600CCC360628110A40F6951B66DA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.86 MB",
                    "hash": "4575DF998C2358C21294A824879BEC5C"
                },
                "320k": {
                    "size": "9.64 MB",
                    "hash": "F4D5BED40AD285ABC53BD38BF8D23CE5"
                },
                "flac": {
                    "size": "25.40 MB",
                    "hash": "08AD600CCC360628110A40F6951B66DA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "辛晓琪",
            "name": "领悟",
            "albumName": "超级星光PK宝典",
            "albumId": "5291222",
            "songmid": "303147831",
            "source": "kg",
            "interval": "04:53",
            "img": "http://imge.kugou.com/stdmusic/400/20210114/20210114135931748364.jpg",
            "lrc": null,
            "hash": "506A90089D79C5782040C95273E65AFE",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.48 MB",
                    "hash": "506A90089D79C5782040C95273E65AFE"
                },
                {
                    "type": "320k",
                    "size": "11.19 MB",
                    "hash": "D369B3E276F94225E402C28E1F4F3663"
                },
                {
                    "type": "flac",
                    "size": "32.19 MB",
                    "hash": "A94E3928A233DE0E8ED115B351E79713"
                },
                {
                    "type": "flac24bit",
                    "size": "33.48 MB",
                    "hash": "069BB3475676465E5D4CC9BFA6F72552"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.48 MB",
                    "hash": "506A90089D79C5782040C95273E65AFE"
                },
                "320k": {
                    "size": "11.19 MB",
                    "hash": "D369B3E276F94225E402C28E1F4F3663"
                },
                "flac": {
                    "size": "32.19 MB",
                    "hash": "A94E3928A233DE0E8ED115B351E79713"
                },
                "flac24bit": {
                    "size": "33.48 MB",
                    "hash": "069BB3475676465E5D4CC9BFA6F72552"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "罗大方",
            "name": "郑智化 - 水手",
            "albumName": "年轻人喜欢的嗨曲",
            "albumId": "170045845",
            "songmid": "1103844194",
            "source": "kg",
            "interval": "04:59",
            "img": "http://imge.kugou.com/stdmusic/400/20251207/20251207214921457762.jpg",
            "lrc": null,
            "hash": "B831B046A63D2E88CE6F2AD92A7882E6",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.58 MB",
                    "hash": "B831B046A63D2E88CE6F2AD92A7882E6"
                },
                {
                    "type": "320k",
                    "size": "11.44 MB",
                    "hash": "0E419C98E4937A5A8AF9EA32F4396D53"
                },
                {
                    "type": "flac",
                    "size": "30.84 MB",
                    "hash": "9371830D31AE810E05DF41C8C05B1C02"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.58 MB",
                    "hash": "B831B046A63D2E88CE6F2AD92A7882E6"
                },
                "320k": {
                    "size": "11.44 MB",
                    "hash": "0E419C98E4937A5A8AF9EA32F4396D53"
                },
                "flac": {
                    "size": "30.84 MB",
                    "hash": "9371830D31AE810E05DF41C8C05B1C02"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "动力火车",
            "name": "那就这样吧",
            "albumName": "百万全纪录",
            "albumId": "966494",
            "songmid": "302422514",
            "source": "kg",
            "interval": "04:36",
            "img": "http://imge.kugou.com/stdmusic/400/20190610/20190610190802674888.jpg",
            "lrc": null,
            "hash": "E447995B7B15B4D4D3DFA9BCD09F39ED",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.21 MB",
                    "hash": "E447995B7B15B4D4D3DFA9BCD09F39ED"
                },
                {
                    "type": "320k",
                    "size": "10.54 MB",
                    "hash": "ABBB636452E3F5A7AE4877D14D489E3D"
                },
                {
                    "type": "flac",
                    "size": "29.20 MB",
                    "hash": "3ABD895B009CE3E49BA15690F3D08D30"
                },
                {
                    "type": "flac24bit",
                    "size": "30.11 MB",
                    "hash": "C5D2FCC19E86285BBAD99F9DE6371E1B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.21 MB",
                    "hash": "E447995B7B15B4D4D3DFA9BCD09F39ED"
                },
                "320k": {
                    "size": "10.54 MB",
                    "hash": "ABBB636452E3F5A7AE4877D14D489E3D"
                },
                "flac": {
                    "size": "29.20 MB",
                    "hash": "3ABD895B009CE3E49BA15690F3D08D30"
                },
                "flac24bit": {
                    "size": "30.11 MB",
                    "hash": "C5D2FCC19E86285BBAD99F9DE6371E1B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "刘德华",
            "name": "冰雨",
            "albumName": "经典重现",
            "albumId": "961788",
            "songmid": "1082901547",
            "source": "kg",
            "interval": "04:39",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121715903769.jpg",
            "lrc": null,
            "hash": "ACFD23883542F8B71D99F3E2BA20A306",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.27 MB",
                    "hash": "ACFD23883542F8B71D99F3E2BA20A306"
                },
                {
                    "type": "320k",
                    "size": "10.67 MB",
                    "hash": "EF1BFC2C29803A83E79F18B4300CD62B"
                },
                {
                    "type": "flac",
                    "size": "32.75 MB",
                    "hash": "4B3BED8CBC5069EB85FF3BAC365A1996"
                },
                {
                    "type": "flac24bit",
                    "size": "34.16 MB",
                    "hash": "6160E6C03C93CB06A67DF1ECB74AFDCE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.27 MB",
                    "hash": "ACFD23883542F8B71D99F3E2BA20A306"
                },
                "320k": {
                    "size": "10.67 MB",
                    "hash": "EF1BFC2C29803A83E79F18B4300CD62B"
                },
                "flac": {
                    "size": "32.75 MB",
                    "hash": "4B3BED8CBC5069EB85FF3BAC365A1996"
                },
                "flac24bit": {
                    "size": "34.16 MB",
                    "hash": "6160E6C03C93CB06A67DF1ECB74AFDCE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "彭佳慧",
            "name": "相见恨晚",
            "albumName": "敲敲我的头",
            "albumId": "977553",
            "songmid": "339459",
            "source": "kg",
            "interval": "04:14",
            "img": "http://imge.kugou.com/stdmusic/400/20241118/20241118143503371788.jpg",
            "lrc": null,
            "hash": "01214FB85BAF49AB74F10AFA4C363540",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.89 MB",
                    "hash": "01214FB85BAF49AB74F10AFA4C363540"
                },
                {
                    "type": "320k",
                    "size": "9.72 MB",
                    "hash": "3AC5D3EFDEAB597207CB0D83A0DAF99D"
                },
                {
                    "type": "flac",
                    "size": "27.48 MB",
                    "hash": "6C70AF47A7B0C9E28C6BEC829A167E72"
                },
                {
                    "type": "flac24bit",
                    "size": "48.81 MB",
                    "hash": "097BD67AD61D6361A6E5F7C73781BF36"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.89 MB",
                    "hash": "01214FB85BAF49AB74F10AFA4C363540"
                },
                "320k": {
                    "size": "9.72 MB",
                    "hash": "3AC5D3EFDEAB597207CB0D83A0DAF99D"
                },
                "flac": {
                    "size": "27.48 MB",
                    "hash": "6C70AF47A7B0C9E28C6BEC829A167E72"
                },
                "flac24bit": {
                    "size": "48.81 MB",
                    "hash": "097BD67AD61D6361A6E5F7C73781BF36"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王力宏",
            "name": "唯一",
            "albumName": "婚礼歌手 幸福情歌精选",
            "albumId": "160919265",
            "songmid": "302450553",
            "source": "kg",
            "interval": "04:19",
            "img": "http://imge.kugou.com/stdmusic/400/20260503/20260503210711169482.jpg",
            "lrc": null,
            "hash": "ABFC9EDEC179DB3E0D772CE737441081",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.95 MB",
                    "hash": "ABFC9EDEC179DB3E0D772CE737441081"
                },
                {
                    "type": "320k",
                    "size": "9.89 MB",
                    "hash": "B81DE6D6449BDE0258E7FA88B0F6007B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.95 MB",
                    "hash": "ABFC9EDEC179DB3E0D772CE737441081"
                },
                "320k": {
                    "size": "9.89 MB",
                    "hash": "B81DE6D6449BDE0258E7FA88B0F6007B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王强",
            "name": "秋天不回来 (DJ版)(网友改编)",
            "albumName": "",
            "songmid": "1085185790",
            "source": "kg",
            "interval": "04:11",
            "img": "http://singerimg.kugou.com/uploadpic/softhead/400/20230420/20230420153655191349.jpg",
            "lrc": null,
            "hash": "8478CC0A2DA253394175AC359D9B7F84",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.84 MB",
                    "hash": "8478CC0A2DA253394175AC359D9B7F84"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.84 MB",
                    "hash": "8478CC0A2DA253394175AC359D9B7F84"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陈晓东",
            "name": "比我幸福",
            "albumName": "环球最爱巨星系列",
            "albumId": "1653120",
            "songmid": "303213921",
            "source": "kg",
            "interval": "04:32",
            "img": "http://imge.kugou.com/stdmusic/400/20160908/20160908170521660116.jpg",
            "lrc": null,
            "hash": "AEED97B10F79047C0E5D0A0BE1963FFD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.15 MB",
                    "hash": "AEED97B10F79047C0E5D0A0BE1963FFD"
                },
                {
                    "type": "320k",
                    "size": "10.38 MB",
                    "hash": "395E2869822E1D230F8A9E8CB9001539"
                },
                {
                    "type": "flac",
                    "size": "32.99 MB",
                    "hash": "A22CD727B174D073F7AD943EA66FE275"
                },
                {
                    "type": "flac24bit",
                    "size": "31.47 MB",
                    "hash": "86CE3A5392FA41AA8448A1637D8B6FE7"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.15 MB",
                    "hash": "AEED97B10F79047C0E5D0A0BE1963FFD"
                },
                "320k": {
                    "size": "10.38 MB",
                    "hash": "395E2869822E1D230F8A9E8CB9001539"
                },
                "flac": {
                    "size": "32.99 MB",
                    "hash": "A22CD727B174D073F7AD943EA66FE275"
                },
                "flac24bit": {
                    "size": "31.47 MB",
                    "hash": "86CE3A5392FA41AA8448A1637D8B6FE7"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "唐磊",
            "name": "丁香花",
            "albumName": "丁香花",
            "albumId": "981768",
            "songmid": "245627",
            "source": "kg",
            "interval": "04:25",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620095751706795.jpg",
            "lrc": null,
            "hash": "B4D9E5994192C35095BC6A50D6BDE135",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.06 MB",
                    "hash": "B4D9E5994192C35095BC6A50D6BDE135"
                },
                {
                    "type": "320k",
                    "size": "10.14 MB",
                    "hash": "382F0486CA860DE63092C43020195570"
                },
                {
                    "type": "flac",
                    "size": "28.07 MB",
                    "hash": "FE7CA4F0694526098FE639E4D7CDFB8C"
                },
                {
                    "type": "flac24bit",
                    "size": "29.04 MB",
                    "hash": "BC4035A5CCBA63713C1ECC1B3CBE2B44"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.06 MB",
                    "hash": "B4D9E5994192C35095BC6A50D6BDE135"
                },
                "320k": {
                    "size": "10.14 MB",
                    "hash": "382F0486CA860DE63092C43020195570"
                },
                "flac": {
                    "size": "28.07 MB",
                    "hash": "FE7CA4F0694526098FE639E4D7CDFB8C"
                },
                "flac24bit": {
                    "size": "29.04 MB",
                    "hash": "BC4035A5CCBA63713C1ECC1B3CBE2B44"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "阿杜",
            "name": "撕夜",
            "albumName": "天黑",
            "albumId": "963634",
            "songmid": "247397",
            "source": "kg",
            "interval": "04:38",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121718748395.jpg",
            "lrc": null,
            "hash": "F4654DA8D595995AA50EC54232E1D525",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.26 MB",
                    "hash": "F4654DA8D595995AA50EC54232E1D525"
                },
                {
                    "type": "320k",
                    "size": "10.64 MB",
                    "hash": "3A6E1E9E136DC4CFF854253CD6556F07"
                },
                {
                    "type": "flac",
                    "size": "31.43 MB",
                    "hash": "75F4D5E7BCC47A3105CA73A3718060BA"
                },
                {
                    "type": "flac24bit",
                    "size": "32.53 MB",
                    "hash": "E57C03618430F08FD04320712AF6E7BA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.26 MB",
                    "hash": "F4654DA8D595995AA50EC54232E1D525"
                },
                "320k": {
                    "size": "10.64 MB",
                    "hash": "3A6E1E9E136DC4CFF854253CD6556F07"
                },
                "flac": {
                    "size": "31.43 MB",
                    "hash": "75F4D5E7BCC47A3105CA73A3718060BA"
                },
                "flac24bit": {
                    "size": "32.53 MB",
                    "hash": "E57C03618430F08FD04320712AF6E7BA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "罗大方",
            "name": "89.S.H.E.恋人未满",
            "albumName": "80后音乐记忆",
            "albumId": "170131393",
            "songmid": "302505362",
            "source": "kg",
            "interval": "04:36",
            "img": "http://imge.kugou.com/stdmusic/400/20251208/20251208214920939721.jpg",
            "lrc": null,
            "hash": "6B27EA41802C74AFB19877E18196658B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.22 MB",
                    "hash": "6B27EA41802C74AFB19877E18196658B"
                },
                {
                    "type": "320k",
                    "size": "10.56 MB",
                    "hash": "43090B82C5B76534D58CFF68FE3196EE"
                },
                {
                    "type": "flac",
                    "size": "32.72 MB",
                    "hash": "91D4A1808E137C8EED2CD4FE01E003A4"
                },
                {
                    "type": "flac24bit",
                    "size": "31.35 MB",
                    "hash": "62F314AD9486F04FEFECDE388CDC10AA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.22 MB",
                    "hash": "6B27EA41802C74AFB19877E18196658B"
                },
                "320k": {
                    "size": "10.56 MB",
                    "hash": "43090B82C5B76534D58CFF68FE3196EE"
                },
                "flac": {
                    "size": "32.72 MB",
                    "hash": "91D4A1808E137C8EED2CD4FE01E003A4"
                },
                "flac24bit": {
                    "size": "31.35 MB",
                    "hash": "62F314AD9486F04FEFECDE388CDC10AA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "刘若英",
            "name": "成全",
            "albumName": "年华",
            "albumId": "980103",
            "songmid": "221919",
            "source": "kg",
            "interval": "04:36",
            "img": "http://imge.kugou.com/stdmusic/400/20231106/20231106113801693474.jpg",
            "lrc": null,
            "hash": "CE49D62B34AA86CC801339C6A60B9D93",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.22 MB",
                    "hash": "CE49D62B34AA86CC801339C6A60B9D93"
                },
                {
                    "type": "320k",
                    "size": "10.55 MB",
                    "hash": "E8D0C420481BAF0A8E7D6A32C58C9AF3"
                },
                {
                    "type": "flac",
                    "size": "31.29 MB",
                    "hash": "3541A8259C43B504758E5E0E65CCED4F"
                },
                {
                    "type": "flac24bit",
                    "size": "31.81 MB",
                    "hash": "D5043D74C97D2912DFAD80D1CFFF72B5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.22 MB",
                    "hash": "CE49D62B34AA86CC801339C6A60B9D93"
                },
                "320k": {
                    "size": "10.55 MB",
                    "hash": "E8D0C420481BAF0A8E7D6A32C58C9AF3"
                },
                "flac": {
                    "size": "31.29 MB",
                    "hash": "3541A8259C43B504758E5E0E65CCED4F"
                },
                "flac24bit": {
                    "size": "31.81 MB",
                    "hash": "D5043D74C97D2912DFAD80D1CFFF72B5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "游鸿明",
            "name": "爱我的人和我爱的人",
            "albumName": "世界太冷漠",
            "albumId": "1737855",
            "songmid": "302433466",
            "source": "kg",
            "interval": "04:32",
            "img": "http://imge.kugou.com/stdmusic/400/20250101/20250101070927253505.jpg",
            "lrc": null,
            "hash": "E72451E2D12CA3B41A725B6027F7A84A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.16 MB",
                    "hash": "E72451E2D12CA3B41A725B6027F7A84A"
                },
                {
                    "type": "320k",
                    "size": "10.39 MB",
                    "hash": "43A08D41CE93F9EBCAF69B921A7CF58F"
                },
                {
                    "type": "flac",
                    "size": "28.15 MB",
                    "hash": "54E1074DF04E0C186A6B26B18178260D"
                },
                {
                    "type": "flac24bit",
                    "size": "54.81 MB",
                    "hash": "3815FB7417D7832A2CE66F628898765F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.16 MB",
                    "hash": "E72451E2D12CA3B41A725B6027F7A84A"
                },
                "320k": {
                    "size": "10.39 MB",
                    "hash": "43A08D41CE93F9EBCAF69B921A7CF58F"
                },
                "flac": {
                    "size": "28.15 MB",
                    "hash": "54E1074DF04E0C186A6B26B18178260D"
                },
                "flac24bit": {
                    "size": "54.81 MB",
                    "hash": "3815FB7417D7832A2CE66F628898765F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陈坤",
            "name": "月半弯",
            "albumName": "渗透",
            "albumId": "961097",
            "songmid": "341413",
            "source": "kg",
            "interval": "04:10",
            "img": "http://imge.kugou.com/stdmusic/400/20250207/20250207161147812620.jpg",
            "lrc": null,
            "hash": "AA67F0E8981D2E3E1B5F781036412A6B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.82 MB",
                    "hash": "AA67F0E8981D2E3E1B5F781036412A6B"
                },
                {
                    "type": "320k",
                    "size": "9.55 MB",
                    "hash": "B145A050E3397E39A2861CD628A8D2B7"
                },
                {
                    "type": "flac",
                    "size": "27.46 MB",
                    "hash": "6E8D4AEBF2F140ADCA1648A3D5112796"
                },
                {
                    "type": "flac24bit",
                    "size": "27.93 MB",
                    "hash": "CD6D23E3A0F9F6EB79F99699852B4A6F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.82 MB",
                    "hash": "AA67F0E8981D2E3E1B5F781036412A6B"
                },
                "320k": {
                    "size": "9.55 MB",
                    "hash": "B145A050E3397E39A2861CD628A8D2B7"
                },
                "flac": {
                    "size": "27.46 MB",
                    "hash": "6E8D4AEBF2F140ADCA1648A3D5112796"
                },
                "flac24bit": {
                    "size": "27.93 MB",
                    "hash": "CD6D23E3A0F9F6EB79F99699852B4A6F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "范玮琪",
            "name": "可不可以不勇敢",
            "albumName": "真善美",
            "albumId": "971886",
            "songmid": "176675",
            "source": "kg",
            "interval": "04:10",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121648311036.jpg",
            "lrc": null,
            "hash": "2EAB874373A1D9A0AA693BBA3990DE4E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.83 MB",
                    "hash": "2EAB874373A1D9A0AA693BBA3990DE4E"
                },
                {
                    "type": "320k",
                    "size": "9.57 MB",
                    "hash": "CF38E18CC6E23BBCFC4108F9FDB81F8C"
                },
                {
                    "type": "flac",
                    "size": "25.36 MB",
                    "hash": "D224F17E92F323578CB7DECD8324913E"
                },
                {
                    "type": "flac24bit",
                    "size": "26.19 MB",
                    "hash": "30DFE6A2C093A7F98F1082D2A2498970"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.83 MB",
                    "hash": "2EAB874373A1D9A0AA693BBA3990DE4E"
                },
                "320k": {
                    "size": "9.57 MB",
                    "hash": "CF38E18CC6E23BBCFC4108F9FDB81F8C"
                },
                "flac": {
                    "size": "25.36 MB",
                    "hash": "D224F17E92F323578CB7DECD8324913E"
                },
                "flac24bit": {
                    "size": "26.19 MB",
                    "hash": "30DFE6A2C093A7F98F1082D2A2498970"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张颖",
            "name": "无所谓",
            "albumName": "风尘醉笛",
            "albumId": "100510363",
            "songmid": "1090655672",
            "source": "kg",
            "interval": "04:22",
            "img": "http://imge.kugou.com/stdmusic/400/20201114/20201114231957197306.jpg",
            "lrc": null,
            "hash": "A78EBBEB539AE7B9BEA437C3B335636F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.01 MB",
                    "hash": "A78EBBEB539AE7B9BEA437C3B335636F"
                },
                {
                    "type": "320k",
                    "size": "10.03 MB",
                    "hash": "BE9157C35D73E5410934F0F1DEABDD48"
                },
                {
                    "type": "flac",
                    "size": "29.58 MB",
                    "hash": "C544AE55A84F5696B341B500BBB292FE"
                },
                {
                    "type": "flac24bit",
                    "size": "28.21 MB",
                    "hash": "E315365772E79EFEB42D82DAE8A60AD8"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.01 MB",
                    "hash": "A78EBBEB539AE7B9BEA437C3B335636F"
                },
                "320k": {
                    "size": "10.03 MB",
                    "hash": "BE9157C35D73E5410934F0F1DEABDD48"
                },
                "flac": {
                    "size": "29.58 MB",
                    "hash": "C544AE55A84F5696B341B500BBB292FE"
                },
                "flac24bit": {
                    "size": "28.21 MB",
                    "hash": "E315365772E79EFEB42D82DAE8A60AD8"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "南拳妈妈",
            "name": "牡丹江",
            "albumName": "K情歌10",
            "albumId": "8438612",
            "songmid": "304490597",
            "source": "kg",
            "interval": "03:57",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620074650207307.jpg",
            "lrc": null,
            "hash": "6EADADD0AED9C71ECBDAC44396914F51",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.63 MB",
                    "hash": "6EADADD0AED9C71ECBDAC44396914F51"
                },
                {
                    "type": "320k",
                    "size": "9.63 MB",
                    "hash": "7F663E682FAB4B8971FB8EA7798F460C"
                },
                {
                    "type": "flac",
                    "size": "24.92 MB",
                    "hash": "0D4393C990092568BAC1CDE3CB2057BE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.63 MB",
                    "hash": "6EADADD0AED9C71ECBDAC44396914F51"
                },
                "320k": {
                    "size": "9.63 MB",
                    "hash": "7F663E682FAB4B8971FB8EA7798F460C"
                },
                "flac": {
                    "size": "24.92 MB",
                    "hash": "0D4393C990092568BAC1CDE3CB2057BE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "品冠",
            "name": "我以为",
            "albumName": "姊妹 电视剧原声带",
            "albumId": "885139",
            "songmid": "304520167",
            "source": "kg",
            "interval": "04:58",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620053355595771.jpg",
            "lrc": null,
            "hash": "472BE93753884F74EEC75CBA1F629B39",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.55 MB",
                    "hash": "472BE93753884F74EEC75CBA1F629B39"
                },
                {
                    "type": "320k",
                    "size": "11.39 MB",
                    "hash": "CB7E40F92996E2D714BA44F51676BA28"
                },
                {
                    "type": "flac",
                    "size": "32.69 MB",
                    "hash": "C7E6A0E3B4AC95C595D3F9BEAF1E44BE"
                },
                {
                    "type": "flac24bit",
                    "size": "33.83 MB",
                    "hash": "DB77C32B115C906912E1F972921776B0"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.55 MB",
                    "hash": "472BE93753884F74EEC75CBA1F629B39"
                },
                "320k": {
                    "size": "11.39 MB",
                    "hash": "CB7E40F92996E2D714BA44F51676BA28"
                },
                "flac": {
                    "size": "32.69 MB",
                    "hash": "C7E6A0E3B4AC95C595D3F9BEAF1E44BE"
                },
                "flac24bit": {
                    "size": "33.83 MB",
                    "hash": "DB77C32B115C906912E1F972921776B0"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林俊杰",
            "name": "美人鱼",
            "albumName": "期待爱 新歌+精选",
            "albumId": "526378",
            "songmid": "301284397",
            "source": "kg",
            "interval": "04:14",
            "img": "http://imge.kugou.com/stdmusic/400/20200922/20200922063702445527.jpg",
            "lrc": null,
            "hash": "A83FF657F615E4D5F6CC888F33300C9A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.88 MB",
                    "hash": "A83FF657F615E4D5F6CC888F33300C9A"
                },
                {
                    "type": "320k",
                    "size": "9.69 MB",
                    "hash": "717B77E3508DFED9631C4C4E37CC3566"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.88 MB",
                    "hash": "A83FF657F615E4D5F6CC888F33300C9A"
                },
                "320k": {
                    "size": "9.69 MB",
                    "hash": "717B77E3508DFED9631C4C4E37CC3566"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "杨丞琳",
            "name": "暧昧",
            "albumName": "暧昧",
            "albumId": "973888",
            "songmid": "348669",
            "source": "kg",
            "interval": "04:11",
            "img": "http://imge.kugou.com/stdmusic/400/20260604/20260604171533200788.jpg",
            "lrc": null,
            "hash": "6DE072AD8AF6B8D1BFF8AB71E54B462B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.84 MB",
                    "hash": "6DE072AD8AF6B8D1BFF8AB71E54B462B"
                },
                {
                    "type": "320k",
                    "size": "9.59 MB",
                    "hash": "1BBF76D24D890050A7E335E7CDFDBF40"
                },
                {
                    "type": "flac",
                    "size": "26.28 MB",
                    "hash": "92B85E4514074674FFABB0F521CEE8AB"
                },
                {
                    "type": "flac24bit",
                    "size": "47.41 MB",
                    "hash": "94521BA394D22EC90C403F4786FEA593"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.84 MB",
                    "hash": "6DE072AD8AF6B8D1BFF8AB71E54B462B"
                },
                "320k": {
                    "size": "9.59 MB",
                    "hash": "1BBF76D24D890050A7E335E7CDFDBF40"
                },
                "flac": {
                    "size": "26.28 MB",
                    "hash": "92B85E4514074674FFABB0F521CEE8AB"
                },
                "flac24bit": {
                    "size": "47.41 MB",
                    "hash": "94521BA394D22EC90C403F4786FEA593"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "十点读书",
            "name": "285.潘玮柏 我的麦克风 热播劲爆音乐",
            "albumName": "催眠音乐 助眠 治愈 解压 疗愈 轻音乐 音乐故事",
            "albumId": "69542532",
            "songmid": "1081238716",
            "source": "kg",
            "interval": "03:38",
            "img": "http://imge.kugou.com/stdmusic/400/20230303/20230303135101415981.jpg",
            "lrc": null,
            "hash": "56317F23C69113B8ED56DC69D7946E1F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.34 MB",
                    "hash": "56317F23C69113B8ED56DC69D7946E1F"
                },
                {
                    "type": "320k",
                    "size": "8.34 MB",
                    "hash": "C7A7E0D144EB25E0625D6F72259A04F6"
                },
                {
                    "type": "flac",
                    "size": "27.29 MB",
                    "hash": "1A172E6FA6262D993C1FD2C067068354"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.34 MB",
                    "hash": "56317F23C69113B8ED56DC69D7946E1F"
                },
                "320k": {
                    "size": "8.34 MB",
                    "hash": "C7A7E0D144EB25E0625D6F72259A04F6"
                },
                "flac": {
                    "size": "27.29 MB",
                    "hash": "1A172E6FA6262D993C1FD2C067068354"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "文文",
            "name": "我会好好的",
            "albumName": "SteictW文文",
            "albumId": "75516444",
            "songmid": "1080735305",
            "source": "kg",
            "interval": "04:28",
            "img": "http://imge.kugou.com/stdmusic/400/20230706/20230706115007475763.jpg",
            "lrc": null,
            "hash": "921AC2484CCA214DC8D3D45C06B5A254",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.10 MB",
                    "hash": "921AC2484CCA214DC8D3D45C06B5A254"
                },
                {
                    "type": "320k",
                    "size": "10.25 MB",
                    "hash": "80BB8745BC92EF4F507C1F38DE5CDB97"
                },
                {
                    "type": "flac",
                    "size": "30.14 MB",
                    "hash": "EE28629A3CF141DCD8140435B2C87735"
                },
                {
                    "type": "flac24bit",
                    "size": "31.01 MB",
                    "hash": "871B4CD2C9A5910F7DD6364AF9D0F9F7"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.10 MB",
                    "hash": "921AC2484CCA214DC8D3D45C06B5A254"
                },
                "320k": {
                    "size": "10.25 MB",
                    "hash": "80BB8745BC92EF4F507C1F38DE5CDB97"
                },
                "flac": {
                    "size": "30.14 MB",
                    "hash": "EE28629A3CF141DCD8140435B2C87735"
                },
                "flac24bit": {
                    "size": "31.01 MB",
                    "hash": "871B4CD2C9A5910F7DD6364AF9D0F9F7"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "阿杜",
            "name": "天黑",
            "albumName": "天黑",
            "albumId": "963634",
            "songmid": "177155",
            "source": "kg",
            "interval": "04:22",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121718748395.jpg",
            "lrc": null,
            "hash": "77B40C1B285A23D96F92A220C19B1B15",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.01 MB",
                    "hash": "77B40C1B285A23D96F92A220C19B1B15"
                },
                {
                    "type": "320k",
                    "size": "10.02 MB",
                    "hash": "9F9F4A01A63C33F0ABCB8102E2DE6579"
                },
                {
                    "type": "flac",
                    "size": "26.69 MB",
                    "hash": "C8A53EADBE232A99EADF9906C8F2B8E6"
                },
                {
                    "type": "flac24bit",
                    "size": "27.64 MB",
                    "hash": "355806CE5469EDD1AE6921BD2B3E6D19"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.01 MB",
                    "hash": "77B40C1B285A23D96F92A220C19B1B15"
                },
                "320k": {
                    "size": "10.02 MB",
                    "hash": "9F9F4A01A63C33F0ABCB8102E2DE6579"
                },
                "flac": {
                    "size": "26.69 MB",
                    "hash": "C8A53EADBE232A99EADF9906C8F2B8E6"
                },
                "flac24bit": {
                    "size": "27.64 MB",
                    "hash": "355806CE5469EDD1AE6921BD2B3E6D19"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "小虎队",
            "name": "青苹果乐园",
            "albumName": "童话家",
            "albumId": "1820451",
            "songmid": "302502702",
            "source": "kg",
            "interval": "03:44",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909133718546876.jpg",
            "lrc": null,
            "hash": "9A3BAAE9BBCF1DEFA94D64C8A9CAE02F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.43 MB",
                    "hash": "9A3BAAE9BBCF1DEFA94D64C8A9CAE02F"
                },
                {
                    "type": "320k",
                    "size": "8.58 MB",
                    "hash": "3D5BA044D86BF23EFD0E808DDC0047E6"
                },
                {
                    "type": "flac",
                    "size": "24.69 MB",
                    "hash": "D854AA034F4DB837DB67B1929738FD17"
                },
                {
                    "type": "flac24bit",
                    "size": "25.29 MB",
                    "hash": "8D9B6028157A27245AC631B2B0856D6E"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.43 MB",
                    "hash": "9A3BAAE9BBCF1DEFA94D64C8A9CAE02F"
                },
                "320k": {
                    "size": "8.58 MB",
                    "hash": "3D5BA044D86BF23EFD0E808DDC0047E6"
                },
                "flac": {
                    "size": "24.69 MB",
                    "hash": "D854AA034F4DB837DB67B1929738FD17"
                },
                "flac24bit": {
                    "size": "25.29 MB",
                    "hash": "8D9B6028157A27245AC631B2B0856D6E"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张柏芝",
            "name": "星语心愿",
            "albumName": "任何天气",
            "albumId": "967268",
            "songmid": "302418225",
            "source": "kg",
            "interval": "03:20",
            "img": "http://imge.kugou.com/stdmusic/400/20150715/20150715212836357068.jpg",
            "lrc": null,
            "hash": "951E4A5397AAF7C351B8F660227A4C77",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.06 MB",
                    "hash": "951E4A5397AAF7C351B8F660227A4C77"
                },
                {
                    "type": "320k",
                    "size": "7.64 MB",
                    "hash": "D180139E3C5E3B80D5A093F8E74B3A1E"
                },
                {
                    "type": "flac",
                    "size": "20.06 MB",
                    "hash": "B9009E67A4894DF93F309636458B5DBA"
                },
                {
                    "type": "flac24bit",
                    "size": "20.58 MB",
                    "hash": "AD8E389C7ACC00CCB6F6D4FD1565F800"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.06 MB",
                    "hash": "951E4A5397AAF7C351B8F660227A4C77"
                },
                "320k": {
                    "size": "7.64 MB",
                    "hash": "D180139E3C5E3B80D5A093F8E74B3A1E"
                },
                "flac": {
                    "size": "20.06 MB",
                    "hash": "B9009E67A4894DF93F309636458B5DBA"
                },
                "flac24bit": {
                    "size": "20.58 MB",
                    "hash": "AD8E389C7ACC00CCB6F6D4FD1565F800"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "沙宝亮",
            "name": "暗香",
            "albumName": "沙宝亮",
            "albumId": "983668",
            "songmid": "254071",
            "source": "kg",
            "interval": "04:37",
            "img": "http://imge.kugou.com/stdmusic/400/20200927/20200927193342738258.jpg",
            "lrc": null,
            "hash": "2531369EAC365C943792E6012D2C6C36",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.24 MB",
                    "hash": "2531369EAC365C943792E6012D2C6C36"
                },
                {
                    "type": "320k",
                    "size": "10.59 MB",
                    "hash": "A7EF83BBE544E41061D9EA39D1B7BC97"
                },
                {
                    "type": "flac",
                    "size": "30.76 MB",
                    "hash": "177D02E1E28A654D11B5D56AD13B812E"
                },
                {
                    "type": "flac24bit",
                    "size": "116.98 MB",
                    "hash": "D97E5FE105FC3A65FB45F7A08202685B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.24 MB",
                    "hash": "2531369EAC365C943792E6012D2C6C36"
                },
                "320k": {
                    "size": "10.59 MB",
                    "hash": "A7EF83BBE544E41061D9EA39D1B7BC97"
                },
                "flac": {
                    "size": "30.76 MB",
                    "hash": "177D02E1E28A654D11B5D56AD13B812E"
                },
                "flac24bit": {
                    "size": "116.98 MB",
                    "hash": "D97E5FE105FC3A65FB45F7A08202685B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "迪克牛仔",
            "name": "有多少爱可以重来",
            "albumName": "黄金十载",
            "albumId": "15247966",
            "songmid": "169183",
            "source": "kg",
            "interval": "04:51",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121710625939.jpg",
            "lrc": null,
            "hash": "CC000CC6820B55AFAF3C4E926AA2D1B8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.45 MB",
                    "hash": "CC000CC6820B55AFAF3C4E926AA2D1B8"
                },
                {
                    "type": "320k",
                    "size": "11.12 MB",
                    "hash": "7F94C58AD748D39028E6394D39F836BB"
                },
                {
                    "type": "flac",
                    "size": "30.60 MB",
                    "hash": "F3CF495EAA627EB5F34854B4303C1A8A"
                },
                {
                    "type": "flac24bit",
                    "size": "31.67 MB",
                    "hash": "1C72331807EDCCB45471EABC4DE9DA40"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.45 MB",
                    "hash": "CC000CC6820B55AFAF3C4E926AA2D1B8"
                },
                "320k": {
                    "size": "11.12 MB",
                    "hash": "7F94C58AD748D39028E6394D39F836BB"
                },
                "flac": {
                    "size": "30.60 MB",
                    "hash": "F3CF495EAA627EB5F34854B4303C1A8A"
                },
                "flac24bit": {
                    "size": "31.67 MB",
                    "hash": "1C72331807EDCCB45471EABC4DE9DA40"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "伍佰 & China Blue",
            "name": "挪威的森林",
            "albumName": "摇滚滚石 My Rock",
            "albumId": "19300802",
            "songmid": "1079126717",
            "source": "kg",
            "interval": "06:32",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909144405251636.jpg",
            "lrc": null,
            "hash": "5CCCF0FAE724F2E616FF9C308A450B23",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "6.00 MB",
                    "hash": "5CCCF0FAE724F2E616FF9C308A450B23"
                },
                {
                    "type": "320k",
                    "size": "14.99 MB",
                    "hash": "A35099F0FFBFEE274C4787B15AA731D9"
                },
                {
                    "type": "flac",
                    "size": "42.75 MB",
                    "hash": "10B53DBE3ADDE3705A83FE490C4FB24E"
                },
                {
                    "type": "flac24bit",
                    "size": "43.88 MB",
                    "hash": "4F9B457A4F40A9BEFDB6DCB27689BC8A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "6.00 MB",
                    "hash": "5CCCF0FAE724F2E616FF9C308A450B23"
                },
                "320k": {
                    "size": "14.99 MB",
                    "hash": "A35099F0FFBFEE274C4787B15AA731D9"
                },
                "flac": {
                    "size": "42.75 MB",
                    "hash": "10B53DBE3ADDE3705A83FE490C4FB24E"
                },
                "flac24bit": {
                    "size": "43.88 MB",
                    "hash": "4F9B457A4F40A9BEFDB6DCB27689BC8A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁咏琪",
            "name": "胆小鬼",
            "albumName": "梁咏琪同名专辑",
            "albumId": "964252",
            "songmid": "302426323",
            "source": "kg",
            "interval": "04:20",
            "img": "http://imge.kugou.com/stdmusic/400/20150714/20150714140721262769.jpg",
            "lrc": null,
            "hash": "C1F455874A448CD675D143CECADF71B2",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.28 MB",
                    "hash": "C1F455874A448CD675D143CECADF71B2"
                },
                {
                    "type": "320k",
                    "size": "9.95 MB",
                    "hash": "259009E36C5F5730A0261A8B8D2CA0B2"
                },
                {
                    "type": "flac",
                    "size": "27.54 MB",
                    "hash": "EF275C586EDC3798DE82F546133227E1"
                },
                {
                    "type": "flac24bit",
                    "size": "27.87 MB",
                    "hash": "D69353EEE89A8A543DFF0E886C56F2A8"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.28 MB",
                    "hash": "C1F455874A448CD675D143CECADF71B2"
                },
                "320k": {
                    "size": "9.95 MB",
                    "hash": "259009E36C5F5730A0261A8B8D2CA0B2"
                },
                "flac": {
                    "size": "27.54 MB",
                    "hash": "EF275C586EDC3798DE82F546133227E1"
                },
                "flac24bit": {
                    "size": "27.87 MB",
                    "hash": "D69353EEE89A8A543DFF0E886C56F2A8"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "黄品源",
            "name": "你怎么舍得我难过",
            "albumName": "壹 (1)",
            "albumId": "554007",
            "songmid": "302416273",
            "source": "kg",
            "interval": "04:56",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909123241546215.jpg",
            "lrc": null,
            "hash": "F251386D281CE4FCA28272AC66F95990",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.52 MB",
                    "hash": "F251386D281CE4FCA28272AC66F95990"
                },
                {
                    "type": "320k",
                    "size": "11.29 MB",
                    "hash": "C80F167A806FDF65BD99EC3E73A67181"
                },
                {
                    "type": "flac",
                    "size": "29.15 MB",
                    "hash": "B44B29BCE209AE730401D316E15BEBF7"
                },
                {
                    "type": "flac24bit",
                    "size": "56.25 MB",
                    "hash": "E7DCB24386C4962990C22FE4F6390F31"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.52 MB",
                    "hash": "F251386D281CE4FCA28272AC66F95990"
                },
                "320k": {
                    "size": "11.29 MB",
                    "hash": "C80F167A806FDF65BD99EC3E73A67181"
                },
                "flac": {
                    "size": "29.15 MB",
                    "hash": "B44B29BCE209AE730401D316E15BEBF7"
                },
                "flac24bit": {
                    "size": "56.25 MB",
                    "hash": "E7DCB24386C4962990C22FE4F6390F31"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "黄品源",
            "name": "小薇",
            "albumName": "泪光闪闪,源来有你",
            "albumId": "4129454",
            "songmid": "302428255",
            "source": "kg",
            "interval": "03:17",
            "img": "http://imge.kugou.com/stdmusic/400/20160907/20160907182552620163.jpg",
            "lrc": null,
            "hash": "B6AED238E7BE1496DEC6F10F694B74CD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.01 MB",
                    "hash": "B6AED238E7BE1496DEC6F10F694B74CD"
                },
                {
                    "type": "320k",
                    "size": "7.52 MB",
                    "hash": "3E56C88024C94E6F14CA079B68BF7BF4"
                },
                {
                    "type": "flac",
                    "size": "22.37 MB",
                    "hash": "3D998931F1E77E82E8947B1059B14605"
                },
                {
                    "type": "flac24bit",
                    "size": "23.27 MB",
                    "hash": "189C9BB2F367C14D8757FF1EEE68F8C3"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.01 MB",
                    "hash": "B6AED238E7BE1496DEC6F10F694B74CD"
                },
                "320k": {
                    "size": "7.52 MB",
                    "hash": "3E56C88024C94E6F14CA079B68BF7BF4"
                },
                "flac": {
                    "size": "22.37 MB",
                    "hash": "3D998931F1E77E82E8947B1059B14605"
                },
                "flac24bit": {
                    "size": "23.27 MB",
                    "hash": "189C9BB2F367C14D8757FF1EEE68F8C3"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁静茹",
            "name": "可惜不是你",
            "albumName": "丝路",
            "albumId": "964280",
            "songmid": "302415832",
            "source": "kg",
            "interval": "04:45",
            "img": "http://imge.kugou.com/stdmusic/400/20210113/20210113212926438173.jpg",
            "lrc": null,
            "hash": "42C08A12B92F15B36856FB91FB5886F5",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.36 MB",
                    "hash": "42C08A12B92F15B36856FB91FB5886F5"
                },
                {
                    "type": "320k",
                    "size": "10.91 MB",
                    "hash": "C9EA73FF047F7A21135BC7627EEFA9E1"
                },
                {
                    "type": "flac",
                    "size": "28.43 MB",
                    "hash": "CB9A05BD5973609A9519132117FF3992"
                },
                {
                    "type": "flac24bit",
                    "size": "29.19 MB",
                    "hash": "5CEDD7C3EA48DE65CBD363265428CA24"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.36 MB",
                    "hash": "42C08A12B92F15B36856FB91FB5886F5"
                },
                "320k": {
                    "size": "10.91 MB",
                    "hash": "C9EA73FF047F7A21135BC7627EEFA9E1"
                },
                "flac": {
                    "size": "28.43 MB",
                    "hash": "CB9A05BD5973609A9519132117FF3992"
                },
                "flac24bit": {
                    "size": "29.19 MB",
                    "hash": "5CEDD7C3EA48DE65CBD363265428CA24"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "莫文蔚、黄品源",
            "name": "那么爱你为什么",
            "albumName": "我的·莫文蔚 (五光十色最精彩选辑)",
            "albumId": "2996915",
            "songmid": "302427845",
            "source": "kg",
            "interval": "04:24",
            "img": "http://imge.kugou.com/stdmusic/400/20160907/20160907214426826339.jpg",
            "lrc": null,
            "hash": "45ABE8DEBA92BF1F18F359A838F3BD4E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.04 MB",
                    "hash": "45ABE8DEBA92BF1F18F359A838F3BD4E"
                },
                {
                    "type": "320k",
                    "size": "10.10 MB",
                    "hash": "0DB0CF3386042281DD7910D303631B82"
                },
                {
                    "type": "flac",
                    "size": "30.69 MB",
                    "hash": "0FA54C46BE92D719EC80108785A51012"
                },
                {
                    "type": "flac24bit",
                    "size": "31.66 MB",
                    "hash": "CEADE61B0E2609BF15F0AB8FA7761419"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.04 MB",
                    "hash": "45ABE8DEBA92BF1F18F359A838F3BD4E"
                },
                "320k": {
                    "size": "10.10 MB",
                    "hash": "0DB0CF3386042281DD7910D303631B82"
                },
                "flac": {
                    "size": "30.69 MB",
                    "hash": "0FA54C46BE92D719EC80108785A51012"
                },
                "flac24bit": {
                    "size": "31.66 MB",
                    "hash": "CEADE61B0E2609BF15F0AB8FA7761419"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁静茹",
            "name": "勇气",
            "albumName": "恋爱的力量",
            "albumId": "973299",
            "songmid": "342151",
            "source": "kg",
            "interval": "03:59",
            "img": "http://imge.kugou.com/stdmusic/400/20241205/20241205192457266564.jpg",
            "lrc": null,
            "hash": "A4D0C350CF4475BFBB0AB28DC6E25A8D",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.65 MB",
                    "hash": "A4D0C350CF4475BFBB0AB28DC6E25A8D"
                },
                {
                    "type": "320k",
                    "size": "9.12 MB",
                    "hash": "2DF26740EA6246591B294BAC600AAEB7"
                },
                {
                    "type": "flac",
                    "size": "23.94 MB",
                    "hash": "1E126DBBC2632168110D1609D51649EE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.65 MB",
                    "hash": "A4D0C350CF4475BFBB0AB28DC6E25A8D"
                },
                "320k": {
                    "size": "9.12 MB",
                    "hash": "2DF26740EA6246591B294BAC600AAEB7"
                },
                "flac": {
                    "size": "23.94 MB",
                    "hash": "1E126DBBC2632168110D1609D51649EE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张震岳",
            "name": "爱我别走",
            "albumName": "滚石香港黄金十年 张震岳精选",
            "albumId": "508436",
            "songmid": "302512672",
            "source": "kg",
            "interval": "04:44",
            "img": "http://imge.kugou.com/stdmusic/400/20231117/20231117182105501739.jpg",
            "lrc": null,
            "hash": "2C5F815E1B19427D7770975CEAB3D66D",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.35 MB",
                    "hash": "2C5F815E1B19427D7770975CEAB3D66D"
                },
                {
                    "type": "320k",
                    "size": "10.87 MB",
                    "hash": "FD53596D922ADF9ACAD91903A80A3367"
                },
                {
                    "type": "flac",
                    "size": "30.49 MB",
                    "hash": "9872CF569895DA03A329478A5C9F3DAB"
                },
                {
                    "type": "flac24bit",
                    "size": "172.99 MB",
                    "hash": "65E8D826B8D91DCCFE5F3E10C233E7E6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.35 MB",
                    "hash": "2C5F815E1B19427D7770975CEAB3D66D"
                },
                "320k": {
                    "size": "10.87 MB",
                    "hash": "FD53596D922ADF9ACAD91903A80A3367"
                },
                "flac": {
                    "size": "30.49 MB",
                    "hash": "9872CF569895DA03A329478A5C9F3DAB"
                },
                "flac24bit": {
                    "size": "172.99 MB",
                    "hash": "65E8D826B8D91DCCFE5F3E10C233E7E6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林忆莲",
            "name": "为你我受冷风吹",
            "albumName": "回忆莲莲",
            "albumId": "970442",
            "songmid": "302417922",
            "source": "kg",
            "interval": "04:17",
            "img": "http://imge.kugou.com/stdmusic/400/20190717/20190717104710406744.jpg",
            "lrc": null,
            "hash": "D6355EEC2795992DCB3DB4A7AB868B96",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.93 MB",
                    "hash": "D6355EEC2795992DCB3DB4A7AB868B96"
                },
                {
                    "type": "320k",
                    "size": "9.83 MB",
                    "hash": "778A8262533A466CACDB331823409E60"
                },
                {
                    "type": "flac",
                    "size": "25.70 MB",
                    "hash": "55A2DF30A8B2AE5E67B5F5FE33B0D0E2"
                },
                {
                    "type": "flac24bit",
                    "size": "26.49 MB",
                    "hash": "EB6827103CDE4D8215EF28A31A5CE96C"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.93 MB",
                    "hash": "D6355EEC2795992DCB3DB4A7AB868B96"
                },
                "320k": {
                    "size": "9.83 MB",
                    "hash": "778A8262533A466CACDB331823409E60"
                },
                "flac": {
                    "size": "25.70 MB",
                    "hash": "55A2DF30A8B2AE5E67B5F5FE33B0D0E2"
                },
                "flac24bit": {
                    "size": "26.49 MB",
                    "hash": "EB6827103CDE4D8215EF28A31A5CE96C"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "任贤齐",
            "name": "伤心太平洋",
            "albumName": "毕业旅行",
            "albumId": "886005",
            "songmid": "301294972",
            "source": "kg",
            "interval": "04:27",
            "img": "http://imge.kugou.com/stdmusic/400/20150718/20150718130709164799.jpg",
            "lrc": null,
            "hash": "CF652DD52EF0AC8B4449CB39FF04A7DD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.08 MB",
                    "hash": "CF652DD52EF0AC8B4449CB39FF04A7DD"
                },
                {
                    "type": "320k",
                    "size": "10.20 MB",
                    "hash": "3B6B50DC3921722C65CB3595B48336A2"
                },
                {
                    "type": "flac",
                    "size": "32.21 MB",
                    "hash": "A6CAC2D64EFA051BBA070D9F0E5EBC60"
                },
                {
                    "type": "flac24bit",
                    "size": "32.82 MB",
                    "hash": "F40082389A7C07182389D23E647536E5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.08 MB",
                    "hash": "CF652DD52EF0AC8B4449CB39FF04A7DD"
                },
                "320k": {
                    "size": "10.20 MB",
                    "hash": "3B6B50DC3921722C65CB3595B48336A2"
                },
                "flac": {
                    "size": "32.21 MB",
                    "hash": "A6CAC2D64EFA051BBA070D9F0E5EBC60"
                },
                "flac24bit": {
                    "size": "32.82 MB",
                    "hash": "F40082389A7C07182389D23E647536E5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "黄品源",
            "name": "海浪",
            "albumName": "大人的情歌",
            "albumId": "885989",
            "songmid": "302421845",
            "source": "kg",
            "interval": "04:49",
            "img": "http://imge.kugou.com/stdmusic/400/20190927/20190927184001212603.jpg",
            "lrc": null,
            "hash": "C9CEB26274F73F9E1B88456EE91B7441",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.43 MB",
                    "hash": "C9CEB26274F73F9E1B88456EE91B7441"
                },
                {
                    "type": "320k",
                    "size": "11.06 MB",
                    "hash": "C258B2D4599F6C0F8CBF29953A83654F"
                },
                {
                    "type": "flac",
                    "size": "29.76 MB",
                    "hash": "132C088136402B1BEA0159B847390AFA"
                },
                {
                    "type": "flac24bit",
                    "size": "146.42 MB",
                    "hash": "3F135FE864FE10DA8C8DEC3AFD052F10"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.43 MB",
                    "hash": "C9CEB26274F73F9E1B88456EE91B7441"
                },
                "320k": {
                    "size": "11.06 MB",
                    "hash": "C258B2D4599F6C0F8CBF29953A83654F"
                },
                "flac": {
                    "size": "29.76 MB",
                    "hash": "132C088136402B1BEA0159B847390AFA"
                },
                "flac24bit": {
                    "size": "146.42 MB",
                    "hash": "3F135FE864FE10DA8C8DEC3AFD052F10"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张震岳",
            "name": "爱的初体验",
            "albumName": "滚石香港黄金十年 张震岳精选",
            "albumId": "508436",
            "songmid": "302445405",
            "source": "kg",
            "interval": "04:03",
            "img": "http://imge.kugou.com/stdmusic/400/20231117/20231117182105501739.jpg",
            "lrc": null,
            "hash": "786DF3A3593058650E07155CB3103574",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.72 MB",
                    "hash": "786DF3A3593058650E07155CB3103574"
                },
                {
                    "type": "320k",
                    "size": "9.29 MB",
                    "hash": "A1A3B23FD3F99E256A6D209C2E5FDC4C"
                },
                {
                    "type": "flac",
                    "size": "28.72 MB",
                    "hash": "8E4CD2B2F80C5D1FAC362314508EDCB9"
                },
                {
                    "type": "flac24bit",
                    "size": "49.25 MB",
                    "hash": "A5F987758027B951FEF6F17D8F03C601"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.72 MB",
                    "hash": "786DF3A3593058650E07155CB3103574"
                },
                "320k": {
                    "size": "9.29 MB",
                    "hash": "A1A3B23FD3F99E256A6D209C2E5FDC4C"
                },
                "flac": {
                    "size": "28.72 MB",
                    "hash": "8E4CD2B2F80C5D1FAC362314508EDCB9"
                },
                "flac24bit": {
                    "size": "49.25 MB",
                    "hash": "A5F987758027B951FEF6F17D8F03C601"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "李圣杰",
            "name": "手放开",
            "albumName": "绝对痴心·手放开",
            "albumId": "959847",
            "songmid": "328747",
            "source": "kg",
            "interval": "04:25",
            "img": "http://imge.kugou.com/stdmusic/400/20250221/20250221180742612489.jpg",
            "lrc": null,
            "hash": "022583751858F1E3558F32EC4ECF7DD5",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.05 MB",
                    "hash": "022583751858F1E3558F32EC4ECF7DD5"
                },
                {
                    "type": "320k",
                    "size": "10.12 MB",
                    "hash": "0AB603978EE5FF7B7F872A0968FF0805"
                },
                {
                    "type": "flac",
                    "size": "29.29 MB",
                    "hash": "E8A8F736910305EF05AABEDC2C5A5343"
                },
                {
                    "type": "flac24bit",
                    "size": "30.25 MB",
                    "hash": "B66D9FEFCF45F1029D523E7E690A9694"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.05 MB",
                    "hash": "022583751858F1E3558F32EC4ECF7DD5"
                },
                "320k": {
                    "size": "10.12 MB",
                    "hash": "0AB603978EE5FF7B7F872A0968FF0805"
                },
                "flac": {
                    "size": "29.29 MB",
                    "hash": "E8A8F736910305EF05AABEDC2C5A5343"
                },
                "flac24bit": {
                    "size": "30.25 MB",
                    "hash": "B66D9FEFCF45F1029D523E7E690A9694"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "潘越云",
            "name": "我是不是你最疼爱的人",
            "albumName": "童年 蓝天 橄榄树",
            "albumId": "1791701",
            "songmid": "302447939",
            "source": "kg",
            "interval": "04:08",
            "img": "http://imge.kugou.com/stdmusic/400/20161005/20161005110211345053.jpg",
            "lrc": null,
            "hash": "1B56B0A7201D3344B0126081F31A7745",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.79 MB",
                    "hash": "1B56B0A7201D3344B0126081F31A7745"
                },
                {
                    "type": "320k",
                    "size": "9.48 MB",
                    "hash": "41CC2E8FE581D9635593A6060405EFA0"
                },
                {
                    "type": "flac",
                    "size": "26.26 MB",
                    "hash": "5E6B3401178B74D897209A9399FFFEF6"
                },
                {
                    "type": "flac24bit",
                    "size": "26.97 MB",
                    "hash": "D9EEE3445EECF28FE8A0CAEEAE8F5BE4"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.79 MB",
                    "hash": "1B56B0A7201D3344B0126081F31A7745"
                },
                "320k": {
                    "size": "9.48 MB",
                    "hash": "41CC2E8FE581D9635593A6060405EFA0"
                },
                "flac": {
                    "size": "26.26 MB",
                    "hash": "5E6B3401178B74D897209A9399FFFEF6"
                },
                "flac24bit": {
                    "size": "26.97 MB",
                    "hash": "D9EEE3445EECF28FE8A0CAEEAE8F5BE4"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "李宗盛",
            "name": "凡人歌",
            "albumName": "男人三十",
            "albumId": "557555",
            "songmid": "302436723",
            "source": "kg",
            "interval": "03:47",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909124316352321.jpg",
            "lrc": null,
            "hash": "433403D9B05297EADE984EBFFE468093",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.48 MB",
                    "hash": "433403D9B05297EADE984EBFFE468093"
                },
                {
                    "type": "320k",
                    "size": "8.69 MB",
                    "hash": "EF715E2366B6DF18076EED7341AE4DBD"
                },
                {
                    "type": "flac",
                    "size": "27.62 MB",
                    "hash": "17CE998504A7614A3CB44FC02B426735"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.48 MB",
                    "hash": "433403D9B05297EADE984EBFFE468093"
                },
                "320k": {
                    "size": "8.69 MB",
                    "hash": "EF715E2366B6DF18076EED7341AE4DBD"
                },
                "flac": {
                    "size": "27.62 MB",
                    "hash": "17CE998504A7614A3CB44FC02B426735"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "刘若英",
            "name": "为爱痴狂",
            "albumName": "Princess from East '01 - Rene Liu",
            "albumId": "526829",
            "songmid": "301368520",
            "source": "kg",
            "interval": "05:05",
            "img": "http://imge.kugou.com/stdmusic/400/20200909/20200909113606974959.jpg",
            "lrc": null,
            "hash": "8BAE3F74E519EC7FE70138251079D5B5",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.66 MB",
                    "hash": "8BAE3F74E519EC7FE70138251079D5B5"
                },
                {
                    "type": "320k",
                    "size": "11.65 MB",
                    "hash": "C4BB3CD61D4F94F64CA6EAFC8A0D108B"
                },
                {
                    "type": "flac",
                    "size": "27.98 MB",
                    "hash": "5B409587DF16B7C2FD1978FE4BF8BE8C"
                },
                {
                    "type": "flac24bit",
                    "size": "91.27 MB",
                    "hash": "E8217A415D04BD6E880DD88DDAEE897A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.66 MB",
                    "hash": "8BAE3F74E519EC7FE70138251079D5B5"
                },
                "320k": {
                    "size": "11.65 MB",
                    "hash": "C4BB3CD61D4F94F64CA6EAFC8A0D108B"
                },
                "flac": {
                    "size": "27.98 MB",
                    "hash": "5B409587DF16B7C2FD1978FE4BF8BE8C"
                },
                "flac24bit": {
                    "size": "91.27 MB",
                    "hash": "E8217A415D04BD6E880DD88DDAEE897A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "赵咏华",
            "name": "最浪漫的事",
            "albumName": "乱世佳人",
            "albumId": "1055924",
            "songmid": "322227",
            "source": "kg",
            "interval": "04:25",
            "img": "http://imge.kugou.com/stdmusic/400/20231019/20231019114003961769.jpg",
            "lrc": null,
            "hash": "4064FFBB8C259B9D7BCAB163E69C8566",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.05 MB",
                    "hash": "4064FFBB8C259B9D7BCAB163E69C8566"
                },
                {
                    "type": "320k",
                    "size": "10.13 MB",
                    "hash": "F30224ED55638A7F6461AEEAF472D7F5"
                },
                {
                    "type": "flac",
                    "size": "26.84 MB",
                    "hash": "47265C1A7023D860B84EC2715F3A8FFA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.05 MB",
                    "hash": "4064FFBB8C259B9D7BCAB163E69C8566"
                },
                "320k": {
                    "size": "10.13 MB",
                    "hash": "F30224ED55638A7F6461AEEAF472D7F5"
                },
                "flac": {
                    "size": "26.84 MB",
                    "hash": "47265C1A7023D860B84EC2715F3A8FFA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "姜育恒",
            "name": "再回首",
            "albumName": "多年以后·再回首",
            "albumId": "500051",
            "songmid": "301366482",
            "source": "kg",
            "interval": "04:15",
            "img": "http://imge.kugou.com/stdmusic/400/20250901/20250901154003552358.jpg",
            "lrc": null,
            "hash": "BBFB6EF72285F101C72DEFB24EE08DD6",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.90 MB",
                    "hash": "BBFB6EF72285F101C72DEFB24EE08DD6"
                },
                {
                    "type": "320k",
                    "size": "9.76 MB",
                    "hash": "E578E0B7D75E9D00EB2CB10B39813510"
                },
                {
                    "type": "flac",
                    "size": "25.43 MB",
                    "hash": "C25E1AAE1C3F623CDEA1447A4D573D10"
                },
                {
                    "type": "flac24bit",
                    "size": "26.35 MB",
                    "hash": "2AD1485CFA7ED0B47BB23171633E5DC8"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.90 MB",
                    "hash": "BBFB6EF72285F101C72DEFB24EE08DD6"
                },
                "320k": {
                    "size": "9.76 MB",
                    "hash": "E578E0B7D75E9D00EB2CB10B39813510"
                },
                "flac": {
                    "size": "25.43 MB",
                    "hash": "C25E1AAE1C3F623CDEA1447A4D573D10"
                },
                "flac24bit": {
                    "size": "26.35 MB",
                    "hash": "2AD1485CFA7ED0B47BB23171633E5DC8"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "莫文蔚",
            "name": "忽然之间",
            "albumName": "滚石香港黄金十年 莫文蔚精选",
            "albumId": "976827",
            "songmid": "302438696",
            "source": "kg",
            "interval": "03:22",
            "img": "http://imge.kugou.com/stdmusic/400/20250101/20250101072925818712.jpg",
            "lrc": null,
            "hash": "B7E6CAE679AB087B5FBD39F80DDB2082",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.09 MB",
                    "hash": "B7E6CAE679AB087B5FBD39F80DDB2082"
                },
                {
                    "type": "320k",
                    "size": "7.73 MB",
                    "hash": "4859D86F7EEB9829AB5B30CBA63D1FB0"
                },
                {
                    "type": "flac",
                    "size": "19.73 MB",
                    "hash": "BF3002D46AA9BD400962D6EC398495F5"
                },
                {
                    "type": "flac24bit",
                    "size": "20.29 MB",
                    "hash": "3333DB182932F01520A3499F73C8BFAB"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.09 MB",
                    "hash": "B7E6CAE679AB087B5FBD39F80DDB2082"
                },
                "320k": {
                    "size": "7.73 MB",
                    "hash": "4859D86F7EEB9829AB5B30CBA63D1FB0"
                },
                "flac": {
                    "size": "19.73 MB",
                    "hash": "BF3002D46AA9BD400962D6EC398495F5"
                },
                "flac24bit": {
                    "size": "20.29 MB",
                    "hash": "3333DB182932F01520A3499F73C8BFAB"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁咏琪",
            "name": "短发",
            "albumName": "最爱梁咏琪",
            "albumId": "980188",
            "songmid": "168607",
            "source": "kg",
            "interval": "04:42",
            "img": "http://imge.kugou.com/stdmusic/400/20150714/20150714140613166059.jpg",
            "lrc": null,
            "hash": "98A9D6B33985C25D68857467665C9192",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.31 MB",
                    "hash": "98A9D6B33985C25D68857467665C9192"
                },
                {
                    "type": "320k",
                    "size": "10.78 MB",
                    "hash": "28BA9D10C04FB70447012914FCF07AC3"
                },
                {
                    "type": "flac",
                    "size": "28.57 MB",
                    "hash": "25549D3A346B86EE3E77D8EAC8E523C4"
                },
                {
                    "type": "flac24bit",
                    "size": "27.29 MB",
                    "hash": "03848A4EF1E3538777F1EB437A05FDAB"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.31 MB",
                    "hash": "98A9D6B33985C25D68857467665C9192"
                },
                "320k": {
                    "size": "10.78 MB",
                    "hash": "28BA9D10C04FB70447012914FCF07AC3"
                },
                "flac": {
                    "size": "28.57 MB",
                    "hash": "25549D3A346B86EE3E77D8EAC8E523C4"
                },
                "flac24bit": {
                    "size": "27.29 MB",
                    "hash": "03848A4EF1E3538777F1EB437A05FDAB"
                }
            },
            "typeUrl": {}
        }
    ],
    "page": 1,
    "limit": 10000,
    "total": 127,
    "source": "kg",
    "info": {
        "name": "8090后经典老歌丨怀旧金曲唤醒青春记忆",
        "img": "http://c1.kgimg.com/custom/240/20260223/20260223174958787645.jpg",
        "desc": "在一个安静的夜晚，无意间点放了一首老歌，很久没有听老歌的我，想要切换歌曲，但瞬间又不想换歌了，歌声仿佛让从前又呈现在眼前。那时的一切依然历历在目，那些曾让自己开怀大笑的人、那些让自己烦恼何其多的事、那些如此熟悉的地方。\n一切如此熟悉又陌生，那个阳光明媚的午后，在学校教室里，广播放着歌，你与我讨论这这首歌，这首歌很好听，你知道叫什么名字吗？我也不知道，啊哈哈哈.......\n\n那些笑声越来越远，那些人脸越来越模糊，那些时光不会回来了，只有那时候听的歌，像个老朋友在回忆陪着我们，告诉我们别忘记那些回忆。."
    }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET  获取排行榜分类

GET /api/music/leaderboard/boards

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|source|query|string| 否 |none|

> 返回示例

> 200 Response

```json
{
    "list": [
        {
            "id": "kg__8888",
            "name": "TOP500",
            "bangid": "8888"
        },
        {
            "id": "kg__6666",
            "name": "飙升榜",
            "bangid": "6666"
        },
        {
            "id": "kg__59703",
            "name": "蜂鸟流行音乐榜",
            "bangid": "59703"
        },
        {
            "id": "kg__52144",
            "name": "抖音热歌榜",
            "bangid": "52144"
        },
        {
            "id": "kg__52767",
            "name": "快手热歌榜",
            "bangid": "52767"
        },
        {
            "id": "kg__24971",
            "name": "DJ热歌榜",
            "bangid": "24971"
        },
        {
            "id": "kg__23784",
            "name": "网络红歌榜",
            "bangid": "23784"
        },
        {
            "id": "kg__44412",
            "name": "说唱先锋榜",
            "bangid": "44412"
        },
        {
            "id": "kg__31308",
            "name": "内地榜",
            "bangid": "31308"
        },
        {
            "id": "kg__33160",
            "name": "电音榜",
            "bangid": "33160"
        },
        {
            "id": "kg__31313",
            "name": "香港地区榜",
            "bangid": "31313"
        },
        {
            "id": "kg__51341",
            "name": "民谣榜",
            "bangid": "51341"
        },
        {
            "id": "kg__54848",
            "name": "台湾地区榜",
            "bangid": "54848"
        },
        {
            "id": "kg__31310",
            "name": "欧美榜",
            "bangid": "31310"
        },
        {
            "id": "kg__33162",
            "name": "ACG新歌榜",
            "bangid": "33162"
        },
        {
            "id": "kg__31311",
            "name": "韩国榜",
            "bangid": "31311"
        },
        {
            "id": "kg__31312",
            "name": "日本榜",
            "bangid": "31312"
        },
        {
            "id": "kg__49225",
            "name": "80后热歌榜",
            "bangid": "49225"
        },
        {
            "id": "kg__49223",
            "name": "90后热歌榜",
            "bangid": "49223"
        },
        {
            "id": "kg__49224",
            "name": "00后热歌榜",
            "bangid": "49224"
        },
        {
            "id": "kg__33165",
            "name": "粤语金曲榜",
            "bangid": "33165"
        },
        {
            "id": "kg__33166",
            "name": "欧美金曲榜",
            "bangid": "33166"
        },
        {
            "id": "kg__33163",
            "name": "影视金曲榜",
            "bangid": "33163"
        },
        {
            "id": "kg__51340",
            "name": "伤感榜",
            "bangid": "51340"
        },
        {
            "id": "kg__35811",
            "name": "会员专享榜",
            "bangid": "35811"
        },
        {
            "id": "kg__37361",
            "name": "雷达榜",
            "bangid": "37361"
        },
        {
            "id": "kg__21101",
            "name": "分享榜",
            "bangid": "21101"
        },
        {
            "id": "kg__46910",
            "name": "综艺新歌榜",
            "bangid": "46910"
        },
        {
            "id": "kg__30972",
            "name": "酷狗音乐人原创榜",
            "bangid": "30972"
        },
        {
            "id": "kg__60170",
            "name": "闽南语榜",
            "bangid": "60170"
        },
        {
            "id": "kg__65234",
            "name": "儿歌榜",
            "bangid": "65234"
        },
        {
            "id": "kg__4681",
            "name": "美国BillBoard榜",
            "bangid": "4681"
        },
        {
            "id": "kg__25028",
            "name": "Beatport电子舞曲榜",
            "bangid": "25028"
        },
        {
            "id": "kg__4680",
            "name": "英国单曲榜",
            "bangid": "4680"
        },
        {
            "id": "kg__38623",
            "name": "韩国Melon音乐榜",
            "bangid": "38623"
        },
        {
            "id": "kg__42807",
            "name": "joox本地热歌榜",
            "bangid": "42807"
        },
        {
            "id": "kg__36107",
            "name": "小语种热歌榜",
            "bangid": "36107"
        },
        {
            "id": "kg__4673",
            "name": "日本公信榜",
            "bangid": "4673"
        },
        {
            "id": "kg__46868",
            "name": "日本SPACE SHOWER榜",
            "bangid": "46868"
        },
        {
            "id": "kg__42808",
            "name": "KKBOX风云榜",
            "bangid": "42808"
        },
        {
            "id": "kg__60171",
            "name": "越南语榜",
            "bangid": "60171"
        },
        {
            "id": "kg__60172",
            "name": "泰语榜",
            "bangid": "60172"
        },
        {
            "id": "kg__59895",
            "name": "R&B榜",
            "bangid": "59895"
        },
        {
            "id": "kg__59896",
            "name": "摇滚榜",
            "bangid": "59896"
        },
        {
            "id": "kg__59897",
            "name": "爵士榜",
            "bangid": "59897"
        },
        {
            "id": "kg__59898",
            "name": "乡村音乐榜",
            "bangid": "59898"
        },
        {
            "id": "kg__59900",
            "name": "纯音乐榜",
            "bangid": "59900"
        },
        {
            "id": "kg__59899",
            "name": "古典榜",
            "bangid": "59899"
        },
        {
            "id": "kg__22603",
            "name": "5sing音乐榜",
            "bangid": "22603"
        },
        {
            "id": "kg__21335",
            "name": "繁星音乐榜",
            "bangid": "21335"
        },
        {
            "id": "kg__33161",
            "name": "古风新歌榜",
            "bangid": "33161"
        }
    ],
    "source": "kg"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取排行榜内的歌曲

GET /api/music/leaderboard/list

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|source|query|string| 否 |none|
|bangid|query|string| 否 |none|
|page|query|string| 否 |none|

> 返回示例

> 200 Response

```json
{
    "total": 500,
    "list": [
        {
            "singer": "阿图表妹",
            "name": "你有没有真的爱过我",
            "albumName": "你有没有真的爱过我",
            "albumId": "190170015",
            "songmid": 571484095,
            "source": "kg",
            "interval": "04:03",
            "img": "http://imge.kugou.com/stdmusic/400/20260604/20260604164021847508.jpg",
            "lrc": null,
            "hash": "FE39668F68770C3FB3BE57A3E86CCC10",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.72 MB",
                    "hash": "FE39668F68770C3FB3BE57A3E86CCC10"
                },
                {
                    "type": "320k",
                    "size": "9.30 MB",
                    "hash": "E7C44199E3EBE0463E6DA3E191E8E9CA"
                },
                {
                    "type": "flac",
                    "size": "28.01 MB",
                    "hash": "17C60D0C6663B90676C812B8A35C1E64"
                },
                {
                    "type": "flac24bit",
                    "size": "51.53 MB",
                    "hash": "616882B2426694D0D20B8CA5870D70F6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.72 MB",
                    "hash": "FE39668F68770C3FB3BE57A3E86CCC10"
                },
                "320k": {
                    "size": "9.30 MB",
                    "hash": "E7C44199E3EBE0463E6DA3E191E8E9CA"
                },
                "flac": {
                    "size": "28.01 MB",
                    "hash": "17C60D0C6663B90676C812B8A35C1E64"
                },
                "flac24bit": {
                    "size": "51.53 MB",
                    "hash": "616882B2426694D0D20B8CA5870D70F6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "河南三妹5233",
            "name": "岁月如笔写春秋",
            "albumName": "岁月如笔写春秋",
            "albumId": "191576482",
            "songmid": 575927110,
            "source": "kg",
            "interval": "04:11",
            "img": "http://imge.kugou.com/stdmusic/400/20260528/20260528212904938023.jpg",
            "lrc": null,
            "hash": "5D4C2F9D994E5BECDC9BA0FBC6BD3DD8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.84 MB",
                    "hash": "5D4C2F9D994E5BECDC9BA0FBC6BD3DD8"
                },
                {
                    "type": "320k",
                    "size": "9.60 MB",
                    "hash": "66B6541D79E4A2C34E22547F11B37BBF"
                },
                {
                    "type": "flac",
                    "size": "29.24 MB",
                    "hash": "F3940E723DB9651AB4DDFA0F1B724C4A"
                },
                {
                    "type": "flac24bit",
                    "size": "50.21 MB",
                    "hash": "522ACEF014CF5F856D18AF604CE4DC0A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.84 MB",
                    "hash": "5D4C2F9D994E5BECDC9BA0FBC6BD3DD8"
                },
                "320k": {
                    "size": "9.60 MB",
                    "hash": "66B6541D79E4A2C34E22547F11B37BBF"
                },
                "flac": {
                    "size": "29.24 MB",
                    "hash": "F3940E723DB9651AB4DDFA0F1B724C4A"
                },
                "flac24bit": {
                    "size": "50.21 MB",
                    "hash": "522ACEF014CF5F856D18AF604CE4DC0A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "徐良、刘丹萌",
            "name": "抽离",
            "albumName": "情话",
            "albumId": "547514",
            "songmid": 749975,
            "source": "kg",
            "interval": "04:18",
            "img": "http://imge.kugou.com/stdmusic/400/20250207/20250207161247131083.jpg",
            "lrc": null,
            "hash": "37A9C74C33A9FAEFF672CFDF4C699581",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.94 MB",
                    "hash": "37A9C74C33A9FAEFF672CFDF4C699581"
                },
                {
                    "type": "320k",
                    "size": "9.85 MB",
                    "hash": "EC7F074A8D1FC72ABD77ADCBFD7D2822"
                },
                {
                    "type": "flac",
                    "size": "26.22 MB",
                    "hash": "057627655174C11B378F57D23BFB7D9F"
                },
                {
                    "type": "flac24bit",
                    "size": "26.98 MB",
                    "hash": "D8CAB150F0D46888FFC57F53A7F30FC5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.94 MB",
                    "hash": "37A9C74C33A9FAEFF672CFDF4C699581"
                },
                "320k": {
                    "size": "9.85 MB",
                    "hash": "EC7F074A8D1FC72ABD77ADCBFD7D2822"
                },
                "flac": {
                    "size": "26.22 MB",
                    "hash": "057627655174C11B378F57D23BFB7D9F"
                },
                "flac24bit": {
                    "size": "26.98 MB",
                    "hash": "D8CAB150F0D46888FFC57F53A7F30FC5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Xcho、Мот",
            "name": "Баллада",
            "albumName": "Баллада",
            "albumId": "91468549",
            "songmid": 344952854,
            "source": "kg",
            "interval": "03:02",
            "img": "http://imge.kugou.com/stdmusic/400/20240413/20240413093005612241.jpg",
            "lrc": null,
            "hash": "0B2EC37A6E065AD181378AAD27391F8F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.78 MB",
                    "hash": "0B2EC37A6E065AD181378AAD27391F8F"
                },
                {
                    "type": "320k",
                    "size": "6.95 MB",
                    "hash": "258215372499DD4704104E5AB7E2E4B6"
                },
                {
                    "type": "flac",
                    "size": "21.06 MB",
                    "hash": "746639040B7FD6B8511F54A7BD4D1535"
                },
                {
                    "type": "flac24bit",
                    "size": "38.89 MB",
                    "hash": "BFCF050B99BAAA155CF19127052187A3"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.78 MB",
                    "hash": "0B2EC37A6E065AD181378AAD27391F8F"
                },
                "320k": {
                    "size": "6.95 MB",
                    "hash": "258215372499DD4704104E5AB7E2E4B6"
                },
                "flac": {
                    "size": "21.06 MB",
                    "hash": "746639040B7FD6B8511F54A7BD4D1535"
                },
                "flac24bit": {
                    "size": "38.89 MB",
                    "hash": "BFCF050B99BAAA155CF19127052187A3"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王铮亮、谭松韵",
            "name": "小半 (Live)",
            "albumName": "天赐的声音第七季 第2期",
            "albumId": "196185049",
            "songmid": 1106638148,
            "source": "kg",
            "interval": "05:14",
            "img": "http://imge.kugou.com/stdmusic/400/20260619/20260619162042192936.jpg",
            "lrc": null,
            "hash": "D0CF7A8F58E9AB02D7B3305E425AE73C",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.80 MB",
                    "hash": "D0CF7A8F58E9AB02D7B3305E425AE73C"
                },
                {
                    "type": "320k",
                    "size": "12.00 MB",
                    "hash": "5BB925BF5789BC03D7B1A23F8C2C0088"
                },
                {
                    "type": "flac",
                    "size": "32.76 MB",
                    "hash": "180F7447074DDF2EF5AC2B067167785B"
                },
                {
                    "type": "flac24bit",
                    "size": "63.37 MB",
                    "hash": "61DF9DC9A9FB708B91938EE99C61C8E8"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.80 MB",
                    "hash": "D0CF7A8F58E9AB02D7B3305E425AE73C"
                },
                "320k": {
                    "size": "12.00 MB",
                    "hash": "5BB925BF5789BC03D7B1A23F8C2C0088"
                },
                "flac": {
                    "size": "32.76 MB",
                    "hash": "180F7447074DDF2EF5AC2B067167785B"
                },
                "flac24bit": {
                    "size": "63.37 MB",
                    "hash": "61DF9DC9A9FB708B91938EE99C61C8E8"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "尹美莱、Tiger JK、Bizzy",
            "name": "Angel",
            "albumName": "天使",
            "albumId": "964390",
            "songmid": 5447287,
            "source": "kg",
            "interval": "04:15",
            "img": "http://imge.kugou.com/stdmusic/400/20211108/20211108104204326077.jpg",
            "lrc": null,
            "hash": "062EA07BB74A381C54524C9F91714D81",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.90 MB",
                    "hash": "062EA07BB74A381C54524C9F91714D81"
                },
                {
                    "type": "320k",
                    "size": "9.74 MB",
                    "hash": "B943A76AB3A9EE753DBA93ABADCEB2EF"
                },
                {
                    "type": "flac",
                    "size": "32.48 MB",
                    "hash": "3BC96786452C7B34781FD1BF65AAC769"
                },
                {
                    "type": "flac24bit",
                    "size": "33.47 MB",
                    "hash": "D1EBF9A1EA355196026D93258422A7D7"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.90 MB",
                    "hash": "062EA07BB74A381C54524C9F91714D81"
                },
                "320k": {
                    "size": "9.74 MB",
                    "hash": "B943A76AB3A9EE753DBA93ABADCEB2EF"
                },
                "flac": {
                    "size": "32.48 MB",
                    "hash": "3BC96786452C7B34781FD1BF65AAC769"
                },
                "flac24bit": {
                    "size": "33.47 MB",
                    "hash": "D1EBF9A1EA355196026D93258422A7D7"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "超哥",
            "name": "踏马寻花向自由 (雷鬼版)",
            "albumName": "踏马寻花向自由（雷鬼版）",
            "albumId": "194886112",
            "songmid": 598285497,
            "source": "kg",
            "interval": "02:59",
            "img": "http://imge.kugou.com/stdmusic/400/20260610/20260610133425971953.jpg",
            "lrc": null,
            "hash": "B5BA68A039E54847B4E14A46A268991B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.74 MB",
                    "hash": "B5BA68A039E54847B4E14A46A268991B"
                },
                {
                    "type": "320k",
                    "size": "6.84 MB",
                    "hash": "072B9C77FD0A89331F8B0A62EC348AE4"
                },
                {
                    "type": "flac",
                    "size": "20.41 MB",
                    "hash": "44537DFB947EE298BE95262721F18DC5"
                },
                {
                    "type": "flac24bit",
                    "size": "35.50 MB",
                    "hash": "3079FABD2FDE517AB8D285CE086AD186"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.74 MB",
                    "hash": "B5BA68A039E54847B4E14A46A268991B"
                },
                "320k": {
                    "size": "6.84 MB",
                    "hash": "072B9C77FD0A89331F8B0A62EC348AE4"
                },
                "flac": {
                    "size": "20.41 MB",
                    "hash": "44537DFB947EE298BE95262721F18DC5"
                },
                "flac24bit": {
                    "size": "35.50 MB",
                    "hash": "3079FABD2FDE517AB8D285CE086AD186"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "莫文蔚",
            "name": "阴天",
            "albumName": "You Can",
            "albumId": "970575",
            "songmid": 302451553,
            "source": "kg",
            "interval": "04:02",
            "img": "http://imge.kugou.com/stdmusic/400/20230822/20230822173602614845.jpg",
            "lrc": null,
            "hash": "E4271CB5938F401AA283FBEA49223BF8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.70 MB",
                    "hash": "E4271CB5938F401AA283FBEA49223BF8"
                },
                {
                    "type": "320k",
                    "size": "9.25 MB",
                    "hash": "F188BE5B17BB1EC72225660C0A91060A"
                },
                {
                    "type": "flac",
                    "size": "25.77 MB",
                    "hash": "35B026DB540C7B26807D13680B349378"
                },
                {
                    "type": "flac24bit",
                    "size": "26.27 MB",
                    "hash": "F4F310D81D7CC71E97C9DDB24D34D2DB"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.70 MB",
                    "hash": "E4271CB5938F401AA283FBEA49223BF8"
                },
                "320k": {
                    "size": "9.25 MB",
                    "hash": "F188BE5B17BB1EC72225660C0A91060A"
                },
                "flac": {
                    "size": "25.77 MB",
                    "hash": "35B026DB540C7B26807D13680B349378"
                },
                "flac24bit": {
                    "size": "26.27 MB",
                    "hash": "F4F310D81D7CC71E97C9DDB24D34D2DB"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "落日微醺",
            "name": "黄昏 (纵然青丝如霜)(R&B版)",
            "albumName": "黄昏（纵然青丝如霜）（R&B版）",
            "albumId": "194767721",
            "songmid": 597507118,
            "source": "kg",
            "interval": "04:05",
            "img": "http://imge.kugou.com/stdmusic/400/20260609/20260609161011216344.jpg",
            "lrc": null,
            "hash": "423FC1778078ACF260242626820E4244",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.74 MB",
                    "hash": "423FC1778078ACF260242626820E4244"
                },
                {
                    "type": "320k",
                    "size": "9.36 MB",
                    "hash": "96EFF958982D4BCF303DDB780649B1BE"
                },
                {
                    "type": "flac",
                    "size": "24.53 MB",
                    "hash": "DED75D6C670B01E0A18E1E9B28829B9A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.74 MB",
                    "hash": "423FC1778078ACF260242626820E4244"
                },
                "320k": {
                    "size": "9.36 MB",
                    "hash": "96EFF958982D4BCF303DDB780649B1BE"
                },
                "flac": {
                    "size": "24.53 MB",
                    "hash": "DED75D6C670B01E0A18E1E9B28829B9A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "金志文",
            "name": "为爱痴狂 (想要问问你敢不敢)",
            "albumName": "花火 原声大碟",
            "albumId": "9052054",
            "songmid": 25630281,
            "source": "kg",
            "interval": "02:21",
            "img": "http://imge.kugou.com/stdmusic/400/20260611/20260611191000673510.jpg",
            "lrc": null,
            "hash": "8CA8C420761A7C36FF16DD42FE5D331D",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.17 MB",
                    "hash": "8CA8C420761A7C36FF16DD42FE5D331D"
                },
                {
                    "type": "320k",
                    "size": "5.41 MB",
                    "hash": "65FEAA4ADBC6176F7FD5D1F1E168E8CB"
                },
                {
                    "type": "flac",
                    "size": "9.05 MB",
                    "hash": "19F612D414FA13D4B2C2FD57082BFD18"
                },
                {
                    "type": "flac24bit",
                    "size": "18.25 MB",
                    "hash": "9387472E2F449815EBE91ECDAC4F19E1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.17 MB",
                    "hash": "8CA8C420761A7C36FF16DD42FE5D331D"
                },
                "320k": {
                    "size": "5.41 MB",
                    "hash": "65FEAA4ADBC6176F7FD5D1F1E168E8CB"
                },
                "flac": {
                    "size": "9.05 MB",
                    "hash": "19F612D414FA13D4B2C2FD57082BFD18"
                },
                "flac24bit": {
                    "size": "18.25 MB",
                    "hash": "9387472E2F449815EBE91ECDAC4F19E1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陈小春",
            "name": "借过一下 (Live)",
            "albumName": "国乐无双 第3期",
            "albumId": "194300314",
            "songmid": 1106433861,
            "source": "kg",
            "interval": "04:24",
            "img": "http://imge.kugou.com/stdmusic/400/20260605/20260605172541716964.jpg",
            "lrc": null,
            "hash": "A60B8E5852E414B356C9F71BD7F16BC6",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.04 MB",
                    "hash": "A60B8E5852E414B356C9F71BD7F16BC6"
                },
                {
                    "type": "320k",
                    "size": "10.11 MB",
                    "hash": "CF7BF4C4F5600D2920943FEA5A9855F7"
                },
                {
                    "type": "flac",
                    "size": "29.05 MB",
                    "hash": "1F40195BE89FE18F0196E2C1817B4E4B"
                },
                {
                    "type": "flac24bit",
                    "size": "54.95 MB",
                    "hash": "F46D6C5EE63C386570E35D2689836B68"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.04 MB",
                    "hash": "A60B8E5852E414B356C9F71BD7F16BC6"
                },
                "320k": {
                    "size": "10.11 MB",
                    "hash": "CF7BF4C4F5600D2920943FEA5A9855F7"
                },
                "flac": {
                    "size": "29.05 MB",
                    "hash": "1F40195BE89FE18F0196E2C1817B4E4B"
                },
                "flac24bit": {
                    "size": "54.95 MB",
                    "hash": "F46D6C5EE63C386570E35D2689836B68"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "宝石Gem",
            "name": "枪火 (相对那就针锋相对)",
            "albumName": "通俗说唱",
            "albumId": "154798334",
            "songmid": 516236736,
            "source": "kg",
            "interval": "03:18",
            "img": "http://imge.kugou.com/stdmusic/400/20250719/20250719220010249278.jpg",
            "lrc": null,
            "hash": "76923758046CB591DC9556D1FB69D976",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.02 MB",
                    "hash": "76923758046CB591DC9556D1FB69D976"
                },
                {
                    "type": "320k",
                    "size": "7.56 MB",
                    "hash": "98D75C1443BDFB9062270415C6BFCFF2"
                },
                {
                    "type": "flac",
                    "size": "23.40 MB",
                    "hash": "56CB57FB1B344F6975AE3E9A463B98D7"
                },
                {
                    "type": "flac24bit",
                    "size": "42.56 MB",
                    "hash": "47195A1F5F4C5CA5CC0541D1221C20FB"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.02 MB",
                    "hash": "76923758046CB591DC9556D1FB69D976"
                },
                "320k": {
                    "size": "7.56 MB",
                    "hash": "98D75C1443BDFB9062270415C6BFCFF2"
                },
                "flac": {
                    "size": "23.40 MB",
                    "hash": "56CB57FB1B344F6975AE3E9A463B98D7"
                },
                "flac24bit": {
                    "size": "42.56 MB",
                    "hash": "47195A1F5F4C5CA5CC0541D1221C20FB"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "白小白",
            "name": "人生路漫漫",
            "albumName": "人生路漫漫",
            "albumId": "179917533",
            "songmid": 548404459,
            "source": "kg",
            "interval": "03:55",
            "img": "http://imge.kugou.com/stdmusic/400/20260326/20260326182610525334.jpg",
            "lrc": null,
            "hash": "B8CA573A69DB5050C7EE0C1AB79144E5",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.59 MB",
                    "hash": "B8CA573A69DB5050C7EE0C1AB79144E5"
                },
                {
                    "type": "320k",
                    "size": "8.97 MB",
                    "hash": "AB74B9584F71FDBC59656C06CD101A16"
                },
                {
                    "type": "flac",
                    "size": "25.03 MB",
                    "hash": "7B889606DA82E5C2EDA67912CD2BF1FD"
                },
                {
                    "type": "flac24bit",
                    "size": "47.84 MB",
                    "hash": "1A8212B217FE68C8D042B49BD5940DDF"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.59 MB",
                    "hash": "B8CA573A69DB5050C7EE0C1AB79144E5"
                },
                "320k": {
                    "size": "8.97 MB",
                    "hash": "AB74B9584F71FDBC59656C06CD101A16"
                },
                "flac": {
                    "size": "25.03 MB",
                    "hash": "7B889606DA82E5C2EDA67912CD2BF1FD"
                },
                "flac24bit": {
                    "size": "47.84 MB",
                    "hash": "1A8212B217FE68C8D042B49BD5940DDF"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "郭少杰",
            "name": "岁月如笔写春秋",
            "albumName": "岁月如笔写春秋",
            "albumId": "190046745",
            "songmid": 571101241,
            "source": "kg",
            "interval": "04:11",
            "img": "http://imge.kugou.com/stdmusic/400/20260608/20260608151447300545.jpg",
            "lrc": null,
            "hash": "6FCF099C6A88F85FC8417AFD452D54FD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.84 MB",
                    "hash": "6FCF099C6A88F85FC8417AFD452D54FD"
                },
                {
                    "type": "320k",
                    "size": "9.60 MB",
                    "hash": "528BF0A4EE662F0CCBB08926946FDA32"
                },
                {
                    "type": "flac",
                    "size": "29.13 MB",
                    "hash": "F644BCB6DEA9D62CC362511D0374A010"
                },
                {
                    "type": "flac24bit",
                    "size": "50.10 MB",
                    "hash": "ADDE7E90C3242B3EEE6F29980BC21B1D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.84 MB",
                    "hash": "6FCF099C6A88F85FC8417AFD452D54FD"
                },
                "320k": {
                    "size": "9.60 MB",
                    "hash": "528BF0A4EE662F0CCBB08926946FDA32"
                },
                "flac": {
                    "size": "29.13 MB",
                    "hash": "F644BCB6DEA9D62CC362511D0374A010"
                },
                "flac24bit": {
                    "size": "50.10 MB",
                    "hash": "ADDE7E90C3242B3EEE6F29980BC21B1D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张靓颖",
            "name": "野心家",
            "albumName": "灼灼韶华 影视原声带",
            "albumId": "161637189",
            "songmid": 477568288,
            "source": "kg",
            "interval": "04:42",
            "img": "http://imge.kugou.com/stdmusic/400/20250911/20250911154151208993.jpg",
            "lrc": null,
            "hash": "1789AD88CFDD254910125F22494C0E8B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.31 MB",
                    "hash": "1789AD88CFDD254910125F22494C0E8B"
                },
                {
                    "type": "320k",
                    "size": "10.78 MB",
                    "hash": "49E4228C5870B9F51D9F883326CC7CA2"
                },
                {
                    "type": "flac",
                    "size": "28.62 MB",
                    "hash": "12E572FB7FB4265756EDEBE9E7F4C390"
                },
                {
                    "type": "flac24bit",
                    "size": "55.81 MB",
                    "hash": "B8135E4B0F35A4D28DCB2ED93DB2503F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.31 MB",
                    "hash": "1789AD88CFDD254910125F22494C0E8B"
                },
                "320k": {
                    "size": "10.78 MB",
                    "hash": "49E4228C5870B9F51D9F883326CC7CA2"
                },
                "flac": {
                    "size": "28.62 MB",
                    "hash": "12E572FB7FB4265756EDEBE9E7F4C390"
                },
                "flac24bit": {
                    "size": "55.81 MB",
                    "hash": "B8135E4B0F35A4D28DCB2ED93DB2503F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "imase",
            "name": "NIGHT DANCER",
            "albumName": "NIGHT DANCER",
            "albumId": "59918395",
            "songmid": 185029311,
            "source": "kg",
            "interval": "03:30",
            "img": "http://imge.kugou.com/stdmusic/400/20250311/20250311105025403709.jpg",
            "lrc": null,
            "hash": "572C3807BF90891332ED77A72DB74272",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.22 MB",
                    "hash": "572C3807BF90891332ED77A72DB74272"
                },
                {
                    "type": "320k",
                    "size": "8.05 MB",
                    "hash": "ED05204BDDF0824626B3D00728051D40"
                },
                {
                    "type": "flac",
                    "size": "22.59 MB",
                    "hash": "5D10EB19CC6A8A38CD614590F2B0F455"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.22 MB",
                    "hash": "572C3807BF90891332ED77A72DB74272"
                },
                "320k": {
                    "size": "8.05 MB",
                    "hash": "ED05204BDDF0824626B3D00728051D40"
                },
                "flac": {
                    "size": "22.59 MB",
                    "hash": "5D10EB19CC6A8A38CD614590F2B0F455"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "万海东",
            "name": "有风的日落",
            "albumName": "有风的日落",
            "albumId": "181906094",
            "songmid": 554283302,
            "source": "kg",
            "interval": "03:49",
            "img": "http://imge.kugou.com/stdmusic/400/20260521/20260521171520363078.jpg",
            "lrc": null,
            "hash": "94774F06E73EF9ABD739423E1A414593",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.51 MB",
                    "hash": "94774F06E73EF9ABD739423E1A414593"
                },
                {
                    "type": "320k",
                    "size": "8.77 MB",
                    "hash": "DEA1108A92ED48B3B51F7010FE2AD0E2"
                },
                {
                    "type": "flac",
                    "size": "26.51 MB",
                    "hash": "8643BEA855B435D7B9AEF57BE8BB327A"
                },
                {
                    "type": "flac24bit",
                    "size": "48.97 MB",
                    "hash": "AA51518632C104E943D19EA2F3EB41AE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.51 MB",
                    "hash": "94774F06E73EF9ABD739423E1A414593"
                },
                "320k": {
                    "size": "8.77 MB",
                    "hash": "DEA1108A92ED48B3B51F7010FE2AD0E2"
                },
                "flac": {
                    "size": "26.51 MB",
                    "hash": "8643BEA855B435D7B9AEF57BE8BB327A"
                },
                "flac24bit": {
                    "size": "48.97 MB",
                    "hash": "AA51518632C104E943D19EA2F3EB41AE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张靓颖、曾舜晞",
            "name": "锁 (Live)",
            "albumName": "天赐的声音第七季 第2期",
            "albumId": "196185049",
            "songmid": 1106638365,
            "source": "kg",
            "interval": "03:44",
            "img": "http://imge.kugou.com/stdmusic/400/20260619/20260619162042192936.jpg",
            "lrc": null,
            "hash": "638AAD25590BCA90E939028CC03E183C",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.43 MB",
                    "hash": "638AAD25590BCA90E939028CC03E183C"
                },
                {
                    "type": "320k",
                    "size": "8.58 MB",
                    "hash": "B0B158F533D8564B44FFEB90DB0F3B81"
                },
                {
                    "type": "flac",
                    "size": "25.08 MB",
                    "hash": "618D669A7A845D4187C267083D433995"
                },
                {
                    "type": "flac24bit",
                    "size": "46.77 MB",
                    "hash": "61F53D6662F1785E68CC78B166D18484"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.43 MB",
                    "hash": "638AAD25590BCA90E939028CC03E183C"
                },
                "320k": {
                    "size": "8.58 MB",
                    "hash": "B0B158F533D8564B44FFEB90DB0F3B81"
                },
                "flac": {
                    "size": "25.08 MB",
                    "hash": "618D669A7A845D4187C267083D433995"
                },
                "flac24bit": {
                    "size": "46.77 MB",
                    "hash": "61F53D6662F1785E68CC78B166D18484"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Richz",
            "name": "Fever Pitch",
            "albumName": "Fever Pitch",
            "albumId": "180499937",
            "songmid": 550109760,
            "source": "kg",
            "interval": "02:15",
            "img": "http://imge.kugou.com/stdmusic/400/20260323/20260323142821933875.jpg",
            "lrc": null,
            "hash": "594B915AEEDA7DA8F5BD70B63EA76EAD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.07 MB",
                    "hash": "594B915AEEDA7DA8F5BD70B63EA76EAD"
                },
                {
                    "type": "320k",
                    "size": "5.17 MB",
                    "hash": "AAB0FBCE16F6D9AF7CCB08E2D0035177"
                },
                {
                    "type": "flac",
                    "size": "16.79 MB",
                    "hash": "F6940FE285AC675FE68F2650DFE2A908"
                },
                {
                    "type": "flac24bit",
                    "size": "28.11 MB",
                    "hash": "DDCDD04718A2850C8356505A85DA4386"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.07 MB",
                    "hash": "594B915AEEDA7DA8F5BD70B63EA76EAD"
                },
                "320k": {
                    "size": "5.17 MB",
                    "hash": "AAB0FBCE16F6D9AF7CCB08E2D0035177"
                },
                "flac": {
                    "size": "16.79 MB",
                    "hash": "F6940FE285AC675FE68F2650DFE2A908"
                },
                "flac24bit": {
                    "size": "28.11 MB",
                    "hash": "DDCDD04718A2850C8356505A85DA4386"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "贺一航",
            "name": "听说当初你找过我",
            "albumName": "《听说你当初找过我》国语版",
            "albumId": "1969900",
            "songmid": 25123665,
            "source": "kg",
            "interval": "04:06",
            "img": "http://imge.kugou.com/stdmusic/400/20250217/20250217144402572275.jpg",
            "lrc": null,
            "hash": "8853D5BDDDE97FEACFAF65371B68AD57",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.76 MB",
                    "hash": "8853D5BDDDE97FEACFAF65371B68AD57"
                },
                {
                    "type": "320k",
                    "size": "9.40 MB",
                    "hash": "971339AB38463E13AB275DF9361EB993"
                },
                {
                    "type": "flac",
                    "size": "25.97 MB",
                    "hash": "C6E4BBFA5C9906C3A22E7015D3D7FC2C"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.76 MB",
                    "hash": "8853D5BDDDE97FEACFAF65371B68AD57"
                },
                "320k": {
                    "size": "9.40 MB",
                    "hash": "971339AB38463E13AB275DF9361EB993"
                },
                "flac": {
                    "size": "25.97 MB",
                    "hash": "C6E4BBFA5C9906C3A22E7015D3D7FC2C"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "伯爵Johnny、唐伯虎Annie",
            "name": "西厢寻他",
            "albumName": "西厢寻他",
            "albumId": "53205523",
            "songmid": 144458245,
            "source": "kg",
            "interval": "03:43",
            "img": "http://imge.kugou.com/stdmusic/400/20220119/20220119144302512528.jpg",
            "lrc": null,
            "hash": "2B657B5B5D781C1A61D7E0D1F5E2DE22",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.41 MB",
                    "hash": "2B657B5B5D781C1A61D7E0D1F5E2DE22"
                },
                {
                    "type": "320k",
                    "size": "8.53 MB",
                    "hash": "ADBA6B01034AAD3132816F384EA3EB5D"
                },
                {
                    "type": "flac",
                    "size": "24.95 MB",
                    "hash": "EEFD446260FDF3EDF278766A76582D07"
                },
                {
                    "type": "flac24bit",
                    "size": "45.24 MB",
                    "hash": "32F95ABB07A09806FDEB2B37B448C416"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.41 MB",
                    "hash": "2B657B5B5D781C1A61D7E0D1F5E2DE22"
                },
                "320k": {
                    "size": "8.53 MB",
                    "hash": "ADBA6B01034AAD3132816F384EA3EB5D"
                },
                "flac": {
                    "size": "24.95 MB",
                    "hash": "EEFD446260FDF3EDF278766A76582D07"
                },
                "flac24bit": {
                    "size": "45.24 MB",
                    "hash": "32F95ABB07A09806FDEB2B37B448C416"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "筷子兄弟",
            "name": "逍遥仙",
            "albumName": "逍遥仙",
            "albumId": "195208297",
            "songmid": 1106567811,
            "source": "kg",
            "interval": "03:44",
            "img": "http://imge.kugou.com/stdmusic/400/20260618/20260618172438316402.jpg",
            "lrc": null,
            "hash": "DB55839AA8A9EBCECCD87948ED031B15",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.43 MB",
                    "hash": "DB55839AA8A9EBCECCD87948ED031B15"
                },
                {
                    "type": "320k",
                    "size": "8.57 MB",
                    "hash": "935E4AA35CC5CBE84BA43008ED328F4E"
                },
                {
                    "type": "flac",
                    "size": "26.57 MB",
                    "hash": "A0CB8BF89734F09CD6C3C6D12D8F6AAF"
                },
                {
                    "type": "flac24bit",
                    "size": "48.54 MB",
                    "hash": "F2920CC12162355A0019703255E6AFC6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.43 MB",
                    "hash": "DB55839AA8A9EBCECCD87948ED031B15"
                },
                "320k": {
                    "size": "8.57 MB",
                    "hash": "935E4AA35CC5CBE84BA43008ED328F4E"
                },
                "flac": {
                    "size": "26.57 MB",
                    "hash": "A0CB8BF89734F09CD6C3C6D12D8F6AAF"
                },
                "flac24bit": {
                    "size": "48.54 MB",
                    "hash": "F2920CC12162355A0019703255E6AFC6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Suki刘舒妤",
            "name": "失眠",
            "albumName": "Ladies Night",
            "albumId": "671621",
            "songmid": 1099164186,
            "source": "kg",
            "interval": "03:31",
            "img": "http://imge.kugou.com/stdmusic/400/20260415/20260415190622329436.jpg",
            "lrc": null,
            "hash": "EC476A2009EF5DCAC13EDCD11870DF55",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.22 MB",
                    "hash": "EC476A2009EF5DCAC13EDCD11870DF55"
                },
                {
                    "type": "320k",
                    "size": "8.06 MB",
                    "hash": "0F027DFC57447BA46C85FC067B2E7ED6"
                },
                {
                    "type": "flac",
                    "size": "17.13 MB",
                    "hash": "D570E0994720DAA789BA710021955ADA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.22 MB",
                    "hash": "EC476A2009EF5DCAC13EDCD11870DF55"
                },
                "320k": {
                    "size": "8.06 MB",
                    "hash": "0F027DFC57447BA46C85FC067B2E7ED6"
                },
                "flac": {
                    "size": "17.13 MB",
                    "hash": "D570E0994720DAA789BA710021955ADA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陈粒",
            "name": "小半",
            "albumName": "小梦大半",
            "albumId": "1749208",
            "songmid": 22399633,
            "source": "kg",
            "interval": "04:57",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620103339135851.jpg",
            "lrc": null,
            "hash": "AFEA9FFE5D7F0EF0874119A363820D33",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.54 MB",
                    "hash": "AFEA9FFE5D7F0EF0874119A363820D33"
                },
                {
                    "type": "320k",
                    "size": "11.34 MB",
                    "hash": "E1FB163AD061EF4843E4D6A45A5F2495"
                },
                {
                    "type": "flac",
                    "size": "30.73 MB",
                    "hash": "BB5B842622AF6FED0FD2419FD6E75F3F"
                },
                {
                    "type": "flac24bit",
                    "size": "122.51 MB",
                    "hash": "0F19F364246317A0822DD46E6E100647"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.54 MB",
                    "hash": "AFEA9FFE5D7F0EF0874119A363820D33"
                },
                "320k": {
                    "size": "11.34 MB",
                    "hash": "E1FB163AD061EF4843E4D6A45A5F2495"
                },
                "flac": {
                    "size": "30.73 MB",
                    "hash": "BB5B842622AF6FED0FD2419FD6E75F3F"
                },
                "flac24bit": {
                    "size": "122.51 MB",
                    "hash": "0F19F364246317A0822DD46E6E100647"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "汪苏泷、G.E.M. 邓紫棋",
            "name": "让你知道",
            "albumName": "明日世界ACT I",
            "albumId": "182848644",
            "songmid": 1105443681,
            "source": "kg",
            "interval": "03:59",
            "img": "http://imge.kugou.com/stdmusic/400/20260623/20260623120003410674.jpg",
            "lrc": null,
            "hash": "0D037B68DC95AAAFC5F78056D78D7541",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.66 MB",
                    "hash": "0D037B68DC95AAAFC5F78056D78D7541"
                },
                {
                    "type": "320k",
                    "size": "9.15 MB",
                    "hash": "3CCBCF62658D15502753C882BB54A452"
                },
                {
                    "type": "flac",
                    "size": "25.24 MB",
                    "hash": "59F38A0CCCAA9BA618E1FAF6A6D63AE2"
                },
                {
                    "type": "flac24bit",
                    "size": "80.16 MB",
                    "hash": "B8E209531598EBE85A4EBA209081AAB5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.66 MB",
                    "hash": "0D037B68DC95AAAFC5F78056D78D7541"
                },
                "320k": {
                    "size": "9.15 MB",
                    "hash": "3CCBCF62658D15502753C882BB54A452"
                },
                "flac": {
                    "size": "25.24 MB",
                    "hash": "59F38A0CCCAA9BA618E1FAF6A6D63AE2"
                },
                "flac24bit": {
                    "size": "80.16 MB",
                    "hash": "B8E209531598EBE85A4EBA209081AAB5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林栖",
            "name": "若不是因为你 (深情版)",
            "albumName": "若不是因为你",
            "albumId": "176013962",
            "songmid": 535578777,
            "source": "kg",
            "interval": "04:13",
            "img": "http://imge.kugou.com/stdmusic/400/20260209/20260209172247328990.jpg",
            "lrc": null,
            "hash": "6CCB2559DE8FC8965E98F641C4C33B6A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.87 MB",
                    "hash": "6CCB2559DE8FC8965E98F641C4C33B6A"
                },
                {
                    "type": "320k",
                    "size": "9.67 MB",
                    "hash": "04451E2D1AB1D49F0A502A62E9B4A0E1"
                },
                {
                    "type": "flac",
                    "size": "27.30 MB",
                    "hash": "A2C20E43F4C853DA17F6A57872CAD084"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.87 MB",
                    "hash": "6CCB2559DE8FC8965E98F641C4C33B6A"
                },
                "320k": {
                    "size": "9.67 MB",
                    "hash": "04451E2D1AB1D49F0A502A62E9B4A0E1"
                },
                "flac": {
                    "size": "27.30 MB",
                    "hash": "A2C20E43F4C853DA17F6A57872CAD084"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "莫文蔚",
            "name": "盛夏的果实",
            "albumName": "《北极光》国语版",
            "albumId": "978378",
            "songmid": 301315251,
            "source": "kg",
            "interval": "04:10",
            "img": "http://imge.kugou.com/stdmusic/400/20250221/20250221180820211739.jpg",
            "lrc": null,
            "hash": "1C86CBC64AE9A6C3539A36CAADDF1A59",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.83 MB",
                    "hash": "1C86CBC64AE9A6C3539A36CAADDF1A59"
                },
                {
                    "type": "320k",
                    "size": "9.57 MB",
                    "hash": "BCF00BDDA1B91EBC63F0C7DB702EB4AB"
                },
                {
                    "type": "flac",
                    "size": "23.45 MB",
                    "hash": "9FDC0CB7204A6AC102581523A2D1022D"
                },
                {
                    "type": "flac24bit",
                    "size": "24.41 MB",
                    "hash": "DBB7A3A921BCA86504C449CFE34664DF"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.83 MB",
                    "hash": "1C86CBC64AE9A6C3539A36CAADDF1A59"
                },
                "320k": {
                    "size": "9.57 MB",
                    "hash": "BCF00BDDA1B91EBC63F0C7DB702EB4AB"
                },
                "flac": {
                    "size": "23.45 MB",
                    "hash": "9FDC0CB7204A6AC102581523A2D1022D"
                },
                "flac24bit": {
                    "size": "24.41 MB",
                    "hash": "DBB7A3A921BCA86504C449CFE34664DF"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陈小春",
            "name": "街角的晚风",
            "albumName": "街角的晚风",
            "albumId": "169830039",
            "songmid": 515103833,
            "source": "kg",
            "interval": "04:00",
            "img": "http://imge.kugou.com/stdmusic/400/20251205/20251205134231782648.jpg",
            "lrc": null,
            "hash": "18B89D66950B7856EABB131BB6273F6E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.66 MB",
                    "hash": "18B89D66950B7856EABB131BB6273F6E"
                },
                {
                    "type": "320k",
                    "size": "9.16 MB",
                    "hash": "DC4FB75CE17D1A18FE6F0BDF49ACCBE4"
                },
                {
                    "type": "flac",
                    "size": "30.38 MB",
                    "hash": "0CE78D40AF04E9FFD28EC2D0BD6117D6"
                },
                {
                    "type": "flac24bit",
                    "size": "54.25 MB",
                    "hash": "9C60B0C80C583BB454BD6F690AC9256C"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.66 MB",
                    "hash": "18B89D66950B7856EABB131BB6273F6E"
                },
                "320k": {
                    "size": "9.16 MB",
                    "hash": "DC4FB75CE17D1A18FE6F0BDF49ACCBE4"
                },
                "flac": {
                    "size": "30.38 MB",
                    "hash": "0CE78D40AF04E9FFD28EC2D0BD6117D6"
                },
                "flac24bit": {
                    "size": "54.25 MB",
                    "hash": "9C60B0C80C583BB454BD6F690AC9256C"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Dizzy Dizzo (蔡诗芸)",
            "name": "雨过后的风景",
            "albumName": "黑色彩虹",
            "albumId": "974143",
            "songmid": 26928,
            "source": "kg",
            "interval": "04:03",
            "img": "http://imge.kugou.com/stdmusic/400/20260126/20260126211840542004.jpg",
            "lrc": null,
            "hash": "E3F046EDB5EB76BBA5A44FFA3D8F8C42",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.71 MB",
                    "hash": "E3F046EDB5EB76BBA5A44FFA3D8F8C42"
                },
                {
                    "type": "320k",
                    "size": "9.28 MB",
                    "hash": "0ECA7B07904DA80D08A4043DD8C750CD"
                },
                {
                    "type": "flac",
                    "size": "26.02 MB",
                    "hash": "66D272FAEDE45AE48F7FD9A86D2D7234"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.71 MB",
                    "hash": "E3F046EDB5EB76BBA5A44FFA3D8F8C42"
                },
                "320k": {
                    "size": "9.28 MB",
                    "hash": "0ECA7B07904DA80D08A4043DD8C750CD"
                },
                "flac": {
                    "size": "26.02 MB",
                    "hash": "66D272FAEDE45AE48F7FD9A86D2D7234"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "任然",
            "name": "无人之岛",
            "albumName": "《荒岛》国语版",
            "albumId": "2916172",
            "songmid": 28073138,
            "source": "kg",
            "interval": "04:45",
            "img": "http://imge.kugou.com/stdmusic/400/20241203/20241203170635388725.jpg",
            "lrc": null,
            "hash": "8E568D8806F771607104D8BF9695ACE0",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.35 MB",
                    "hash": "8E568D8806F771607104D8BF9695ACE0"
                },
                {
                    "type": "320k",
                    "size": "10.88 MB",
                    "hash": "A9474C8A374908DE4C3663E43D18D55B"
                },
                {
                    "type": "flac",
                    "size": "28.95 MB",
                    "hash": "A672FFF25AB0DB68B6BF2C40FA8005B1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.35 MB",
                    "hash": "8E568D8806F771607104D8BF9695ACE0"
                },
                "320k": {
                    "size": "10.88 MB",
                    "hash": "A9474C8A374908DE4C3663E43D18D55B"
                },
                "flac": {
                    "size": "28.95 MB",
                    "hash": "A672FFF25AB0DB68B6BF2C40FA8005B1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "芮恩",
            "name": "讨厌",
            "albumName": "Ruien",
            "albumId": "2996887",
            "songmid": 63114,
            "source": "kg",
            "interval": "04:17",
            "img": "http://imge.kugou.com/stdmusic/400/20230119/20230119185304196586.jpg",
            "lrc": null,
            "hash": "C88A8D3EF16E2C4E944B947E0F56A7AD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.94 MB",
                    "hash": "C88A8D3EF16E2C4E944B947E0F56A7AD"
                },
                {
                    "type": "320k",
                    "size": "9.84 MB",
                    "hash": "9053D7AC46B11843F6B36850F44283A8"
                },
                {
                    "type": "flac",
                    "size": "28.35 MB",
                    "hash": "65CFDEB726C636F139B552D723AA795D"
                },
                {
                    "type": "flac24bit",
                    "size": "29.11 MB",
                    "hash": "247DB344C09588068DD8C27871CC7FA8"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.94 MB",
                    "hash": "C88A8D3EF16E2C4E944B947E0F56A7AD"
                },
                "320k": {
                    "size": "9.84 MB",
                    "hash": "9053D7AC46B11843F6B36850F44283A8"
                },
                "flac": {
                    "size": "28.35 MB",
                    "hash": "65CFDEB726C636F139B552D723AA795D"
                },
                "flac24bit": {
                    "size": "29.11 MB",
                    "hash": "247DB344C09588068DD8C27871CC7FA8"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Gareth.T",
            "name": "玻璃",
            "albumName": "玻璃",
            "albumId": "191663409",
            "songmid": 1106037536,
            "source": "kg",
            "interval": "03:05",
            "img": "http://imge.kugou.com/stdmusic/400/20260518/20260518195422316857.jpg",
            "lrc": null,
            "hash": "ED0ED6B17B6C29695E97F5CC945C7901",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.82 MB",
                    "hash": "ED0ED6B17B6C29695E97F5CC945C7901"
                },
                {
                    "type": "320k",
                    "size": "7.06 MB",
                    "hash": "9D5C2B97B1FDE84A2C3FE4DE811C6EE5"
                },
                {
                    "type": "flac",
                    "size": "20.37 MB",
                    "hash": "A851780031942CF114C6AC251D53B3A1"
                },
                {
                    "type": "flac24bit",
                    "size": "38.62 MB",
                    "hash": "D5EF664A828388681AF5AE0903CC751D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.82 MB",
                    "hash": "ED0ED6B17B6C29695E97F5CC945C7901"
                },
                "320k": {
                    "size": "7.06 MB",
                    "hash": "9D5C2B97B1FDE84A2C3FE4DE811C6EE5"
                },
                "flac": {
                    "size": "20.37 MB",
                    "hash": "A851780031942CF114C6AC251D53B3A1"
                },
                "flac24bit": {
                    "size": "38.62 MB",
                    "hash": "D5EF664A828388681AF5AE0903CC751D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "落日微醺",
            "name": "Amani (女声版)",
            "albumName": "Amani",
            "albumId": "194642479",
            "songmid": 595877387,
            "source": "kg",
            "interval": "03:54",
            "img": "http://imge.kugou.com/stdmusic/400/20260616/20260616163740548123.jpg",
            "lrc": null,
            "hash": "0E1705D85CE6D8BE87784DFA9C9A5624",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.57 MB",
                    "hash": "0E1705D85CE6D8BE87784DFA9C9A5624"
                },
                {
                    "type": "320k",
                    "size": "8.93 MB",
                    "hash": "B243D0C6DE9961E5106F8DA6F89FEDD6"
                },
                {
                    "type": "flac",
                    "size": "23.29 MB",
                    "hash": "A35D088EF508C1059032DF34CA5B7AA6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.57 MB",
                    "hash": "0E1705D85CE6D8BE87784DFA9C9A5624"
                },
                "320k": {
                    "size": "8.93 MB",
                    "hash": "B243D0C6DE9961E5106F8DA6F89FEDD6"
                },
                "flac": {
                    "size": "23.29 MB",
                    "hash": "A35D088EF508C1059032DF34CA5B7AA6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "杨坤、郭采洁",
            "name": "答案",
            "albumName": "今夜二十岁",
            "albumId": "972892",
            "songmid": 2520453,
            "source": "kg",
            "interval": "03:51",
            "img": "http://imge.kugou.com/stdmusic/400/20201104/20201104104509817203.jpg",
            "lrc": null,
            "hash": "CBF05F9D1C71FFBF59241B38FB4ABED7",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.54 MB",
                    "hash": "CBF05F9D1C71FFBF59241B38FB4ABED7"
                },
                {
                    "type": "320k",
                    "size": "8.84 MB",
                    "hash": "2305F9F0DA7CCEDA2424B653A594277B"
                },
                {
                    "type": "flac",
                    "size": "24.93 MB",
                    "hash": "8286F9582496A0DC76FD350BC63843F2"
                },
                {
                    "type": "flac24bit",
                    "size": "25.81 MB",
                    "hash": "2418A139B192F6C0E3DFDF6D6813393D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.54 MB",
                    "hash": "CBF05F9D1C71FFBF59241B38FB4ABED7"
                },
                "320k": {
                    "size": "8.84 MB",
                    "hash": "2305F9F0DA7CCEDA2424B653A594277B"
                },
                "flac": {
                    "size": "24.93 MB",
                    "hash": "8286F9582496A0DC76FD350BC63843F2"
                },
                "flac24bit": {
                    "size": "25.81 MB",
                    "hash": "2418A139B192F6C0E3DFDF6D6813393D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "白兰的",
            "name": "摇太阳 (雷鬼版)",
            "albumName": "经典老歌烟嗓翻唱集",
            "albumId": "183678520",
            "songmid": 559042601,
            "source": "kg",
            "interval": "04:32",
            "img": "http://imge.kugou.com/stdmusic/400/20260416/20260416193431525156.jpg",
            "lrc": null,
            "hash": "97915750F2E7DEBEB4E2C7AF4AA7F5A1",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.16 MB",
                    "hash": "97915750F2E7DEBEB4E2C7AF4AA7F5A1"
                },
                {
                    "type": "320k",
                    "size": "10.40 MB",
                    "hash": "95A9E0B76D3469389BC51402D45F5A4C"
                },
                {
                    "type": "flac",
                    "size": "33.12 MB",
                    "hash": "7BF0652035016A3D92B979506841F2BE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.16 MB",
                    "hash": "97915750F2E7DEBEB4E2C7AF4AA7F5A1"
                },
                "320k": {
                    "size": "10.40 MB",
                    "hash": "95A9E0B76D3469389BC51402D45F5A4C"
                },
                "flac": {
                    "size": "33.12 MB",
                    "hash": "7BF0652035016A3D92B979506841F2BE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "超级大瓜",
            "name": "你的眼神 (女声版)",
            "albumName": "像一阵细雨洒落我心底",
            "albumId": "195667488",
            "songmid": 601809111,
            "source": "kg",
            "interval": "03:28",
            "img": "http://imge.kugou.com/stdmusic/400/20260616/20260616120710463330.jpg",
            "lrc": null,
            "hash": "B1270F725880F3E3D700498387A25FA8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.18 MB",
                    "hash": "B1270F725880F3E3D700498387A25FA8"
                },
                {
                    "type": "320k",
                    "size": "7.94 MB",
                    "hash": "A7FD1B626BAE7CAFF6300CFD77278AEA"
                },
                {
                    "type": "flac",
                    "size": "21.48 MB",
                    "hash": "F6814BEF7A0B885B11EC1541693AB7CB"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.18 MB",
                    "hash": "B1270F725880F3E3D700498387A25FA8"
                },
                "320k": {
                    "size": "7.94 MB",
                    "hash": "A7FD1B626BAE7CAFF6300CFD77278AEA"
                },
                "flac": {
                    "size": "21.48 MB",
                    "hash": "F6814BEF7A0B885B11EC1541693AB7CB"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "李荣浩",
            "name": "恋人",
            "albumName": "黑马",
            "albumId": "106374641",
            "songmid": 363537969,
            "source": "kg",
            "interval": "04:35",
            "img": "http://imge.kugou.com/stdmusic/400/20241016/20241016175101115675.jpg",
            "lrc": null,
            "hash": "9DA7851E2BF83B18C74CBBAB461CEFDD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.21 MB",
                    "hash": "9DA7851E2BF83B18C74CBBAB461CEFDD"
                },
                {
                    "type": "320k",
                    "size": "10.53 MB",
                    "hash": "C8DE6F8214A0556AC3F0BE4872A6EED8"
                },
                {
                    "type": "flac",
                    "size": "26.86 MB",
                    "hash": "34C52ED693A5519D72DA623EBA0E7DE1"
                },
                {
                    "type": "flac24bit",
                    "size": "53.62 MB",
                    "hash": "CE16C9658C82664796DBB7585588AAC5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.21 MB",
                    "hash": "9DA7851E2BF83B18C74CBBAB461CEFDD"
                },
                "320k": {
                    "size": "10.53 MB",
                    "hash": "C8DE6F8214A0556AC3F0BE4872A6EED8"
                },
                "flac": {
                    "size": "26.86 MB",
                    "hash": "34C52ED693A5519D72DA623EBA0E7DE1"
                },
                "flac24bit": {
                    "size": "53.62 MB",
                    "hash": "CE16C9658C82664796DBB7585588AAC5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "徐良、小凌",
            "name": "坏女孩",
            "albumName": "不良少年",
            "albumId": "511536",
            "songmid": 301344189,
            "source": "kg",
            "interval": "04:06",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620074915201495.jpg",
            "lrc": null,
            "hash": "813447A7B1220E4AB95CADE34BF7B7B8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.76 MB",
                    "hash": "813447A7B1220E4AB95CADE34BF7B7B8"
                },
                {
                    "type": "320k",
                    "size": "9.41 MB",
                    "hash": "07493EA680EF6EDD46DC93646860D4AD"
                },
                {
                    "type": "flac",
                    "size": "23.32 MB",
                    "hash": "C9511C065265B2E4ECEEDE8B696AAFB6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.76 MB",
                    "hash": "813447A7B1220E4AB95CADE34BF7B7B8"
                },
                "320k": {
                    "size": "9.41 MB",
                    "hash": "07493EA680EF6EDD46DC93646860D4AD"
                },
                "flac": {
                    "size": "23.32 MB",
                    "hash": "C9511C065265B2E4ECEEDE8B696AAFB6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "央金拉姆",
            "name": "山歌追上云朵",
            "albumName": "山歌追上云朵",
            "albumId": "193932928",
            "songmid": 586285436,
            "source": "kg",
            "interval": "03:35",
            "img": "http://imge.kugou.com/stdmusic/400/20260603/20260603103412322802.jpg",
            "lrc": null,
            "hash": "B81F368C6B44B98B0E2B4E9F417F1002",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.28 MB",
                    "hash": "B81F368C6B44B98B0E2B4E9F417F1002"
                },
                {
                    "type": "320k",
                    "size": "8.20 MB",
                    "hash": "D05CBF29142992405D60DEAB6AEFFC3C"
                },
                {
                    "type": "flac",
                    "size": "20.57 MB",
                    "hash": "D5479316D22170B24D3C2D41B58FCA23"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.28 MB",
                    "hash": "B81F368C6B44B98B0E2B4E9F417F1002"
                },
                "320k": {
                    "size": "8.20 MB",
                    "hash": "D05CBF29142992405D60DEAB6AEFFC3C"
                },
                "flac": {
                    "size": "20.57 MB",
                    "hash": "D5479316D22170B24D3C2D41B58FCA23"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "万海东",
            "name": "若今生无缘 (若今生已无缘)",
            "albumName": "若今生无缘（若今生已无缘）",
            "albumId": "195038536",
            "songmid": 599836462,
            "source": "kg",
            "interval": "03:40",
            "img": "http://imge.kugou.com/stdmusic/400/20260611/20260611165101574296.jpg",
            "lrc": null,
            "hash": "E74F4CC22263126EDD4A721AD0D0D0A8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.36 MB",
                    "hash": "E74F4CC22263126EDD4A721AD0D0D0A8"
                },
                {
                    "type": "320k",
                    "size": "8.39 MB",
                    "hash": "C6A54074E90BEB59D8B91749AAC4B323"
                },
                {
                    "type": "flac",
                    "size": "24.06 MB",
                    "hash": "661FDC79E23F4B63C060FEBF09AAA432"
                },
                {
                    "type": "flac24bit",
                    "size": "45.15 MB",
                    "hash": "721059193DA324C646CFF5C86E038412"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.36 MB",
                    "hash": "E74F4CC22263126EDD4A721AD0D0D0A8"
                },
                "320k": {
                    "size": "8.39 MB",
                    "hash": "C6A54074E90BEB59D8B91749AAC4B323"
                },
                "flac": {
                    "size": "24.06 MB",
                    "hash": "661FDC79E23F4B63C060FEBF09AAA432"
                },
                "flac24bit": {
                    "size": "45.15 MB",
                    "hash": "721059193DA324C646CFF5C86E038412"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "刘珂矣",
            "name": "半壶纱",
            "albumName": "半壶纱",
            "albumId": "948327",
            "songmid": 3980631,
            "source": "kg",
            "interval": "03:41",
            "img": "http://imge.kugou.com/stdmusic/400/20210108/20210108122513746401.jpg",
            "lrc": null,
            "hash": "951AB088C5A08F491471A1296DF93707",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.39 MB",
                    "hash": "951AB088C5A08F491471A1296DF93707"
                },
                {
                    "type": "320k",
                    "size": "8.47 MB",
                    "hash": "68E20AA713305B7143D697DCA74CC50C"
                },
                {
                    "type": "flac",
                    "size": "26.01 MB",
                    "hash": "DEA9D00681FA7DB502C862CF0A35456C"
                },
                {
                    "type": "flac24bit",
                    "size": "42.08 MB",
                    "hash": "B74EC9EA2613A04AE814B9C90DE4139B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.39 MB",
                    "hash": "951AB088C5A08F491471A1296DF93707"
                },
                "320k": {
                    "size": "8.47 MB",
                    "hash": "68E20AA713305B7143D697DCA74CC50C"
                },
                "flac": {
                    "size": "26.01 MB",
                    "hash": "DEA9D00681FA7DB502C862CF0A35456C"
                },
                "flac24bit": {
                    "size": "42.08 MB",
                    "hash": "B74EC9EA2613A04AE814B9C90DE4139B"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陈默默",
            "name": "风说",
            "albumName": "风说",
            "albumId": "184291436",
            "songmid": 560763842,
            "source": "kg",
            "interval": "03:16",
            "img": "http://imge.kugou.com/stdmusic/400/20260421/20260421154312639099.jpg",
            "lrc": null,
            "hash": "0B5170DE93324721489451BA976EA11F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.00 MB",
                    "hash": "0B5170DE93324721489451BA976EA11F"
                },
                {
                    "type": "320k",
                    "size": "7.51 MB",
                    "hash": "6B16D67AAA786A1BBF3F4ACE8C35EFFF"
                },
                {
                    "type": "flac",
                    "size": "20.77 MB",
                    "hash": "DB0EDA46BD78D6E152E09D33F90BC25C"
                },
                {
                    "type": "flac24bit",
                    "size": "39.35 MB",
                    "hash": "365D07CD5D6BEFA80054010AD3717580"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.00 MB",
                    "hash": "0B5170DE93324721489451BA976EA11F"
                },
                "320k": {
                    "size": "7.51 MB",
                    "hash": "6B16D67AAA786A1BBF3F4ACE8C35EFFF"
                },
                "flac": {
                    "size": "20.77 MB",
                    "hash": "DB0EDA46BD78D6E152E09D33F90BC25C"
                },
                "flac24bit": {
                    "size": "39.35 MB",
                    "hash": "365D07CD5D6BEFA80054010AD3717580"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "MGD、MXZHPHXNK",
            "name": "Sinos De Natal",
            "albumName": "Sinos De Natal",
            "albumId": "168252092",
            "songmid": 510807736,
            "source": "kg",
            "interval": "02:12",
            "img": "http://imge.kugou.com/stdmusic/400/20251120/20251120235312970252.jpg",
            "lrc": null,
            "hash": "237C8FD6EC0BFC92E2584EF377705E8F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.03 MB",
                    "hash": "237C8FD6EC0BFC92E2584EF377705E8F"
                },
                {
                    "type": "320k",
                    "size": "5.07 MB",
                    "hash": "CBA62458F4E36CDA5D453246EDDA1258"
                },
                {
                    "type": "flac",
                    "size": "13.64 MB",
                    "hash": "3BD6605B19DDE019EE5123B83A01F1C6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.03 MB",
                    "hash": "237C8FD6EC0BFC92E2584EF377705E8F"
                },
                "320k": {
                    "size": "5.07 MB",
                    "hash": "CBA62458F4E36CDA5D453246EDDA1258"
                },
                "flac": {
                    "size": "13.64 MB",
                    "hash": "3BD6605B19DDE019EE5123B83A01F1C6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "林雪儿",
            "name": "我在月光下许过情真 (女版R&B)",
            "albumName": "我在月下许过情真(女版R&B)",
            "albumId": "192996378",
            "songmid": 580434743,
            "source": "kg",
            "interval": "02:56",
            "img": "http://imge.kugou.com/stdmusic/400/20260527/20260527182200332612.jpg",
            "lrc": null,
            "hash": "95E8185C8A4E770E0B5AEA4505F02BEF",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.69 MB",
                    "hash": "95E8185C8A4E770E0B5AEA4505F02BEF"
                },
                {
                    "type": "320k",
                    "size": "6.73 MB",
                    "hash": "F6BC6EFE1EAE438DAA7211BBD45ED095"
                },
                {
                    "type": "flac",
                    "size": "17.58 MB",
                    "hash": "2DCED5B381715B867973545362AD3EAB"
                },
                {
                    "type": "flac24bit",
                    "size": "34.55 MB",
                    "hash": "9308F8CC08F971377015C25D80925BB6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.69 MB",
                    "hash": "95E8185C8A4E770E0B5AEA4505F02BEF"
                },
                "320k": {
                    "size": "6.73 MB",
                    "hash": "F6BC6EFE1EAE438DAA7211BBD45ED095"
                },
                "flac": {
                    "size": "17.58 MB",
                    "hash": "2DCED5B381715B867973545362AD3EAB"
                },
                "flac24bit": {
                    "size": "34.55 MB",
                    "hash": "9308F8CC08F971377015C25D80925BB6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "杨丞琳",
            "name": "雨爱",
            "albumName": "雨爱",
            "albumId": "2694607",
            "songmid": 348980,
            "source": "kg",
            "interval": "04:20",
            "img": "http://imge.kugou.com/stdmusic/400/20250716/20250716140851912935.jpg",
            "lrc": null,
            "hash": "2592FFA57A2D8B1A16F18D991B7098CD",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.98 MB",
                    "hash": "2592FFA57A2D8B1A16F18D991B7098CD"
                },
                {
                    "type": "320k",
                    "size": "9.94 MB",
                    "hash": "E72D5EEC94706BEF1BB6DCA4DE1CF09F"
                },
                {
                    "type": "flac",
                    "size": "32.06 MB",
                    "hash": "F9ED36771CE6A071C2A4C210E4E68F56"
                },
                {
                    "type": "flac24bit",
                    "size": "32.64 MB",
                    "hash": "3E483896EA485A57E390A7717E615486"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.98 MB",
                    "hash": "2592FFA57A2D8B1A16F18D991B7098CD"
                },
                "320k": {
                    "size": "9.94 MB",
                    "hash": "E72D5EEC94706BEF1BB6DCA4DE1CF09F"
                },
                "flac": {
                    "size": "32.06 MB",
                    "hash": "F9ED36771CE6A071C2A4C210E4E68F56"
                },
                "flac24bit": {
                    "size": "32.64 MB",
                    "hash": "3E483896EA485A57E390A7717E615486"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "许果果",
            "name": "伤心太平洋 (烟嗓版)",
            "albumName": "伤心太平洋",
            "albumId": "190022561",
            "songmid": 571027811,
            "source": "kg",
            "interval": "04:34",
            "img": "http://imge.kugou.com/stdmusic/400/20260508/20260508133057346141.jpg",
            "lrc": null,
            "hash": "620B8E5B2C6E4650201F3A86D4F92142",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.20 MB",
                    "hash": "620B8E5B2C6E4650201F3A86D4F92142"
                },
                {
                    "type": "320k",
                    "size": "10.49 MB",
                    "hash": "253C2681842716C145A0FAB0F820B3F5"
                },
                {
                    "type": "flac",
                    "size": "42.40 MB",
                    "hash": "912F29F24941011DE36756F32B67D768"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.20 MB",
                    "hash": "620B8E5B2C6E4650201F3A86D4F92142"
                },
                "320k": {
                    "size": "10.49 MB",
                    "hash": "253C2681842716C145A0FAB0F820B3F5"
                },
                "flac": {
                    "size": "42.40 MB",
                    "hash": "912F29F24941011DE36756F32B67D768"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "弦外之音",
            "name": "我羡慕天边的风",
            "albumName": "我羡慕天边的风",
            "albumId": "195206254",
            "songmid": 600418293,
            "source": "kg",
            "interval": "03:20",
            "img": "http://imge.kugou.com/stdmusic/400/20260612/20260612165146227031.jpg",
            "lrc": null,
            "hash": "F9A6EBD3CCC4A13BCE352066931134F8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.05 MB",
                    "hash": "F9A6EBD3CCC4A13BCE352066931134F8"
                },
                {
                    "type": "320k",
                    "size": "7.63 MB",
                    "hash": "E95EDB3FE84A3662674669AFE7F9D8CC"
                },
                {
                    "type": "flac",
                    "size": "22.63 MB",
                    "hash": "80F189E2CFBD84D51EFA089E192D24A4"
                },
                {
                    "type": "flac24bit",
                    "size": "41.84 MB",
                    "hash": "12CDE0D45917156626E8B743C91C2F32"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.05 MB",
                    "hash": "F9A6EBD3CCC4A13BCE352066931134F8"
                },
                "320k": {
                    "size": "7.63 MB",
                    "hash": "E95EDB3FE84A3662674669AFE7F9D8CC"
                },
                "flac": {
                    "size": "22.63 MB",
                    "hash": "80F189E2CFBD84D51EFA089E192D24A4"
                },
                "flac24bit": {
                    "size": "41.84 MB",
                    "hash": "12CDE0D45917156626E8B743C91C2F32"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁静茹",
            "name": "情歌",
            "albumName": "现在开始我爱你",
            "albumId": "2997268",
            "songmid": 336897,
            "source": "kg",
            "interval": "04:20",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121849111761.jpg",
            "lrc": null,
            "hash": "72DB6DA75FFE23A3A6361BDB8F44D5F4",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.97 MB",
                    "hash": "72DB6DA75FFE23A3A6361BDB8F44D5F4"
                },
                {
                    "type": "320k",
                    "size": "9.92 MB",
                    "hash": "358349A8A03C8B0A7C1DDD1BFC087599"
                },
                {
                    "type": "flac",
                    "size": "28.51 MB",
                    "hash": "12FA760D3FEC0E613BD4256ADDF87C0A"
                },
                {
                    "type": "flac24bit",
                    "size": "29.62 MB",
                    "hash": "37133F33D76174B1E6C9DAA1548D12F9"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.97 MB",
                    "hash": "72DB6DA75FFE23A3A6361BDB8F44D5F4"
                },
                "320k": {
                    "size": "9.92 MB",
                    "hash": "358349A8A03C8B0A7C1DDD1BFC087599"
                },
                "flac": {
                    "size": "28.51 MB",
                    "hash": "12FA760D3FEC0E613BD4256ADDF87C0A"
                },
                "flac24bit": {
                    "size": "29.62 MB",
                    "hash": "37133F33D76174B1E6C9DAA1548D12F9"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王菲",
            "name": "主角",
            "albumName": "主角",
            "albumId": "189702143",
            "songmid": 1105696595,
            "source": "kg",
            "interval": "05:00",
            "img": "http://imge.kugou.com/stdmusic/400/20260506/20260506111442641887.jpg",
            "lrc": null,
            "hash": "5AC9B20840021F9BE51D76C3067BCC26",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.58 MB",
                    "hash": "5AC9B20840021F9BE51D76C3067BCC26"
                },
                {
                    "type": "320k",
                    "size": "11.46 MB",
                    "hash": "9261161165424834D1500645C275442C"
                },
                {
                    "type": "flac",
                    "size": "28.27 MB",
                    "hash": "BFD5CF0F1324F059438EFC6621806C41"
                },
                {
                    "type": "flac24bit",
                    "size": "93.76 MB",
                    "hash": "AA144A728177FA0EDDA437219F0C140E"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.58 MB",
                    "hash": "5AC9B20840021F9BE51D76C3067BCC26"
                },
                "320k": {
                    "size": "11.46 MB",
                    "hash": "9261161165424834D1500645C275442C"
                },
                "flac": {
                    "size": "28.27 MB",
                    "hash": "BFD5CF0F1324F059438EFC6621806C41"
                },
                "flac24bit": {
                    "size": "93.76 MB",
                    "hash": "AA144A728177FA0EDDA437219F0C140E"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "h3R3",
            "name": "来不及爱你",
            "albumName": "来不及爱你",
            "albumId": "76488384",
            "songmid": 267256021,
            "source": "kg",
            "interval": "03:25",
            "img": "http://imge.kugou.com/stdmusic/400/20250318/20250318151044306429.jpg",
            "lrc": null,
            "hash": "E3ED52965CEE83A40D73C5FB1DA7FF62",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.13 MB",
                    "hash": "E3ED52965CEE83A40D73C5FB1DA7FF62"
                },
                {
                    "type": "320k",
                    "size": "7.83 MB",
                    "hash": "8C3A6C5925E112C377FC43973DF18F40"
                },
                {
                    "type": "flac",
                    "size": "21.53 MB",
                    "hash": "C2FB756BD19EC8811E5FD817B0F0F48F"
                },
                {
                    "type": "flac24bit",
                    "size": "38.76 MB",
                    "hash": "E335C972D27DF8D5DD54366C7148DE31"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.13 MB",
                    "hash": "E3ED52965CEE83A40D73C5FB1DA7FF62"
                },
                "320k": {
                    "size": "7.83 MB",
                    "hash": "8C3A6C5925E112C377FC43973DF18F40"
                },
                "flac": {
                    "size": "21.53 MB",
                    "hash": "C2FB756BD19EC8811E5FD817B0F0F48F"
                },
                "flac24bit": {
                    "size": "38.76 MB",
                    "hash": "E335C972D27DF8D5DD54366C7148DE31"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "五月天",
            "name": "后来的我们",
            "albumName": "自传",
            "albumId": "1748942",
            "songmid": 22299058,
            "source": "kg",
            "interval": "05:46",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620080504731678.jpg",
            "lrc": null,
            "hash": "09120C11A5C376EC7D1640098FA70CDC",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "5.29 MB",
                    "hash": "09120C11A5C376EC7D1640098FA70CDC"
                },
                {
                    "type": "320k",
                    "size": "13.21 MB",
                    "hash": "EF0331E32BC133A67EAB16D710965E21"
                },
                {
                    "type": "flac",
                    "size": "41.00 MB",
                    "hash": "90A14E20BAB062926C5645BB51A72599"
                },
                {
                    "type": "flac24bit",
                    "size": "72.72 MB",
                    "hash": "B322FFE5A4DA621036A9B5CC1B07B7AC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "5.29 MB",
                    "hash": "09120C11A5C376EC7D1640098FA70CDC"
                },
                "320k": {
                    "size": "13.21 MB",
                    "hash": "EF0331E32BC133A67EAB16D710965E21"
                },
                "flac": {
                    "size": "41.00 MB",
                    "hash": "90A14E20BAB062926C5645BB51A72599"
                },
                "flac24bit": {
                    "size": "72.72 MB",
                    "hash": "B322FFE5A4DA621036A9B5CC1B07B7AC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "萧亚轩",
            "name": "表白",
            "albumName": "1087",
            "albumId": "18052287",
            "songmid": 218195,
            "source": "kg",
            "interval": "03:29",
            "img": "http://imge.kugou.com/stdmusic/400/20241206/20241206175503873783.jpg",
            "lrc": null,
            "hash": "0521A7354DF37C1C9705A3E3FD204B95",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.20 MB",
                    "hash": "0521A7354DF37C1C9705A3E3FD204B95"
                },
                {
                    "type": "320k",
                    "size": "7.99 MB",
                    "hash": "3856ABBDC32525F2EE8F11C6952FEEA0"
                },
                {
                    "type": "flac",
                    "size": "26.34 MB",
                    "hash": "ED76257B3336DDF8EA0DE1681AB79336"
                },
                {
                    "type": "flac24bit",
                    "size": "26.61 MB",
                    "hash": "D7CB1A162F792FF75741998164444064"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.20 MB",
                    "hash": "0521A7354DF37C1C9705A3E3FD204B95"
                },
                "320k": {
                    "size": "7.99 MB",
                    "hash": "3856ABBDC32525F2EE8F11C6952FEEA0"
                },
                "flac": {
                    "size": "26.34 MB",
                    "hash": "ED76257B3336DDF8EA0DE1681AB79336"
                },
                "flac24bit": {
                    "size": "26.61 MB",
                    "hash": "D7CB1A162F792FF75741998164444064"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "潘广益",
            "name": "好想再爱你",
            "albumName": "好想再爱你",
            "albumId": "957659",
            "songmid": 1049449437,
            "source": "kg",
            "interval": "04:30",
            "img": "http://imge.kugou.com/stdmusic/400/20250207/20250207161344106383.jpg",
            "lrc": null,
            "hash": "B78BA4062528E712B68C42DC6A4D9AAE",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.14 MB",
                    "hash": "B78BA4062528E712B68C42DC6A4D9AAE"
                },
                {
                    "type": "320k",
                    "size": "10.34 MB",
                    "hash": "91C9D34E39EEB5169545D226A775658F"
                },
                {
                    "type": "flac",
                    "size": "24.38 MB",
                    "hash": "4F9E7D5ED302D9D3E1A6CCC64BA388F3"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.14 MB",
                    "hash": "B78BA4062528E712B68C42DC6A4D9AAE"
                },
                "320k": {
                    "size": "10.34 MB",
                    "hash": "91C9D34E39EEB5169545D226A775658F"
                },
                "flac": {
                    "size": "24.38 MB",
                    "hash": "4F9E7D5ED302D9D3E1A6CCC64BA388F3"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "落日微醺",
            "name": "往事如烟 (R&B版)",
            "albumName": "往事如烟(R&B版)",
            "albumId": "194290753",
            "songmid": 590320944,
            "source": "kg",
            "interval": "04:34",
            "img": "http://imge.kugou.com/stdmusic/400/20260607/20260607222755363737.jpg",
            "lrc": null,
            "hash": "C4148CDAE0A57131607D096740BE08B3",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.20 MB",
                    "hash": "C4148CDAE0A57131607D096740BE08B3"
                },
                {
                    "type": "320k",
                    "size": "10.49 MB",
                    "hash": "04667A104591A282BA9346533F32DC61"
                },
                {
                    "type": "flac",
                    "size": "29.81 MB",
                    "hash": "7232940407945876096C834D759E46CF"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.20 MB",
                    "hash": "C4148CDAE0A57131607D096740BE08B3"
                },
                "320k": {
                    "size": "10.49 MB",
                    "hash": "04667A104591A282BA9346533F32DC61"
                },
                "flac": {
                    "size": "29.81 MB",
                    "hash": "7232940407945876096C834D759E46CF"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "六哲、贺敬轩",
            "name": "让全世界知道我爱你",
            "albumName": "让全世界知道我爱你",
            "albumId": "2638080",
            "songmid": 25276321,
            "source": "kg",
            "interval": "04:20",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620104412853275.jpg",
            "lrc": null,
            "hash": "2E8DAC292DC7DEF06AECED7A34FA9A07",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.98 MB",
                    "hash": "2E8DAC292DC7DEF06AECED7A34FA9A07"
                },
                {
                    "type": "320k",
                    "size": "9.94 MB",
                    "hash": "713AF17C56EDA09FA8FE4F55D27AF204"
                },
                {
                    "type": "flac",
                    "size": "28.40 MB",
                    "hash": "D19A5AA8B623527C266690FEC006DD68"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.98 MB",
                    "hash": "2E8DAC292DC7DEF06AECED7A34FA9A07"
                },
                "320k": {
                    "size": "9.94 MB",
                    "hash": "713AF17C56EDA09FA8FE4F55D27AF204"
                },
                "flac": {
                    "size": "28.40 MB",
                    "hash": "D19A5AA8B623527C266690FEC006DD68"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "陈奕迅",
            "name": "最佳损友",
            "albumName": "《最佳损友》粤语版",
            "albumId": "964332",
            "songmid": 1082844625,
            "source": "kg",
            "interval": "03:53",
            "img": "http://imge.kugou.com/stdmusic/400/20241206/20241206175512148035.jpg",
            "lrc": null,
            "hash": "CBFA7DDE592B23322E21E4BDAA9BE9F9",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.56 MB",
                    "hash": "CBFA7DDE592B23322E21E4BDAA9BE9F9"
                },
                {
                    "type": "320k",
                    "size": "8.91 MB",
                    "hash": "B1FE6CAC1E88080766A01CAD021DA367"
                },
                {
                    "type": "flac",
                    "size": "23.83 MB",
                    "hash": "148BF355ED2AE02BB8E09BDD0429A13B"
                },
                {
                    "type": "flac24bit",
                    "size": "39.69 MB",
                    "hash": "DFCC71E87A73DFE3264B5380C13554FC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.56 MB",
                    "hash": "CBFA7DDE592B23322E21E4BDAA9BE9F9"
                },
                "320k": {
                    "size": "8.91 MB",
                    "hash": "B1FE6CAC1E88080766A01CAD021DA367"
                },
                "flac": {
                    "size": "23.83 MB",
                    "hash": "148BF355ED2AE02BB8E09BDD0429A13B"
                },
                "flac24bit": {
                    "size": "39.69 MB",
                    "hash": "DFCC71E87A73DFE3264B5380C13554FC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "阿肆",
            "name": "喜欢",
            "albumName": "喜欢",
            "albumId": "14167090",
            "songmid": 36420406,
            "source": "kg",
            "interval": "04:10",
            "img": "http://imge.kugou.com/stdmusic/400/20260528/20260528052742961876.jpg",
            "lrc": null,
            "hash": "F4233033E11BEF5AECD3BD64528A8236",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.82 MB",
                    "hash": "F4233033E11BEF5AECD3BD64528A8236"
                },
                {
                    "type": "320k",
                    "size": "9.55 MB",
                    "hash": "321B7E6BB909C8C1A3D425A71B605365"
                },
                {
                    "type": "flac",
                    "size": "30.29 MB",
                    "hash": "E84DB58BCEBE38D1D5635A689F539C41"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.82 MB",
                    "hash": "F4233033E11BEF5AECD3BD64528A8236"
                },
                "320k": {
                    "size": "9.55 MB",
                    "hash": "321B7E6BB909C8C1A3D425A71B605365"
                },
                "flac": {
                    "size": "30.29 MB",
                    "hash": "E84DB58BCEBE38D1D5635A689F539C41"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "郭静",
            "name": "心墙",
            "albumName": "在树上唱歌",
            "albumId": "968033",
            "songmid": 245126,
            "source": "kg",
            "interval": "03:47",
            "img": "http://imge.kugou.com/stdmusic/400/20250227/20250227150402830819.jpg",
            "lrc": null,
            "hash": "97870F3D4B01A7822DC497C6127EA66D",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.47 MB",
                    "hash": "97870F3D4B01A7822DC497C6127EA66D"
                },
                {
                    "type": "320k",
                    "size": "8.66 MB",
                    "hash": "5998440148A59A2046969AA7BBDE6F87"
                },
                {
                    "type": "flac",
                    "size": "25.02 MB",
                    "hash": "F67F4A7D95C649B7533DA61743EEEEA8"
                },
                {
                    "type": "flac24bit",
                    "size": "26.70 MB",
                    "hash": "9FCE11731CC205973CB9C4BD251F1B2D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.47 MB",
                    "hash": "97870F3D4B01A7822DC497C6127EA66D"
                },
                "320k": {
                    "size": "8.66 MB",
                    "hash": "5998440148A59A2046969AA7BBDE6F87"
                },
                "flac": {
                    "size": "25.02 MB",
                    "hash": "F67F4A7D95C649B7533DA61743EEEEA8"
                },
                "flac24bit": {
                    "size": "26.70 MB",
                    "hash": "9FCE11731CC205973CB9C4BD251F1B2D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "阿肆、郭采洁",
            "name": "世界上的另一个我",
            "albumName": "世界上的另一个我",
            "albumId": "4255765",
            "songmid": 29393917,
            "source": "kg",
            "interval": "03:58",
            "img": "http://imge.kugou.com/stdmusic/400/20220921/20220921060604118055.jpg",
            "lrc": null,
            "hash": "73C0E5566146583A631C9A94203405D6",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.63 MB",
                    "hash": "73C0E5566146583A631C9A94203405D6"
                },
                {
                    "type": "320k",
                    "size": "9.08 MB",
                    "hash": "7C7FBED10A80E8B34B3E548FDC48DA74"
                },
                {
                    "type": "flac",
                    "size": "27.87 MB",
                    "hash": "35EC6A9F9180BF269FC4E969D89EAB61"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.63 MB",
                    "hash": "73C0E5566146583A631C9A94203405D6"
                },
                "320k": {
                    "size": "9.08 MB",
                    "hash": "7C7FBED10A80E8B34B3E548FDC48DA74"
                },
                "flac": {
                    "size": "27.87 MB",
                    "hash": "35EC6A9F9180BF269FC4E969D89EAB61"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "薛之谦",
            "name": "认真的雪",
            "albumName": "薛之谦",
            "albumId": "2689239",
            "songmid": 299190,
            "source": "kg",
            "interval": "04:19",
            "img": "http://imge.kugou.com/stdmusic/400/20241205/20241205201419764427.jpg",
            "lrc": null,
            "hash": "D2E00CC158DB4DA18927AC3B01CC371B",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.95 MB",
                    "hash": "D2E00CC158DB4DA18927AC3B01CC371B"
                },
                {
                    "type": "320k",
                    "size": "9.88 MB",
                    "hash": "40803B03B4E47B2B3011C120DE443056"
                },
                {
                    "type": "flac",
                    "size": "25.53 MB",
                    "hash": "4111E70D3C92738EC07CCB272B69F225"
                },
                {
                    "type": "flac24bit",
                    "size": "47.01 MB",
                    "hash": "F12ABBC3A0D4B6AF09CCD0BD7C8D3960"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.95 MB",
                    "hash": "D2E00CC158DB4DA18927AC3B01CC371B"
                },
                "320k": {
                    "size": "9.88 MB",
                    "hash": "40803B03B4E47B2B3011C120DE443056"
                },
                "flac": {
                    "size": "25.53 MB",
                    "hash": "4111E70D3C92738EC07CCB272B69F225"
                },
                "flac24bit": {
                    "size": "47.01 MB",
                    "hash": "F12ABBC3A0D4B6AF09CCD0BD7C8D3960"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "光良",
            "name": "第一次",
            "albumName": "十光年",
            "albumId": "930387",
            "songmid": 301369096,
            "source": "kg",
            "interval": "04:23",
            "img": "http://imge.kugou.com/stdmusic/400/20231027/20231027105002301032.jpg",
            "lrc": null,
            "hash": "872C58BF22F873F1F36CDA2500E58EC9",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.02 MB",
                    "hash": "872C58BF22F873F1F36CDA2500E58EC9"
                },
                {
                    "type": "320k",
                    "size": "10.05 MB",
                    "hash": "870F96C4F6B65BE4E95BE9BA0D71F8C3"
                },
                {
                    "type": "flac",
                    "size": "25.57 MB",
                    "hash": "E9C446669EDD6F8BADDD31EEF081915C"
                },
                {
                    "type": "flac24bit",
                    "size": "26.48 MB",
                    "hash": "6922219F601175165A680720933D8FFC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.02 MB",
                    "hash": "872C58BF22F873F1F36CDA2500E58EC9"
                },
                "320k": {
                    "size": "10.05 MB",
                    "hash": "870F96C4F6B65BE4E95BE9BA0D71F8C3"
                },
                "flac": {
                    "size": "25.57 MB",
                    "hash": "E9C446669EDD6F8BADDD31EEF081915C"
                },
                "flac24bit": {
                    "size": "26.48 MB",
                    "hash": "6922219F601175165A680720933D8FFC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "宋雨琦 (YUQI)",
            "name": "Radio (Dum-Dum)",
            "albumName": "Radio (Dum-Dum)",
            "albumId": "140913986",
            "songmid": 444923011,
            "source": "kg",
            "interval": "02:32",
            "img": "http://imge.kugou.com/stdmusic/400/20250314/20250314182742315632.jpg",
            "lrc": null,
            "hash": "E8FFC3F649DA4476E2CEABFF3F94D103",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.33 MB",
                    "hash": "E8FFC3F649DA4476E2CEABFF3F94D103"
                },
                {
                    "type": "320k",
                    "size": "5.82 MB",
                    "hash": "BBCF7B38076ADD71B72C1736CD07AB39"
                },
                {
                    "type": "flac",
                    "size": "18.59 MB",
                    "hash": "0D53DF2A96866E7FF2553C65748EF69D"
                },
                {
                    "type": "flac24bit",
                    "size": "55.17 MB",
                    "hash": "0E2E7AA9B16021D20735658657988558"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.33 MB",
                    "hash": "E8FFC3F649DA4476E2CEABFF3F94D103"
                },
                "320k": {
                    "size": "5.82 MB",
                    "hash": "BBCF7B38076ADD71B72C1736CD07AB39"
                },
                "flac": {
                    "size": "18.59 MB",
                    "hash": "0D53DF2A96866E7FF2553C65748EF69D"
                },
                "flac24bit": {
                    "size": "55.17 MB",
                    "hash": "0E2E7AA9B16021D20735658657988558"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "卡带森林",
            "name": "我把心事说给风",
            "albumName": "我把心事说给风",
            "albumId": "191850028",
            "songmid": 576809444,
            "source": "kg",
            "interval": "03:15",
            "img": "http://imge.kugou.com/stdmusic/400/20260618/20260618172557466228.png",
            "lrc": null,
            "hash": "93A399B60016E5131A7675EBB4835FF0",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.98 MB",
                    "hash": "93A399B60016E5131A7675EBB4835FF0"
                },
                {
                    "type": "320k",
                    "size": "7.45 MB",
                    "hash": "1C64E25F292ADEFE80994BC7A20249FC"
                },
                {
                    "type": "flac",
                    "size": "22.92 MB",
                    "hash": "DB089D6D9D005B55AC724404A4AE09F3"
                },
                {
                    "type": "flac24bit",
                    "size": "42.04 MB",
                    "hash": "C1727AD63FA587590D48F423A5BBE73A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.98 MB",
                    "hash": "93A399B60016E5131A7675EBB4835FF0"
                },
                "320k": {
                    "size": "7.45 MB",
                    "hash": "1C64E25F292ADEFE80994BC7A20249FC"
                },
                "flac": {
                    "size": "22.92 MB",
                    "hash": "DB089D6D9D005B55AC724404A4AE09F3"
                },
                "flac24bit": {
                    "size": "42.04 MB",
                    "hash": "C1727AD63FA587590D48F423A5BBE73A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王一佳",
            "name": "沙漠开不出玫瑰花",
            "albumName": "沙漠开不出玫瑰花",
            "albumId": "183014106",
            "songmid": 557166562,
            "source": "kg",
            "interval": "03:04",
            "img": "http://imge.kugou.com/stdmusic/400/20260515/20260515153157821661.jpg",
            "lrc": null,
            "hash": "4B7E6524801BED3951C2CEFD81A5A959",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.82 MB",
                    "hash": "4B7E6524801BED3951C2CEFD81A5A959"
                },
                {
                    "type": "320k",
                    "size": "7.04 MB",
                    "hash": "F49251C6C42960EAFFF83CE37280D79C"
                },
                {
                    "type": "flac",
                    "size": "19.82 MB",
                    "hash": "D778B8222DA7874AD73CE8AED6BACEE4"
                },
                {
                    "type": "flac24bit",
                    "size": "37.58 MB",
                    "hash": "7FA78C0E42AEE809184F3D3A75AFB0CD"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.82 MB",
                    "hash": "4B7E6524801BED3951C2CEFD81A5A959"
                },
                "320k": {
                    "size": "7.04 MB",
                    "hash": "F49251C6C42960EAFFF83CE37280D79C"
                },
                "flac": {
                    "size": "19.82 MB",
                    "hash": "D778B8222DA7874AD73CE8AED6BACEE4"
                },
                "flac24bit": {
                    "size": "37.58 MB",
                    "hash": "7FA78C0E42AEE809184F3D3A75AFB0CD"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "汪苏泷、徐良",
            "name": "后会无期",
            "albumName": "不良少年",
            "albumId": "511536",
            "songmid": 348311,
            "source": "kg",
            "interval": "03:31",
            "img": "http://imge.kugou.com/stdmusic/400/20200620/20200620074915201495.jpg",
            "lrc": null,
            "hash": "23E848E785DBCB9A2B1416E4DB068D8E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.23 MB",
                    "hash": "23E848E785DBCB9A2B1416E4DB068D8E"
                },
                {
                    "type": "320k",
                    "size": "8.08 MB",
                    "hash": "16BADEB7BB2739066A6A839F9F34449F"
                },
                {
                    "type": "flac",
                    "size": "21.67 MB",
                    "hash": "584B131F9921BD6597EDF28ED6F70409"
                },
                {
                    "type": "flac24bit",
                    "size": "22.24 MB",
                    "hash": "F69AF2B5B53F990CC3C9E5750F653F0C"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.23 MB",
                    "hash": "23E848E785DBCB9A2B1416E4DB068D8E"
                },
                "320k": {
                    "size": "8.08 MB",
                    "hash": "16BADEB7BB2739066A6A839F9F34449F"
                },
                "flac": {
                    "size": "21.67 MB",
                    "hash": "584B131F9921BD6597EDF28ED6F70409"
                },
                "flac24bit": {
                    "size": "22.24 MB",
                    "hash": "F69AF2B5B53F990CC3C9E5750F653F0C"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "落日微醺",
            "name": "一千零一夜 (R&B版)",
            "albumName": "一千零一夜（R&B版）",
            "albumId": "191525119",
            "songmid": 575757160,
            "source": "kg",
            "interval": "04:04",
            "img": "http://imge.kugou.com/stdmusic/400/20260518/20260518140126851220.jpg",
            "lrc": null,
            "hash": "3788E51B85C92FA2B8D69C889270011E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.72 MB",
                    "hash": "3788E51B85C92FA2B8D69C889270011E"
                },
                {
                    "type": "320k",
                    "size": "9.31 MB",
                    "hash": "127D91A692ABA261565F291BB4893F31"
                },
                {
                    "type": "flac",
                    "size": "25.12 MB",
                    "hash": "506E4DFD898303A4C59774703EBD2C3A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.72 MB",
                    "hash": "3788E51B85C92FA2B8D69C889270011E"
                },
                "320k": {
                    "size": "9.31 MB",
                    "hash": "127D91A692ABA261565F291BB4893F31"
                },
                "flac": {
                    "size": "25.12 MB",
                    "hash": "506E4DFD898303A4C59774703EBD2C3A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王睿卓、加木",
            "name": "茶花开了，该回家了",
            "albumName": "茶花开了，该回家了",
            "albumId": "133732298",
            "songmid": 426362743,
            "source": "kg",
            "interval": "03:09",
            "img": "http://imge.kugou.com/stdmusic/400/20260305/20260305152445620499.jpg",
            "lrc": null,
            "hash": "99F0F17B7C6F110346411E7AD552156D",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.90 MB",
                    "hash": "99F0F17B7C6F110346411E7AD552156D"
                },
                {
                    "type": "320k",
                    "size": "7.24 MB",
                    "hash": "AF9284AD4384624848DE787D48501A18"
                },
                {
                    "type": "flac",
                    "size": "20.11 MB",
                    "hash": "17E8155EC0799EEF1B72E18CC8890A1F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.90 MB",
                    "hash": "99F0F17B7C6F110346411E7AD552156D"
                },
                "320k": {
                    "size": "7.24 MB",
                    "hash": "AF9284AD4384624848DE787D48501A18"
                },
                "flac": {
                    "size": "20.11 MB",
                    "hash": "17E8155EC0799EEF1B72E18CC8890A1F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "徐良",
            "name": "那时雨",
            "albumName": "那时雨",
            "albumId": "16900987",
            "songmid": 594124,
            "source": "kg",
            "interval": "03:34",
            "img": "http://imge.kugou.com/stdmusic/400/20190313/20190313172302870218.jpg",
            "lrc": null,
            "hash": "CE76C60251F6193BC5BBA5B46B977747",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.27 MB",
                    "hash": "CE76C60251F6193BC5BBA5B46B977747"
                },
                {
                    "type": "320k",
                    "size": "8.18 MB",
                    "hash": "5080046CA4AB02D4CE1AA426E8E672AE"
                },
                {
                    "type": "flac",
                    "size": "24.64 MB",
                    "hash": "0AC1CFCBFFDD7920166706B0F72431B0"
                },
                {
                    "type": "flac24bit",
                    "size": "25.25 MB",
                    "hash": "E5FDEA84405E14DFDCB4F1D5A91A52BA"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.27 MB",
                    "hash": "CE76C60251F6193BC5BBA5B46B977747"
                },
                "320k": {
                    "size": "8.18 MB",
                    "hash": "5080046CA4AB02D4CE1AA426E8E672AE"
                },
                "flac": {
                    "size": "24.64 MB",
                    "hash": "0AC1CFCBFFDD7920166706B0F72431B0"
                },
                "flac24bit": {
                    "size": "25.25 MB",
                    "hash": "E5FDEA84405E14DFDCB4F1D5A91A52BA"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "阿麦姑娘",
            "name": "叹我",
            "albumName": "叹我",
            "albumId": "190806182",
            "songmid": 573242377,
            "source": "kg",
            "interval": "03:33",
            "img": "http://imge.kugou.com/stdmusic/400/20260513/20260513120118978328.jpg",
            "lrc": null,
            "hash": "93ECCCA40680D1798CADBB1EEFA019A6",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.26 MB",
                    "hash": "93ECCCA40680D1798CADBB1EEFA019A6"
                },
                {
                    "type": "320k",
                    "size": "8.15 MB",
                    "hash": "5D3D33EDD19BEC6C311C1153C7AC3D9A"
                },
                {
                    "type": "flac",
                    "size": "23.08 MB",
                    "hash": "55159B755ABBB8A3452B1FD934BA76AC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.26 MB",
                    "hash": "93ECCCA40680D1798CADBB1EEFA019A6"
                },
                "320k": {
                    "size": "8.15 MB",
                    "hash": "5D3D33EDD19BEC6C311C1153C7AC3D9A"
                },
                "flac": {
                    "size": "23.08 MB",
                    "hash": "55159B755ABBB8A3452B1FD934BA76AC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Bobo博official",
            "name": "不要在我寂寞的时候说爱我 (funky版)",
            "albumName": "不要在我寂寞的时候说爱我 (funky版)",
            "albumId": "180788163",
            "songmid": 550937539,
            "source": "kg",
            "interval": "02:24",
            "img": "http://imge.kugou.com/stdmusic/400/20260519/20260519101118620030.jpg",
            "lrc": null,
            "hash": "5E043A1E610CC92EC4D10816861667F8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.21 MB",
                    "hash": "5E043A1E610CC92EC4D10816861667F8"
                },
                {
                    "type": "320k",
                    "size": "5.53 MB",
                    "hash": "68C2774863D1B65BDF3C1B33ACAB38A3"
                },
                {
                    "type": "flac",
                    "size": "18.12 MB",
                    "hash": "B0DD4987216BFB3E7C31C74B093FB4C2"
                },
                {
                    "type": "flac24bit",
                    "size": "32.35 MB",
                    "hash": "C5DEDF656BA7531E800F9809949519DD"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.21 MB",
                    "hash": "5E043A1E610CC92EC4D10816861667F8"
                },
                "320k": {
                    "size": "5.53 MB",
                    "hash": "68C2774863D1B65BDF3C1B33ACAB38A3"
                },
                "flac": {
                    "size": "18.12 MB",
                    "hash": "B0DD4987216BFB3E7C31C74B093FB4C2"
                },
                "flac24bit": {
                    "size": "32.35 MB",
                    "hash": "C5DEDF656BA7531E800F9809949519DD"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "寂寞阿图",
            "name": "你有没有真的爱过我 (烟嗓版)",
            "albumName": "你有没有真的爱过我",
            "albumId": "190169654",
            "songmid": 571483075,
            "source": "kg",
            "interval": "03:45",
            "img": "http://imge.kugou.com/stdmusic/400/20260509/20260509161121607077.jpg",
            "lrc": null,
            "hash": "5EF8404977086AB95C304D857271FB10",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.45 MB",
                    "hash": "5EF8404977086AB95C304D857271FB10"
                },
                {
                    "type": "320k",
                    "size": "8.61 MB",
                    "hash": "D84897CA5BECE519C6C716B2DC559E4E"
                },
                {
                    "type": "flac",
                    "size": "25.56 MB",
                    "hash": "4B4AB589A94E3178335311CDFD2253C2"
                },
                {
                    "type": "flac24bit",
                    "size": "47.37 MB",
                    "hash": "F8376C833554CC1A346785E15F48364E"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.45 MB",
                    "hash": "5EF8404977086AB95C304D857271FB10"
                },
                "320k": {
                    "size": "8.61 MB",
                    "hash": "D84897CA5BECE519C6C716B2DC559E4E"
                },
                "flac": {
                    "size": "25.56 MB",
                    "hash": "4B4AB589A94E3178335311CDFD2253C2"
                },
                "flac24bit": {
                    "size": "47.37 MB",
                    "hash": "F8376C833554CC1A346785E15F48364E"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "z阿康",
            "name": "我很想见见你",
            "albumName": "我很想见见你",
            "albumId": "194056203",
            "songmid": 588015703,
            "source": "kg",
            "interval": "03:40",
            "img": "http://imge.kugou.com/stdmusic/400/20260603/20260603204121656434.jpg",
            "lrc": null,
            "hash": "4D812ED2C0E7AA61F60097327399816C",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.37 MB",
                    "hash": "4D812ED2C0E7AA61F60097327399816C"
                },
                {
                    "type": "320k",
                    "size": "8.41 MB",
                    "hash": "A24677E9E95CFA6A7A17B629A08EDAE1"
                },
                {
                    "type": "flac",
                    "size": "24.22 MB",
                    "hash": "E36335954396DD524BBE6318CD06C222"
                },
                {
                    "type": "flac24bit",
                    "size": "45.72 MB",
                    "hash": "84A07784894E8AB826BF06D1C6AD4056"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.37 MB",
                    "hash": "4D812ED2C0E7AA61F60097327399816C"
                },
                "320k": {
                    "size": "8.41 MB",
                    "hash": "A24677E9E95CFA6A7A17B629A08EDAE1"
                },
                "flac": {
                    "size": "24.22 MB",
                    "hash": "E36335954396DD524BBE6318CD06C222"
                },
                "flac24bit": {
                    "size": "45.72 MB",
                    "hash": "84A07784894E8AB826BF06D1C6AD4056"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "筷子兄弟",
            "name": "父亲",
            "albumName": "父亲",
            "albumId": "17165001",
            "songmid": 147237,
            "source": "kg",
            "interval": "04:40",
            "img": "http://imge.kugou.com/stdmusic/400/20170727/20170727104528236550.jpg",
            "lrc": null,
            "hash": "1ECF6D4B2C6FC915D99B768C0D7CE77E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.28 MB",
                    "hash": "1ECF6D4B2C6FC915D99B768C0D7CE77E"
                },
                {
                    "type": "320k",
                    "size": "10.69 MB",
                    "hash": "FAD6F0CA237C8EE8D0971494240D8C6C"
                },
                {
                    "type": "flac",
                    "size": "31.33 MB",
                    "hash": "E8805543D8B8D66B95567B1D682674BD"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.28 MB",
                    "hash": "1ECF6D4B2C6FC915D99B768C0D7CE77E"
                },
                "320k": {
                    "size": "10.69 MB",
                    "hash": "FAD6F0CA237C8EE8D0971494240D8C6C"
                },
                "flac": {
                    "size": "31.33 MB",
                    "hash": "E8805543D8B8D66B95567B1D682674BD"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Justin Bieber、Nicki Minaj",
            "name": "Beauty And A Beat",
            "albumName": "美和节奏",
            "albumId": "16996733",
            "songmid": 514198,
            "source": "kg",
            "interval": "03:47",
            "img": "http://imge.kugou.com/stdmusic/400/20241203/20241203151654261938.jpg",
            "lrc": null,
            "hash": "FF5719341A9B004AA3E7312D617AE305",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.48 MB",
                    "hash": "FF5719341A9B004AA3E7312D617AE305"
                },
                {
                    "type": "320k",
                    "size": "8.70 MB",
                    "hash": "E03626541DBC97B7AFA5C51FB830E9D2"
                },
                {
                    "type": "flac",
                    "size": "29.12 MB",
                    "hash": "3BD04A3FF77871FEB3FBC7D24589FDA8"
                },
                {
                    "type": "flac24bit",
                    "size": "30.23 MB",
                    "hash": "EF01ED9F36D7B452A32032AA286A66A5"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.48 MB",
                    "hash": "FF5719341A9B004AA3E7312D617AE305"
                },
                "320k": {
                    "size": "8.70 MB",
                    "hash": "E03626541DBC97B7AFA5C51FB830E9D2"
                },
                "flac": {
                    "size": "29.12 MB",
                    "hash": "3BD04A3FF77871FEB3FBC7D24589FDA8"
                },
                "flac24bit": {
                    "size": "30.23 MB",
                    "hash": "EF01ED9F36D7B452A32032AA286A66A5"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "老韩很哇塞",
            "name": "人间的剧本",
            "albumName": "人间的剧本",
            "albumId": "195240853",
            "songmid": 600520466,
            "source": "kg",
            "interval": "03:18",
            "img": "http://imge.kugou.com/stdmusic/400/20260612/20260612212310834842.jpg",
            "lrc": null,
            "hash": "F80698DAC679080F9E38F3DBB07BD17A",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.02 MB",
                    "hash": "F80698DAC679080F9E38F3DBB07BD17A"
                },
                {
                    "type": "320k",
                    "size": "7.56 MB",
                    "hash": "FB1E11C7FF4707E39BCE5E2E47307255"
                },
                {
                    "type": "flac",
                    "size": "22.83 MB",
                    "hash": "0C8CEBB4B58D8C2409531FFCB4BF28E1"
                },
                {
                    "type": "flac24bit",
                    "size": "42.16 MB",
                    "hash": "4E859F4A50B27A36FE92AF8196AACD68"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.02 MB",
                    "hash": "F80698DAC679080F9E38F3DBB07BD17A"
                },
                "320k": {
                    "size": "7.56 MB",
                    "hash": "FB1E11C7FF4707E39BCE5E2E47307255"
                },
                "flac": {
                    "size": "22.83 MB",
                    "hash": "0C8CEBB4B58D8C2409531FFCB4BF28E1"
                },
                "flac24bit": {
                    "size": "42.16 MB",
                    "hash": "4E859F4A50B27A36FE92AF8196AACD68"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "郭顶",
            "name": "我们俩",
            "albumName": "微微",
            "albumId": "979601",
            "songmid": 55683,
            "source": "kg",
            "interval": "03:13",
            "img": "http://imge.kugou.com/stdmusic/400/20241029/20241029161103543086.jpg",
            "lrc": null,
            "hash": "DD4D224BC3DBFD1A0F6E338928620E69",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "2.96 MB",
                    "hash": "DD4D224BC3DBFD1A0F6E338928620E69"
                },
                {
                    "type": "320k",
                    "size": "7.39 MB",
                    "hash": "8A2ABF4FD6FA569BC5EFDC44FDDA5A85"
                },
                {
                    "type": "flac",
                    "size": "20.43 MB",
                    "hash": "6834247646814057EF7EA74B2454B127"
                }
            ],
            "_types": {
                "128k": {
                    "size": "2.96 MB",
                    "hash": "DD4D224BC3DBFD1A0F6E338928620E69"
                },
                "320k": {
                    "size": "7.39 MB",
                    "hash": "8A2ABF4FD6FA569BC5EFDC44FDDA5A85"
                },
                "flac": {
                    "size": "20.43 MB",
                    "hash": "6834247646814057EF7EA74B2454B127"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "礼越",
            "name": "静音恋人 (两颗缠绕的心)",
            "albumName": "静音恋人",
            "albumId": "183361126",
            "songmid": 558173720,
            "source": "kg",
            "interval": "03:26",
            "img": "http://imge.kugou.com/stdmusic/400/20260415/20260415181650219331.jpg",
            "lrc": null,
            "hash": "61F7ABEFA41C847C8F237C68883027CA",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.15 MB",
                    "hash": "61F7ABEFA41C847C8F237C68883027CA"
                },
                {
                    "type": "320k",
                    "size": "7.89 MB",
                    "hash": "C7DFE5718E1C6B1001AB2D5CC13BE235"
                },
                {
                    "type": "flac",
                    "size": "23.19 MB",
                    "hash": "2D9DA85A3F42F5F88F102210CE35E7CE"
                },
                {
                    "type": "flac24bit",
                    "size": "43.23 MB",
                    "hash": "D1D74120B64BE898785F3976847C06C1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.15 MB",
                    "hash": "61F7ABEFA41C847C8F237C68883027CA"
                },
                "320k": {
                    "size": "7.89 MB",
                    "hash": "C7DFE5718E1C6B1001AB2D5CC13BE235"
                },
                "flac": {
                    "size": "23.19 MB",
                    "hash": "2D9DA85A3F42F5F88F102210CE35E7CE"
                },
                "flac24bit": {
                    "size": "43.23 MB",
                    "hash": "D1D74120B64BE898785F3976847C06C1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "井迪儿",
            "name": "失控",
            "albumName": "失控",
            "albumId": "40221609",
            "songmid": 86863601,
            "source": "kg",
            "interval": "04:15",
            "img": "http://imge.kugou.com/stdmusic/400/20210106/20210106110202982955.jpg",
            "lrc": null,
            "hash": "44FE8C442EB1F254D15717F1DC03C9BF",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.89 MB",
                    "hash": "44FE8C442EB1F254D15717F1DC03C9BF"
                },
                {
                    "type": "320k",
                    "size": "9.73 MB",
                    "hash": "AB60142AC04907B7CBE9FC3DD8143752"
                },
                {
                    "type": "flac",
                    "size": "29.04 MB",
                    "hash": "68FCAE1C172ED1F54773F317F6090287"
                },
                {
                    "type": "flac24bit",
                    "size": "29.90 MB",
                    "hash": "8891F81D0FBE6D8C919E3C8589C4953F"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.89 MB",
                    "hash": "44FE8C442EB1F254D15717F1DC03C9BF"
                },
                "320k": {
                    "size": "9.73 MB",
                    "hash": "AB60142AC04907B7CBE9FC3DD8143752"
                },
                "flac": {
                    "size": "29.04 MB",
                    "hash": "68FCAE1C172ED1F54773F317F6090287"
                },
                "flac24bit": {
                    "size": "29.90 MB",
                    "hash": "8891F81D0FBE6D8C919E3C8589C4953F"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "颜人中",
            "name": "有些",
            "albumName": "失眠症候群",
            "albumId": "34604592",
            "songmid": 64515272,
            "source": "kg",
            "interval": "03:49",
            "img": "http://imge.kugou.com/stdmusic/400/20251217/20251217184452437401.jpg",
            "lrc": null,
            "hash": "D79E556C176AE1A3ADE8B532810C4CE8",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.50 MB",
                    "hash": "D79E556C176AE1A3ADE8B532810C4CE8"
                },
                {
                    "type": "320k",
                    "size": "8.76 MB",
                    "hash": "BCC5B2A148814D6D9D5D1671CEEF6C0A"
                },
                {
                    "type": "flac",
                    "size": "21.60 MB",
                    "hash": "8C0E866E07F5C6DC67F197C9AED5FB37"
                },
                {
                    "type": "flac24bit",
                    "size": "43.64 MB",
                    "hash": "F1D21C06A4FAE70F97780694839DCBB1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.50 MB",
                    "hash": "D79E556C176AE1A3ADE8B532810C4CE8"
                },
                "320k": {
                    "size": "8.76 MB",
                    "hash": "BCC5B2A148814D6D9D5D1671CEEF6C0A"
                },
                "flac": {
                    "size": "21.60 MB",
                    "hash": "8C0E866E07F5C6DC67F197C9AED5FB37"
                },
                "flac24bit": {
                    "size": "43.64 MB",
                    "hash": "F1D21C06A4FAE70F97780694839DCBB1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "宋亚轩",
            "name": "同花顺 (Live)",
            "albumName": "国乐无双 第5期",
            "albumId": "196186782",
            "songmid": 1106647631,
            "source": "kg",
            "interval": "03:56",
            "img": "http://imge.kugou.com/stdmusic/400/20260619/20260619155251484657.jpg",
            "lrc": null,
            "hash": "5FB9D284336389C7AD9FC9AE9A042E82",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.60 MB",
                    "hash": "5FB9D284336389C7AD9FC9AE9A042E82"
                },
                {
                    "type": "320k",
                    "size": "9.01 MB",
                    "hash": "FAC90AF7815F2C908417472B603D0C3F"
                },
                {
                    "type": "flac",
                    "size": "24.34 MB",
                    "hash": "9A5DE6915619F3EFA92F78B042CC2EAE"
                },
                {
                    "type": "flac24bit",
                    "size": "47.39 MB",
                    "hash": "A4C5C1AD11CB004043B2CF78620AAB44"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.60 MB",
                    "hash": "5FB9D284336389C7AD9FC9AE9A042E82"
                },
                "320k": {
                    "size": "9.01 MB",
                    "hash": "FAC90AF7815F2C908417472B603D0C3F"
                },
                "flac": {
                    "size": "24.34 MB",
                    "hash": "9A5DE6915619F3EFA92F78B042CC2EAE"
                },
                "flac24bit": {
                    "size": "47.39 MB",
                    "hash": "A4C5C1AD11CB004043B2CF78620AAB44"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "白兰的",
            "name": "得意的笑 (雷鬼版)",
            "albumName": "四月第一周大热单曲",
            "albumId": "182710576",
            "songmid": 556465121,
            "source": "kg",
            "interval": "04:07",
            "img": "http://imge.kugou.com/stdmusic/400/20260409/20260409192641393718.jpg",
            "lrc": null,
            "hash": "1392D0C06686D4779E14F4503B330140",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.78 MB",
                    "hash": "1392D0C06686D4779E14F4503B330140"
                },
                {
                    "type": "320k",
                    "size": "9.46 MB",
                    "hash": "EBBA30495F026C671F777F5F6D22DB24"
                },
                {
                    "type": "flac",
                    "size": "28.89 MB",
                    "hash": "9DAF86EDCA3881881B0282D08DDAF89D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.78 MB",
                    "hash": "1392D0C06686D4779E14F4503B330140"
                },
                "320k": {
                    "size": "9.46 MB",
                    "hash": "EBBA30495F026C671F777F5F6D22DB24"
                },
                "flac": {
                    "size": "28.89 MB",
                    "hash": "9DAF86EDCA3881881B0282D08DDAF89D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "金海心",
            "name": "阳光下的星星",
            "albumName": "金海心精选歌曲",
            "albumId": "1738155",
            "songmid": 154438,
            "source": "kg",
            "interval": "04:43",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121616808035.jpg",
            "lrc": null,
            "hash": "8B60D8B58137C2D256DAA71B9D84C046",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.33 MB",
                    "hash": "8B60D8B58137C2D256DAA71B9D84C046"
                },
                {
                    "type": "320k",
                    "size": "10.82 MB",
                    "hash": "96F2D2C8A366B3DC618023295E40D1DA"
                },
                {
                    "type": "flac",
                    "size": "27.09 MB",
                    "hash": "E294A7951195E85D8A949EB9041CC3CC"
                },
                {
                    "type": "flac24bit",
                    "size": "28.09 MB",
                    "hash": "AFD210DAC9129CCF71280032AFE9972A"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.33 MB",
                    "hash": "8B60D8B58137C2D256DAA71B9D84C046"
                },
                "320k": {
                    "size": "10.82 MB",
                    "hash": "96F2D2C8A366B3DC618023295E40D1DA"
                },
                "flac": {
                    "size": "27.09 MB",
                    "hash": "E294A7951195E85D8A949EB9041CC3CC"
                },
                "flac24bit": {
                    "size": "28.09 MB",
                    "hash": "AFD210DAC9129CCF71280032AFE9972A"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "王艳薇",
            "name": "离开我的依赖",
            "albumName": "离开我的依赖",
            "albumId": "36181053",
            "songmid": 67347251,
            "source": "kg",
            "interval": "03:53",
            "img": "http://imge.kugou.com/stdmusic/400/20250725/20250725103502185296.jpg",
            "lrc": null,
            "hash": "A9C377CC1B9931F0CE81907E23E4D588",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.57 MB",
                    "hash": "A9C377CC1B9931F0CE81907E23E4D588"
                },
                {
                    "type": "320k",
                    "size": "8.92 MB",
                    "hash": "2D180C85ADADDC7FA19AD9B6DD827821"
                },
                {
                    "type": "flac",
                    "size": "28.43 MB",
                    "hash": "A94C863610A66DACF65B1B4BE9185FD3"
                },
                {
                    "type": "flac24bit",
                    "size": "48.05 MB",
                    "hash": "F68A5DC1D0A5EC34E9CD98AAB5BFA8AC"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.57 MB",
                    "hash": "A9C377CC1B9931F0CE81907E23E4D588"
                },
                "320k": {
                    "size": "8.92 MB",
                    "hash": "2D180C85ADADDC7FA19AD9B6DD827821"
                },
                "flac": {
                    "size": "28.43 MB",
                    "hash": "A94C863610A66DACF65B1B4BE9185FD3"
                },
                "flac24bit": {
                    "size": "48.05 MB",
                    "hash": "F68A5DC1D0A5EC34E9CD98AAB5BFA8AC"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "许嵩",
            "name": "老歌",
            "albumName": "安泊猜想",
            "albumId": "195575102",
            "songmid": 1106591930,
            "source": "kg",
            "interval": "03:44",
            "img": "http://imge.kugou.com/stdmusic/400/20260615/20260615170953315470.jpg",
            "lrc": null,
            "hash": "7136750C61734E5C8B5395FF5120EE1F",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.43 MB",
                    "hash": "7136750C61734E5C8B5395FF5120EE1F"
                },
                {
                    "type": "320k",
                    "size": "8.57 MB",
                    "hash": "93E7B9AF3836DB32B0AB6CC177386B4C"
                },
                {
                    "type": "flac",
                    "size": "22.61 MB",
                    "hash": "3329E193497334F897EFCFBD321D14BB"
                },
                {
                    "type": "flac24bit",
                    "size": "44.36 MB",
                    "hash": "D17183AE9196C5346F00E0A0C3BFD035"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.43 MB",
                    "hash": "7136750C61734E5C8B5395FF5120EE1F"
                },
                "320k": {
                    "size": "8.57 MB",
                    "hash": "93E7B9AF3836DB32B0AB6CC177386B4C"
                },
                "flac": {
                    "size": "22.61 MB",
                    "hash": "3329E193497334F897EFCFBD321D14BB"
                },
                "flac24bit": {
                    "size": "44.36 MB",
                    "hash": "D17183AE9196C5346F00E0A0C3BFD035"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "鹿晗",
            "name": "勋章",
            "albumName": "勋章",
            "albumId": "2059004",
            "songmid": 18758291,
            "source": "kg",
            "interval": "03:33",
            "img": "http://imge.kugou.com/stdmusic/400/20250217/20250217144212257577.jpg",
            "lrc": null,
            "hash": "6FB3EB3F13CD64DF6E9784F6E487BAB1",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.27 MB",
                    "hash": "6FB3EB3F13CD64DF6E9784F6E487BAB1"
                },
                {
                    "type": "320k",
                    "size": "8.16 MB",
                    "hash": "24EC0CBAE11A3E8D014A22219A6AFEE6"
                },
                {
                    "type": "flac",
                    "size": "23.75 MB",
                    "hash": "A57CD29CB103445F42F3826819F837C7"
                },
                {
                    "type": "flac24bit",
                    "size": "41.56 MB",
                    "hash": "944CB2E541CDB0A6DD77364A561C97EE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.27 MB",
                    "hash": "6FB3EB3F13CD64DF6E9784F6E487BAB1"
                },
                "320k": {
                    "size": "8.16 MB",
                    "hash": "24EC0CBAE11A3E8D014A22219A6AFEE6"
                },
                "flac": {
                    "size": "23.75 MB",
                    "hash": "A57CD29CB103445F42F3826819F837C7"
                },
                "flac24bit": {
                    "size": "41.56 MB",
                    "hash": "944CB2E541CDB0A6DD77364A561C97EE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "曾舜晞、姚晓棠",
            "name": "街角的晚风 (Live)",
            "albumName": "天赐的声音第七季 第1期",
            "albumId": "195193434",
            "songmid": 1106566970,
            "source": "kg",
            "interval": "04:13",
            "img": "http://imge.kugou.com/stdmusic/400/20260612/20260612154641900845.jpg",
            "lrc": null,
            "hash": "0ECC798AF3EC332661AC59DCE7A76C03",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.86 MB",
                    "hash": "0ECC798AF3EC332661AC59DCE7A76C03"
                },
                {
                    "type": "320k",
                    "size": "9.66 MB",
                    "hash": "2E58225CC7DF977E91FCF1B08A4A91A0"
                },
                {
                    "type": "flac",
                    "size": "30.26 MB",
                    "hash": "E71BB05EC0256CF772F8E6D2C6C69CA6"
                },
                {
                    "type": "flac24bit",
                    "size": "54.97 MB",
                    "hash": "E8E1D73990029425C3AFA07E23DF44B8"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.86 MB",
                    "hash": "0ECC798AF3EC332661AC59DCE7A76C03"
                },
                "320k": {
                    "size": "9.66 MB",
                    "hash": "2E58225CC7DF977E91FCF1B08A4A91A0"
                },
                "flac": {
                    "size": "30.26 MB",
                    "hash": "E71BB05EC0256CF772F8E6D2C6C69CA6"
                },
                "flac24bit": {
                    "size": "54.97 MB",
                    "hash": "E8E1D73990029425C3AFA07E23DF44B8"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "汪苏泷",
            "name": "写故事的人",
            "albumName": "明日世界ACT I",
            "albumId": "182848644",
            "songmid": 1105453713,
            "source": "kg",
            "interval": "04:08",
            "img": "http://imge.kugou.com/stdmusic/400/20260623/20260623120003410674.jpg",
            "lrc": null,
            "hash": "0A396FA95B16CA40CFFC5D6CC91AE37C",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.79 MB",
                    "hash": "0A396FA95B16CA40CFFC5D6CC91AE37C"
                },
                {
                    "type": "320k",
                    "size": "9.47 MB",
                    "hash": "CFA8EF5FAA9AE4DC455B916ADE47404B"
                },
                {
                    "type": "flac",
                    "size": "25.59 MB",
                    "hash": "2329149D8DDD482FCBF4A60C47EF53B9"
                },
                {
                    "type": "flac24bit",
                    "size": "81.84 MB",
                    "hash": "24EB09C409B5E14A220747646CDBED45"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.79 MB",
                    "hash": "0A396FA95B16CA40CFFC5D6CC91AE37C"
                },
                "320k": {
                    "size": "9.47 MB",
                    "hash": "CFA8EF5FAA9AE4DC455B916ADE47404B"
                },
                "flac": {
                    "size": "25.59 MB",
                    "hash": "2329149D8DDD482FCBF4A60C47EF53B9"
                },
                "flac24bit": {
                    "size": "81.84 MB",
                    "hash": "24EB09C409B5E14A220747646CDBED45"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "青鸟飞鱼",
            "name": "此生不换",
            "albumName": "一匹 (宠物再生版)",
            "albumId": "49812122",
            "songmid": 301292205,
            "source": "kg",
            "interval": "04:27",
            "img": "http://imge.kugou.com/stdmusic/400/20250623/20250623043520681592.jpg",
            "lrc": null,
            "hash": "61AA3E30BF3F50F23FCAABD56DB46755",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.09 MB",
                    "hash": "61AA3E30BF3F50F23FCAABD56DB46755"
                },
                {
                    "type": "320k",
                    "size": "10.22 MB",
                    "hash": "A45429BEE11FF30CE3DA9BCE10E8B48A"
                },
                {
                    "type": "flac",
                    "size": "29.27 MB",
                    "hash": "36D0C987DA819EA6BD01D8741D431A22"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.09 MB",
                    "hash": "61AA3E30BF3F50F23FCAABD56DB46755"
                },
                "320k": {
                    "size": "10.22 MB",
                    "hash": "A45429BEE11FF30CE3DA9BCE10E8B48A"
                },
                "flac": {
                    "size": "29.27 MB",
                    "hash": "36D0C987DA819EA6BD01D8741D431A22"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "白兰的",
            "name": "花心 (雷鬼版)",
            "albumName": "雷鬼版的4月翻唱集",
            "albumId": "186247265",
            "songmid": 564740503,
            "source": "kg",
            "interval": "04:08",
            "img": "http://imge.kugou.com/stdmusic/400/20260429/20260429113620104973.jpg",
            "lrc": null,
            "hash": "D9C96E61E5C20340173B44E71789F665",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.79 MB",
                    "hash": "D9C96E61E5C20340173B44E71789F665"
                },
                {
                    "type": "320k",
                    "size": "9.48 MB",
                    "hash": "0310074139377B6837FA87BE749AF0B2"
                },
                {
                    "type": "flac",
                    "size": "27.64 MB",
                    "hash": "174336AFE1CA1F1B1F483B1C39694F3D"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.79 MB",
                    "hash": "D9C96E61E5C20340173B44E71789F665"
                },
                "320k": {
                    "size": "9.48 MB",
                    "hash": "0310074139377B6837FA87BE749AF0B2"
                },
                "flac": {
                    "size": "27.64 MB",
                    "hash": "174336AFE1CA1F1B1F483B1C39694F3D"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Charlie Puth、Selena Gomez",
            "name": "We Don't Talk Anymore (Mr. Collipark Remix)",
            "albumName": "只剩沉默",
            "albumId": "1746993",
            "songmid": 22154421,
            "source": "kg",
            "interval": "04:14",
            "img": "http://imge.kugou.com/stdmusic/400/20250813/20250813073642531553.jpg",
            "lrc": null,
            "hash": "8F323B0610BE8D862B7CBB41C3398766",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.88 MB",
                    "hash": "8F323B0610BE8D862B7CBB41C3398766"
                },
                {
                    "type": "320k",
                    "size": "9.71 MB",
                    "hash": "842147AAF2856072D3B31630C0902790"
                },
                {
                    "type": "flac",
                    "size": "30.11 MB",
                    "hash": "3C52A88CB4308B8FDBFEA12094C3BE7E"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.88 MB",
                    "hash": "8F323B0610BE8D862B7CBB41C3398766"
                },
                "320k": {
                    "size": "9.71 MB",
                    "hash": "842147AAF2856072D3B31630C0902790"
                },
                "flac": {
                    "size": "30.11 MB",
                    "hash": "3C52A88CB4308B8FDBFEA12094C3BE7E"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "张芸京",
            "name": "偏爱",
            "albumName": "破天荒",
            "albumId": "968788",
            "songmid": 907824,
            "source": "kg",
            "interval": "03:32",
            "img": "http://imge.kugou.com/stdmusic/400/20221125/20221125063514484979.jpg",
            "lrc": null,
            "hash": "4A544525C1F78DBDF25361DB0E255495",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.25 MB",
                    "hash": "4A544525C1F78DBDF25361DB0E255495"
                },
                {
                    "type": "320k",
                    "size": "8.12 MB",
                    "hash": "F69A2F14885BF1A3B6E236584045D1B2"
                },
                {
                    "type": "flac",
                    "size": "24.19 MB",
                    "hash": "29EE08103A33AD6707E71FD5F1CC239A"
                },
                {
                    "type": "flac24bit",
                    "size": "24.79 MB",
                    "hash": "27B39645A74D5A47F793E9207BBD97AE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.25 MB",
                    "hash": "4A544525C1F78DBDF25361DB0E255495"
                },
                "320k": {
                    "size": "8.12 MB",
                    "hash": "F69A2F14885BF1A3B6E236584045D1B2"
                },
                "flac": {
                    "size": "24.19 MB",
                    "hash": "29EE08103A33AD6707E71FD5F1CC239A"
                },
                "flac24bit": {
                    "size": "24.79 MB",
                    "hash": "27B39645A74D5A47F793E9207BBD97AE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "Glass Animals",
            "name": "The Other Side Of Paradise (Explicit)",
            "albumName": "天堂的彼端",
            "albumId": "47764102",
            "songmid": 22571731,
            "source": "kg",
            "interval": "05:20",
            "img": "http://imge.kugou.com/stdmusic/400/20210809/20210809125603527147.jpg",
            "lrc": null,
            "hash": "222314858D998CCDDD4BF0B7BAF2F5A2",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.89 MB",
                    "hash": "222314858D998CCDDD4BF0B7BAF2F5A2"
                },
                {
                    "type": "320k",
                    "size": "12.24 MB",
                    "hash": "D0D69CD4E56293314CA7944FECB123DD"
                },
                {
                    "type": "flac",
                    "size": "35.61 MB",
                    "hash": "1CAF9ABC87D0901CF235DB2CCA516336"
                },
                {
                    "type": "flac24bit",
                    "size": "62.59 MB",
                    "hash": "1E851809B22901DFAC3978ECE6E48AFD"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.89 MB",
                    "hash": "222314858D998CCDDD4BF0B7BAF2F5A2"
                },
                "320k": {
                    "size": "12.24 MB",
                    "hash": "D0D69CD4E56293314CA7944FECB123DD"
                },
                "flac": {
                    "size": "35.61 MB",
                    "hash": "1CAF9ABC87D0901CF235DB2CCA516336"
                },
                "flac24bit": {
                    "size": "62.59 MB",
                    "hash": "1E851809B22901DFAC3978ECE6E48AFD"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "聲無哀樂乐队THEWEAPONS、龚琳娜、杨宗勋",
            "name": "江声入旧年",
            "albumName": "江声入旧年",
            "albumId": "172928690",
            "songmid": 525877573,
            "source": "kg",
            "interval": "04:11",
            "img": "http://imge.kugou.com/stdmusic/400/20260106/20260106193852140888.jpg",
            "lrc": null,
            "hash": "CC9C270CD9409E62960A83BC5B28DC6C",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.84 MB",
                    "hash": "CC9C270CD9409E62960A83BC5B28DC6C"
                },
                {
                    "type": "320k",
                    "size": "9.61 MB",
                    "hash": "42056AE3FC4ABFFA1E98934E55F49A22"
                },
                {
                    "type": "flac",
                    "size": "25.50 MB",
                    "hash": "12C0EB832ADBA3AA820F6A7C00B2E26A"
                },
                {
                    "type": "flac24bit",
                    "size": "49.80 MB",
                    "hash": "7F373149C0FBEB68D52DFD264EF557F6"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.84 MB",
                    "hash": "CC9C270CD9409E62960A83BC5B28DC6C"
                },
                "320k": {
                    "size": "9.61 MB",
                    "hash": "42056AE3FC4ABFFA1E98934E55F49A22"
                },
                "flac": {
                    "size": "25.50 MB",
                    "hash": "12C0EB832ADBA3AA820F6A7C00B2E26A"
                },
                "flac24bit": {
                    "size": "49.80 MB",
                    "hash": "7F373149C0FBEB68D52DFD264EF557F6"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "派伟俊、mac ova seas",
            "name": "左转灯 (1000 Times +1)",
            "albumName": "左转灯 (1000 Times +1)",
            "albumId": "164658305",
            "songmid": 501200460,
            "source": "kg",
            "interval": "03:17",
            "img": "http://imge.kugou.com/stdmusic/400/20251015/20251015182041394583.jpg",
            "lrc": null,
            "hash": "E51ABAF534E7D2BA42DB5604421D4838",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.01 MB",
                    "hash": "E51ABAF534E7D2BA42DB5604421D4838"
                },
                {
                    "type": "320k",
                    "size": "7.53 MB",
                    "hash": "9907BCDA5E9542ACC381ECABAFA61A8C"
                },
                {
                    "type": "flac",
                    "size": "21.68 MB",
                    "hash": "278D36E56D5AF3EE2AEA9702D2B91940"
                },
                {
                    "type": "flac24bit",
                    "size": "40.64 MB",
                    "hash": "6CCBD459C13149C7FF2A7D3970EA5191"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.01 MB",
                    "hash": "E51ABAF534E7D2BA42DB5604421D4838"
                },
                "320k": {
                    "size": "7.53 MB",
                    "hash": "9907BCDA5E9542ACC381ECABAFA61A8C"
                },
                "flac": {
                    "size": "21.68 MB",
                    "hash": "278D36E56D5AF3EE2AEA9702D2B91940"
                },
                "flac24bit": {
                    "size": "40.64 MB",
                    "hash": "6CCBD459C13149C7FF2A7D3970EA5191"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁博",
            "name": "出现又离开 (Live)",
            "albumName": "我是唱作人 第2期",
            "albumId": "19284949",
            "songmid": 54003685,
            "source": "kg",
            "interval": "06:43",
            "img": "http://imge.kugou.com/stdmusic/400/20250228/20250228160451682948.jpg",
            "lrc": null,
            "hash": "DEAB3B0160E9A410CE0AAA9ED8AC602E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "6.17 MB",
                    "hash": "DEAB3B0160E9A410CE0AAA9ED8AC602E"
                },
                {
                    "type": "320k",
                    "size": "15.41 MB",
                    "hash": "20F9C8AE1A5F38D91B3A5BC0BCAE708B"
                },
                {
                    "type": "flac",
                    "size": "41.43 MB",
                    "hash": "DB6FB6A913F19BD95751698B490C2882"
                },
                {
                    "type": "flac24bit",
                    "size": "78.43 MB",
                    "hash": "D4B259C0B050D26A26332A4B9F82D180"
                }
            ],
            "_types": {
                "128k": {
                    "size": "6.17 MB",
                    "hash": "DEAB3B0160E9A410CE0AAA9ED8AC602E"
                },
                "320k": {
                    "size": "15.41 MB",
                    "hash": "20F9C8AE1A5F38D91B3A5BC0BCAE708B"
                },
                "flac": {
                    "size": "41.43 MB",
                    "hash": "DB6FB6A913F19BD95751698B490C2882"
                },
                "flac24bit": {
                    "size": "78.43 MB",
                    "hash": "D4B259C0B050D26A26332A4B9F82D180"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "许嵩",
            "name": "心安之地",
            "albumName": "安泊猜想",
            "albumId": "195575102",
            "songmid": 1106591924,
            "source": "kg",
            "interval": "04:22",
            "img": "http://imge.kugou.com/stdmusic/400/20260615/20260615170953315470.jpg",
            "lrc": null,
            "hash": "2B95001491D12B8823C3F9EADAFA275E",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.00 MB",
                    "hash": "2B95001491D12B8823C3F9EADAFA275E"
                },
                {
                    "type": "320k",
                    "size": "10.00 MB",
                    "hash": "80C2B1049824A8ADC1F5790840C951B0"
                },
                {
                    "type": "flac",
                    "size": "30.12 MB",
                    "hash": "9E7CB5C12B7F0B1C78C1F007BF52CB8E"
                },
                {
                    "type": "flac24bit",
                    "size": "55.83 MB",
                    "hash": "B2FD2AFDBB2EA09B954009D594154671"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.00 MB",
                    "hash": "2B95001491D12B8823C3F9EADAFA275E"
                },
                "320k": {
                    "size": "10.00 MB",
                    "hash": "80C2B1049824A8ADC1F5790840C951B0"
                },
                "flac": {
                    "size": "30.12 MB",
                    "hash": "9E7CB5C12B7F0B1C78C1F007BF52CB8E"
                },
                "flac24bit": {
                    "size": "55.83 MB",
                    "hash": "B2FD2AFDBB2EA09B954009D594154671"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "梁静茹",
            "name": "勇气",
            "albumName": "《勇气》国语版",
            "albumId": "973299",
            "songmid": 342151,
            "source": "kg",
            "interval": "03:59",
            "img": "http://imge.kugou.com/stdmusic/400/20241205/20241205192457266564.jpg",
            "lrc": null,
            "hash": "A4D0C350CF4475BFBB0AB28DC6E25A8D",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.65 MB",
                    "hash": "A4D0C350CF4475BFBB0AB28DC6E25A8D"
                },
                {
                    "type": "320k",
                    "size": "9.12 MB",
                    "hash": "2DF26740EA6246591B294BAC600AAEB7"
                },
                {
                    "type": "flac",
                    "size": "23.94 MB",
                    "hash": "1E126DBBC2632168110D1609D51649EE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.65 MB",
                    "hash": "A4D0C350CF4475BFBB0AB28DC6E25A8D"
                },
                "320k": {
                    "size": "9.12 MB",
                    "hash": "2DF26740EA6246591B294BAC600AAEB7"
                },
                "flac": {
                    "size": "23.94 MB",
                    "hash": "1E126DBBC2632168110D1609D51649EE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "杨丞琳",
            "name": "带我走",
            "albumName": "半熟宣言",
            "albumId": "975441",
            "songmid": 3406655,
            "source": "kg",
            "interval": "04:50",
            "img": "http://imge.kugou.com/stdmusic/400/20250125/20250125121758285156.jpg",
            "lrc": null,
            "hash": "0C57DE35C3CB2A32A8CF634E4F8309C4",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.44 MB",
                    "hash": "0C57DE35C3CB2A32A8CF634E4F8309C4"
                },
                {
                    "type": "320k",
                    "size": "11.10 MB",
                    "hash": "3AB887D4C2A9B87CEFBD5E4559C3DA00"
                },
                {
                    "type": "flac",
                    "size": "29.34 MB",
                    "hash": "06BDA20E60DC6D05EF4FB4F386762B0C"
                },
                {
                    "type": "flac24bit",
                    "size": "53.87 MB",
                    "hash": "5A8CAD975D6DEF79207F81341264FFDE"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.44 MB",
                    "hash": "0C57DE35C3CB2A32A8CF634E4F8309C4"
                },
                "320k": {
                    "size": "11.10 MB",
                    "hash": "3AB887D4C2A9B87CEFBD5E4559C3DA00"
                },
                "flac": {
                    "size": "29.34 MB",
                    "hash": "06BDA20E60DC6D05EF4FB4F386762B0C"
                },
                "flac24bit": {
                    "size": "53.87 MB",
                    "hash": "5A8CAD975D6DEF79207F81341264FFDE"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "周杰伦",
            "name": "那天下雨了",
            "albumName": "太阳之子",
            "albumId": "179652761",
            "songmid": 1105012495,
            "source": "kg",
            "interval": "03:43",
            "img": "http://imge.kugou.com/stdmusic/400/20260319/20260319101420611881.jpg",
            "lrc": null,
            "hash": "1335F720C701863F127FB14CCC9C08A2",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "3.41 MB",
                    "hash": "1335F720C701863F127FB14CCC9C08A2"
                },
                {
                    "type": "320k",
                    "size": "8.52 MB",
                    "hash": "FD631D8979879E3685F89253A357FADF"
                },
                {
                    "type": "flac",
                    "size": "24.54 MB",
                    "hash": "09084751174B0E8D4B896AFEA4DA354F"
                },
                {
                    "type": "flac24bit",
                    "size": "46.22 MB",
                    "hash": "A6A9A4AB7A6967AD4EB0A5E3D3AC94D1"
                }
            ],
            "_types": {
                "128k": {
                    "size": "3.41 MB",
                    "hash": "1335F720C701863F127FB14CCC9C08A2"
                },
                "320k": {
                    "size": "8.52 MB",
                    "hash": "FD631D8979879E3685F89253A357FADF"
                },
                "flac": {
                    "size": "24.54 MB",
                    "hash": "09084751174B0E8D4B896AFEA4DA354F"
                },
                "flac24bit": {
                    "size": "46.22 MB",
                    "hash": "A6A9A4AB7A6967AD4EB0A5E3D3AC94D1"
                }
            },
            "typeUrl": {}
        },
        {
            "singer": "任然",
            "name": "疑心病",
            "albumName": "世界之外",
            "albumId": "1818864",
            "songmid": 53625096,
            "source": "kg",
            "interval": "04:43",
            "img": "http://imge.kugou.com/stdmusic/400/20250228/20250228160348223947.jpg",
            "lrc": null,
            "hash": "9D8C7468BE4391B85794617090585646",
            "otherSource": null,
            "types": [
                {
                    "type": "128k",
                    "size": "4.33 MB",
                    "hash": "9D8C7468BE4391B85794617090585646"
                },
                {
                    "type": "320k",
                    "size": "10.82 MB",
                    "hash": "8579883374F301241EE5AA1729E6F051"
                },
                {
                    "type": "flac",
                    "size": "28.07 MB",
                    "hash": "A3906C254E4D5D995BF8506B4305B0A9"
                },
                {
                    "type": "flac24bit",
                    "size": "28.97 MB",
                    "hash": "CF4F0F829750237D20900E52ABA6134B"
                }
            ],
            "_types": {
                "128k": {
                    "size": "4.33 MB",
                    "hash": "9D8C7468BE4391B85794617090585646"
                },
                "320k": {
                    "size": "10.82 MB",
                    "hash": "8579883374F301241EE5AA1729E6F051"
                },
                "flac": {
                    "size": "28.07 MB",
                    "hash": "A3906C254E4D5D995BF8506B4305B0A9"
                },
                "flac24bit": {
                    "size": "28.97 MB",
                    "hash": "CF4F0F829750237D20900E52ABA6134B"
                }
            },
            "typeUrl": {}
        }
    ],
    "limit": 100,
    "page": 1,
    "source": "kg"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## POST 获取音乐播放直链

POST /api/music/url

> Body 请求参数

```json
{
    "songInfo": {
        "source": "kg",
        "hash": "FE39668F68770C3FB3BE57A3E86CCC10",
        "_types": {
            "128k": {
                "hash": "FE39668F68770C3FB3BE57A3E86CCC10"
            }
        }
    },
    "quality": "128k"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|x-user-name|header|string| 否 |如果提供了具名用户，必须通过 Token 或密码验证|
|x-client-id|header|string| 否 |none|
|x-req-id|header|string| 否 |none|
|x-user-token|header|string| 否 |none|
|body|body|object| 是 |none|

> 返回示例

> 200 Response

```json
{
    "url": "http://fsandroid.kugou.com/202606250907/f214c7e2d554d8c01b58b8e21157fef9/v3/fe39668f68770c3fb3be57a3e86ccc10/yp/full/ap3293_us2191351204_mi336d5ebc5436534e61d16e63ddfca327_pi2_qu128_pa151369488_ct330200_s2917443989.mp3",
    "type": "128k",
    "sourceName": "长青SVIP音源",
    "attempts": [
        {
            "name": "长青SVIP音源",
            "status": "success"
        }
    ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

# 数据模型

