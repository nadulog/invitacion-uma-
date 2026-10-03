Add-Type -AssemblyName System.Drawing

$assetRoot = Join-Path $PSScriptRoot '..\assets'

function New-Canvas([string]$sourceName) {
  $source = Join-Path $assetRoot $sourceName
  return [System.Drawing.Bitmap]::FromFile($source)
}

function Save-Canvas($image, [string]$targetName) {
  $target = Join-Path $assetRoot $targetName
  $image.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
  $image.Dispose()
}

function New-CenteredFormat {
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center
  return $format
}

function Draw-CenteredText($graphics, [string]$text, [float]$size, [float]$x, [float]$y, [float]$width, [float]$height, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular, [string]$family = 'Times New Roman') {
  $font = [System.Drawing.Font]::new($family, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(238, 238, 238))
  $format = New-CenteredFormat
  $graphics.DrawString($text, $font, $brush, [System.Drawing.RectangleF]::new($x, $y, $width, $height), $format)
  $format.Dispose(); $brush.Dispose(); $font.Dispose()
}

function Prepare-Graphics($image) {
  $graphics = [System.Drawing.Graphics]::FromImage($image)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  return $graphics
}

function Fill-Dark($graphics, [float]$x, [float]$y, [float]$width, [float]$height, [int]$level = 0) {
  $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, $level, $level, $level))
  $graphics.FillRectangle($brush, $x, $y, $width, $height)
  $brush.Dispose()
}

# Fecha y hora
$image = New-Canvas 'fecha-base.png'
$graphics = Prepare-Graphics $image
Fill-Dark $graphics 70 430 724 930 4
$acuteA = [char]0x00C1
$acuteI = [char]0x00CD
$acuteO = [char]0x00D3
$middleDot = [char]0x00B7
$star = [char]0x2726
Draw-CenteredText $graphics "S $acuteA B A D O" 38 70 455 724 80

$dayFont = [System.Drawing.Font]::new('Times New Roman', 340, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$dayPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$dayFormat = New-CenteredFormat
$dayPath.AddString('31', $dayFont.FontFamily, [int]$dayFont.Style, $dayFont.Size, [System.Drawing.RectangleF]::new(90, 535, 684, 410), $dayFormat)
$dayBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.PointF]::new(0, 540), [System.Drawing.PointF]::new(0, 960), [System.Drawing.Color]::White, [System.Drawing.Color]::FromArgb(110, 110, 110))
$graphics.FillPath($dayBrush, $dayPath)
$outline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(245, 245, 245), 2)
$graphics.DrawPath($outline, $dayPath)
$orbit = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(150, 220, 220, 220), 2)
$graphics.DrawEllipse($orbit, 62, 690, 740, 200)
$graphics.DrawEllipse($orbit, 105, 665, 655, 245)
$orbit.Dispose(); $outline.Dispose(); $dayBrush.Dispose(); $dayPath.Dispose(); $dayFormat.Dispose(); $dayFont.Dispose()

Draw-CenteredText $graphics "O C T U B R E  $middleDot  2 0 2 6" 35 70 1000 724 90
Draw-CenteredText $graphics '21:30 A 04:30 HS' 49 70 1180 724 100
$graphics.Dispose()
Save-Canvas $image 'fecha.png'

# Ubicación
$image = New-Canvas 'ubicacion-base.png'
$graphics = Prepare-Graphics $image
Fill-Dark $graphics 50 315 764 520
Draw-CenteredText $graphics "C $acuteO M O   L L E G A R" 31 70 350 724 70
Draw-CenteredText $graphics 'NACA EVENTOS' 78 55 455 754 120
Draw-CenteredText $graphics 'D A R D O   R O C H A   1 7 5 0' 27 65 650 734 55
Draw-CenteredText $graphics "M A R T $acuteI N E Z" 29 65 715 734 55
$graphics.Dispose()
Save-Canvas $image 'ubicacion.png'

# Dress code
$image = New-Canvas 'dress-code-base.png'
$graphics = Prepare-Graphics $image
Fill-Dark $graphics 205 565 500 440
Fill-Dark $graphics 700 565 85 180
Draw-CenteredText $graphics 'ELEGANTE' 81 205 620 500 120
Draw-CenteredText $graphics 'EVITAR COLORES' 25 205 805 500 45
Draw-CenteredText $graphics "PLATEADO  $middleDot  GRIS" 38 205 850 500 70
$graphics.Dispose()
Save-Canvas $image 'dress-code.png'

# Datos para regalos
$image = New-Canvas 'regalos-datos-base.png'
$graphics = Prepare-Graphics $image
Fill-Dark $graphics 170 565 600 105 7
Fill-Dark $graphics 300 790 330 90 7
Fill-Dark $graphics 260 925 420 160 7
Draw-CenteredText $graphics 'Uma Hidalgo' 55 165 565 535 95
Draw-CenteredText $graphics 'UMIFESTXV' 57 165 790 535 95
$graphics.Dispose()
Save-Canvas $image 'regalos-datos-uma.png'

# Fecha límite de confirmación
$image = New-Canvas 'rsvp-base.png'
$graphics = Prepare-Graphics $image
Fill-Dark $graphics 170 900 524 90
Draw-CenteredText $graphics "CONFIRMAR ANTES DEL 26 $middleDot 10 $middleDot 2026" 21 170 912 524 55
$graphics.Dispose()
Save-Canvas $image 'rsvp.png'

Write-Output 'Recursos gráficos de Uma generados.'
