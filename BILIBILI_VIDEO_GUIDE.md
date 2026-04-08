# Bilibili 视频嵌入链接获取指南

## 方法一:分享按钮法(最简单)⭐

### 步骤:
1. 打开 Bilibili 视频页面
2. 点击视频下方的"分享"按钮(箭头图标)
3. 点击"嵌入代码"
4. 复制显示的代码

### 示例:
```html
<!-- Bilibili 提供的嵌入代码 -->
<iframe src="//player.bilibili.com/player.html?aid=669520137&bvid=BV1oa4y1L7mw&cid=234543483&page=1"
        scrolling="no"
        border="0"
        frameborder="no"
        framespacing="0"
        allowfullscreen="true">
</iframe>
```

### 提取URL:
```
//player.bilibili.com/player.html?aid=669520137&bvid=BV1oa4y1L7mw&cid=234543483&page=1
```

---

## 方法二:BV号直接构造

### 步骤:
1. 从视频URL获取BV号
   ```
   URL: https://www.bilibili.com/video/BV1oa4y1L7mw
   BV号: BV1oa4y1L7mw
   ```

2. 构造嵌入链接:
   ```
   //player.bilibili.com/player.html?bvid=BV1oa4y1L7mw&page=1
   ```

---

## 方法三:开发者工具法(最完整)

### 步骤:
1. 在视频页面按 F12 打开开发者工具
2. 切换到 Console(控制台)标签
3. 输入以下代码:

```javascript
// 获取视频信息
const videoData = {
    aid: window.__INITIAL_STATE__.aid,
    bvid: window.__INITIAL_STATE__.bvid,
    cid: window.__INITIAL_STATE__.videoData.cid,
    title: window.__INITIAL_STATE__.videoData.title
};

console.log('视频标题:', videoData.title);
console.log('嵌入链接:', `//player.bilibili.com/player.html?aid=${videoData.aid}&bvid=${videoData.bvid}&cid=${videoData.cid}&page=1`);
```

4. 复制控制台输出的嵌入链接

---

## 完整示例:添加真实视频

### 1. 获取嵌入链接
假设您找到了一个编程教程视频:
- Bilibili 链接: https://www.bilibili.com/video/BV1GJ411x7h7
- 通过分享获取嵌入链接:
  ```
  //player.bilibili.com/player.html?aid=80433022&bvid=BV1GJ411x7h7&cid=137649199&page=1
  ```

### 2. 添加到数据文件
编辑 `source/videos/videos-data.json`:

```json
{
  "id": 9,
  "title": "Python入门教程",
  "icon": "fab fa-python",
  "url": "//player.bilibili.com/player.html?aid=80433022&bvid=BV1GJ411x7h7&cid=137649199&page=1",
  "description": "Python编程入门教程,适合零基础学习",
  "tags": ["Python", "编程", "入门"],
  "category": "编程教程",
  "date": "2026-04-09"
}
```

### 3. 重启项目
```bash
bash restart.sh
```

---

## 常见问题

### Q1: 视频无法播放?
**A:** 检查以下几点:
- 嵌入链接是否正确
- 视频是否被删除或设为私密
- 浏览器是否阻止了 iframe

### Q2: 如何嵌入分P视频的不同页?
**A:** 修改 `page` 参数:
```
//player.bilibili.com/player.html?bvid=BV1oa4y1L7mw&page=2
```

### Q3: 如何设置自动播放?
**A:** 在URL后添加 `&autoplay=1`:
```
//player.bilibili.com/player.html?bvid=BV1oa4y1L7mw&page=1&autoplay=1
```
注意:大多数浏览器会阻止自动播放

### Q4: 如何设置视频画质?
**A:** 添加 `&high_quality=1` 参数:
```
//player.bilibili.com/player.html?bvid=BV1oa4y1L7mw&page=1&high_quality=1
```

---

## 其他视频平台

### YouTube
```
URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ
嵌入链接: https://www.youtube.com/embed/dQw4w9WgXcQ
```

### 腾讯视频
```
嵌入链接: https://v.qq.com/txp/iframe/player.html?vid=视频ID
```

### 优酷
```
嵌入链接: https://player.youku.com/embed/视频ID
```

---

## 快速工具

您可以访问这些在线工具快速获取嵌入代码:
- Bilibili: https://www.bilibili.com/blackboard/html5player.html
- 或直接使用视频页面的"分享 → 嵌入代码"功能