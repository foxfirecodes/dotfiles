function tool_installer -a subcmd
    switch $subcmd
        case mise
            curl https://mise.run | sh
            return
        case pnpm
            curl -fsSL https://get.pnpm.io/install.sh | sh -
            awk '/^# pnpm$/,/^# pnpm end$/{next} {print}' ~/.config/fish/config.fish >/tmp/config.fish && cp /tmp/config.fish ~/.config/fish/config.fish
            fish_indent -w ~/.config/fish/config.fish
            return
    end
end
