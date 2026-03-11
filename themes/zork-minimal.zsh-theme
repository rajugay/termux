# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  ZORK MINIMAL 2026 — Clean & Fast                              ║
# ║  Truecolor | Smart git | Exec time | Error flash | Lean        ║
# ║  Made by Zork | 2026 Edition                                    ║
# ╚══════════════════════════════════════════════════════════════════╝

setopt PROMPT_SUBST

# ─── Truecolor Helpers ───
_zm_rgb() { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_zm_rst() { echo -n "%{\033[0m%}"; }

# ─── Git Info (compact but smart) ───
_zm_git() {
    (( $+commands[git] )) || return
    [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]] || return
    local branch
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null || command git describe --tags --always 2>/dev/null)
    [[ -z "$branch" ]] && return

    local dirty="" staged="" untracked=""
    [[ -n $(command git diff --name-only 2>/dev/null) ]] && dirty="*"
    [[ -n $(command git diff --cached --name-only 2>/dev/null) ]] && staged="+"
    [[ -n $(command git ls-files --others --exclude-standard 2>/dev/null) ]] && untracked="?"

    local ahead="" behind=""
    local ab
    ab=$(command git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [[ -n "$ab" ]]; then
        ahead=${ab%%$'\t'*}
        behind=${ab##*$'\t'}
    fi

    local sc="80;120;255"
    [[ -n "$dirty" ]] && sc="255;200;0"
    [[ -n "$staged" && -z "$dirty" ]] && sc="0;255;200"

    local info=""
    info+=" $(_zm_rgb ${sc}) ${branch}"
    [[ -n "$dirty" ]] && info+="${dirty}"
    [[ -n "$staged" ]] && info+="${staged}"
    [[ -n "$untracked" ]] && info+="${untracked}"
    [[ "$ahead" -gt 0 ]] 2>/dev/null && info+="⬆${ahead}"
    [[ "$behind" -gt 0 ]] 2>/dev/null && info+="⬇${behind}"
    info+="$(_zm_rst)"
    echo -n "$info"
}

# ─── Gradient Arrows ───
_zm_arrows() {
    if [[ ${_ZM_LAST_EXIT:-0} -ne 0 ]]; then
        echo -n "$(_zm_rgb 255 60 60)"
    else
        echo -n "$(_zm_rgb 0 255 136)"
    fi
    echo -n "❯"
    echo -n "$(_zm_rgb 0 200 255)❯"
    echo -n "$(_zm_rgb 100 100 255)❯"
    echo -n "$(_zm_rst) "
}

# ─── Exec Time Hook ───
_zm_preexec() { _ZM_START=$EPOCHSECONDS; _ZM_CMD_RAN=1; }
_zm_precmd() {
    local ec=$?
    [[ -n "$_ZM_CMD_RAN" ]] && _ZM_LAST_EXIT=$ec
    unset _ZM_CMD_RAN
    if [[ -n "$_ZM_START" ]]; then
        _ZM_ELAPSED=$(( EPOCHSECONDS - _ZM_START ))
    else
        _ZM_ELAPSED=0
    fi
    unset _ZM_START
}

_ZM_LAST_EXIT=0
autoload -Uz add-zsh-hook
add-zsh-hook preexec _zm_preexec
add-zsh-hook precmd _zm_precmd
precmd_functions=(_zm_precmd ${(@)precmd_functions:#_zm_precmd})

# ─── Prompts ───
PROMPT='$(_zm_rgb 0 200 255)%3~$(_zm_rst)$(_zm_git) $(_zm_arrows)'

RPROMPT='$(
    local parts=""
    if [[ $_ZM_ELAPSED -gt 2 ]]; then
        local t=$_ZM_ELAPSED
        if [[ $t -gt 60 ]]; then
            parts+="$(_zm_rgb 60 60 80) $(( t/60 ))m$(( t%60 ))s$(_zm_rst) "
        else
            parts+="$(_zm_rgb 60 60 80) ${t}s$(_zm_rst) "
        fi
    fi
    parts+="$(_zm_rgb 50 50 70)%T$(_zm_rst)"
    echo -n "$parts"
)'

PS2='$(_zm_rgb 0 150 200)…❯ $(_zm_rst)'
SPROMPT="$(_zm_rgb 255 180 0) %R$(_zm_rst) → $(_zm_rgb 0 255 136)%r$(_zm_rst)? [y/n] "

export LS_COLORS='di=1;38;2;0;200;255:ln=1;38;2;200;100;255:ex=1;38;2;0;255;136:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;0;255;136'
