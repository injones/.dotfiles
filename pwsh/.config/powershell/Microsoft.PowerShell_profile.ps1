$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"

# setup bash controls
Set-PSReadLineKeyHandler -Key Ctrl+N -Function NextHistory
Set-PSReadLineKeyHandler -Key Ctrl+P -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Ctrl+A -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl+E -Function EndOfLine
Set-PSReadLineKeyHandler -Key Ctrl+K -Function KillLine
Set-PSReadLineKeyHandler -Key Ctrl+U -Function BackwardKillLine
Set-PSReadLineKeyHandler -Key Ctrl+W -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+Y -Function Yank
Set-PSReadLineKeyHandler -Key Ctrl+L -Function ClearScreen

Invoke-Expression (&starship init powershell)
