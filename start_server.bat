@echo off
chcp 65001 >nul
echo ========================================================
echo   PEA Financial Planner - Mobile Web Server
echo ========================================================
echo.
echo กำลังเปิดเซิร์ฟเวอร์สำหรับใช้งานบนมือถือ...
echo.
echo [1] บนคอมพิวเตอร์: เปิดเบราว์เซอร์ไปที่ http://localhost:8080
echo [2] บนมือถือ (WiFi เดียวกัน): เปิดเบราว์เซอร์ไปที่ http://172.30.139.169:8080
echo.
echo (กดปิดหน้าต่างนี้เมื่อต้องการหยุดการทำงาน)
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$listener = New-Object System.Net.HttpListener; ^
$listener.Prefixes.Add('http://*:8080/'); ^
$listener.Prefixes.Add('http://localhost:8080/'); ^
try { $listener.Start() } catch { Write-Host 'Cannot bind port 8080, trying localhost only...'; $listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add('http://localhost:8080/'); $listener.Start() }; ^
Write-Host 'Server started at http://localhost:8080'; ^
$folder = '%~dp0'; ^
while ($listener.IsListening) { ^
    $context = $listener.GetContext(); ^
    $request = $context.Request; ^
    $response = $context.Response; ^
    $rawUrl = $request.Url.LocalPath; ^
    if ($rawUrl -eq '/') { $rawUrl = '/index.html' }; ^
    $filePath = [System.IO.Path]::Combine($folder, $rawUrl.TrimStart('/')); ^
    if ([System.IO.File]::Exists($filePath)) { ^
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower(); ^
        $contentType = switch ($ext) { ^
            '.html' { 'text/html; charset=utf-8' } ^
            '.json' { 'application/json; charset=utf-8' } ^
            '.svg'  { 'image/svg+xml' } ^
            '.js'   { 'application/javascript; charset=utf-8' } ^
            '.css'  { 'text/css; charset=utf-8' } ^
            default { 'application/octet-stream' } ^
        }; ^
        $bytes = [System.IO.File]::ReadAllBytes($filePath); ^
        $response.ContentType = $contentType; ^
        $response.ContentLength64 = $bytes.Length; ^
        $response.OutputStream.Write($bytes, 0, $bytes.Length); ^
    } else { ^
        $response.StatusCode = 404; ^
    }; ^
    $response.Close(); ^
}"
pause
