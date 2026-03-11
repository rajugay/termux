# vim:ft=zsh ts=2 sw=2 sts=2
# ╔══════════════════════════════════════════════════════════════════╗
# ║  ZORK 2026 - The Ultimate Termux ZSH Theme                     ║
# ║  Truecolor gradients | Git powerline | Battery | XP Level       ║
# ║  Login-aware | XP Level | Responsive                            ║
# ║  Made by Zork | 2026 Edition                                    ║
# ╚══════════════════════════════════════════════════════════════════╝

# ─── Truecolor Helpers ───
_zork_rgb() { echo -n "%{\033[38;2;$1;$2;$3m%}"; }
_zork_bg_rgb() { echo -n "%{\033[48;2;$1;$2;$3m%}"; }
_zork_reset() { echo -n "%{\033[0m%}"; }

# ─── Nerd Font / Powerline Symbols ───
ZORK_SEP=""            # Powerline separator
ZORK_SEP_THIN=""       # Thin separator
ZORK_SEP_R=""          # Reverse powerline
ZORK_BRANCH=""         # Git branch
ZORK_LOCK=""           # Lock/readonly
ZORK_BOLT="⚡"          # Background jobs
ZORK_GEAR=""           # Error
ZORK_CROSS="✘"          # Fail
ZORK_CHECK="✔"          # Pass
ZORK_ARROW="❯"          # Prompt arrow
ZORK_CLOCK=""          # Clock
ZORK_FOLDER=""         # Directory
ZORK_DIAMOND="◆"        # Diamond bullet
ZORK_STAR="★"           # Star
ZORK_DOT="●"            # Dot bullet
ZORK_DASH="─"           # Horizontal line
ZORK_CORNER_TL="╭"      # Top-left corner
ZORK_CORNER_BL="╰"      # Bottom-left corner
ZORK_VLINE="│"          # Vertical line

# ─── Color Palette ───
ZORK_BG_DARK="16;16;28"
ZORK_BG_MID="30;30;50"
ZORK_GREEN="0;255;136"
ZORK_CYAN="0;230;255"
ZORK_BLUE="80;120;255"
ZORK_PURPLE="180;60;255"
ZORK_PINK="255;0;200"
ZORK_ORANGE="255;165;0"
ZORK_RED="255;60;60"
ZORK_YELLOW="255;220;0"
ZORK_WHITE="240;240;255"
ZORK_GRAY="100;100;120"
ZORK_DIM="60;60;80"

# ─── Gradient Prompt Characters (2026 Glow Edition) ───
_zork_gradient_arrows() {
    local arrows=""
    arrows+="$(_zork_rgb 0 180 100)${ZORK_CORNER_BL}"
    arrows+="$(_zork_rgb 0 200 120)${ZORK_DASH}${ZORK_DASH}"
    arrows+="$(_zork_rgb 0 255 136)❯"
    arrows+="$(_zork_rgb 0 220 200)❯"
    arrows+="$(_zork_rgb 0 180 255)❯"
    arrows+="$(_zork_reset) "
    echo -n "$arrows"
}

# ─── Top separator line (gradient, matches left prompt width) ───
_zork_top_line() {
    local cols=${COLUMNS:-80}
    # Scale to ~55% of terminal width — matches left prompt segments
    local seg_len=$(( cols * 55 / 100 ))
    [[ $seg_len -lt 12 ]] && seg_len=12
    [[ $seg_len -gt 50 ]] && seg_len=50
    local line=""
    line+="$(_zork_rgb 0 100 80)${ZORK_CORNER_TL}"
    local i r g b
    for ((i=0; i<seg_len; i++)); do
        r=0
        g=$(( 80 + i * 175 / seg_len ))
        [[ $g -gt 255 ]] && g=255
        b=$(( 120 - i * 80 / seg_len ))
        [[ $b -lt 40 ]] && b=40
        line+="%{\033[38;2;${r};${g};${b}m%}${ZORK_DASH}"
    done
    line+="$(_zork_rgb 0 255 136)${ZORK_DOT}"
    line+="$(_zork_reset)"
    echo -n "$line"
}

# ─── Left vertical connector (links ╭ to ╰) ───
_zork_vline_start() {
    echo -n "$(_zork_rgb 0 100 80)${ZORK_VLINE}$(_zork_reset)"
}

# ─── Time Segment (with glow dot) ───
_zork_time() {
    echo -n "$(_zork_bg_rgb 22 22 38)$(_zork_rgb 0 180 220) ${ZORK_CLOCK} %T $(_zork_reset)"
    echo -n "$(_zork_rgb 22 22 38)${ZORK_SEP}$(_zork_reset)"
}

# ─── User@Host Segment (enhanced) ───
_zork_user() {
    if [[ $UID -eq 0 ]]; then
        echo -n "$(_zork_bg_rgb 100 10 10)$(_zork_rgb 255 180 180) ⚡ %n $(_zork_reset)"
        echo -n "$(_zork_rgb 100 10 10)${ZORK_SEP}$(_zork_reset)"
    else
        echo -n "$(_zork_bg_rgb 0 50 35)$(_zork_rgb 0 255 136)  %n $(_zork_reset)"
        echo -n "$(_zork_rgb 0 50 35)${ZORK_SEP}$(_zork_reset)"
    fi
}

# ─── Directory Segment (with icon) ───
_zork_dir() {
    echo -n "$(_zork_bg_rgb 16 32 70)$(_zork_rgb 80 180 255) ${ZORK_FOLDER} %3~ $(_zork_reset)"
    echo -n "$(_zork_rgb 16 32 70)${ZORK_SEP}$(_zork_reset)"
}

# ─── Git Segment ───
_zork_git() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)
        
        local dirty=""
        local staged=""
        local untracked=""
        local ahead=""
        local behind=""
        local stashed=""
        
        # Status flags
        [[ -n $(git diff --name-only 2>/dev/null) ]] && dirty=" ✗"
        [[ -n $(git diff --cached --name-only 2>/dev/null) ]] && staged=" ✚"
        [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]] && untracked=" ?"
        
        # Ahead/behind
        local ab
        ab=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
        if [[ -n "$ab" ]]; then
            local a=$(echo "$ab" | cut -f1)
            local b=$(echo "$ab" | cut -f2)
            [[ $a -gt 0 ]] && ahead=" ↑${a}"
            [[ $b -gt 0 ]] && behind=" ↓${b}"
        fi
        
        # Stash count
        local stash_count
        stash_count=$(git stash list 2>/dev/null | wc -l)
        [[ $stash_count -gt 0 ]] && stashed=" ≡${stash_count}"
        
        # Color based on state
        local git_bg_r git_bg_g git_bg_b git_fg_r git_fg_g git_fg_b
        if [[ -n "$dirty" ]]; then
            git_bg_r=80; git_bg_g=40; git_bg_b=0; git_fg_r=255; git_fg_g=200; git_fg_b=0
        elif [[ -n "$staged" ]]; then
            git_bg_r=0; git_bg_g=60; git_bg_b=60; git_fg_r=0; git_fg_g=255; git_fg_b=200
        else
            git_bg_r=0; git_bg_g=50; git_bg_b=0; git_fg_r=0; git_fg_g=255; git_fg_b=100
        fi
        
        echo -n "$(_zork_bg_rgb $git_bg_r $git_bg_g $git_bg_b)$(_zork_rgb $git_fg_r $git_fg_g $git_fg_b) ${ZORK_BRANCH} ${branch}${dirty}${staged}${untracked}${ahead}${behind}${stashed} $(_zork_reset)"
        echo -n "$(_zork_rgb $git_bg_r $git_bg_g $git_bg_b)${ZORK_SEP}$(_zork_reset)"
    fi
}

# ─── Virtual Environment Segment ───
_zork_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name
        venv_name=$(basename "$VIRTUAL_ENV")
        echo -n "$(_zork_bg_rgb 50 0 80)$(_zork_rgb 200 100 255)  ${venv_name} $(_zork_reset)"
        echo -n "$(_zork_rgb 50 0 80)${ZORK_SEP}$(_zork_reset)"
    fi
}

# ─── Battery Segment (Termux) ───
_zork_battery() {
    # Cache battery for 60 seconds to avoid slowdown
    local cache_dir="${HOME}/.zorkos/cache"
    [[ -d "$cache_dir" ]] || mkdir -p "$cache_dir" 2>/dev/null
    local cache_file="${cache_dir}/.battery_cache"
    local now=${EPOCHSECONDS:-$(date +%s)}
    local cached_time=0
    local cached_val=""
    
    if [[ -f "$cache_file" ]] && [[ -r "$cache_file" ]]; then
        cached_time=$(head -1 "$cache_file" 2>/dev/null || echo 0)
        cached_val=$(tail -1 "$cache_file" 2>/dev/null || echo "")
    fi
    
    # Only re-fetch if cache is stale and termux-battery-status exists
    if { [[ $(( now - cached_time )) -gt 60 ]] || [[ -z "$cached_val" ]]; } && command -v termux-battery-status &>/dev/null; then
        local bat_json
        bat_json=$(timeout 3 termux-battery-status 2>/dev/null || true)
        if [[ -n "$bat_json" ]]; then
            local pct bat_status
            pct=$(echo "$bat_json" | grep -o '"percentage":[0-9]*' | grep -o '[0-9]*' 2>/dev/null || echo "")
            bat_status=$(echo "$bat_json" | grep -o '"status":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
            
            if [[ -n "$pct" ]] && [[ "$pct" =~ ^[0-9]+$ ]]; then
                local bat_icon bat_bg_r bat_bg_g bat_bg_b bat_fg_r bat_fg_g bat_fg_b
                if [[ "$bat_status" == "CHARGING" ]]; then
                    bat_icon="⚡"; bat_bg_r=0; bat_bg_g=60; bat_bg_b=0; bat_fg_r=0; bat_fg_g=255; bat_fg_b=136
                elif [[ $pct -le 15 ]]; then
                    bat_icon=""; bat_bg_r=80; bat_bg_g=0; bat_bg_b=0; bat_fg_r=255; bat_fg_g=60; bat_fg_b=60
                elif [[ $pct -le 40 ]]; then
                    bat_icon=""; bat_bg_r=60; bat_bg_g=40; bat_bg_b=0; bat_fg_r=255; bat_fg_g=200; bat_fg_b=0
                elif [[ $pct -le 70 ]]; then
                    bat_icon=""; bat_bg_r=30; bat_bg_g=40; bat_bg_b=0; bat_fg_r=200; bat_fg_g=255; bat_fg_b=0
                else
                    bat_icon=""; bat_bg_r=0; bat_bg_g=40; bat_bg_b=0; bat_fg_r=0; bat_fg_g=255; bat_fg_b=136
                fi
                cached_val="${bat_icon}|${pct}|${bat_bg_r} ${bat_bg_g} ${bat_bg_b}|${bat_fg_r} ${bat_fg_g} ${bat_fg_b}"
                echo -e "${now}\n${cached_val}" > "$cache_file" 2>/dev/null || true
            fi
        fi
    fi
    
    if [[ -n "$cached_val" ]] && [[ "$cached_val" == *"|"* ]]; then
        local _bicon _bpct _bbg _bfg _rest
        _bicon="${cached_val%%|*}"; _rest="${cached_val#*|}"
        _bpct="${_rest%%|*}"; _rest="${_rest#*|}"
        _bbg="${_rest%%|*}"
        _bfg="${_rest##*|}"
        [[ -n "$_bpct" ]] && [[ -n "$_bbg" ]] && [[ -n "$_bfg" ]] || return
        # Validate space-separated RGB format; purge stale semicolon cache
        if [[ "$_bbg" == *";"* ]] || [[ "$_bfg" == *";"* ]]; then
            rm -f "$cache_file" 2>/dev/null; return
        fi
        echo -n "$(_zork_bg_rgb ${=_bbg})$(_zork_rgb ${=_bfg}) ${_bicon} ${_bpct}%% $(_zork_reset)"
        echo -n "$(_zork_rgb ${=_bbg})${ZORK_SEP}$(_zork_reset)"
    fi
}

# ─── XP Level Badge (from achievements) ───
_zork_xp_badge() {
    local stats_file="${HOME}/.zorkos/achievements/stats.db"
    if [[ -f "$stats_file" ]]; then
        local xp level level_icon
        xp=$(grep "^TOTAL_XP=" "$stats_file" 2>/dev/null | cut -d= -f2)
        [[ -z "$xp" ]] && return
        [[ $xp -lt 100 ]] && return
        
        if [[ $xp -ge 10000 ]]; then level="LGD"; level_icon="🌟"
        elif [[ $xp -ge 5000 ]]; then level="MST"; level_icon="👑"
        elif [[ $xp -ge 2000 ]]; then level="EXP"; level_icon="⚔️"
        elif [[ $xp -ge 1000 ]]; then level="ADV"; level_icon="🔷"
        elif [[ $xp -ge 500 ]]; then level="INT"; level_icon="🔶"
        else level="BEG"; level_icon="🔰"
        fi
        
        echo -n "$(_zork_bg_rgb 40 30 10)$(_zork_rgb 255 215 0) ${level_icon}${level} $(_zork_reset)"
        echo -n "$(_zork_rgb 40 30 10)${ZORK_SEP}$(_zork_reset)"
    fi
}

# ─── Exit Code Segment ───
_zork_status() {
    [[ ${_ZORK_LAST_EXIT:-0} -ne 0 ]] || return
    echo -n "$(_zork_bg_rgb 80 0 0)$(_zork_rgb 255 100 100) ${ZORK_CROSS} ${_ZORK_LAST_EXIT} $(_zork_reset)$(_zork_rgb 80 0 0)${ZORK_SEP}$(_zork_reset)"
}

# ─── Jobs Segment ───
_zork_jobs() {
    echo -n "%(1j.$(_zork_bg_rgb 60 60 0)$(_zork_rgb 255 255 0) ${ZORK_BOLT} %j $(_zork_reset)$(_zork_rgb 60 60 0)${ZORK_SEP}$(_zork_reset).)"
}

# ─── Right Prompt: Execution Time ───
_zork_exec_time() {
    if [[ -n "$_ZORK_CMD_START" ]]; then
        local elapsed=$(( EPOCHSECONDS - _ZORK_CMD_START ))
        if [[ $elapsed -gt 2 ]]; then
            if [[ $elapsed -gt 3600 ]]; then
                printf " %dh%dm%ds" $(( elapsed / 3600 )) $(( (elapsed % 3600) / 60 )) $(( elapsed % 60 ))
            elif [[ $elapsed -gt 60 ]]; then
                printf " %dm%ds" $(( elapsed / 60 )) $(( elapsed % 60 ))
            else
                printf " %ds" "$elapsed"
            fi
        fi
    fi
}

# Hook: record command start time
_zork_preexec() {
    _ZORK_CMD_START=$EPOCHSECONDS
    _ZORK_CMD_RAN=1
}

# Hook: clear command start after execution
_zork_precmd() {
    local ec=$?
    # Only capture exit code if user actually ran a command
    [[ -n "$_ZORK_CMD_RAN" ]] && _ZORK_LAST_EXIT=$ec
    unset _ZORK_CMD_RAN
    
    # Exec time for right prompt
    if [[ -n "$_ZORK_CMD_START" ]]; then
        _ZORK_EXEC_TIME=$(( EPOCHSECONDS - _ZORK_CMD_START ))
    else
        _ZORK_EXEC_TIME=0
    fi
    unset _ZORK_CMD_START
}

_ZORK_LAST_EXIT=0
autoload -Uz add-zsh-hook
add-zsh-hook preexec _zork_preexec
add-zsh-hook precmd _zork_precmd
# Ensure exit-code capture runs before any OMZ precmd hook
precmd_functions=(_zork_precmd ${(@)precmd_functions:#_zork_precmd})

# ─── Build Prompt (2026 Enhanced) ───
build_prompt() {
    echo -n "$(_zork_status)"
    echo -n "$(_zork_jobs)"
    echo -n "$(_zork_time)"
    echo -n "$(_zork_user)"
    echo -n "$(_zork_dir)"
    echo -n "$(_zork_venv)"
    echo -n "$(_zork_git)"
}

# ─── Build Right Prompt (2026 Enhanced) ───
build_rprompt() {
    # Exec time
    if [[ $_ZORK_EXEC_TIME -gt 2 ]]; then
        local t=$_ZORK_EXEC_TIME
        local time_str
        if [[ $t -gt 3600 ]]; then
            time_str=$(printf "%dh%dm%ds" $(( t / 3600 )) $(( (t % 3600) / 60 )) $(( t % 60 )))
        elif [[ $t -gt 60 ]]; then
            time_str=$(printf "%dm%ds" $(( t / 60 )) $(( t % 60 )))
        else
            time_str=$(printf "%ds" "$t")
        fi
        echo -n "$(_zork_rgb 80 80 100) ${time_str}$(_zork_reset)"
    fi
    # Battery
    echo -n "$(_zork_battery)"
    # XP level badge
    echo -n "$(_zork_xp_badge)"
    # Date with subtle separator
    echo -n "$(_zork_rgb 40 40 60) ${ZORK_SEP_R}$(_zork_bg_rgb 22 22 38)$(_zork_rgb 60 80 120)  %D{%a %d %b} $(_zork_reset)"
}

# ─── Set Prompts (2026 3-Line Edition) ───
setopt PROMPT_SUBST

PROMPT='
$(_zork_top_line)
$(_zork_vline_start)$(build_prompt)
$(_zork_gradient_arrows)'

RPROMPT='$(build_rprompt)'

# ─── PS2: Continuation Prompt (futuristic) ───
PS2='$(_zork_rgb 0 120 100) ${ZORK_VLINE}  $(_zork_rgb 0 200 180)…$(_zork_rgb 0 255 200)❯ $(_zork_reset)'

# ─── SPROMPT: Spelling correction ───
SPROMPT="$(_zork_rgb 255 180 0)  Correct $(_zork_rgb 255 60 60)%R$(_zork_reset) to $(_zork_rgb 0 255 136)%r$(_zork_reset)? $(_zork_rgb 100 100 120)[y/n/a/e]$(_zork_reset) "

# ─── Terminal Title (via hooks, no override) ───
_zork_title_precmd() {
    print -Pn "\e]0;⚡ %n@%m: %~\a"
}
_zork_title_preexec() {
    print -Pn "\e]0;⚡ $1\a"
}

case $TERM in
    xterm*|rxvt*|screen*)
        add-zsh-hook precmd _zork_title_precmd
        add-zsh-hook preexec _zork_title_preexec
        ;;
esac

# ─── LS Colors ───
export LS_COLORS='di=1;38;2;0;200;255:ln=1;38;2;200;100;255:so=1;38;2;255;0;200:pi=1;38;2;255;220;0:ex=1;38;2;0;255;136:bd=1;38;2;255;165;0:cd=1;38;2;255;100;100:su=1;38;2;255;0;0:sg=1;38;2;255;69;0:tw=1;48;2;0;80;0;38;2;0;255;136:ow=1;38;2;0;255;200:*.tar=1;38;2;255;60;60:*.zip=1;38;2;255;60;60:*.gz=1;38;2;255;60;60:*.jpg=1;38;2;255;0;200:*.png=1;38;2;255;0;200:*.mp3=1;38;2;0;255;200:*.mp4=1;38;2;0;200;255:*.py=1;38;2;0;255;136:*.js=1;38;2;255;220;0:*.sh=1;38;2;0;255;136'
