# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  ZORK NEON 2026 — Maximum Eye Candy                             ║
# ║  3-Line Box | Powerline segments | Deep git | Neon gradients   ║
# ║  Battery | Exec time | Exit code | Full RGB                    ║
# ║  Made by Zork | 2026 Edition                                    ║
# ╚══════════════════════════════════════════════════════════════════╝

setopt PROMPT_SUBST

# ─── Truecolor Helpers ───
_zn_rgb() { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_zn_bg()  { echo -n "%{\033[48;2;$1;$2;$3m%}"; }
_zn_rst() { echo -n "%{\033[0m%}"; }

SEP=""

# ─── Top Line ───
_zn_topline() {
    local cols=${COLUMNS:-80}
    local w=$(( cols * 55 / 100 ))
    local line=""
    line+="$(_zn_rgb 255 0 200)╭"
    local i; for (( i=0; i<w; i++ )); do line+="─"; done
    line+="●$(_zn_rst)"
    echo -n "$line"
}

# ─── Vertical Connector ───
_zn_vline() { echo -n "$(_zn_rgb 255 0 200)│$(_zn_rst) "; }

# ─── Exit Code Segment ───
_zn_exit() {
    [[ ${_ZN_LAST_EXIT:-0} -ne 0 ]] || return
    echo -n "$(_zn_bg 60 0 0)$(_zn_rgb 255 100 100) ✘ ${_ZN_LAST_EXIT} $(_zn_rst)$(_zn_rgb 60 0 0)${SEP}$(_zn_rst)"
}

# ─── Time Segment ───
_zn_time() {
    echo -n "$(_zn_bg 20 0 40)$(_zn_rgb 200 100 255)  %T $(_zn_rst)$(_zn_rgb 20 0 40)${SEP}$(_zn_rst)"
}

# ─── User Segment ───
_zn_user() {
    echo -n "$(_zn_bg 0 40 40)$(_zn_rgb 0 255 200) %n $(_zn_rst)$(_zn_rgb 0 40 40)${SEP}$(_zn_rst)"
}

# ─── Dir Segment ───
_zn_dir() {
    echo -n "$(_zn_bg 0 20 60)$(_zn_rgb 0 180 255)  %3~ $(_zn_rst)$(_zn_rgb 0 20 60)${SEP}$(_zn_rst)"
}

# ─── Git Segment (deep) ───
_zn_git() {
    (( $+commands[git] )) || return
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return
    local branch
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null || command git describe --tags --always 2>/dev/null)
    [[ -z "$branch" ]] && return

    local dirty="" staged="" untracked="" stash=""
    [[ -n $(command git diff --name-only 2>/dev/null) ]] && dirty="✗"
    [[ -n $(command git diff --cached --name-only 2>/dev/null) ]] && staged="✚"
    [[ -n $(command git ls-files --others --exclude-standard 2>/dev/null) ]] && untracked="?"
    local stash_count
    stash_count=$(command git stash list 2>/dev/null | wc -l)
    [[ $stash_count -gt 0 ]] && stash="≡${stash_count}"

    local ahead="" behind=""
    local ab
    ab=$(command git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [[ -n "$ab" ]]; then
        ahead=${ab%%$'\t'*}
        behind=${ab##*$'\t'}
    fi

    # Neon color by state
    local bg_r=0 bg_g=40 bg_b=0
    [[ -n "$dirty" ]] && { bg_r=40; bg_g=30; bg_b=0; }

    local seg=""
    seg+="$(_zn_bg $bg_r $bg_g $bg_b)$(_zn_rgb 255 200 0)  ${branch}"
    [[ -n "$dirty" ]] && seg+=" $(_zn_rgb 255 0 100)${dirty}"
    [[ -n "$staged" ]] && seg+=" $(_zn_rgb 0 255 200)${staged}"
    [[ -n "$untracked" ]] && seg+=" $(_zn_rgb 200 100 255)${untracked}"
    [[ "$ahead" -gt 0 ]] 2>/dev/null && seg+=" $(_zn_rgb 0 200 255)⬆${ahead}"
    [[ "$behind" -gt 0 ]] 2>/dev/null && seg+=" $(_zn_rgb 255 100 100)⬇${behind}"
    [[ -n "$stash" ]] && seg+=" $(_zn_rgb 200 200 0)${stash}"
    seg+=" $(_zn_rst)$(_zn_rgb $bg_r $bg_g $bg_b)${SEP}$(_zn_rst)"
    echo -n "$seg"
}

# ─── Venv Segment ───
_zn_venv() {
    [[ -n "$VIRTUAL_ENV" ]] || return
    echo -n "$(_zn_bg 0 30 20)$(_zn_rgb 0 255 136) 🐍 ${VIRTUAL_ENV:t} $(_zn_rst)$(_zn_rgb 0 30 20)${SEP}$(_zn_rst)"
}

# ─── Neon Gradient Arrows ───
_zn_arrows() {
    echo -n "$(_zn_rgb 255 0 200)╰"
    echo -n "$(_zn_rgb 220 0 220)──"
    echo -n "$(_zn_rgb 255 0 200)❯"
    echo -n "$(_zn_rgb 200 0 255)❯"
    echo -n "$(_zn_rgb 100 0 255)❯"
    echo -n "$(_zn_rst) "
}

# ─── Exec Time Hook ───
_zn_preexec() { _ZN_START=$EPOCHSECONDS; _ZN_CMD_RAN=1; }
_zn_precmd() {
    local ec=$?
    [[ -n "$_ZN_CMD_RAN" ]] && _ZN_LAST_EXIT=$ec
    unset _ZN_CMD_RAN
    if [[ -n "$_ZN_START" ]]; then
        _ZN_ELAPSED=$(( EPOCHSECONDS - _ZN_START ))
    else
        _ZN_ELAPSED=0
    fi
    unset _ZN_START
}

_ZN_LAST_EXIT=0
autoload -Uz add-zsh-hook
add-zsh-hook preexec _zn_preexec
add-zsh-hook precmd _zn_precmd
precmd_functions=(_zn_precmd ${(@)precmd_functions:#_zn_precmd})

# ─── Battery (neon style) ───
_zn_battery() {
    local bat_file="/sys/class/power_supply/battery/capacity"
    [[ -f "$bat_file" ]] || return
    local pct
    pct=$(cat "$bat_file" 2>/dev/null)
    [[ -z "$pct" ]] && return
    local r g b icon
    if [[ $pct -le 20 ]]; then
        r=255; g=0; b=60; icon="󰁺"
    elif [[ $pct -le 50 ]]; then
        r=255; g=200; b=0; icon="󰁾"
    else
        r=0; g=255; b=136; icon="󰁹"
    fi
    echo -n "$(_zn_rgb $r $g $b)${icon} ${pct}%%$(_zn_rst)"
}

# ─── Prompts ───
PROMPT='$(_zn_topline)
$(_zn_vline)$(_zn_exit)$(_zn_time)$(_zn_user)$(_zn_dir)$(_zn_git)$(_zn_venv)
$(_zn_arrows)'

RPROMPT='$(
    local parts=""
    # Exec time
    if [[ $_ZN_ELAPSED -gt 2 ]]; then
        local t=$_ZN_ELAPSED
        if [[ $t -gt 60 ]]; then
            parts+="$(_zn_rgb 200 100 255) $(( t/60 ))m$(( t%60 ))s$(_zn_rst) "
        else
            parts+="$(_zn_rgb 200 100 255) ${t}s$(_zn_rst) "
        fi
    fi
    # Battery
    local bat=$(_zn_battery)
    [[ -n "$bat" ]] && parts+="${bat} "
    # Day
    parts+="$(_zn_rgb 60 60 80)%D{%a %d}$(_zn_rst)"
    echo -n "$parts"
)'

PS2='$(_zn_rgb 255 0 200)│$(_zn_rgb 200 0 255) …❯ $(_zn_rst)'
SPROMPT="$(_zn_rgb 255 180 0) %R$(_zn_rst) → $(_zn_rgb 255 0 200)%r$(_zn_rst)? [y/n] "

export LS_COLORS='di=1;38;2;0;200;255:ln=1;38;2;255;0;200:so=1;38;2;200;100;255:ex=1;38;2;0;255;136:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;0;255;136:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.jpg=1;38;2;255;0;200:*.mp3=1;38;2;0;255;200'
