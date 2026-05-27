# vi: ft=tmux

if-shell '[ "$(uname -s)" = Darwin ]' {
  set -s extended-keys off
  set -g @scroll-speed-num-lines-per-scroll 1
}
