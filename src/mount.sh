_patch_table() { 
    _patch_table_edit_options \
        '--label;[`_choice_label`]' \
        '--options;*,[`_choice_options`]' \
        '--options-mode;[ignore|append|prepend|replace]' \
        '--options-source;[fstab|mtab|disable]' \
        '--source;[`_choice_source`]' \
        '--target(<path>)' \
        '--types;*,[`_choice_fstype`]' \
        '--uuid;[`_choice_uuid`]' \
    | \
    _patch_table_edit_arguments \
        ';;' \
        'mount-source;[`_choice_mount_source`]' \
        'mount-target;[`_choice_mount_target`]' \

}

_choice_label() {
    lsblk --json -o KNAME,LABEL,PARTLABEL,PARTUUID,PATH,SIZE,PARTTYPENAME,TYPE,UUID | \
    yq '.blockdevices[] | select(.label != null) | .label + "	"  + (.kname // "")'
}

_choice_options() {
    cat <<-'EOF' | _argc_util_comp_kv = 
async;;All I/O to the filesystem should be done asynchronously.
atime;;Do not use the noatime feature.
noatime;;Do not update inode access times on this filesystem.
auto;;Can be mounted with the -a option.
noauto;;Can only be mounted explicitly.
context=;;Set context
fscontext=;;Set context
defcontext=;;Set context
rootcontext=;;Set context
defaults;;Use the default options
dev;;Interpret character or block special devices on the filesystem.
nodev;;Do not interpret character or block special devices on the filesystem.
diratime;;Update directory inode access times on this filesystem.
nodiratime;;Do not update directory inode access times on this filesystem.
dirsync;;All directory updates within the filesystem should be done synchronously.
exec;;Permit execution of binaries.
noexec;;Do not permit direct execution of any binaries on the mounted filesystem.
group;;Allow an ordinary user to mount the filesystem if one of that user’s groups matches the group of the device.
iversion;;Every time the inode is modified, the i_version field will be incremented.
noiversion;;Do not increment the i_version inode field.
mand;;Allow mandatory locks on this filesystem.
nomand;;Do not allow mandatory locks on this filesystem.
_netdev;;The filesystem resides on a device that requires network access
nofail;;Do not report errors for this device if it does not exist.
relatime;;Update inode access times relative to modify or change time.
norelatime;;Do not use the relatime feature.
strictatime;;Allows to explicitly request full atime updates.
nostrictatime;;Use the kernel’s default behavior for inode access time updates.
lazytime;;Only update times on the in-memory version of the file inode.
nolazytime;;Do not use the lazytime feature.
suid;;Honor set-user-ID and set-group-ID bits or file capabilities
nosuid;;Do not honor set-user-ID and set-group-ID bits or file capabilities
silent;;Turn on the silent flag.
loud;;Turn off the silent flag.
owner;;Allow an ordinary user to mount the filesystem if that user is the owner of the device.
remount;;Attempt to remount an already-mounted filesystem.
ro;;Mount the filesystem read-only.
rw;;Mount the filesystem read-write.
sync;;All I/O to the filesystem should be done synchronously.
user;;Allow an ordinary user to mount the filesystem.
nouser;;Forbid an ordinary user to mount the filesystem.
users;;Allow any user to mount and to unmount the filesystem
X-mount.mkdir;;Allow to make a target directory if it does not exist yet.
X-mount.subdir=;;Allow mounting sub-directory from a filesystem instead of the root directory.
nosymfollow;;Do not follow symlinks when resolving paths.
EOF
}

_choice_source() {
    if _argc_util_has_path_prefix "$ARGC_FILTER"; then
        _choice_block_device
        _argc_util_comp_path
        return
    fi
    cat <<-'EOF' | _argc_util_comp_kv = 
LABEL=`_choice_label`;;specifies device by filesystem label
UUID=`_choice_uuid`;;specifies device by filesystem UUID
PARTLABEL=`_choice_partlabel`;;specifies device by partition label
PARTUUID=`_choice_partuuid`;;specifies device by partition UUID
ID=;;specifies device by udev hardware ID
EOF
}

_choice_fstype() {
    cat <<-'EOF'
bfs	is the native file system for the BeOS
brtfs	combines the copy-on-write principle with a logical volume manager
cramfs	a free read-only Linux file system designed for simplicity and space-efficiency
exfat	is a file system optimized for flash memory such as USB flash drives and SD cards
ext	is an elaborate extension of the minix filesystem.
ext2	is the high performance disk filesystem used by Linux  for  fixed  disks  as  well  as removable  media.
ext3	is a journaling version of the ext2 filesystem.
ext4	is  a  set  of  upgrades  to  ext3  including  substantial performance and reliability enhancements.
fat	is a file system developed for personal computers
f2fs	s a flash file system initially developed by Samsung Electronics
hpfs	is  the High Performance Filesystem, used in OS/2.
iso9660	is a CD-ROM filesystem type conforming to the ISO 9660 standard.
jfs	is a journaling filesystem, developed by IBM.
minix	is  the  filesystem  used in the Minix operating system, the first to run under Linux.
msdos	is  the filesystem used by DOS, Windows, and some OS/2 computers.
ncpfs	is  a  network  filesystem that supports the NCP protocol, used by Novell NetWare.
nfs	is the network filesystem used to access disks located on remote computers.
ntfs	is the filesystem native to Microsoft Windows NT.
proc	is a pseudo filesystem which is used as an interface to kernel data structures.
reiserfs	is a journaling filesystem, designed by Hans Reiser.
smb	is  a  network  filesystem  that  supports the SMB protocol.
sysv	is an implementation of the System V/Coherent filesystem for Linux.
tmpfs	is  a  filesystem  whose  contents  reside in virtual memory.
umsdos	is  an  extended DOS filesystem used by Linux.
vfat	is an extended FAT filesystem used by Microsoft Windows95 and Windows NT.
xfs	is a journaling filesystem, developed by SGI.
xiafs	was designed and implemented to be a stable, safe filesystem by  extending  the  Minix filesystem code.
EOF
}

_choice_block_device() {
    lsblk --json -o KNAME,LABEL,PARTLABEL,PARTUUID,PATH,SIZE,PARTTYPENAME,TYPE,UUID | \
    yq '.blockdevices[] | .path + "	" + .size + " " + (.parttypename // "")'
}

_choice_uuid() {
    lsblk --json -o KNAME,LABEL,PARTLABEL,PARTUUID,PATH,SIZE,PARTTYPENAME,TYPE,UUID | \
    yq '.blockdevices[] | select(.uuid != null) | .uuid + "	" + (.kname // "")'
}

_choice_partlabel() {
    lsblk --json -o KNAME,LABEL,PARTLABEL,PARTUUID,PATH,SIZE,PARTTYPENAME,TYPE,UUID | \
    yq '.blockdevices[] | select(.partlabel != null) | .partlabel + "	" + (.kname // "")'
}

_choice_partuuid() {
    lsblk --json -o KNAME,LABEL,PARTLABEL,PARTUUID,PATH,SIZE,PARTTYPENAME,TYPE,UUID | \
    yq '.blockdevices[] | select(.partuuid != null) | .partuuid + "	" + (.kname // "")'
}

_choice_mount_source() {
    if [[ -n "$argc_all" ]]; then
        return
    fi
    if helper_is_operation; then
        _choice_mount_point
        return
    fi
    if [[ -n "$argc_source" ]]; then
        if [[ -n "$argc_target" ]]; then
            return
        fi
        echo __argc_value=dir
        return
    fi
    _choice_source
}

_choice_mount_target() {
    if [[ -n "$argc_all" ]]; then
        return
    fi
    if helper_is_operation; then
        if [[ -n "$argc_bind" ]] \
        || [[ -n "$argc_move" ]] \
        || [[ -n "$argc_rbind" ]] \
        ; then
            echo __argc_value=dir
            return
        fi
    fi
    if [[ -z "$argc_source" ]] && [[ -z "$argc_target" ]]; then
        echo __argc_value=dir
        return
    fi
}

_choice_mount_point() {
    cat /proc/mounts | gawk '{print $2 "\t" $1}' 
}

helper_is_operation() {
    if [[ -n "$argc_bind" ]] \
    || [[ -n "$argc_move" ]] \
    || [[ -n "$argc_rbind" ]] \
    || [[ -n "$argc_make_shared" ]] \
    || [[ -n "$argc_make_slave" ]] \
    || [[ -n "$argc_make_private" ]] \
    || [[ -n "$argc_make_unbindable" ]] \
    || [[ -n "$argc_make_rshared" ]] \
    || [[ -n "$argc_make_rslave" ]] \
    || [[ -n "$argc_make_rprivate" ]] \
    ; then
        return 0
    else
        return 1
    fi
}