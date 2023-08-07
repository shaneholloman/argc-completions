_patch_help() { 
    _common_edit() {
        gawk '{
            printLine = 1
            if (match($0, /^\s*-/)) {
                gsub(/\[no\]/, "[no-]", $0)
                if (match($0, / \((.*)\)$/, arr)) {
                    option = substr($0, 1, RSTART -1)
                    notation = ""
                    bool = 0
                    desc = ""
                    split(arr[1], parts, ";")
                    for (i in parts) {
                        part = parts[i]
                        if (part == "a boolean") {
                            bool = 1
                        } else if (match(part, /^\S+$/)) {
                            notation = "<" part ">"
                        } else if (match(part, /^(a|an)? ?(\S+)$/, arr2)) {
                            notation = "<" arr2[2]  ">"
                        } else if (match(part, / or \S+$/)) {
                            gsub(/(, | or )/, "|", part)
                            notation = "{" part "}"
                        } else if (match(part, / default:/)) {
                        } else if (part == "a build target label" && notation == "") {
                            notation = "<label>"
                        } else {
                            desc = desc part
                        }
                    }
                    if (bool == 0 && notation == "") {
                        if (match(desc, /path|file/)) {
                            notation = "<path>"
                        } else if (match(desc, /dir|folder/)) {
                            notation = "<dir>"
                        } else {
                            notation = "<value>"
                        }
                    }
                    print option " " notation "   " desc
                    printLine = 0
                }
            }
            if (printLine == 1) {
                print $0
            }
        }'
    }

    if [[ "$*" == "bazel" ]]; then
        _patch_help_run_help_subcmd $@
        bazel help startup_options 2>/dev/null | _common_edit
    else
        _patch_help_run_help_subcmd $@ | _common_edit
    fi
}

_patch_table() { 
    table="$(sed 's/ <label> #/ <label> # # [`_choice_target`]/')"

    if [[ "$*" == "bazel info" ]]; then
        echo "$table" | \
        _patch_table_edit_arguments 'keys;*[`_choice_info_key`]'

    elif [[ "$*" == "bazel test" ]] \
      || [[ "$*" == "bazel coverage" ]] \
    ; then
        echo "$table" | \
        _patch_table_edit_arguments 'test-targets;*[`_choice_test_target`]'

    elif [[ "$*" == "bazel aquery" ]] \
      || [[ "$*" == "bazel build" ]] \
      || [[ "$*" == "bazel cquery" ]] \
      || [[ "$*" == "bazel fetch" ]] \
      || [[ "$*" == "bazel mobile-install" ]] \
      || [[ "$*" == "bazel print_action" ]] \
    ; then
        echo "$table" | \
        _patch_table_edit_arguments \
            'targets;*[`_choice_target`]' \
            'target;[`_choice_target`]' \

    elif [[ "$*" == "bazel run" ]]; then
        echo "$table" | \
        _patch_table_edit_arguments 'binary target;*[`_choice_run_target`]'

    else
        echo "$table"

    fi
}

_choice_info_key() {
    bazel help info-keys | sed 's/ \+/\t/'
}

_choice_test_target() {
    _helper_find_target test
}

_choice_run_target() {
    _helper_find_target run
}

_choice_target() {
    _helper_find_target
}

_helper_find_target() {
    local pattern
    if [[ "$1" == "test" ]]; then
        pattern='(test|test_suite)'
    elif [[ "$1" == "run" ]]; then
        pattern='(binary)'
    fi
    _helper_find_workspace_dir
    if [[ -z "$workspace_dir" ]]; then
        return
    fi
    if [[ "$ARGC_FILTER" == *':'* ]]; then
        _helper_find_rules_in_package
    else
        _helper_find_package
    fi
}

_helper_find_rules_in_package() {
    local package_name="${ARGC_FILTER%%:*}"
    bazel --output_base=/tmp/bazel-completion-$USER query \
        --keep_going --noshow_progress --output=label "kind('$pattern rule', '$package_name:*')"
}

_helper_find_package() {
    find "$workspace_dir" -name BUILD* | \
    sed \
        -e 's|/BUILD\(\.bazel\)\?$|:\x00|' \
        -e "s|^$workspace_dir:|//:|" \
        -e "s|^$workspace_dir|/|" \

}

_helper_find_workspace_dir() {
    workspace_dir="$(_argc_util_path_search_parent -p WORKSPACE WORKSPACE.bazel)"
}