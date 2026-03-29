# ─────────────────────────────────────────────
#  Cool Zsh Prompt
#  Features: hostname, cwd, time, cmd duration
# ─────────────────────────────────────────────

# Track command start time
_prompt_preexec() {
  _cmd_start=$SECONDS
}

# Calculate duration before each prompt render
_prompt_precmd() {
  if [[ -n $_cmd_start ]]; then
    local elapsed=$(( SECONDS - _cmd_start ))
    unset _cmd_start

    if (( elapsed >= 3600 )); then
      _cmd_duration="${elapsed}s"  # Could format as h:m:s if desired
      local h=$(( elapsed / 3600 ))
      local m=$(( (elapsed % 3600) / 60 ))
      local s=$(( elapsed % 60 ))
      _cmd_duration="${h}h${m}m${s}s"
    elif (( elapsed >= 60 )); then
      local m=$(( elapsed / 60 ))
      local s=$(( elapsed % 60 ))
      _cmd_duration="${m}m${s}s"
    elif (( elapsed >= 1 )); then
      _cmd_duration="${elapsed}s"
    else
      _cmd_duration=""
    fi
  else
    _cmd_duration=""
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd

# Enable prompt substitution
setopt PROMPT_SUBST

# ── Colors ──────────────────────────────────
# Use 256-color codes for richer palette
local c_reset='%f%k%b'
local c_host='%F{81}'      # cyan-ish blue
local c_cwd='%F{214}'      # warm orange
local c_time='%F{245}'     # muted grey
local c_dur='%F{203}'      # coral/red
local c_prompt='%F{149}'   # soft green
local c_sep='%F{238}'      # dark grey

# ── Git branch segment (only shown inside a git repo) ──
_git_segment() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(git rev-parse --short HEAD 2>/dev/null) || return
  echo -n "%F{238}─%F{238}[%F{140} ${branch}%F{238}]"
}

# ── Duration segment (only shown when non-empty) ──
_duration_segment() {
  if [[ -n $_cmd_duration ]]; then
    echo -n "%F{238}[%F{203} ${_cmd_duration} %F{238}]%f "
  fi
}

# ── Build the prompt ────────────────────────
#
#  ┌─[14:32:05]─[host]─[~/path/to/dir]─[ branch]
#  └─ ❯
#

PROMPT='
%F{238}┌─%F{238}[%F{245}%D{%H:%M:%S}%F{238}]%F{238}─%F{81}[%B%m%b%F{81}]%F{238}─%F{214}[%B%~%b%F{214}]%F{238}$(_git_segment)
%F{238}└─%F{149}%(!.#.❯)%f '

RPROMPT='$(_duration_segment)'
