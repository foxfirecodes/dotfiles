# vi: ft=tmux

# adapted from https://github.com/folke/tokyonight.nvim/blob/main/extras/tmux/tokyonight_night.tmux

# TokyoNight colors for Tmux

set -g @FG_PRIMARY "#7aa2f7"
set -g @BG_PRIMARY "#16161e"
set -g @BG_SECONDARY "#3b4261"

set -g mode-style "fg=#{@FG_PRIMARY},bg=#{@BG_SECONDARY}"

set -g message-style "fg=#{@FG_PRIMARY},bg=#{@BG_SECONDARY}"
set -g message-command-style "fg=#{@FG_PRIMARY},bg=#{@BG_SECONDARY}"

set -g pane-border-style "fg=#{@BG_SECONDARY}"
set -g pane-active-border-style "fg=#{@FG_PRIMARY}"

# set -g status "on"
# set -g status-justify "left"
# 
# set -g status-style "fg=#{@FG_PRIMARY},bg=#{@BG_PRIMARY}"
# 
# set -g status-left-length "100"
# set -g status-right-length "100"
# 
# set -g status-left-style NONE
# set -g status-right-style NONE
# 
# set -g status-left "#[fg=#15161e,bg=#{@FG_PRIMARY},bold] #S #[fg=#{@FG_PRIMARY},bg=#{@BG_PRIMARY},nobold,nounderscore,noitalics]"
# set -g status-right "#[fg=#{@BG_PRIMARY},bg=#{@BG_PRIMARY},nobold,nounderscore,noitalics]#[fg=#{@FG_PRIMARY},bg=#{@BG_PRIMARY}] #{prefix_highlight} #[fg=#{@BG_SECONDARY},bg=#{@BG_PRIMARY},nobold,nounderscore,noitalics]#[fg=#{@FG_PRIMARY},bg=#{@BG_SECONDARY}] %Y-%m-%d  %H:%M #[fg=#{@FG_PRIMARY},bg=#{@BG_SECONDARY},nobold,nounderscore,noitalics]#[fg=#15161e,bg=#{@FG_PRIMARY},bold] #h "
# 
# setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#{@BG_PRIMARY}"
# setw -g window-status-separator ""
# setw -g window-status-style "NONE,fg=#a9b1d6,bg=#{@BG_PRIMARY}"
# setw -g window-status-format "#[fg=#{@BG_PRIMARY},bg=#{@BG_PRIMARY},nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#{@BG_PRIMARY},bg=#{@BG_PRIMARY},nobold,nounderscore,noitalics]"
# setw -g window-status-current-format "#[fg=#{@BG_PRIMARY},bg=#{@BG_SECONDARY},nobold,nounderscore,noitalics]#[fg=#{@FG_PRIMARY},bg=#{@BG_SECONDARY},bold] #I  #W #F #[fg=#{@BG_SECONDARY},bg=#{@BG_PRIMARY},nobold,nounderscore,noitalics]"
# 
# # tmux-plugins/tmux-prefix-highlight support
# set -g @prefix_highlight_output_prefix "#[fg=#e0af68]#[bg=#{@BG_PRIMARY}]#[fg=#{@BG_PRIMARY}]#[bg=#e0af68]"
# set -g @prefix_highlight_output_suffix ""
