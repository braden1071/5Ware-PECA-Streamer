Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Add Win32 API functions for dragging
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    public const int WM_NCLBUTTONDOWN = 0xA1;
    public const int HTCAPTION = 0x2;

    [DllImport("user32.dll")]
    public static extern bool ReleaseCapture();

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$consolePtr = [Win32]::GetConsoleWindow()
[Win32]::ShowWindow($consolePtr, 0)  # 0 = Hide, 5 = Show

# -----------------------------
# FUNCTION: Rounded corners
# -----------------------------
function Set-RoundedForm {
    param (
        [System.Windows.Forms.Form]$Form,
        [int]$Radius = 25
    )

    $rect = New-Object System.Drawing.Rectangle(0,0,$Form.Width,$Form.Height)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath

    $diameter = $Radius * 2
    $path.AddArc($rect.X, $rect.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($rect.Right - $diameter, $rect.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($rect.Right - $diameter, $rect.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()

    $Form.Region = New-Object System.Drawing.Region($path)
}

# -----------------------------
# HIDE POWERSHELL CONSOLE WINDOW (preserve this original logic)
# -----------------------------
#Add-Type @"
#using System;
#using System.Runtime.InteropServices;
#public class Win32Hide {
#    [DllImport("kernel32.dll")]
#    public static extern IntPtr GetConsoleWindow();
#
#    [DllImport("user32.dll")]
#    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
#}
#"@

#$consolePtr = [Win32Hide]::GetConsoleWindow()
#[Win32Hide]::ShowWindow($consolePtr, 0)  # 0 = Hide

# -----------------------------
# FORM SETUP
# -----------------------------
$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(600, 625)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$Form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
Set-RoundedForm -Form $Form -Radius 25
$Form.GetType().GetProperty("DoubleBuffered",
    [Reflection.BindingFlags] "Instance,NonPublic"
).SetValue($Form, $true, $null)

# -----------------------------
# TITLE LABEL
# -----------------------------
$label = New-Object System.Windows.Forms.Label
$label.Text = "5Ware"
$label.AutoSize = $true
$label.BackColor = [System.Drawing.Color]::Transparent
$label.ForeColor = [System.Drawing.Color]::FromArgb(140, 70, 100, 200)  # Original style color
$label.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$label.Location = New-Object System.Drawing.Point(20, 14)  # Adjust position as needed
$Form.Controls.Add($label)

# -----------------------------
# CLOSE BUTTON (apple style)
# -----------------------------
$Margin = 22
$ButtonSpacing = 8

$CloseLabel = New-Object System.Windows.Forms.Label
$CloseLabel.Size = New-Object System.Drawing.Size(18, 18)
$CloseLabel.BackColor = [System.Drawing.Color]::Transparent
$CloseLabel.ForeColor = [System.Drawing.Color]::White
$CloseLabel.Cursor = [System.Windows.Forms.Cursors]::Hand
$CloseLabel.TextAlign = 'MiddleCenter'

$CloseLabel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $color = if ($CloseLabel.Tag -eq "hover") {
        [System.Drawing.Color]::FromArgb(255, 90, 90)
    } else {
        [System.Drawing.Color]::FromArgb(230, 70, 70)
    }
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $brush = New-Object System.Drawing.SolidBrush $color
    $g.FillEllipse($brush, 1, 1, $CloseLabel.Width - 2, $CloseLabel.Height - 2)
    $brush.Dispose()

    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 1)
    $centerX = $CloseLabel.Width / 2
    $centerY = $CloseLabel.Height / 2
    $half = 3
    $g.DrawLine($pen, $centerX - $half, $centerY - $half, $centerX + $half, $centerY + $half)
    $g.DrawLine($pen, $centerX - $half, $centerY + $half, $centerX + $half, $centerY - $half)
    $pen.Dispose()
})

$CloseLabel.Add_MouseEnter({
    $CloseLabel.Tag = "hover"
    $CloseLabel.Invalidate()
})
$CloseLabel.Add_MouseLeave({
    $CloseLabel.Tag = ""
    $CloseLabel.Invalidate()
})
$CloseLabel.Add_Click({ $Form.Close() })

# -----------------------------
# MINIMIZE BUTTON (apple style)
# -----------------------------
$MinimizeLabel = New-Object System.Windows.Forms.Label
$MinimizeLabel.Size = New-Object System.Drawing.Size(18, 18)
$MinimizeLabel.BackColor = [System.Drawing.Color]::Transparent
$MinimizeLabel.ForeColor = [System.Drawing.Color]::White
$MinimizeLabel.Cursor = [System.Windows.Forms.Cursors]::Hand
$MinimizeLabel.TextAlign = 'MiddleCenter'

$MinimizeLabel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $color = if ($MinimizeLabel.Tag -eq "hover") {
        [System.Drawing.Color]::FromArgb(100, 190, 90)
    } else {
        [System.Drawing.Color]::FromArgb(85, 160, 80)
    }
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $brush = New-Object System.Drawing.SolidBrush $color
    $g.FillEllipse($brush, 1, 1, $MinimizeLabel.Width - 2, $MinimizeLabel.Height - 2)
    $brush.Dispose()

    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 1)
    $centerX = $MinimizeLabel.Width / 2
    $centerY = $MinimizeLabel.Height / 2
    $half = 4
    $g.DrawLine($pen, $centerX - $half, $centerY, $centerX + $half, $centerY)
    $pen.Dispose()
})

$MinimizeLabel.Add_MouseEnter({
    $MinimizeLabel.Tag = "hover"
    $MinimizeLabel.Invalidate()
})
$MinimizeLabel.Add_MouseLeave({
    $MinimizeLabel.Tag = ""
    $MinimizeLabel.Invalidate()
})
$MinimizeLabel.Add_Click({
    $Form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
})

# -----------------------------
# POSITION WINDOW BUTTONS
# -----------------------------
function Update-WindowButtonsPosition {
    param($Form, $CloseBtn, $MinBtn)
    $xClose = $Form.ClientSize.Width - $CloseBtn.Width - $Margin
    $yClose = $Margin
    $CloseBtn.Location = New-Object System.Drawing.Point($xClose, $yClose)

    $xMin = $xClose - $MinBtn.Width - $ButtonSpacing
    $yMin = $Margin
    $MinBtn.Location = New-Object System.Drawing.Point($xMin, $yMin)
}

Update-WindowButtonsPosition -Form $Form -CloseBtn $CloseLabel -MinBtn $MinimizeLabel
$Form.Add_Resize({ Update-WindowButtonsPosition -Form $Form -CloseBtn $CloseLabel -MinBtn $MinimizeLabel })
$Form.Controls.Add($CloseLabel)
$Form.Controls.Add($MinimizeLabel)

# -----------------------------
# MAKE FORM DRAGGABLE
# -----------------------------
$Form.Add_MouseDown({
    if ($_.Button -eq 'Left') {
        [Win32]::ReleaseCapture()
        [Win32]::SendMessage($Form.Handle, [Win32]::WM_NCLBUTTONDOWN, [Win32]::HTCAPTION, 0)
    }
})

# -----------------------------
# LOAD ICON FROM WEB
# -----------------------------
$iconUrl = "https://cdn.discordapp.com/attachments/1157150426106437677/1437819789325369354/favicon.ico?ex=691fd647&is=691e84c7&hm=92047e14520191d9392fab2a6afa2160f9f011a7ce41cd87a44bb8a3f6ccf553&"
try {
    $wc = New-Object System.Net.WebClient
    $iconBytes = $wc.DownloadData($iconUrl)
    $ms = New-Object System.IO.MemoryStream(,$iconBytes)
    $Form.Icon = New-Object System.Drawing.Icon($ms)
} catch {
    Write-Host "Failed to load icon from URL."
}

# -----------------------------
# FONTS
# -----------------------------
$font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$headerFont = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$subHeaderFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)

# -----------------------------
# MODS DATA
# -----------------------------
$mods = @(
    @{Name="One Shot";             URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/streamedpeds_players.rpf"},
    @{Name="No Recoil";            URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/pedprops.rpf"; File="pedprops.rpf"},
    @{Name="Soft Aimbot";          URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/grassparticlesfx.rpf"; File="grassparticlesfx.rpf"},
    @{Name="Hard Aimbot";          URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/grassparticlesfxx.rpf"},
    @{Name="Fast Reload";          URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/SCRIPT.rpf"; File="SCRIPT.rpf"},
    @{Name="Magic Bullets";        URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/common.rpf"; File="common.rpf"},
    @{Name="No Fall Damage";       URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/Player.rpf"; File="Player.rpf"},
    @{Name="Quick Reactions";      URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/RADIO_X.rpf"; File="RADIO_X.rpf"},
    @{Name="Infinite Stamina";     URL="https://github.com/braden1071/5Ware-SoftwareFiveM/raw/refs/heads/main/update.rpf"; File="update.rpf"}
)

# -----------------------------
# CHECKBOXES PANEL (MOD LIST)
# -----------------------------
$checkboxes = @()
$modsPanel = New-Object System.Windows.Forms.Panel
$modsPanel.Location = New-Object System.Drawing.Point(40, 255)
$modsPanel.Size = New-Object System.Drawing.Size(520, 110)
$modsPanel.BackColor = [System.Drawing.Color]::FromArgb(24,26,32)
$modsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$modsPanel.AutoScroll = $true
$Form.Controls.Add($modsPanel)

$startX = 12
$startY = 12
$spacingX = 195
$spacingY = 30
$columns = 3

for ($i = 0; $i -lt $mods.Count; $i++) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $mods[$i].Name
    $cb.Font = $font
    $cb.ForeColor = [System.Drawing.Color]::FromArgb(220,220,230)
    $cb.AutoSize = $true
    $cb.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $cb.BackColor = $modsPanel.BackColor

    $col = $i % $columns
    $row = [math]::Floor($i / $columns)

    $xPos = $startX + ($col * $spacingX)
    $yPos = $startY + ($row * $spacingY)
    $cb.Location = New-Object System.Drawing.Point($xPos, $yPos)

    $modsPanel.Controls.Add($cb)
    $checkboxes += $cb
}

# -----------------------------
# FUNCTION: Rounded Panel to Checkbox
# -----------------------------
function Set-RoundedPanel {
    param (
        [System.Windows.Forms.Panel]$Panel,
        [int]$Radius = 15
    )

    $rect = New-Object System.Drawing.Rectangle(0, 0, $Panel.Width, $Panel.Height)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath

    $diameter = $Radius * 2
    $path.AddArc($rect.X, $rect.Y, $diameter, $diameter, 190, 90)                    # top-left tweak
    $path.AddArc($rect.Right - $diameter, $rect.Y, $diameter, $diameter, 250, 90)    # top-right tweak
    $path.AddArc($rect.Right - $diameter, $rect.Bottom - $diameter, $diameter, $diameter, 10, 90) # bottom-right tweak
    $path.AddArc($rect.X, $rect.Bottom - $diameter, $diameter, $diameter, 100, 90)   # bottom-left tweak
    $path.CloseFigure()

    $Panel.Region = New-Object System.Drawing.Region($path)
}

# Apply rounded corners to the mods panel
Set-RoundedPanel -Panel $modsPanel -Radius 15

# Optional: Update region if panel is resized
$modsPanel.Add_Resize({ Set-RoundedPanel -Panel $modsPanel -Radius 15 })

# -----------------------------
# STATUS PANEL
# -----------------------------
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Location = New-Object System.Drawing.Point(40, 390)
$statusPanel.Size = New-Object System.Drawing.Size(520, 140)
$statusPanel.BackColor = [System.Drawing.Color]::FromArgb(18,20,26)
$statusPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$statusPanel.Padding = New-Object System.Windows.Forms.Padding(6)
$Form.Controls.Add($statusPanel)

$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.ReadOnly = $true
$statusBox.ScrollBars = "Vertical"
$statusBox.BackColor = [System.Drawing.Color]::FromArgb(12,14,18)
$statusBox.ForeColor = [System.Drawing.Color]::FromArgb(130,220,140)
$statusBox.BorderStyle = "None"
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$statusBox.Location = New-Object System.Drawing.Point(6, 6)
$statusBox.Size = New-Object System.Drawing.Size(504, 128)
$statusPanel.Controls.Add($statusBox)

function Write-Status {
    param($text)
    if ($statusBox.InvokeRequired) {
        $null = $statusBox.Invoke([Action]{ Write-Status $text })
    } else {
        $statusBox.AppendText("$text`r`n")
        $statusBox.SelectionStart = $statusBox.Text.Length
        $statusBox.ScrollToCaret()
    }
}

# -----------------------------
# BUTTONS (Load & Discord)
# -----------------------------
function Get-ImageFromUrl($url) {
    try {
        $wc = New-Object System.Net.WebClient
        $bytes = $wc.DownloadData($url)
        $stream = New-Object System.IO.MemoryStream(,$bytes)
        return [System.Drawing.Image]::FromStream($stream)
    } catch {
        Write-Host "Failed to load image from URL: $url"
        return $null
    }
}

# -----------------------------
# DISCORD BUTTON
# -----------------------------
$discordImage = Get-ImageFromUrl "https://img.icons8.com/?size=50&id=61604&format=png"

if ($discordImage) {
    $btnDiscord = New-Object System.Windows.Forms.PictureBox
    $btnDiscord.Size = New-Object System.Drawing.Size(50,50)          # Force 50x50
    $btnDiscord.Location = New-Object System.Drawing.Point(277,555)
    $btnDiscord.Image = $discordImage
    $btnDiscord.SizeMode = 'StretchImage'
    $btnDiscord.BackColor = [System.Drawing.Color]::Transparent
    $btnDiscord.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnDiscord.Add_Click({ Start-Process "https://discord.gg/aVT27gryay" })
    $Form.Controls.Add($btnDiscord)
}

# -----------------------------
# SUPPORT BUTTON
# -----------------------------
$discordImage = Get-ImageFromUrl "https://cdn-icons-png.flaticon.com/512/7413/7413914.png"

if ($discordImage) {
    $btnDiscord = New-Object System.Windows.Forms.PictureBox
    $btnDiscord.Size = New-Object System.Drawing.Size(46,46)          # Force 50x50
    $btnDiscord.Location = New-Object System.Drawing.Point(480,555)
    $btnDiscord.Image = $discordImage
    $btnDiscord.SizeMode = 'StretchImage'
    $btnDiscord.BackColor = [System.Drawing.Color]::Transparent
    $btnDiscord.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnDiscord.Add_Click({ Start-Process "https://discord.gg/uyeQ3GBXg7" })
    $Form.Controls.Add($btnDiscord)
}

# -----------------------------
# LOAD BUTTON
# -----------------------------
$loadImage = Get-ImageFromUrl "https://cdn-icons-png.freepik.com/512/8371/8371002.png" # Must be PNG with transparency

if ($loadImage) {
    $btnLoad = New-Object System.Windows.Forms.PictureBox
    $btnLoad.Size = New-Object System.Drawing.Size(50,50)              # Force 50x50
    $btnLoad.Location = New-Object System.Drawing.Point(67,555)
    $btnLoad.Image = $loadImage
    $btnLoad.SizeMode = 'StretchImage'
    $btnLoad.BackColor = [System.Drawing.Color]::Transparent
    $btnLoad.Cursor = [System.Windows.Forms.Cursors]::Hand
    $Form.Controls.Add($btnLoad)
}
# -----------------------------
# End of BUTTONS (Load & Discord)
# -----------------------------



# -----------------------------
# ANIMATED SWIRLING PULSATING SPIRAL (Wider)
# -----------------------------
# Enable double buffering
$Form.GetType().GetProperty("DoubleBuffered", [Reflection.BindingFlags] "Instance,NonPublic").SetValue($Form, $true, $null)

$clientWidth = [int]$Form.ClientSize.Width
$clientHeight = [int]$Form.ClientSize.Height
$centerX = $clientWidth / 2
$centerY = $clientHeight / 2

$script:__ui_rand = New-Object System.Random
$script:__ui_particles = @()
$particleCount = 60

# Spiral settings
$script:__ui_angle = 0
# Increased the max radius to allow particles to spread wider
$script:__ui_radiusMax = [math]::Min($clientWidth, $clientHeight) / 2 - 5
$script:__ui_pulsePhase = 0

for ($i = 0; $i -lt $particleCount; $i++) {
    $pobj = [PSCustomObject]@{
        index = $i
        color = [System.Drawing.Color]::FromArgb(180, 80 + $script:__ui_rand.Next(0, 80), 50 + $script:__ui_rand.Next(0, 80), 200 + $script:__ui_rand.Next(0, 55))
        size = 4 + $script:__ui_rand.Next(2, 6)
        offset = $i / $particleCount * 2 * [math]::PI
        swirlSpeed = ($script:__ui_rand.NextDouble() * 0.04 + 0.01) * (-1 + 2 * $script:__ui_rand.NextDouble())
        # Increased swingFactor range to 0.5–1.0 -> wider swing to edges
        swingFactor = 0.6 + $script:__ui_rand.NextDouble() * 0.6
    }
    $script:__ui_particles += $pobj
}

$Form.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $rect = $sender.ClientRectangle

    # Background gradient
    $c1 = [System.Drawing.Color]::FromArgb(15, 10, 30, 60)
    $c2 = [System.Drawing.Color]::FromArgb(15, 60, 10, 90)
    $lg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $c1, $c2, 90)
    $g.FillRectangle($lg, $rect)
    $lg.Dispose()

    # Draw spiral particles
    foreach ($p in $script:__ui_particles) {
        # Pulsating radius
        $pulse = [math]::Sin($script:__ui_pulsePhase + $p.index * 0.2) * 0.25 + 1.0
        $radius = $p.index / $particleCount * $script:__ui_radiusMax * $pulse * $p.swingFactor

        # Swirl angle
        $angle = $script:__ui_angle + $p.offset + $p.swirlSpeed * $p.index

        # Convert to X,Y
        $x = $centerX + $radius * [math]::Cos($angle)
        $y = $centerY + $radius * [math]::Sin($angle)

        $brush = New-Object System.Drawing.SolidBrush($p.color)
        $r = [int]($p.size * $pulse)
        $g.FillEllipse($brush, [int]($x - $r/2), [int]($y - $r/2), $r, $r)
        $brush.Dispose()
    }
     # Draw spiral particles (second pass)
    foreach ($p in $script:__ui_particles) {
        $angle = $script:__ui_angle + $p.offset
        $pulse = [math]::Sin($script:__ui_pulsePhase + $p.index * 0.2) * 0.25 + 1.0
        $radius = $p.index / $particleCount * $script:__ui_radiusMax * $pulse
        $x = $centerX + $radius * [math]::Cos($angle)
        $y = $centerY + $radius * [math]::Sin($angle)

        $brush = New-Object System.Drawing.SolidBrush($p.color)
        $r = [int]($p.size * $pulse)
        $g.FillEllipse($brush, [int]($x - $r/2), [int]($y - $r/2), $r, $r)
        $brush.Dispose()
    }
})

# Timer for animation
$script:__ui_anim_timer = New-Object System.Windows.Forms.Timer
$script:__ui_anim_timer.Interval = 33  # ~30 FPS
$script:__ui_anim_timer.Add_Tick({
    $script:__ui_angle += 0.02        # Main spiral rotation
    $script:__ui_pulsePhase += 0.08   # Pulsation phase
    $Form.Invalidate()
})
$script:__ui_anim_timer.Start()

$Form.Add_Disposed({
    try { if ($script:__ui_anim_timer) { $script:__ui_anim_timer.Stop(); $script:__ui_anim_timer.Dispose() } } catch {}
})

# -----------------------------
# PATH SETUP
# -----------------------------
$FIVEM_PATH = "$env:LOCALAPPDATA\FiveM\FiveM.app\mods"
$FAILED_MODS = @()
$global:ERROR_INFO_SHOWN = $false

# -----------------------------
# LOGIC FUNCTIONS: Wait for FiveM, Wait for Close
# -----------------------------
function Wait-ForFiveM {
    Start-Sleep -Seconds 4
    $statusBox.Invoke([Action]{
        $statusBox.Clear()
        foreach ($cb in $checkboxes) { $cb.Enabled = $true }
        $btnLoad.Enabled = $true
        Write-Status "GUI refreshed. Ready to reload."
    })

    Write-Status "Waiting for FiveM to start..."
    for ($i = 0; $i -lt 60; $i++) {
        $fivem = Get-Process -Name FiveM -ErrorAction SilentlyContinue
        $fivemApp = Get-Process -Name FiveMApp -ErrorAction SilentlyContinue
        if ($fivem -or $fivemApp) {
            Write-Status "FiveM detected, starting mod processing..."
            return $true
        }
        Start-Sleep -Seconds 1
    }
    Write-Status "FiveM did not start within 60 seconds."
    return $false
}

function Wait-ForClose {
    Write-Status "Waiting for FiveM to close..."
    while ($true) {
        $fivem = Get-Process -Name FiveM -ErrorAction SilentlyContinue
        $fivemApp = Get-Process -Name FiveMApp -ErrorAction SilentlyContinue
        if (-not $fivem -and -not $fivemApp) { break }
        Start-Sleep -Seconds 2
    }
    Write-Status "FiveM closed. Cleaning up..."
}

# -----------------------------
# BUTTON CLICK EVENTS
# -----------------------------

$btnLoad.Add_Click({
    $selected = @()
    for ($i = 0; $i -lt $checkboxes.Count; $i++) {
        if ($checkboxes[$i].Checked) { $selected += $mods[$i] }
    }

    if ($selected.Count -eq 0) {
        Write-Status "No mods selected."
        return
    }

    # Freeze checkboxes and Load button, preserving colors
    $btnLoad.Enabled = $false
    foreach ($cb in $checkboxes) { 
        $cb.Tag = $cb.BackColor
        $cb.Enabled = $false
        $cb.BackColor = $cb.Tag
    }

    # Create runspace for background loading
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()

    $ps = [powershell]::Create()
    $ps.Runspace = $runspace

    $ps.AddScript({
        param($selectedMods, $fivemPath, $statusBox, $checkboxes, $btnLoad)

        $FAILED_MODS_RUNSPACE = @()
        $SUCCESSFUL_MODS = @()

        function Write-StatusInGUI($text) {
            $statusBox.Invoke([Action]{
                $statusBox.AppendText("$text`r`n")
                $statusBox.SelectionStart = $statusBox.Text.Length
                $statusBox.ScrollToCaret()
            })
        }

        function Wait-ForFiveMInRunspace {
            Write-StatusInGUI "Waiting for FiveM to start..."
            while ($true) {
                $fivem = Get-Process -Name FiveM -ErrorAction SilentlyContinue
                $fivemApp = Get-Process -Name FiveMApp -ErrorAction SilentlyContinue
                if ($fivem -or $fivemApp) {
                    Write-StatusInGUI "FiveM detected, starting mod processing..."
                    Start-Sleep -Seconds 4
                    $statusBox.Invoke([Action]{
                        $statusBox.Clear()
                    })
                    return $true
                }
                Start-Sleep -Seconds 1
            }
        }

        function Wait-ForCloseInRunspace {
            Start-Sleep -Seconds 1
            $statusBox.Invoke([Action]{
                $statusBox.Clear()
            })

            Write-StatusInGUI "Waiting for FiveM to close..."
            while ($true) {
                $fivem = Get-Process -Name FiveM -ErrorAction SilentlyContinue
                $fivemApp = Get-Process -Name FiveMApp -ErrorAction SilentlyContinue
                if (-not $fivem -and -not $fivemApp) { break }
                Start-Sleep -Seconds 2
            }
            Write-StatusInGUI "FiveM closed. Cleaning up..."
            try {
                if (Test-Path $fivemPath) {
                    Remove-Item -Path $fivemPath -Recurse -Force -ErrorAction SilentlyContinue
                    Write-StatusInGUI "Cleanup complete."
                    Start-Sleep -Seconds 1
                    $statusBox.Invoke([Action]{
                        $statusBox.Clear()
                    })
                }
            } catch {
                Write-StatusInGUI "Failed to delete mods folder."
            }

            $statusBox.Invoke([Action]{
                foreach ($cb in $checkboxes) { 
                    $cb.Enabled = $true
                    $cb.BackColor = $cb.Tag
                }
                $btnLoad.Enabled = $true
            })
        }

        if (!(Test-Path $fivemPath)) {
            if (Wait-ForFiveMInRunspace) {
                New-Item -ItemType Directory -Path $fivemPath | Out-Null
                Write-StatusInGUI "Created folder: $fivemPath"
                try { attrib +h +s $fivemPath; Write-StatusInGUI "Folder hidden successfully." } catch { Write-StatusInGUI "Failed to hide folder." }
            } else {
                Write-StatusInGUI "FiveM not detected, mods folder not created."
                return
            }
        }

        foreach ($m in $selectedMods) {
            $filePath = Join-Path $fivemPath ([System.IO.Path]::GetFileName($m.URL))
            try {
                Invoke-WebRequest -Uri $m.URL -OutFile $filePath -ErrorAction Stop
                Write-StatusInGUI "$($m.Name) - Loaded successfully"
                $SUCCESSFUL_MODS += $m.Name
            } catch {
                Write-StatusInGUI "FAILED: $($m.Name)"
                $FAILED_MODS_RUNSPACE += $m.Name
            }
        }

        if (($FAILED_MODS_RUNSPACE.Count -gt 0) -and (-not $global:ERROR_INFO_SHOWN)) {
            if ($SUCCESSFUL_MODS.Count -eq 0) {
                Write-StatusInGUI "`nNo mods were downloaded."
            }

            Write-StatusInGUI "`n[INFO] The following mods failed to load:"
            foreach ($m in $FAILED_MODS_RUNSPACE) { Write-StatusInGUI "[ERROR] - $m" }

            Write-StatusInGUI "`n5Ware [INFO] - 1. If You Are Receiving This Message That Means You Hit a Roadblock Make a Ticket.."
            Write-StatusInGUI "5Ware [INFO] - 2. Once you have made a Ticket in the 5Ware Discord Send Us the ERROR Code.."
            Write-StatusInGUI "5Ware [INFO] - 3. Joining the Discord is Required to get Support.."
            Write-StatusInGUI "5Ware [ERROR] - [Code: xX9b7K1S2]"

            Start-Process "https://discord.gg/uyeQ3GBXg7"
            $global:ERROR_INFO_SHOWN = $true

            [System.Windows.Forms.MessageBox]::Show("Some mods failed to load. Press OK to continue...", "5Ware Info", "OK", "Information")
        }

        Wait-ForCloseInRunspace
        
        Start-Sleep -Seconds 1
        $statusBox.Invoke([Action]{
            $statusBox.Clear()
            foreach ($cb in $checkboxes) { $cb.Enabled = $true }
            $btnLoad.Enabled = $true
        })
        
    }).AddArgument($selected).AddArgument($FIVEM_PATH).AddArgument($statusBox).AddArgument($checkboxes).AddArgument($btnLoad)

    $asyncResult = $ps.BeginInvoke()

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 200
    $timer.Add_Tick({
        if ($ps.InvocationStateInfo.State -eq 'Completed') {
            $timer.Stop()
            $ps.Dispose()
            $runspace.Close()
        }
    })
    $timer.Start()
})

# -----------------------------
# CLOSE FORM EVENT: Cleanup mods & kill FiveM process safely
# -----------------------------
$Form.Add_FormClosing({
    $fivem = Get-Process -Name "FiveM" -ErrorAction SilentlyContinue
    if ($fivem) {
        [System.Windows.Forms.MessageBox]::Show("Closing GUI will terminate FiveM. Please wait...","Warning","OK","Warning") | Out-Null
        foreach ($p in $fivem) { try { $p.Kill() } catch {} }
        do { Start-Sleep -Milliseconds 500; $fivem = Get-Process -Name "FiveM" -ErrorAction SilentlyContinue } while ($fivem)
    }
    if (Test-Path $FIVEM_PATH) {
        try { Remove-Item -Path $FIVEM_PATH -Recurse -Force -ErrorAction SilentlyContinue } catch { [System.Windows.Forms.MessageBox]::Show("Failed to delete mods folder.","Error","OK","Error") | Out-Null }
    }
})

# -----------------------------
# FADE-IN EFFECT ON SHOW
# -----------------------------
$Form.Opacity = 0.0
$fadeTimer = New-Object System.Windows.Forms.Timer
$fadeTimer.Interval = 20
$fadeTimer.Add_Tick({
    try {
        $Form.Invoke([Action]{
            if ($Form.Opacity -lt 1.0) {
                $Form.Opacity = [math]::Min(1.0, $Form.Opacity + 0.03)
            } else {
                $null = $fadeTimer.Stop()
                $fadeTimer.Dispose()
            }
        })
    } catch {}
})
$Form.Add_Shown({ try { $fadeTimer.Start() } catch {} })

# -----------------------------
# RUN THE FORM
# -----------------------------
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($Form)