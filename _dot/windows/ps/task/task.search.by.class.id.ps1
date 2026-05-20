# --- НАСТРОЙКИ: установите ваш ClassId здесь ---
$ClassId = "6F58F65F-EC0E-4ACA-99FE-FC5A1A25E4BE"  # Замените на нужный GUID (без скобок)
# --- КОНЕЦ НАСТРОЕК ---


# Нормализуем GUID — убираем фигурные скобки, если есть
$ClassId = $ClassId -replace '^{|}', ''
$FullGuid = "{$ClassId}"
Write-Host "Ищем ClassId: $FullGuid" -ForegroundColor Green

# Результат будет накапливаться здесь
$results = @()

# --- Шаг 1: Поиск в реестре ---
Write-Host "`n1. Поиск в реестре..." -ForegroundColor Yellow

$regPaths = @(
    "HKLM:\SOFTWARE\Classes\CLSID\$FullGuid",
    "HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID\$FullGuid",
    "HKCU:\SOFTWARE\Classes\CLSID\$FullGuid"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        Write-Host "  Найден в реестре: $path" -ForegroundColor Cyan
        $regItem = Get-Item $path
        $result = [PSCustomObject]@{
            Type = "Registry"
            Path = $path
            Name = $regItem.PSChildName
            Value = $regItem.GetValue("")
        }

        # Ищем InprocServer32 или LocalServer32
        $inproc = $regItem | Get-ItemProperty -Name "InprocServer32" -ErrorAction SilentlyContinue
        if ($inproc) {
            $result | Add-Member -MemberType NoteProperty -Name "InprocServer32" -Value $inproc.InprocServer32
            Write-Host "  InprocServer32: $($inproc.InprocServer32)" -ForegroundColor White
        }

        $local = $regItem | Get-ItemProperty -Name "LocalServer32" -ErrorAction SilentlyContinue
        if ($local) {
            $result | Add-Member -MemberType NoteProperty -Name "LocalServer32" -Value $local.LocalServer32
            Write-Host "  LocalServer32: $($local.LocalServer32)" -ForegroundColor White
        }

        $results += $result
    }
}

# --- Шаг 2: Поиск в системных DLL ---
Write-Host "`n2. Поиск в DLL‑файлах (может занять несколько минут)..." -ForegroundColor Yellow

$dllPaths = @(
    "C:\Windows\System32\*.dll",
    "C:\Windows\SysWOW64\*.dll"
)

foreach ($pattern in $dllPaths) {
    Write-Host "  Проверяем: $pattern" -ForegroundColor Gray
    $dlls = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue -Force -File

    foreach ($dll in $dlls) {
        try {
            # Читаем содержимое файла как строку (для поиска GUID)
            $content = [System.IO.File]::ReadAllText($dll.FullName)
            if ($content.Contains($ClassId) -or $content.Contains($FullGuid)) {
                Write-Host "  Найден в: $($dll.FullName)" -ForegroundColor Cyan
                $result = [PSCustomObject]@{
                    Type = "DLL"
            Path = $dll.FullName
            Size = $dll.Length
            LastWriteTime = $dll.LastWriteTime
                }
                $results += $result
            }
        } catch {
            # Игнорируем ошибки доступа
        }
    }
}

# --- Вывод результатов ---
Write-Host "`n--- РЕЗУЛЬТАТЫ ПОИСКА ---" -ForegroundColor Green
if ($results.Count -eq 0) {
    Write-Host "Ничего не найдено для ClassId: $FullGuid" -ForegroundColor Red
} else {
    $results | Format-Table -AutoSize
}
