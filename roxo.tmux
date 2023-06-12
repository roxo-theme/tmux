#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
	local option value default
	option="$1"
	default="$2"
	value="$(tmux show-option -gqv "$option")"

	if [ -n "$value" ]; then
		echo "$value"
	else
		echo "$default"
	fi
}

set() {
	local option=$1
	local value=$2
	tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
	local option=$1
	local value=$2
	tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
	# command array
	local tmux_commands=()

	# shellcheck source=roxo.tmuxtheme
	source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/roxo.tmuxtheme")"

	# default icons
	local status_separator="█"
	local user_icon=""
	local window_icon="󰖯"
	local session_icon=""
	local host_icon="󰒋"

	# status
	set status "on"
	set status-bg "${thm_bg}"
	set status-justify "left"
	set status-left-length "100"
	set status-right-length "100"

	# messages
	set message-style "fg=${thm_cyan},bg=${thm_bg},align=centre"
	set message-command-style "fg=${thm_cyan},bg=${thm_bg},align=centre"

	# panes
	set pane-border-style "fg=${thm_magenta}"
	set pane-active-border-style "fg=${thm_blue}"

	# windows
	setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
	setw window-status-separator ""
	setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

	# directory tabs
	setw window-status-format "#[fg=$thm_bg,bg=$thm_magenta] #I #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path} "
	setw window-status-current-format "#[fg=$thm_bg,bg=$thm_orange bold] #I #[fg=$thm_fg,bg=$thm_bg] #{b:pane_current_path} "

	# modes
	setw clock-mode-colour "${thm_blue}"
	setw mode-style "fg=${thm_pink} bg=${thm_bg} bold"

	## --- Statusline --- ##

	local show_window
	readonly show_window="#[fg=$thm_magenta,bg=$thm_bg,nobold,nounderscore,noitalics]$status_separator#[fg=$thm_bg,bg=$thm_magenta,nobold,nounderscore,noitalics]$window_icon#[fg=$thm_magenta,bg=$thm_bg,nobold,nounderscore,noitalics]$status_separator#[fg=$thm_fg,bg=$thm_bg] #W #{?client_prefix,#[fg=$thm_red]"

	local show_session
	readonly show_session="#[fg=$thm_green]#[bg=$thm_bg]$status_separator#{?client_prefix,#[bg=$thm_green],#[bg=$thm_green]}#[fg=$thm_bg]$session_icon#[fg=$thm_green]#[bg=$thm_bg]$status_separator#[fg=$thm_fg,bg=$thm_bg] #S "

	local show_user
	readonly show_user="#[fg=$thm_pink,bg=$thm_bg]$status_separator#[fg=$thm_bg,bg=$thm_pink]$user_icon#[fg=$thm_pink,bg=$thm_bg]$status_separator#[fg=$thm_fg,bg=$thm_bg] #(whoami) "

	local show_host
	readonly show_host="#[fg=$thm_cyan,bg=$thm_bg]$status_separator#[fg=$thm_bg,bg=$thm_cyan]$host_icon#[fg=$thm_cyan,bg=$thm_bg]$status_separator#[fg=$thm_fg,bg=$thm_bg] #H "

	local right_column1=$show_user$show_host
	local right_column2=$show_session$show_window

	set status-left ""
	set status-right "${right_column1}${right_column2}"

	tmux "${tmux_commands[@]}"
}

main "$@"
