#!/bin/bash
stow -v -d "$(dirname "$0")" -t ~ --ignore .gitignore "$@"
