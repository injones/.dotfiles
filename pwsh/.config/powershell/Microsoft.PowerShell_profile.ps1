$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"

# setup bash controls
Set-PSReadLineKeyHandler -Chord Ctrl+n -Function NextHistory
Set-PSReadLineKeyHandler -Chord Ctrl+p -Function PreviousHistory
Set-PSReadLineKeyHandler -Chord Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function KillLine
Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Ctrl+y -Function Yank
Set-PSReadLineKeyHandler -Chord Ctrl+l -Function ClearScreen
Set-PSReadLineKeyHandler -Chord Ctrl+f -Function ForwardChar
Set-PSReadLineKeyHandler -Chord Ctrl+b -Function BackwardChar

function debian {
    wsl -d Debian -- $args
}

$env:FZF_DEFAULT_OPTS = @"
  $env:FZF_DEFAULT_OPTS
  --color=fg:#d0d0d0,fg+:#d0d0d0,bg:#121212,bg+:#262626
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00
  --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf
  --color=border:#262626,label:#aeaeae,query:#d9d9d9
  --border="bold" --border-label="" --preview-window="border-bold" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"
"@

$common_dirs = @("~", "C:\")
$env:COMMON = $common_dirs -join ","
function ccd {
    $selected = $env:COMMON -replace ",", "`n" | fzf
    cd $selected
}

Invoke-Expression (&starship init powershell)
