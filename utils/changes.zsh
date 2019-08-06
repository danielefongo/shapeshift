__shapeshift_config_dir="$HOME/.shapeshift"
__shapeshift_version_file="$__shapeshift_config_dir/version"

function __shapeshift_change_log() {
    local last_version=0
    if [ -f "$__shapeshift_version_file" ]; then
        last_version=$(cat "$__shapeshift_version_file")
    fi

    if [ $last_version -lt $SHAPESHIFT_VERSION ]; then
        for a in $(seq $(( version + 1 )) $SHAPESHIFT_VERSION); do
            __shapeshift_changelog_header "Version $a"
            cat "$__shapeshift_path/changelogs/$a"
            print
        done

        __shapeshift_changelog_header "End of changelog."
    fi

    echo "$SHAPESHIFT_VERSION" > "$__shapeshift_version_file"
}

function __shapeshift_changelog_header() {
    print
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    echo "$@"
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print
}