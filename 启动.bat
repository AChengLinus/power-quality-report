@echo off
chcp 65001 >nul
title 电能质量报告生成工具

echo.
echo ╔════════════════════════════════════════════╗
echo ║   电能质量测试数据汇总报告生成工具          ║
echo ║   Power Quality Report Generator           ║
echo ╚════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

:: 检查 Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Python，请先安装 Python 3
    pause
    exit /b 1
)

:: 检查依赖
python -c "import flask, pandas, docx, xlrd" >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 正在安装依赖...
    python -m pip install -r requirements.txt -q
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败，请手动执行:
        echo   python -m pip install -r requirements.txt
        pause
        exit /b 1
    )
)

:: 获取本机 IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do set LOCAL_IP=%%a
set LOCAL_IP=%LOCAL_IP: =%

:: 启动
echo [启动] 正在启动服务器...
echo.
echo   本机访问:   http://localhost:5000
if defined LOCAL_IP echo   局域网访问: http://%LOCAL_IP%:5000
echo.
echo   按 Ctrl+C 停止
echo ============================================================
echo.

start "" http://localhost:5000

python app.py

pause
