# ─────────────────────────────────────────────
#  Cool Tcsh Prompt
#  Features: time, hostname, cwd, git branch, cmd duration
# ─────────────────────────────────────────────

# ── Command duration ─────────────────────────
# tcsh's built-in time variable: print timing for commands >= 1 second
# %e = elapsed wall-clock seconds
set time = (1 "\033[38;5;238m[\033[38;5;203m took %e sec \033[38;5;238m]\033[0m")

# ── Build prompt via precmd ───────────────────
# tcsh has no preexec, so we rebuild the whole prompt in precmd.
# We use `date` for HH:MM:SS since %p may not be available on all platforms.

alias _update_prompt '\
  set _time = `date +%H:%M:%S`; \
  set _git_seg = ""; \
  set _branch = `git symbolic-ref --short HEAD 2>/dev/null`; \
  if ($status == 0) then; \
    set _git_seg = "\033[38;5;238m─[\033[38;5;140m ${_branch}\033[38;5;238m]"; \
  else; \
    set _branch = `git rev-parse --short HEAD 2>/dev/null`; \
    if ($status == 0) then; \
      set _git_seg = "\033[38;5;238m─[\033[38;5;140m ${_branch}\033[38;5;238m]"; \
    endif; \
  endif; \
  set prompt = "\n\033[38;5;238m┌─[\033[38;5;245m${_time}\033[38;5;238m]─[\033[1;38;5;81m%m\033[0;38;5;238m]─[\033[1;38;5;214m%~\033[0;38;5;238m]${_git_seg}\n\033[38;5;238m└─\033[38;5;149m%# \033[0m"'

alias precmd '_update_prompt'

# Run once immediately so the prompt is set on first load
_update_prompt
