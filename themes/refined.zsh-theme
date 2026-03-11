# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  REFINED 2026 — Pure-Inspired Minimalism                       ║
# ║  Truecolor | VCS info | Exec time | SSH-aware | Ultra clean    ║
# ║  Enhanced by Zork | 2026 Edition                                ║
# ╚══════════════════════════════════════════════════════════════════╝

setopt PROMPT_SUBST

# ─── Truecolor Helpers ───
_rf_rgb() { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_rf_rst() { echo -n "%{\033[0m%}"; }

# ─── VCS Info (zsh-native) ───
autoload -Uz vcs_info add-zsh-hook

zstyle ':vcs_info:*' enable git hg bzr svn
zstyle ':vcs_info:*:*' unstagedstr '!'
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' formats '%s:%b' '%u%c'
zstyle ':vcs_info:*:*' actionformats '%s:%b' '%u%c (%a)'

# Fastest dirty check
_rf_git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    command git diff --quiet --ignore-submodules HEAD &>/dev/null
    [[ $? -eq 1 ]] && echo "*"
}

# ─── Repo Info (printed above prompt like Pure) ───
_rf_repo_line() {
    [[ -z "$vcs_info_msg_0_" ]] && return
    local vcs="$vcs_info_msg_0_"
    local changes="$vcs_info_msg_1_"
    local dirty=$(_rf_git_dirty)

    local branch_color
    if [[ -n "$dirty" ]]; then
        branch_color="255;200;0"
    elif [[ -n "$changes" ]]; then
        branch_color="0;255;200"
    else
        branch_color="200;200;220"
    fi

    echo -n "$(_rf_rgb 80 80 120)${vcs}${dirty}$(_rf_rst)"
    [[ -n "$changes" ]] && echo -n " $(_rf_rgb ${branch_color})${changes}$(_rf_rst)"
}

# ─── Exec Time ───
_rf_preexec() { _RF_START=$EPOCHSECONDS; _RF_CMD_RAN=1; }

_rf_precmd() {
    local ec=$?
    [[ -n "$_RF_CMD_RAN" ]] && _RF_LAST_EXIT=$ec
    unset _RF_CMD_RAN
    vcs_info

    # Calc exec time
    if [[ -n "$_RF_START" ]]; then
        _RF_ELAPSED=$(( EPOCHSECONDS - _RF_START ))
    else
        _RF_ELAPSED=0
    fi
    unset _RF_START

    # Print info line above prompt (Pure-style)
    local info=""
    local dir="$(_rf_rgb 80 140 255)%~$(_rf_rst)"
    local repo="$(_rf_repo_line)"
    local elapsed=""
    if [[ $_RF_ELAPSED -gt 5 ]]; then
        local t=$_RF_ELAPSED
        if [[ $t -gt 60 ]]; then
            elapsed=" $(_rf_rgb 255 200 0)$(( t/60 ))m$(( t%60 ))s$(_rf_rst)"
        else
            elapsed=" $(_rf_rgb 255 200 0)${t}s$(_rf_rst)"
        fi
    fi

    print -P ""
    print -P "${dir} ${repo}${elapsed}"
}

_RF_LAST_EXIT=0
add-zsh-hook preexec _rf_preexec
add-zsh-hook precmd _rf_precmd
precmd_functions=(_rf_precmd ${(@)precmd_functions:#_rf_precmd})

# ─── Arrow Color (exit-code aware) ───
_rf_arrow_color() {
    if [[ ${_RF_LAST_EXIT:-0} -ne 0 ]]; then
        echo -n "$(_rf_rgb 255 60 60)"
    elif [[ $UID -eq 0 ]]; then
        echo -n "$(_rf_rgb 255 80 80)"
    else
        echo -n "$(_rf_rgb 180 60 255)"
    fi
}

# ─── Prompt (single character, like Pure) ───
PROMPT='$(_rf_arrow_color)❯$(_rf_rst) '

# SSH indicator in RPROMPT
RPROMPT='${SSH_TTY:+$(_rf_rgb 60 60 80)%n@%m$(_rf_rst)}'

PS2='$(_rf_rgb 120 60 200)…❯ $(_rf_rst)'
SPROMPT="$(_rf_rgb 255 180 0) %R$(_rf_rst) → $(_rf_rgb 180 60 255)%r$(_rf_rst)? [y/n] "

export LS_COLORS='di=1;38;2;80;140;255:ln=1;38;2;200;100;255:so=1;38;2;180;60;255:ex=1;38;2;0;255;136:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;180;60;255'
