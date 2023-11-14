source ../../../setenv.sh

# ##### Variable section - START
SCRIPT=generateSSLKey.sh
KEYSTORE=$1
VALIDITY=$2
# ##### Variable section - END

# ***** Function section - START
main()
{
	if [ -z $KEYSTORE ]; then 
		inputKeystore
	fi

    if [ -z $VALIDITY ]; then 
		inputValidity
	fi

    mkdir $DEFAULT_KEYSTORE_DIR

    CMD_RUN="keytool -keystore $DEFAULT_KEYSTORE_DIR/$KEYSTORE -alias localhost -validity $VALIDITY -genkey -keyalg RSA -storetype pkcs12"
    echo ${cyn}Generating SSL key with:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
}

inputKeystore()
{
    ###### Set Keystore name
    if [ "$KEYSTORE" != "" ]; then
        echo Keystore is set to $KEYSTORE
    else
        echo ${grn}Enter Keystore - leaving blank will set topic to ${end}${mag}$DEFAULT_KEYSTORE : ${end}
        read KEYSTORE
        if [ "$KEYSTORE" == "" ]; then
            KEYSTORE=$DEFAULT_KEYSTORE
        fi
    fi
}

inputValidity()
{
    ###### Set Validity
    if [ "$VALIDITY" != "" ]; then
        echo Validity is set to $VALIDITY
    else
        echo ${grn}Enter Validity - leaving blank will set topic to ${end}${mag}$DEFAULT_VALIDITY : ${end}
        read VALIDITY
        if [ "$VALIDITY" == "" ]; then
            VALIDITY=$DEFAULT_VALIDITY
        fi
    fi
}
# ***** Function section - END

# ##############################################
# #################### MAIN ####################
# ##############################################
RUN_FUNCTION=main
$RUN_FUNCTION