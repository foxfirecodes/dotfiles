# vi: ft=tmux

if-shell '[ "$(uname -s)" = Darwin ]' {
  # ghostty + tmux + extended-keys on macOS doesnt work right, so to get pi to still work we just rebind shift+enter to ctrl+j
  set -s extended-keys off
  bind -n S-Enter send-keys C-j
  set -g @scroll-speed-num-lines-per-scroll 1
}
