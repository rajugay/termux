# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  ROBBYRUSSELL 2026 — The Classic, Elevated                     ║
# ║  Truecolor | Git status | Exec time | Clean aesthetic          ║
# ║  Enhanced by Zork | 2026 Edition                                ║
# ╚══════════════════════════════════════════════════════════════════╝

setopt PROMPT_SUBST

# ─── Truecolor Helpers ───
_rr_rgb() { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_rr_rst() { echo -n "%{\033[0m%}"; }

# ─── Git Info (enhanced) ───
_rr_git() {
    (( $+commands[git] )) || return
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return
    local branch
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null || command git describe --tags --always 2>/dev/null)
    [[ -z "$branch" ]] && return

    local dirty="" staged="" untracked=""
    [[ -n $(command git diff --name-only 2>/dev/null) ]] && dirty="✗"
    [[ -n $(command git diff --cached --name-only 2>/dev/null) ]] && staged="✚"
    [[ -n $(command git ls-files --others --exclude-standard 2>/dev/null) ]] && untracked="?"

    local state_color state_icon
    if [[ -n "$dirty" ]]; then
        state_color="255;200;0"
        state_icon=" $(_rr_rgb 255 80 80)${dirty}$(_rr_rgb 255 200 0)"
    elif [[ -n "$staged" ]]; then
        state_color="0;255;200"
        state_icon=" $(_rr_rgb 0;255;200)${staged}"
    else
        state_color="0;200;255"
        state_icon=""
    fi
    [[ -n "$untracked" ]] && state_icon+=" $(_rr_rgb 200 100 255)${untracked}"

    echo -n " $(_rr_rgb 80 120 255) ($(_rr_rgb ${state_color})${branch}${state_icon}$(_rr_rgb 80 120 255))$(_rr_rst)"
}

# ─── Gradient Arrow (iconic) ───
_rr_arrow() {
    if [[ ${_RR_LAST_EXIT:-0} -ne 0 ]]; then
        echo -n "$(_rr_rgb 255 60 60)"
    else
        echo -n "$(_rr_rgb 0 255 136)"
    fi
    echo -n "❯"
    echo -n "$(_rr_rgb 0 200 200)❯"
    echo -n "$(_rr_rgb 0 150 255)❯"
    echo -n "$(_rr_rst) "
}

# ─── Exec Time Hook ───
_rr_preexec() { _RR_START=$EPOCHSECONDS; _RR_CMD_RAN=1; }
_rr_precmd() {
    local ec=$?
    [[ -n "$_RR_CMD_RAN" ]] && _RR_LAST_EXIT=$ec
    unset _RR_CMD_RAN
    if [[ -n "$_RR_START" ]]; then
        _RR_ELAPSED=$(( EPOCHSECONDS - _RR_START ))
    else
        _RR_ELAPSED=0
    fi
    unset _RR_START
}

_RR_LAST_EXIT=0
autoload -Uz add-zsh-hook
add-zsh-hook preexec _rr_preexec
add-zsh-hook precmd _rr_precmd
precmd_functions=(_rr_precmd ${(@)precmd_functions:#_rr_precmd})

# ─── Prompts ───
PROMPT='$(_rr_rgb 0 200 255)%c$(_rr_rst)$(_rr_git) $(_rr_arrow)'

RPROMPT='$(
    if [[ $_RR_ELAPSED -gt 2 ]]; then
        local t=$_RR_ELAPSED
        if [[ $t -gt 60 ]]; then
            printf "$(_rr_rgb 80 80 100) %dm%ds$(_rr_rst)" $(( t/60 )) $(( t%60 ))
        else
            printf "$(_rr_rgb 80 80 100) %ds$(_rr_rst)" $t
        fi
    fi
) $(_rr_rgb 60 60 80)%T$(_rr_rst)'

PS2='$(_rr_rgb 0 150 200)…❯ $(_rr_rst)'
SPROMPT="$(_rr_rgb 255 180 0) %R$(_rr_rst) → $(_rr_rgb 0 255 136)%r$(_rr_rst)? [y/n] "

export LS_COLORS='di=1;38;2;0;200;255:ln=1;38;2;200;100;255:ex=1;38;2;0;255;136:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;0;255;136'
