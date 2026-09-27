function rcat -a file
    if test -z "$file"
        echo "usage: rcat <file>"
    else
        set -l rcat_out (mktemp)
        rsync -z $file $rcat_out && cat $rcat_out
        rm $rcat_out
    end
end
