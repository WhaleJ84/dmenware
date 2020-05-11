#!/usr/bin/env sh

# vmrun [AUTHENTICATION-FLAGS] COMMANDS [PARAMETERS]

vmware_folder=$HOME/vmware
authentication_flags="hostType\\nencryptedVirtualPassword\\nGuestUsername\\nGuestPassword"
power_commands="start\\nstop\\nreset\\nsuspend\\npause\\nunpause"
snapshot_commands="listSnapshots\\nsnapshot\\ndeleteSnapshot\\nrevertToSnapshot"
guest_os_commands="runProgramInGuest\\nfileExistsInGuest\\ndirectoryExistsInGuest\\nsetSharedFolderState\\naddSharedFolder\\nremoveSharedFolder\\nenableSharedFolders\\ndisableSharedFolders\\nlistProcessesInGuest\\nkillProcessInGuest\\nrunScriptInGuest\\ndeleteFileInGuest\\ncreateDirectoryInGuest\\ndeleteDirectoryInGuest\\nCreateTempfileInGuest\\nlistDirectoryInGuest\\nCopyFileFromHostToGuest\\nCopyFileFromGuestToHost\\nrenameFileInGuest\\ntypeKeystrokesInGuest\\nconnectNamedDevice\\ndisconnectNamedDevice\\ncaptureScreen\\nwriteVariable\\nreadVariable\\ngetGuestIPAddress"
general_commands="list\\nupgradevm\\ninstallTools\\ncheckToolsState\\ndeleteVM\\nclone"
custom_commands="listVirtualMachines\\nlistRunningMachines\\nselectMachine\\ngetParameters"
options="authentication_flags\\npower_commands\\nsnapshot_commands\\nguest_os_commands\\ngeneral_commands\\ncustom_commands" # Removed 'view_commands'

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
    [ -z $1 ] && selection=$(printf "$power_commands\\nexit" | dmenu -i -p 'Power commands')
    command=$selection
    if [ "$selection" = 'exit' ]; then
        build_commands

    elif [ "$selection" = 'start' ]; then
        use_custom_commands listVirtualMachines
        use_custom_commands getParameters "gui\\nnogui"
        #parameters="gui\\nnogui"
        #parameter=$(printf $parameters | dmenu -i -p 'Parameters')

    elif [ "$selection" = 'stop' -o "$selection" = 'reset' -o "$selection" = 'suspend' -o "$selection" = 'pause' -o "$selection" = 'unpause' ]; then
        use_custom_commands listRunningMachines

        if [ "$selection" = 'stop' -o "$selection" = 'reset' -o "$selection" = 'suspend' ]; then
            use_custom_commands getParameters "hard\\nsoft"
            #parameters="hard\\nsoft"
            #parameter=$(printf $parameters | dmenu -i -p 'Parameters')
        fi
    else
        error_message $selection
    fi
    [ "$machine" = 'exit' ] && exit 1
    vmrun $command "$vmware_folder/$machine_folder/$machine" $parameter
    notify-send "$(vmrun list)"
    build_commands
}

use_snapshot_commands(){
    [ -z $1 ] && selection=$(printf "$snapshot_commands\\nexit" | dmenu -i -p 'Snapshot commands')
    command=$selection
    if [ "$selection" = 'exit' ]; then
        build_commands

    elif [ "$selection" = 'listSnapshots' -o "$selection" = 'snapshot' -o "$selection" = 'deleteSnapshot' -o "$selection" = 'revertToSnapshot' ]; then
        use_custom_commands listVirtualMachines
        selection=$command
        #notify-send "debug_use_snapshot_commands: $selection $command"

        if [ "$selection" = 'snapshot' -o "$selection" = 'deleteSnapshot' -o "$selection" = 'revertToSnapshot' ]; then
            snapshot_name=$(printf '#' | dmenu -i -p 'Snapshot name')
            #notify-send "debug_use_snapshot_commands: $snapshot_name"
        fi
    else
        error_message $selection
    fi
    build_commands
}

use_guest_os_commands(){
    [ -z $1 ] && selection=$(printf "$guest_os_commands\\nexit" | dmenu -i -p 'Guest OS commands')
    command=$selection
    if [ "$selection" = 'exit' ]; then
        build_commands

    elif [ "$selection" = 'runProgramInGuest' -o "$selection" = 'fileExistsInGuest' -o "$selection" = 'directoryExistsInGuest' -o "$selection" = 'setSharedFolderState' -o "$selection" = 'addSharedFolder' -o "$selection" = 'removeSharedFolder' -o "$selection" = 'enableSharedFolders' -o "$selection" = 'disableSharedFolders' -o "$selection" = 'listProcessesInGuest' -o "$selection" = 'killProcessInGuest' -o "$selection" = 'runScriptInGuest' -o "$selection" = 'deleteFileInGuest' -o "$selection" = 'createDirectoryInGuest' -o "$selection" = 'deleteDirectoryInGuest' -o "$selection" = 'CreateTempfileInGuest' -o "$selection" = 'listDirectoryInGuest' -o "$selection" = 'CopyFileFromHostToGuest' -o "$selection" = 'CopyFileFromGuestToHost' -o "$selection" = 'renameFileInGuest' -o "$selection" = 'typeKeystrokesInGuest' -o "$selection" = 'connectNamedDevice' -o "$selection" = 'disconnectNamedDevice' -o "$selection" = 'captureScreen' -o "$selection" = 'writeVariable' -o "$selection" = 'readVariable' -o "$selection" = 'getGuestIPAddress' ]; then
        use_custom_commands listRunningMachines

        if [ "$selection" = 'runProgramInGuest' ]; then
            build_commands

        elif [ "$selection" = 'fileExistsInGuest' -o "$selection" = 'CopyFileFromHostToGuest' -o "$selection" = 'CopyFileFromGuestToHost' ]; then
            a
            [ "$selection" = 'CopyFileFromHostToGuest' -o "$selection" = 'CopyFileFromGuestToHost' ] && a

        elif [ "$selection" = 'runScriptInGuest' ]; then
            #-noWait -activeWindow -interactive
            parameters=$()
            #interpreter path
            interpreter_path=$()
            #script text
            script_text=$()

        elif [ "$selection" = 'getGuestIPAddress' ]; then
            use_custom_commands get_parameters "-wait"
        fi
    else
        error_message $selection
    fi
    build_commands
}

use_general_commands(){
    [ -z $1 ] && selection=$(printf "$general_commands\\nexit" | dmenu -i -p 'General commands')
    command=$selection
    if [ "$selection" = 'list' ]; then
        running_machines=$(vmrun $command)
        notify-send "$running_machines"

    elif [ "$selection" = 'upgradevm' -o "$selection" = 'installTools' -o "$selection" = 'checkToolsState' -o "$selection" = 'deleteVM' ]; then
        use_custom_commands listVirtualMachines
        vmrun $command "$vmware_folder/$machine_folder/$machine"

    elif [ "$selection" = 'clone' ]; then
        a

    elif [ "$selection" = 'exit' ]; then
        build_commands
    else
        error_message $selection
    fi
    build_commands
}

use_custom_commands(){
    [ -z $1 ] && selection=$(printf "$custom_commands\\nexit" | dmenu -i -p 'Custom commands') || selection=$1
    if [ "$selection" = 'listVirtualMachines' ]; then
        virtual_machines=$(ls -R $HOME/vmware | egrep '*.vmx$' | sed -E "s/(.*)/'\1'/; s/ /_/g" | awk 'BEGIN { ORS="\\n" }; {print $1,$2}' | sed 's/ //g' | rev | sed 's/n\\//' | rev)
        use_custom_commands selectMachine $virtual_machines

    elif [ "$selection" = 'listRunningMachines' ]; then
        running_machines=$(vmrun list | sed '1d' | awk -F/ '{print $NF}' | sed -E "s/(.*)/'\1'/; s/ /_/g" | awk 'BEGIN { ORS="\\n" }; {print $1,$2}' | sed 's/ //g' | rev | sed 's/n\\//' | rev)
        use_custom_commands selectMachine $running_machines

    elif [ "$selection" = 'selectMachine' ]; then
        machine=$(printf "$2\\nexit" | dmenu -i -p 'List virtual machines')
        [ "$machine" = 'exit' ] && selection=$machine
        machine=$(echo $machine | sed "s/_/ /g; s/'//g")
        machine_folder=$(echo $machine | sed 's/\.vmx//')
        machine_absolute_path="$vmware_folder/$machine_folder/$machine"
        #notify-send "debug_select_machine: $machine_absolute_path"

    elif [ "$selection" = 'getParameters' ]; then
        parameters="$2"
        parameter=$(printf $parameters | dmenu -i -p 'Parameters')
        notify-send "debug_get_parameters: $parmeters $parameter"

    elif [ "$selection" = 'exit' ]; then
        build_commands
    else
        error_message $selection
    fi
}

#view_commands(){
#build_commands
#}

error_message(){
    [ -z $1 ] && exit 1 || notify-send "$1 not found" && exit 127
}

build_commands(){
    selection=$(printf "$options\\nexit" | dmenu -i -p 'dmenware')
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
        #elif [ "$selection" = 'view_commands' ]; then
        #view_commands
    elif [ "$selection" = 'exit' ]; then
        exit 1
    else
        error_message $selection
    fi
}

build_commands
