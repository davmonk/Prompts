# ─────────────────────────────────────────────
#  Cool Bash Prompt
#  Features: time, hostname, cwd, git branch, cmd duration
# ─────────────────────────────────────────────

# ── Colors ──────────────────────────────────
_c_reset='\[\e[0m\]'
_c_sep='\[\e[38;5;238m\]'
_c_time='\[\e[38;5;245m\]'
_c_host='\[\e[1;38;5;81m\]'
_c_cwd='\[\e[1;38;5;214m\]'
_c_git='\[\e[38;5;140m\]'
_c_prompt='\[\e[38;5;149m\]'
_c_dur='\[\e[38;5;203m\]'

# ── Track command start time ──────────────
_prompt_preexec() {
  _cmd_start=$SECONDS
}

# Attach to DEBUG trap (fires before each command)
trap '_prompt_preexec' DEBUG

# ── Build prompt via PROMPT_COMMAND ──────
_build_prompt() {
  local exit_code=$?

  # Calculate duration
  local dur_segment=""
  if [[ -n $_cmd_start ]]; then
    local elapsed=$(( SECONDS - _cmd_start ))
    unset _cmd_start
    if (( elapsed >= 3600 )); then
      local h=$(( elapsed / 3600 ))
      local m=$(( (elapsed % 3600) / 60 ))
      local s=$(( elapsed % 60 ))
      dur_segment="\[\e[38;5;238m\][\[\e[38;5;203m\] ${h}h${m}m${s}s \[\e[38;5;238m\]] "
    elif (( elapsed >= 60 )); then
      local m=$(( elapsed / 60 ))
      local s=$(( elapsed % 60 ))
      dur_segment="\[\e[38;5;238m\][\[\e[38;5;203m\] ${m}m${s}s \[\e[38;5;238m\]] "
    elif (( elapsed >= 1 )); then
      dur_segment="\[\e[38;5;238m\][\[\e[38;5;203m\] ${elapsed}s \[\e[38;5;238m\]] "
    fi
  fi

  # Git branch
  local git_segment=""
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(git rev-parse --short HEAD 2>/dev/null)
  if [[ -n $branch ]]; then
    git_segment="\[\e[38;5;238m\]-[\[\e[38;5;140m\] ${branch}\[\e[38;5;238m\]]"
  fi

  # Prompt symbol (# for root, ❯ otherwise)
  local symbol="❯"
  [[ $EUID -eq 0 ]] && symbol="#"

  # Right-side duration: move cursor to end of line, print, return
  # Bash doesn't have RPROMPT, so we embed the duration inline on line 2
  PS1="\n\[\e[38;5;238m\]┌─[\[\e[38;5;245m\]\t\[\e[38;5;238m\]]─[\[\e[1;38;5;81m\]\h\[\e[0;38;5;238m\]]─[\[\e[1;38;5;214m\]\w\[\e[0;38;5;238m\]]${git_segment}\n\[\e[38;5;238m\]└─${dur_segment}\[\e[38;5;149m\]${symbol}\[\e[0m\] "
}

PROMPT_COMMAND='_build_prompt'
