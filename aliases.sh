######################################################################
#
# aliases.sh
#	Defines aliases for using kvmtools as root, as well as some
#	other functions (e.g. kvmssh and quickcreate)
#
# NOTE:
#	Before sourcing this file please set the following ENV
#	variables
#
# Required:
# 
#	KVMTOOLS_DIR
#		Location of kvmtools-perl directory. Most likely the
#		same directory this file is located in.
#
# Optional:
#
#	QUICKCREATE_BASE_IMG
#		The base image from which qc (quickcreate) will make
#		thinclones
#
#	QUICKCREATE_DEST_FOLDER
#		The dest folder for where qc (quickcreate) will store
#		the thinclone
#
#       KVMSSH_USER
#               Determines the user to use when ssh'ing into a VM. If
#               undefined the root user will be used
#
######################################################################

if [ -z $KVMTOOLS_DIR ] 
then 
    echo "please set \$KVMTOOLS_DIR"
    return
fi

alias kvmconsole='sudo ${KVMTOOLS_DIR}/kvmconsole'
alias kvmcreate='sudo ${KVMTOOLS_DIR}/kvmcreate'
alias kvmip='sudo ${KVMTOOLS_DIR}/kvmip'
alias kvmls='sudo ${KVMTOOLS_DIR}/kvmls'
alias kvmrm='sudo ${KVMTOOLS_DIR}/kvmrm -f'

######################################################################
#
# kvmssh <vmname>
#	will ssh into a vm as root, provided the vm has an ip
#
######################################################################
kvmssh() {

    # TODO implement this in perl; and make this a true alias
    
    if [ -z $1 ] 
    then
	echo "Please specify a vmname."
    else
        sshuser='root'
        [ -z $KVMSSH_USER ] || sshuser="$KVMSSH_USER"
        ssh "$sshuser"@`sudo ${KVMTOOLS_DIR}/kvmip $1`
    fi    
}

######################################################################
#
# quickcreate <vmname>  -or-  qc <vmname>
#	Both quickcreate and qc are the same. It creates a thinclone
#	of $QUICKCREATE_BASE_IMG in the $QUICKCREATE_DEST_FOLDER. If
#	these ENV variables are not set, quickcreate and qc will not
#	be defined. (They are optional)
#
######################################################################

if [ -z $QUICKCREATE_BASE_IMG ]
then 
    echo "skipping quickcreate definition: \$QUICKCREATE_BASE_IMG is undefined"
    return
fi

if [ -z $QUICKCREATE_DEST_FOLDER ]
then
    echo "skipping quickcreate definition: \$QUICKCREATE_DEST_FOLDER is undefined"
    return
fi

quickcreate() {

    # TODO implement this in perl; and make this a true alias

    if [ -z $1 ] 
    then
	echo "Please specify a vmname."
    else
	sudo ${KVMTOOLS_DIR}/kvmcreate thinclone ${QUICKCREATE_BASE_IMG} dest "${QUICKCREATE_DEST_FOLDER}/${1}.qcow2" name $1
    fi
}

alias qc='quickcreate'

