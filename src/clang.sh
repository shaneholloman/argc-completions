_patch_help() {
    $@ --help | \
    sed \
        -e '/^\s*-###/ d' \
        -e '/^\s*-stdlib++-isystem/ d' \

}

_patch_table() {
    _patch_table_dedup_options \
        ';;' \
        '-flto' \
        '-mabi' \
        '-mcmodel' \
        '-ObjC' \
        '-Xopenmp-target' \

}
