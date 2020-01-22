#!/usr/bin/env sh

# vmrun [AUTHENTICATION-FLAGS] COMMANDS [PARAMETERS]

vmware_folder=$HOME/vmware
authentication_flags="hostType\\nencryptedVirtualPassword\\nGuestUsername\\nGuestPassword"
power_commands="start\\nstop\\nreset\\nsuspend\\npause\\nunpause"
snapshot_commands="listSnapshots\\nsnapshot\\ndeleteSnapshot\\nrevertToSnapshot"
guest_os_commands="runProgramInGuest\\nfileExistsInGuest\\ndirectoryExistsInGuest\\nsetSharedFolderState\\naddSharedFolder\\nremoveSharedFolder\\nenableSharedFolders\\ndisableSharedFolders\\nlistProcessesInGuest\\nkillProcessInGuest\\nrunScriptInGuest\\ndeleteFileInGuest\\ncreateDirectoryInGuest\\ndeleteDirectoryInGuest\\nCreateTempfileInGuest\\nlistDirectoryInGuest\\nCopyFileFromHostToGuest\\nCopyFileFromGuestToHost\\nrenameFileInGuest\\ntypeKeystrokesInGuest\\nconnectNamedDevice\\ndisconnectNamedDevice\\ncaptureScreen\\nwriteVariable\\nreadVariable\\ngetGuestIPAddress"
general_commands="list\\nupgradevm\\ninstallTools\\ncheckToolsState\\ndeleteVM\\nclone"
custom_commands="listVirtualMachines"
options="authentication_flags\\npower_commands\\nsnapshot_commands\\nguest_os_commands\\ngeneral_commands\\ncustom_commands\\nview_commands\\nexit"

set_auth_flags(){
    [ -z $1 ] && flag=$(printf "$authentication_flags\\nexit" | dmenu -i -p 'Authentication flags')
    while [ "$flag" != 'exit' ]; do
        if [ "$flag" = 'hostType' ]; then
            types="ws\\nfusion\\nplayer" # write a check to see which of those are installed
            hostType=$(printf $types | dmenu -i -p 'hostType')
            set_auth_flags
        elif [ "$flag" = 'encryptedVirtualPassword' ]; then
            encryptedVirtualPassword=$(printf '\#' | dmenu -i -p 'encryptedVirtualPassword')
            set_auth_flags
        elif [ "$flag" = 'GuestUsername' ]; then
            GuestUsername=$(printf '\#' | dmenu -i -p 'GuestUsername')
            set_auth_flags
        elif [ "$flag" = 'GuestPassword' ]; then
            GuestPassword=$(printf '\#' | dmenu -i -p 'GuestPassword')
            set_auth_flags
        elif [ "$flag" = 'exit' ]; then
            set_auth_flags
        else
            error_message $flag
        fi
    done
    flags="$hostType\\n$encryptedVirtualPassword\\n$GuestUsername\\n$GuestPassword"
    notify-send "$flags"
    build_commands
}

use_power_commands(){
    [ -z $1 ] && selection=$(printf $power_commands | dmenu -i -p 'Power commands')
    command=$selection
    if [ "$selection" = 'start' ]; then
        parameters="gui\\nnogui"
        parameter=$(printf $parameters | dmenu -i -p 'Parameters')
    elif [ "$selection" = 'stop' -o "$selection" = 'reset' -o "$selection" = 'suspend' ]; then
        parameters="hard\\nsoft"
        parameter=$(printf $parameters | dmenu -i -p 'Parameters')
    else
        error_message $selection
    fi
    use_custom_commands listVirtualMachines
    vmrun $command "$vmware_folder/$machine_folder/$machine" $parameter
    build_commands
}

use_snapshot_commands(){
    [ -z $1 ] && selection=$(printf $snapshot_commands | dmenu -i -p 'Snapshot commands')
    command=$selection
    if [ "$selection" = 'listSnapshots' ]; then
        a
    elif [ "$selection" = 'snapshot' ]; then
        a
    elif [ "$selection" = 'deleteSnapshot' ]; then
        a
    elif [ "$selection" = 'revertToSnapshot' ]; then
        a
    else
        error_message $selection
    fi
    build_commands
}

use_guest_os_commands(){
    [ -z $1 ] && selection=$(printf $guest_os_commands | dmenu -i -p 'Guest OS commands')
    if [ "$selection" = 'getGuestIPAddress' ]; then
        command=$selection
        use_custom_commands listVirtualMachines
        vmrun $command "$vmware_folder/$machine_folder/$machine"
    else
        error_message $selection
    fi
    build_commands
}

use_general_commands(){
    [ -z $1 ] && selection=$(printf $general_commands | dmenu -i -p 'General commands')
    if [ "$selection" = 'list' ]; then
        running_machines=$(vmrun $selection)
        notify-send "$running_machines"
    elif [ "$selection" = 'upgradevm' ]; then
        a
    elif [ "$selection" = 'installTools' ]; then
        command=$selection
        use_custom_commands listVirtualMachines
        vmrun $command "$vmware_folder/$machine_folder/$machine"
    elif [ "$selection" = 'checkToolsState' ]; then
        a
    elif [ "$selection" = 'deleteVM' ]; then
        a
    elif [ "$selection" = 'clone' ]; then
        a
    else
        error_message $selection
    fi
    build_commands
}

use_custom_commands(){
    [ -z $1 ] && selection=$(printf $custom_commands | dmenu -i -p 'Custom commands') || selection=$1
    if [ "$selection" = 'listVirtualMachines' ]; then
        virtual_machines=$(ls -R $HOME/vmware | egrep '*.vmx$' | sed -E "s/(.*)/'\1'/; s/ /_/g" | awk 'BEGIN { ORS="\\n" }; {print $1,$2}' | sed 's/ //g')
        machine=$(printf $virtual_machines | dmenu -i -p 'List virtual machines')
        machine=$(echo $machine | sed "s/_/ /g; s/'//g")
        machine_folder=$(echo $machine | sed 's/\.vmx//')
        machine_absolute_path="$vmware_folder/$machine_folder/$machine"
    else
        error_message $selection
    fi
    #build_commands
}

view_commands(){
    build_commands
}

error_message(){
    notify-send "$1 not found" && exit
}

build_commands(){
    selection=$(printf $options | dmenu -i -p 'dmenware')
    if [ "$selection" = "authentication_flags" ]; then
        set_auth_flags
    elif [ "$selection" = 'power_commands' ]; then
        use_power_commands
    elif [ "$selection" = 'snapshot_commands' ]; then
        use_snapshot_commands
    elif [ "$selection" = 'guest_os_commands' ]; then
        use_guest_os_commands
    elif [ "$selection" = 'general_commands' ]; then
        use_general_commands
    elif [ "$selection" = 'custom_commands' ]; then
        use_custom_commands
    elif [ "$selection" = 'view_commands' ]; then
        view_commands
    elif [ "$selection" = 'exit' ]; then
        exit 1
    else
        error_message $selection
    fi
}

build_commands
