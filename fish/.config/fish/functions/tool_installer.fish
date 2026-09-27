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
        case paseo
            if type -q paseo
                echo "upgrading paseo"
                pnpm up -gL @getpaseo/cli
            else
                echo "installing paseo"
                pnpm add -g @getpaseo/cli
            end

            set -l paseo_daemon_listen (tailscale ip -4):6767
            echo "setting daemon.listen to $paseo_daemon_listen"
            paseo daemon config set daemon.listen $paseo_daemon_listen
            return
        case tailscale
            curl -fsSL https://tailscale.com/install.sh | sh
            return
    end
end
