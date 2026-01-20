Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);

    [DllImport("winmm.dll")]
    public static extern uint timeBeginPeriod(uint uMilliseconds);

    [DllImport("kernel32.dll")]
    public static extern void Sleep(uint dwMilliseconds);

    public const int LEFTDOWN = 0x02;
    public const int LEFTUP   = 0x04;
    public const int RIGHTDOWN= 0x08;
    public const int RIGHTUP  = 0x10;
}
"@

# 1. Force High Precision
[Win32]::timeBeginPeriod(1)

# 2. Prevent Windows Efficiency Mode Throttling
$process = [System.Diagnostics.Process]::GetCurrentProcess()
$process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::RealTime

# 3. Data Pattern
$config = @(
    @(13,34), @(13,37), @(15,34), @(13,15), @(39,29), @(15,13), @(17,13), @(16,12), @(32,39), @(14,15), @(16,36), @(13,17), @(18,37), @(14,12), @(22,36), @(14,12), @(37,24), @(15,10), @(35,40),
    @(13,15), @(38,24), @(14,11), @(27,38), @(13,16), @(37,19), @(14,13), @(26,36), @(12,16), @(37,24), @(15,11), @(25,39), @(14,16), @(34,27), @(14,11), @(34,38), @(13,15), @(39,20), @(13,12),
    @(31,38), @(13,14), @(42,19), @(13,16), @(36,41), @(13,16), @(37,18), @(15,14), @(37,34), @(12,17), @(40,25), @(14,10), @(37,33), @(12,14), @(38,29), @(13,16), @(29,37), @(14,13), @(35,21),
    @(15,10), @(38,29), @(12,15), @(39,17), @(14,15), @(40,34), @(14,15), @(37,13), @(14,19), @(21,35), @(12,10), @(36,11), @(15,14), @(23,32), @(13,12), @(36,23), @(14,15), @(21,35), @(13,15),
    @(40,25), @(15,11), @(39,34), @(13,14), @(38,24), @(15,12), @(30,40), @(13,15), @(38,21), @(14,11), @(22,37), @(16,11), @(36,14), @(16,10), @(37,43), @(14,13), @(41,23), @(14,11), @(32,41), 
    @(13,11), @(40,23), @(14,12), @(23,38), @(13,16), @(23,37), @(14,11), @(36,40), @(13,14), @(38,29), @(14,10), @(41,34), @(13,12), @(35,22), @(14,10), @(33,36), @(13,14), @(36,20), @(13,14),
    @(32,39), @(13,14), @(36,27), @(12,17), @(15,38), @(12,13), @(39,26), @(13,11), @(37,41), @(12,11), @(37,23), @(14,15), @(19,40), @(13,12), @(38,18), @(13,17), @(15,36), @(13,10), @(37,26),
    @(14,16), @(15,37), @(16,10), @(34,41), @(34,39), @(13,12), @(34,39), @(14,13), @(23,39), @(13,11), @(35,14), @(13,17), @(19,35), @(14,10), @(37,24), @(13,18), @(16,37), @(13,12), @(33,29),
    @(15,10), @(35,33), @(18,10), @(35,26), @(14,15), @(16,32), @(12,13), @(35,17), @(16,10), @(31,34), @(14,13), @(33,10), @(34,38), @(14,10), @(33,26), @(14,10), @(38,35), @(13,12), @(36,24),
    @(15,11), @(36,34), @(14,9), @(35,17), @(13,15), @(15,34), @(18,12), @(35,24), @(15,12), @(31,33), @(37,27), @(13,14), @(19,32), @(35,26)
    
)

$idx = 0
$rand = New-Object System.Random

Write-Host "STABILIZED CLICKER ACTIVE" -ForegroundColor Green
Write-Host "Do NOT minimize with the [-] button. Keep it behind your game window." -ForegroundColor Red

while ($true) {
    if ([Win32]::GetAsyncKeyState(0x7B) -lt 0) { break }

    $doLeft  = ([Win32]::GetAsyncKeyState(0x06) -lt 0)
    $doRight = ([Win32]::GetAsyncKeyState(0x05) -lt 0)

    if ($doLeft -or $doRight) {
        $pair = $config[$idx % $config.Count]
        $idx++

        # Jitter calculation
        $downDelay = [Math]::Max(1, $pair[0] - $rand.Next(1,3))
        $upDelay   = [Math]::Max(1, $pair[1] - $rand.Next(1,3))

        # Action
        if ($doLeft) { [Win32]::mouse_event([Win32]::LEFTDOWN, 0, 0, 0, 0) }
        if ($doRight) { [Win32]::mouse_event([Win32]::RIGHTDOWN, 0, 0, 0, 0) }
        
        # High precision sleep
        [Win32]::Sleep($downDelay)

        if ($doLeft) { [Win32]::mouse_event([Win32]::LEFTUP, 0, 0, 0, 0) }
        if ($doRight) { [Win32]::mouse_event([Win32]::RIGHTUP, 0, 0, 0, 0) }

        [Win32]::Sleep($upDelay)
    }
    else {
        # Keep the thread hot but not 100% CPU
        [Win32]::Sleep(1)
    }
}
