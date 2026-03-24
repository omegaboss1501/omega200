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
    @(13,36), @(14,42), @(17,35), @(13,15), @(39,29), @(15,14), @(17,13), @(16,12), @(32,39), @(14,15), @(16,43), @(13,17), @(18,37), @(14,12), @(22,38), @(14,12), @(37,24), @(15,10), @(35,40),
    @(13,15), @(42,24), @(14,11), @(27,38), @(13,16), @(37,19), @(14,13), @(26,38), @(12,16), @(37,24), @(15,11), @(25,39), @(14,16), @(36,27), @(13,11), @(34,38), @(17,15), @(43,20), @(12,12),
    @(31,38), @(13,14), @(42,19), @(13,16), @(36,41), @(13,19), @(36,18), @(15,14), @(37,34), @(12,17), @(40,25), @(14,10), @(37,33), @(12,14), @(38,29), @(13,16), @(29,37), @(14,13), @(41,21),
    @(15,10), @(38,29), @(12,15), @(42,17), @(14,15), @(40,34), @(14,15), @(44,13), @(14,19), @(21,36), @(12,10), @(36,11), @(15,14), @(23,37), @(13,12), @(36,23), @(14,15), @(21,38), @(13,15),
    @(40,25), @(15,11), @(39,34), @(13,14), @(38,24), @(15,12), @(30,40), @(13,15), @(38,21), @(14,11), @(22,37), @(16,11), @(42,14), @(16,10), @(37,43), @(14,13), @(41,23), @(14,11), @(32,41), 
    @(13,11), @(38,23), @(14,12), @(23,38), @(13,16), @(23,37), @(14,11), @(36,39), @(13,14), @(38,29), @(14,10), @(40,34), @(13,12), @(35,22), @(14,10), @(33,36), @(13,14), @(41,20), @(13,14),
    @(32,39), @(13,14), @(36,27), @(12,17), @(15,38), @(14,13), @(39,26), @(13,11), @(37,41), @(12,11), @(42,23), @(14,15), @(19,40), @(13,12), @(43,18), @(13,17), @(15,36), @(13,10), @(37,26),
    @(14,16), @(15,38), @(16,10), @(34,41), @(34,39), @(16,12), @(34,39), @(14,13), @(23,39), @(13,11), @(40,14), @(13,17), @(19,42), @(14,10), @(37,24), @(13,18), @(16,37), @(13,12), @(36,29),
    @(15,10), @(39,33), @(18,10), @(41,26), @(14,15), @(16,44), @(12,13), @(38,17), @(15,10), @(31,38), @(14,13), @(42,10), @(34,38), @(14,10), @(38,26), @(14,10), @(38,35), @(13,12), @(36,24),
    @(17,11), @(36,34), @(14,16), @(38,17), @(13,15), @(15,34), @(18,12), @(43,24), @(15,12), @(41,33), @(37,27), @(13,14), @(19,42), @(35,47)
    
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
