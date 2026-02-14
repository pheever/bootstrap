function __git_clone_preexec --on-event fish_preexec
    set -l cmd (string split ' ' -- $argv[1])

    # Only act on `git clone ...`
    if test (count $cmd) -lt 3; or test "$cmd[1]" != git; or test "$cmd[2]" != clone
        return
    end

    # Extract the URL (skip flags)
    set -l clone_url ""
    set -l has_dest false
    set -l skip_next false
    for i in (seq 3 (count $cmd))
        if $skip_next
            set skip_next false
            continue
        end
        switch $cmd[$i]
            case --branch --depth --jobs -j -b --reference --reference-if-able \
                 --origin -o --template --config -c --server-option \
                 --separate-git-dir --bundle-uri
                set skip_next true
            case '-*'
                continue
            case '*'
                if test -z "$clone_url"
                    set clone_url $cmd[$i]
                else
                    # User specified an explicit destination; don't interfere
                    set has_dest true
                end
        end
    end

    if test -z "$clone_url"; or $has_dest
        return
    end

    # Parse the URL to extract host and path
    set -l host ""
    set -l url_path ""

    switch $clone_url
        case 'https://*' 'http://*'
            set -l stripped (string replace -r '^https?://' '' $clone_url)
            set host (string split -m1 '/' $stripped)[1]
            set url_path (string split -m1 '/' $stripped)[2]
        case 'git@*'
            set -l stripped (string replace 'git@' '' $clone_url)
            set host (string split -m1 ':' $stripped)[1]
            set url_path (string split -m1 ':' $stripped)[2]
        case 'ssh://*'
            set -l stripped (string replace -r '^ssh://[^@]*@' '' $clone_url)
            set host (string split -m1 '/' $stripped)[1]
            set url_path (string split -m1 '/' $stripped)[2]
        case '*:*/*'
            set -l stripped (string replace -r '^[^@]*@' '' $clone_url)
            set host (string split -m1 ':' $stripped)[1]
            set url_path (string split -m1 ':' $stripped)[2]
        case '*'
            return
    end

    # Normalize: strip .git suffix, trailing slashes
    set url_path (string replace -r '\.git$' '' $url_path)
    set url_path (string trim -r -c '/' $url_path)

    # Normalize Azure DevOps
    set host (string replace 'ssh.dev.azure.com' 'dev.azure.com' $host)
    set url_path (string replace -r '/_git/' '/' $url_path)
    set url_path (string replace -r '^v3/' '' $url_path)

    set -l target_dir "$HOME/source/$host/$url_path"
    set -l parent_dir (string replace -r '/[^/]+$' '' $target_dir)

    mkdir -p $parent_dir
    echo ">>> Cloning into $target_dir"
    cd $parent_dir
end
