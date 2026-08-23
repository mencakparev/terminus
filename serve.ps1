param([int]$Port = 8080)

$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$Port/"

$mime = @{
  ".html" = "text/html"; ".htm" = "text/html"; ".css" = "text/css"; ".js" = "application/javascript";
  ".json" = "application/json"; ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"; ".png" = "image/png";
  ".svg" = "image/svg+xml"; ".webp" = "image/webp"; ".ico" = "image/x-icon"; ".xml" = "application/xml";
  ".txt" = "text/plain"; ".woff" = "font/woff"; ".woff2" = "font/woff2"; ".ttf" = "font/ttf"; ".otf" = "font/otf"
}

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $req = $context.Request
  $res = $context.Response
  try {
    $path = [Uri]::UnescapeDataString($req.Url.AbsolutePath)
    if ($path -eq "/") { $path = "/index.html" }
    $filePath = Join-Path $root ($path.TrimStart("/"))

    if (Test-Path $filePath -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($filePath)
      $contentType = $mime[$ext]
      if (-not $contentType) { $contentType = "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($filePath)
      $res.ContentType = $contentType
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $notFoundPath = Join-Path $root "404.html"
      if (Test-Path $notFoundPath) {
        $bytes = [System.IO.File]::ReadAllBytes($notFoundPath)
        $res.ContentType = "text/html"
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      } else {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      }
    }
  } catch {
    $res.StatusCode = 500
  } finally {
    $res.OutputStream.Close()
  }
}
