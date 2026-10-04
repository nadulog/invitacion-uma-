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
  $graphics.PageUnit = [System.Drawing.GraphicsUnit]::Pixel
  $graphics.PageScale = 1
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

function Draw-CrystalThree($graphics) {
  $font = [System.Drawing.Font]::new('Times New Roman', 405, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $format = New-CenteredFormat
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $bounds = [System.Drawing.RectangleF]::new(128, 532, 405, 470)
  $path.AddString('3', $font.FontFamily, [int]$font.Style, $font.Size, $bounds, $format)

  $glow = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(55, 255, 255, 255), 13)
  $graphics.DrawPath($glow, $path)
  $glow.Dispose()

  $base = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.PointF]::new(0, 560),
    [System.Drawing.PointF]::new(0, 990),
    [System.Drawing.Color]::FromArgb(245, 250, 250, 250),
    [System.Drawing.Color]::FromArgb(215, 112, 112, 112)
  )
  $graphics.FillPath($base, $path)
  $base.Dispose()

  $state = $graphics.Save()
  $graphics.SetClip($path)
  $random = [System.Random]::new(31)
  $stepX = 48
  $stepY = 44
  for ($row = 0; $row -lt 11; $row++) {
    for ($col = 0; $col -lt 9; $col++) {
      $left = 130 + ($col * $stepX)
      $top = 545 + ($row * $stepY)
      $jitterX = $random.Next(-13, 14)
      $jitterY = $random.Next(-11, 12)
      $a = [System.Drawing.PointF]::new($left + $jitterX, $top + $jitterY)
      $b = [System.Drawing.PointF]::new($left + $stepX + $random.Next(-9, 10), $top + $random.Next(-9, 10))
      $c = [System.Drawing.PointF]::new($left + $stepX + $random.Next(-9, 10), $top + $stepY + $random.Next(-9, 10))
      $d = [System.Drawing.PointF]::new($left + $random.Next(-9, 10), $top + $stepY + $random.Next(-9, 10))
      $shadeA = $random.Next(52, 246)
      $shadeB = $random.Next(78, 256)
      $brushA = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($random.Next(185, 256), $shadeA, $shadeA, $shadeA))
      $brushB = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($random.Next(185, 256), $shadeB, $shadeB, $shadeB))
      $graphics.FillPolygon($brushA, @($a, $b, $c))
      $graphics.FillPolygon($brushB, @($a, $c, $d))
      $brushA.Dispose(); $brushB.Dispose()
      $facetPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(95, 255, 255, 255), 1)
      $graphics.DrawPolygon($facetPen, @($a, $b, $c, $d))
      $facetPen.Dispose()
    }
  }
  $graphics.Restore($state)

  $outline = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(238, 255, 255, 255), 2)
  $graphics.DrawPath($outline, $path)
  $outline.Dispose(); $path.Dispose(); $format.Dispose(); $font.Dispose()
}

# Fecha y hora
$image = New-Canvas 'fecha-base.png'
$graphics = Prepare-Graphics $image
$acuteA = [char]0x00C1
$acuteI = [char]0x00CD
$acuteO = [char]0x00D3
$middleDot = [char]0x00B7
$star = [char]0x2726

# Conservar la placa original de Emilia: solo se limpia el 2 y los dos renglones variables.
$originalOne = $image.Clone([System.Drawing.Rectangle]::new(450, 545, 235, 470), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
Fill-Dark $graphics 125 545 325 470 3
Fill-Dark $graphics 70 1015 724 125 3
Fill-Dark $graphics 245 1200 365 145 3

Draw-CrystalThree $graphics
$graphics.DrawImage($originalOne, 450, 545)
$originalOne.Dispose()

# Reponer las orbitas sobre el nuevo numero, manteniendo la estetica de la placa original.
$orbit = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(155, 218, 218, 218), 1.7)
$graphics.DrawEllipse($orbit, 60, 682, 742, 205)
$graphics.DrawEllipse($orbit, 106, 660, 650, 250)
$orbit.Dispose()

Draw-CenteredText $graphics "O C T U B R E  $middleDot  2 0 2 6" 35 70 1012 724 96
Draw-CenteredText $graphics '21:30 A 04:30 HS' 49 70 1190 724 110
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
