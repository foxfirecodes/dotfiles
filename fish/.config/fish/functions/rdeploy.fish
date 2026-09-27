function rdeploy -a file
    if test -z "$file"
        echo "usage: rdeploy <file>"
        return 1
    end

    if not test -e "$file"
        echo "file $file does not exist"
        return 1
    end

    set hostnames (grep -oE "[a-zA-Z0-9_-]*.local" ~/.ssh/config)
    for target in $hostnames
        echo "deploying $file to $target"
        rsync -avz $file $target:$file
    end
end
