---
title: 音乐空间
date: 2026-04-08
type: "musics"
---

# 音乐空间

欢迎来到我的音乐空间！这里收藏了我喜欢的音乐,希望你也喜欢。

<div class="music-intro">
  <i class="fas fa-music"></i>
  <p>音乐是生活的调味剂,是心灵的慰藉。在这里,你可以聆听美妙的旋律,感受音乐的魅力。</p>
</div>

<div class="music-player-container">
  <h3><i class="fas fa-headphones"></i> 在线音乐播放器</h3>

  <!-- 搜索框 -->
  <div class="music-search-form">
    <div class="search-input-wrapper">
      <input type="text" id="searchInput" placeholder="输入歌曲名或歌手名..." class="search-input">
      <button onclick="searchMusic()" class="search-button">
        <i class="fas fa-search"></i> 搜索
      </button>
    </div>
    <div class="quick-search-tags">
      <span class="tag-label">热门搜索：</span>
      <button onclick="quickSearch('周杰伦')" class="tag-button">周杰伦</button>
      <button onclick="quickSearch('林俊杰')" class="tag-button">林俊杰</button>
      <button onclick="quickSearch('邓紫棋')" class="tag-button">邓紫棋</button>
      <button onclick="quickSearch('薛之谦')" class="tag-button">薛之谦</button>
      <button onclick="quickSearch('毛不易')" class="tag-button">毛不易</button>
    </div>
  </div>

  <!-- 播放器容器 -->
  <div id="playerContainer" class="music-player-box">
    <meting-js
      id="周杰伦"
      server="netease"
      type="search"
      fixed="false"
      list-folded="true"
      autoplay="false"
      theme="#667eea">
    </meting-js>
  </div>

</div>

<!-- 使用说明 -->
<div class="music-info-box">
  <h4><i class="fas fa-lightbulb"></i> 使用提示</h4>
  <ul>
    <li>在搜索框中输入歌曲名或歌手名，点击搜索按钮</li>
    <li>点击热门标签可快速搜索该歌手的歌曲</li>
    <li>搜索结果会显示在播放器中，点击即可播放</li>
    <li>支持歌词同步显示和多种播放模式</li>
    <li>由于版权原因，部分歌曲可能无法播放</li>
  </ul>
</div>

<style>
.music-intro {
  text-align: center;
  padding: 40px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 15px;
  margin-bottom: 30px;
}

.music-intro i {
  font-size: 48px;
  margin-bottom: 20px;
}

.music-intro p {
  font-size: 18px;
  line-height: 1.8;
  margin: 0;
}

.music-player-container {
  background: white;
  padding: 30px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.08);
  margin: 30px 0;
}

.music-player-container h3 {
  color: #667eea;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
}

.music-player-container h3 i {
  margin-right: 10px;
}

.music-search-box {
  margin: 30px 0;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 10px;
}

.music-search-box p {
  color: #666;
  margin-bottom: 15px;
}

.music-search-box p i {
  color: #667eea;
  margin-right: 5px;
}

.music-divider {
  text-align: center;
  margin: 30px 0;
  position: relative;
}

.music-divider::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  width: 45%;
  height: 1px;
  background: #e0e0e0;
}

.music-divider::after {
  content: '';
  position: absolute;
  right: 0;
  top: 50%;
  width: 45%;
  height: 1px;
  background: #e0e0e0;
}

.music-divider span {
  background: white;
  padding: 0 15px;
  color: #999;
}

.music-info-box {
  padding: 20px;
  background: #fff9e6;
  border-left: 4px solid #ffc107;
  border-radius: 5px;
}

.music-info-box h4 {
  color: #f57c00;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
}

.music-info-box h4 i {
  margin-right: 8px;
}

.music-info-box ul {
  margin: 0;
  padding-left: 20px;
  color: #666;
}

.music-info-box li {
  margin: 8px 0;
  line-height: 1.6;
}

/* 搜索框样式 */
.music-search-form {
  margin: 30px 0;
  padding: 25px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e8eef5 100%);
  border-radius: 12px;
}

.search-input-wrapper {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.search-input {
  flex: 1;
  padding: 12px 20px;
  border: 2px solid #667eea;
  border-radius: 25px;
  font-size: 16px;
  outline: none;
  transition: all 0.3s ease;
}

.search-input:focus {
  border-color: #764ba2;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.search-button {
  padding: 12px 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 25px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.search-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.search-button i {
  font-size: 14px;
}

.quick-search-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
}

.tag-label {
  color: #666;
  font-size: 14px;
}

.tag-button {
  padding: 8px 16px;
  background: white;
  border: 1px solid #667eea;
  color: #667eea;
  border-radius: 20px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tag-button:hover {
  background: #667eea;
  color: white;
  transform: translateY(-2px);
}

.music-player-box {
  margin-top: 30px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 10px;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .search-input-wrapper {
    flex-direction: column;
  }
  
  .search-button {
    width: 100%;
    justify-content: center;
  }
  
  .quick-search-tags {
    justify-content: center;
  }
}
</style>

<!-- JavaScript 功能 -->
<script>
// 搜索音乐
function searchMusic() {
  const keyword = document.getElementById('searchInput').value.trim();
  if (!keyword) {
    alert('请输入歌曲名或歌手名');
    return;
  }
  
  // 创建新的播放器
  const container = document.getElementById('playerContainer');
  container.innerHTML = `
    <meting-js
      id="${keyword}"
      server="netease"
      type="search"
      fixed="false"
      list-folded="true"
      autoplay="false"
      theme="#667eea">
    </meting-js>
  `;
  
  // 重新加载Meting
  if (typeof Meting !== 'undefined') {
    Meting();
  }
}

// 快速搜索
function quickSearch(keyword) {
  document.getElementById('searchInput').value = keyword;
  searchMusic();
}

// 回车搜索
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('searchInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      searchMusic();
    }
  });
});
</script>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/aplayer/dist/APlayer.min.css">
<script src="https://cdn.jsdelivr.net/npm/aplayer/dist/APlayer.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/meting@2/dist/Meting.min.js"></script>