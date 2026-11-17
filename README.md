# 电能质量测试数据汇总报告生成工具（Web 版）

把谐波、间谐波、电能质量三个子项目的测试数据（Excel）按 11 个功率区间分类，自动生成格式统一的 Word 报告：三个章节，每个子项目按「综合值 + 10 个功率区间」合并成表格。

这是一个 **Flask 应用**，需要一个能运行 Python 的容器/主机；静态网页托管（GitHub Pages、EdgeOne Pages 等）不能直接运行它。

## 功能

- 上传单个 Excel 到指定子项目 / 功率区间，上传时立即解析校验
- 按区间展示已上传文件，可单独清空某个子项目
- 一键生成 Word 报告并下载，文件名为「电能质量测试数据汇总报告_时间戳.docx」
- 支持 `.xls`（xlrd）与 `.xlsx`（openpyxl）
- 上传文件存放在临时目录，超过 `SESSION_TTL_HOURS`（默认 12 小时）自动清理

## 目录结构

```
power-quality-report/
├── app.py               # Flask 入口（内嵌前端页面）
├── generate_report.py   # Excel 解析 + Word 报告生成逻辑
├── requirements.txt
├── Dockerfile
├── test_api.py          # 本地接口自测脚本
└── 启动.bat             # Windows 本地一键启动
```

测试数据（`谐波/`、`间谐波/`、`电能质量/`）与生成的报告不包含在仓库里，请放在本地目录中使用。

## 本地运行

要求 Python 3.10+。

```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
python app.py
```

浏览器打开 <http://localhost:5000>。Windows 也可以直接双击 `启动.bat`（会自动安装缺的依赖并打开浏览器）。

## Docker

```bash
docker build -t power-quality-report .
docker run --rm -p 8080:8080 power-quality-report
```

打开 <http://localhost:8080>。

## 环境变量

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `PORT` | `8080`（Docker）/ `5000`（本地） | 监听端口 |
| `HOST` | `0.0.0.0` | 监听地址 |
| `UPLOAD_ROOT` | `/tmp/pq-report-uploads` | 上传文件目录，需要可写 |
| `SESSION_TTL_HOURS` | `12` | 上传目录保留时长（小时） |
| `MAX_UPLOAD_MB` | `50` | 单次请求体上限 |
| `SECRET_KEY` | 内置默认值 | 生产环境请设置随机值 |
| `SESSION_COOKIE_SECURE` | `0` | HTTPS 部署时设为 `1` |

健康检查接口：`GET /healthz`，返回 `{"ok": true, "service": "power-quality-report"}`。

## 部署到腾讯云

> 注意：腾讯云 EdgeOne Pages / 静态网站托管只能放静态文件，**不能运行 Flask**。请选择下面任一方式。

### 方式 A：CloudBase 云托管（推荐，独立容器）

1. 打开腾讯云「云开发 CloudBase」控制台，进入「云托管」。
2. 新建服务：代码来源选 GitHub 仓库 `AChengLinus/power-quality-report`，构建方式选 Dockerfile。
3. 端口填 `8080`，实例规格按最小规格即可（生成报告主要吃 CPU/内存，1 核 2G 足够）。
4. 部署完成后，在「服务设置 → 自定义域名」绑定 `pq.acheng9616.com`，按提示到 DNS 添加 CNAME。
5. 把工具盒首页新增卡片指向该域名即可。

### 方式 B：轻量应用服务器 / CVM

```bash
# 服务器上
git clone https://github.com/AChengLinus/power-quality-report.git
cd power-quality-report
docker build -t power-quality-report .
docker run -d --name pq-report --restart=always -p 80:8080 power-quality-report
```

再用 Nginx 反向代理到 `127.0.0.1:80` 并配置 HTTPS 即可。

## 数据与隐私

- 上传文件只写入容器内的 `UPLOAD_ROOT`，不落数据库、不外传。
- 容器重启或重新部署后临时目录清空；超过 `SESSION_TTL_HOURS` 的目录会被定时清理。
- 报告在请求时生成，直接以附件返回。

## 本地接口自测

先启动应用（默认 5000 端口），然后：

```bash
python test_api.py
```
