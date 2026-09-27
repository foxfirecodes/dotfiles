function rcat -w rsync
    if not count $argv >/dev/null
        echo "usage: rcat <file> [opts]"
    else
        set -l rcat_out (mktemp)
        rsync -z $argv $rcat_out && cat $rcat_out
        rm $rcat_out
    end
end
