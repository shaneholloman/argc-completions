_patch_table() { 
    if [[ "$*" == "stack" ]]; then
        _patch_table_edit_commands \
            'ghci(ghci, repl)' \
            'repl' \
            'runghc(runghc, runhaskell)' \
            'runhaskell' \

    elif [[ "$*" == "stack build" ]] \
      || [[ "$*" == "stack test" ]] \
      || [[ "$*" == "stack bench" ]] \
      || [[ "$*" == "stack haddock" ]] \
      || [[ "$*" == "stack dot" ]] \
    ; then
        _patch_table_edit_arguments 'target;[`_choice_target`]'


    elif [[ "$*" == "stack ide" ]] \
      || [[ "$*" == "stack docker" ]] \
      || [[ "$*" == "stack config" ]] \
      || [[ "$*" == "stack hpc" ]] \
    ; then
        _patch_table_dedup_options \
            '--setup-info-yaml' \
            '--snapshot-location-base' \

    elif [[ "$*" == "stack unpack" ]] \
      || [[ "$*" == "stack list" ]] \
    ; then
        _patch_table_edit_arguments 'package;[`_choice_dependency`]'

    elif [[ "$*" == "stack ghci" ]]; then
        _patch_table_edit_arguments 'target/file;[`_choice_target_or_file`]'

    else
        cat
    fi
}

_choice_target() {
    stack ide targets
}

_choice_dependency() {
    stack ls dependencies | gawk '{print $1}'
}

_choice_target_or_file() {
    if _argc_util_has_path_prefix "$ARGC_FILTER"; then
        _argc_util_comp_path
        return
    fi
    _choice_target
}