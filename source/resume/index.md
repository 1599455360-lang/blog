---
title: 博主简历信息
date: 2026-04-08
type: "resume"
---

<div id="resume-container">
  <div id="password-prompt" class="password-prompt">
    <div class="prompt-box">
      <h3><i class="fas fa-lock"></i> 访问验证</h3>
      <p>请输入访问密码查看简历</p>
      <input type="password" id="access-password" placeholder="请输入密码" />
      <button onclick="checkPassword()" class="submit-btn">确认访问</button>
      <p class="hint">提示：作者本人是谁</p>
    </div>
  </div>

  <div id="resume-content" class="resume-content" style="display:none;">
    <!-- 简历头部 -->
    <div class="resume-header">
      <h1><i class="fas fa-file-pdf"></i> 个人简历</h1>
      <p class="resume-subtitle">JJ_KMR - 软件工程师</p>
    </div>
    <!-- PDF查看选项 -->
    <div class="resume-options">
      <div class="option-card" data-tooltip="在线查看PDF简历">
        <button onclick="showPdfViewer()" class="option-btn">
          <i class="fas fa-eye"></i>
          <span>在线查看</span>
        </button>
        <p>在浏览器中查看PDF简历</p>
      </div>
      <div class="option-card" data-tooltip="下载PDF简历到本地">
        <a href="/medias/resume/resume.pdf" download class="option-btn download-btn">
          <i class="fas fa-download"></i>
          <span>下载简历</span>
        </a>
        <p>下载PDF格式简历文件</p>
      </div>
    </div>
    <!-- PDF查看器容器 -->
    <div id="pdf-viewer-container" class="pdf-viewer-container" style="display:none;">
      <div class="pdf-header">
        <h3><i class="fas fa-file-pdf"></i> PDF简历预览</h3>
        <div class="pdf-controls">
          <button onclick="zoomIn()" class="control-btn" data-tooltip="放大">
            <i class="fas fa-search-plus"></i>
          </button>
          <button onclick="zoomOut()" class="control-btn" data-tooltip="缩小">
            <i class="fas fa-search-minus"></i>
          </button>
          <button onclick="resetZoom()" class="control-btn" data-tooltip="重置">
            <i class="fas fa-undo"></i>
          </button>
          <button onclick="hidePdfViewer()" class="control-btn close-btn" data-tooltip="关闭">
            <i class="fas fa-times"></i>
          </button>
        </div>
      </div>
      <div class="pdf-wrapper">
        <!-- 使用iframe嵌入PDF -->
        <iframe id="pdf-iframe" src="" class="pdf-iframe"></iframe>
        <!-- 或者使用object标签 -->
        <object id="pdf-object" data="" type="application/pdf" class="pdf-object" style="display:none;">
          <p>您的浏览器不支持PDF预览，请<a href="/medias/resume/resume.pdf">下载PDF文件</a></p>
        </object>
      </div>
      <div class="pdf-footer">
        <p><i class="fas fa-info-circle"></i> 提示：如果PDF无法显示，请使用下载功能</p>
      </div>
    </div>
    <!-- 简要信息(可选) -->
    <div class="resume-summary">
      <h3><i class="fas fa-user-circle"></i> 基本信息</h3>
      <div class="summary-grid">
        <div class="summary-item" data-tooltip="点击复制QQ号">
          <i class="fab fa-qq"></i>
          <span>QQ: 1599455360</span>
        </div>
        <div class="summary-item" data-tooltip="发送邮件">
          <i class="fas fa-envelope"></i>
          <span>邮箱: jj13523178139@163.com</span>
        </div>
        <div class="summary-item" data-tooltip="访问GitHub主页">
          <i class="fab fa-github"></i>
          <span>GitHub: <a href="https://github.com/1599455360-lang" target="_blank">1599455360-lang</a></span>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
.password-prompt {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.prompt-box {
  background: white;
  padding: 40px;
  border-radius: 15px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
  text-align: center;
  max-width: 400px;
  width: 90%;
}

.prompt-box h3 {
  color: #667eea;
  margin-bottom: 15px;
}

.prompt-box input {
  width: 100%;
  padding: 12px;
  margin: 15px 0;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 0.3s;
}

.prompt-box input:focus {
  outline: none;
  border-color: #667eea;
}

.submit-btn {
  width: 100%;
  padding: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  cursor: pointer;
  transition: transform 0.3s;
}

.submit-btn:hover {
  transform: translateY(-2px);
}

.hint {
  margin-top: 15px;
  color: #999;
  font-size: 14px;
}

.resume-header {
  text-align: center;
  padding: 40px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  margin-bottom: 40px;
  border-radius: 15px;
}

.resume-header h1 {
  font-size: 42px;
  margin: 0;
}

.resume-header i {
  margin-right: 15px;
}

.resume-subtitle {
  font-size: 20px;
  opacity: 0.9;
  margin-top: 10px;
}

.resume-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 30px;
  margin: 40px 0;
}

.option-card {
  background: white;
  padding: 30px;
  border-radius: 15px;
  box-shadow: 0 5px 20px rgba(0,0,0,0.1);
  text-align: center;
  transition: all 0.3s ease;
  position: relative;
}

.option-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 15px 40px rgba(102, 126, 234, 0.3);
}

.option-btn {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
  padding: 20px 40px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
}

.option-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 20px rgba(102, 126, 234, 0.5);
}

.option-btn i {
  font-size: 32px;
}

.option-card p {
  margin-top: 20px;
  color: #666;
  font-size: 14px;
}

.option-card::before {
  content: attr(data-tooltip);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  padding: 8px 15px;
  background: rgba(0,0,0,0.8);
  color: white;
  border-radius: 8px;
  font-size: 13px;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
}

.option-card:hover::before {
  opacity: 1;
  visibility: visible;
  bottom: calc(100% + 10px);
}

.pdf-viewer-container {
  background: white;
  border-radius: 15px;
  box-shadow: 0 5px 20px rgba(0,0,0,0.1);
  margin: 30px 0;
  overflow: hidden;
}

.pdf-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.pdf-header h3 {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.pdf-controls {
  display: flex;
  gap: 10px;
}

.control-btn {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border: none;
  border-radius: 8px;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.control-btn:hover {
  background: rgba(255,255,255,0.3);
}

.close-btn:hover {
  background: #ff4757;
}

.control-btn::after {
  content: attr(data-tooltip);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  padding: 5px 10px;
  background: rgba(0,0,0,0.8);
  color: white;
  border-radius: 5px;
  font-size: 12px;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
  margin-bottom: 5px;
}

.control-btn:hover::after {
  opacity: 1;
  visibility: visible;
}

.pdf-wrapper {
  position: relative;
  background: #f5f5f5;
  min-height: 800px;
}

.pdf-iframe, .pdf-object {
  width: 100%;
  height: 800px;
  border: none;
}

.pdf-footer {
  padding: 15px 30px;
  background: #f8f9fa;
  text-align: center;
  color: #666;
  font-size: 14px;
}

.pdf-footer i {
  color: #667eea;
  margin-right: 5px;
}

.resume-summary {
  background: white;
  padding: 30px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.08);
  margin: 30px 0;
}

.resume-summary h3 {
  color: #667eea;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.summary-item {
  display: flex;
  align-items: center;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 10px;
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
}

.summary-item:hover {
  background: #667eea;
  color: white;
  transform: translateY(-3px);
}

.summary-item i {
  font-size: 24px;
  margin-right: 15px;
  color: #667eea;
}

.summary-item:hover i {
  color: white;
}

.summary-item a {
  color: #667eea;
  text-decoration: none;
  border-bottom: 1px dashed #667eea;
}

.summary-item:hover a {
  color: white;
  border-bottom-color: white;
}

.summary-item::after {
  content: attr(data-tooltip);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  padding: 5px 10px;
  background: rgba(0,0,0,0.8);
  color: white;
  border-radius: 5px;
  font-size: 12px;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
}

.summary-item:hover::after {
  opacity: 1;
  visibility: visible;
  bottom: calc(100% + 5px);
}
</style>

<script>
let currentZoom = 100;

function checkPassword() {
  const password = document.getElementById('access-password').value;
  // 密码为: lingping
  if (password === 'lingping') {
    document.getElementById('password-prompt').style.display = 'none';
    document.getElementById('resume-content').style.display = 'block';
    sessionStorage.setItem('resume-access', 'granted');
  } else {
    alert('密码错误，请重试或联系博主获取密码');
  }
}

function showPdfViewer() {
  const container = document.getElementById('pdf-viewer-container');
  const iframe = document.getElementById('pdf-iframe');

  // 设置PDF文件路径
  iframe.src = '/medias/resume/resume.pdf';

  container.style.display = 'block';
  container.scrollIntoView({ behavior: 'smooth' });
}

function hidePdfViewer() {
  document.getElementById('pdf-viewer-container').style.display = 'none';
}

function zoomIn() {
  currentZoom += 10;
  applyZoom();
}

function zoomOut() {
  if (currentZoom > 50) {
    currentZoom -= 10;
    applyZoom();
  }
}

function resetZoom() {
  currentZoom = 100;
  applyZoom();
}

function applyZoom() {
  const iframe = document.getElementById('pdf-iframe');
  iframe.style.transform = `scale(${currentZoom / 100})`;
  iframe.style.transformOrigin = 'top center';
}

// 页面加载时检查是否已有访问权限
window.onload = function() {
  if (sessionStorage.getItem('resume-access') === 'granted') {
    document.getElementById('password-prompt').style.display = 'none';
    document.getElementById('resume-content').style.display = 'block';
  }
}

// 支持回车键提交
document.addEventListener('DOMContentLoaded', function() {
  const passwordInput = document.getElementById('access-password');
  if (passwordInput) {
    passwordInput.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        checkPassword();
      }
    });
  }
});
</script>