function kube-import --description 'Merge all yml kubeconfigs from a directory into ~/.kube/config' --argument dir
    if test -z "$dir"
        echo "Usage: kube-import /path/to/dir"
        return 1
    end

    if not test -d "$dir"
        echo "Error: $dir is not a directory"
        return 1
    end

    set -l files $dir/*.yml $dir/*.yaml
    set -l valid
    for f in $files
        test -f "$f"; and set -a valid $f
    end

    if not count $valid >/dev/null
        echo "No .yml or .yaml files found in $dir"
        return 1
    end

    mkdir -p ~/.kube

    # Build KUBECONFIG string: existing config + all new files
    set -l kubeconfig ~/.kube/config
    for f in $valid
        set kubeconfig $kubeconfig:$f
    end

    # Merge and write back
    set -l merged (KUBECONFIG=(string join : $kubeconfig) kubectl config view --flatten)
    if test $status -eq 0
        echo $merged >~/.kube/config
        chmod 600 ~/.kube/config
        echo "Merged "(count $valid)" file(s) into ~/.kube/config"
    else
        echo "Error: kubectl config merge failed"
        return 1
    end
end
