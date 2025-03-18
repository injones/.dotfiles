@findstr/v "^@f.*&" "%~f0"|powershell -&goto:eof
& ([scriptblock]::Create((irm "https://win11debloat.raphi.re/"))) -RunDefaults -Silent
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); irm "https://christitus.com/win" | iex
