# vi: ft=tmux

if-shell '[ "$(uname -s)" = Darwin ]' {
  set -g @scroll-speed-num-lines-per-scroll 1
}
