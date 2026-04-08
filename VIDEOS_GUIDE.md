# Videos 页面使用指南

## 功能特性

✨ **已实现的功能:**
- 📝 通过 JSON 文件管理视频数据
- 🔍 实时搜索功能(支持标题、标签、分类)
- 🏷️ 分类筛选
- 📄 分页功能(每页显示 6 个视频)
- 🎨 精美的卡片式设计
- 📱 完全响应式布局

## 文件结构

```
blog/
├── source/
│   └── videos/
│       ├── index.md              # 视频页面入口
│       └── videos-data.json      # 视频数据文件
└── themes/
    └── matery/
        └── layout/
            └── videos.ejs        # 视频页面布局模板
```

## 如何添加视频

### 1. 编辑视频数据文件

打开 `source/videos/videos-data.json` 文件,按照以下格式添加新视频:

```json
{
  "id": 9,
  "title": "新视频标题",
  "icon": "fas fa-video",
  "url": "//player.bilibili.com/player.html?aid=你的视频ID",
  "description": "视频描述内容",
  "tags": ["标签1", "标签2", "标签3"],
  "category": "技术分享",
  "date": "2026-04-09"
}
```

### 2. 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | Number | 是 | 视频唯一标识符 |
| title | String | 是 | 视频标题 |
| icon | String | 否 | Font Awesome 图标类名 |
| url | String | 是 | 视频嵌入地址 |
| description | String | 是 | 视频描述 |
| tags | Array | 是 | 标签数组 |
| category | String | 是 | 分类名称 |
| date | String | 是 | 发布日期(YYYY-MM-DD) |

### 3. 分类设置

默认支持的分类:
- 技术分享
- 编程教程
- 生活
- 励志

可以自定义添加新分类,只需在 JSON 中设置 category 字段,并在布局模板的筛选按钮中添加对应按钮即可。

## 视频平台支持

### Bilibili
```
//player.bilibili.com/player.html?aid=视频AID&bvid=BV号&cid=视频CID&page=1
```

### YouTube
```
https://www.youtube.com/embed/视频ID
```

### 其他平台
支持任何提供 iframe 嵌入的视频平台

## 常用图标

- `fas fa-video` - 视频图标
- `fas fa-play-circle` - 播放图标
- `fas fa-code` - 代码图标
- `fas fa-laptop-code` - 编程图标
- `fab fa-react` - React 图标
- `fab fa-vuejs` - Vue 图标
- `fab fa-python` - Python 图标
- `fas fa-heart` - 爱心图标
- `fas fa-fire` - 火焰图标
- `fas fa-plane` - 飞机图标

更多图标请访问: https://fontawesome.com/icons

## 功能说明

### 搜索功能
- 支持搜索视频标题、描述和标签
- 实时搜索,输入即显示结果
- 点击清除按钮清空搜索

### 分类筛选
- 点击分类按钮筛选视频
- "全部" 显示所有视频
- 其他分类按钮显示对应分类的视频

### 分页功能
- 每页显示 6 个视频
- 支持上一页/下一页按钮
- 支持点击页码跳转
- 显示当前显示范围和总数

## 自定义配置

### 修改每页显示数量

在 `themes/matery/layout/videos.ejs` 中找到:

```javascript
this.videosPerPage = 6;
```

修改为你想要的数量即可。

### 修改布局样式

所有样式都在 `videos.ejs` 文件的 `<style>` 标签中,可以根据需要自定义:
- 卡片样式
- 颜色主题
- 动画效果
- 响应式断点

## 访问地址

重启项目后访问: **http://localhost:4000/videos/**

## 示例视频数据

已在 `videos-data.json` 中预置了 8 个示例视频:
1. 前端技术分享
2. 编程教程入门
3. 生活记录 Vlog
4. 励志短片精选
5. React 进阶教程
6. Python 数据分析
7. Vue3 完全指南
8. 旅行纪录片

## 注意事项

1. 每次修改 `videos-data.json` 后需要重启项目才能看到效果
2. 视频链接需要使用嵌入地址,而非普通播放地址
3. 确保 id 字段唯一,避免冲突
4. 建议使用有意义的标签,便于搜索和分类