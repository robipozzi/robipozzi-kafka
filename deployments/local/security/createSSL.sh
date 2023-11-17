source ../../../setenv.sh

# ##### Variable section - START
SCRIPT=createSSL.sh
FUNCTION_CHOICE=
FUNCTION=
KEYSTORE=$1
VALIDITY=$2
TRUSTSTORE=$3
# ##### Variable section - END

# ***** Function section - START
main()
{
    mkdir -p $DEFAULT_KEYSTORE_DIR
    $FUNCTION
}

printChooseFunction()
{
	echo ${grn}Choose function : ${end}
    echo "${grn}1. Generate private key and certificate signing request${end}"
    echo "${grn}2. Create own Certification Authority${end}"
	echo "${grn}3. Create client truststore${end}"
    echo "${grn}4. Sign server certificate with CA${end}"
    echo "${grn}5. Generate all SSL configuration${end}"
	read FUNCTION_CHOICE
	setFunctionChoice
}

setFunctionChoice()
{
	case $FUNCTION_CHOICE in
		1)  FUNCTION=createSSLKey
			;;
        2)  FUNCTION=createCA
            ;;
		3)  FUNCTION=createClientTruststore
            ;;
        4)  FUNCTION=signCertificate
            ;;
        5)  FUNCTION=createSSLConfiguration
            ;;
		*) 	printf "\n${red}No valid option selected${end}\n"
			printChooseFunction
			;;
	esac
}

createSSLKey()
{
    echo ${blu}************************************************************${end}
    echo ${blu}***** Generate SSL Key and certificate signing request *****${end}
    echo ${blu}************************************************************${end}
    echo
    echo ${blu}***** Creating a new keystore ... ${end}
    if [ -z $KEYSTORE ]; then 
		inputKeystore
	fi
    if [ -z $VALIDITY ]; then 
		inputValidity
	fi
    # Generate the Keystore
    CMD_RUN="keytool -keystore $DEFAULT_KEYSTORE_DIR/$KEYSTORE -alias $DEFAULT_KEYSTORE_ALIAS -validity $VALIDITY -genkey -keyalg RSA -keysize 2048"
    #################################################################
    ####### TODO START - add hostname info to the certificate #######
    #################################################################
    # If you want to add hostname information to the certificate add "-ext SAN=DNS:{FQDN},IP:{IPADDRESS1}" to the command
    ########################
    ####### TODO END #######
    ########################
    echo ${cyn}Generating SSL keystore using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo 
    echo ${blu}***** Generating a Certificate Signing Request from keystore ...${end}
    ##### Generate a Certificate Signing Request (CSR) from your New Keystore
    CMD_RUN="keytool -certreq -alias $DEFAULT_KEYSTORE_ALIAS -file $DEFAULT_KEYSTORE_DIR/$DEFAULT_CSR -keystore $DEFAULT_KEYSTORE_DIR/$KEYSTORE"
    echo ${cyn}Generating CSR using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo
}

createCA()
{
    echo ${blu}***********************${end}
    echo ${blu}***** Generate CA *****${end}
    echo ${blu}***********************${end}
    echo 
    echo ${blu}***** Generating CA private key and CA Certificate Signing Request ... ${end}
    CMD_RUN="openssl req -new -newkey rsa:2048 -nodes -out $DEFAULT_KEYSTORE_DIR/$DEFAULT_CA_CSR -keyout $DEFAULT_KEYSTORE_DIR/$DEFAULT_CA_PRIVATE_KEY -sha256"
    echo ${cyn}Generating CA private key and CSR using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo 
    echo ${blu}***** Creating CA certificate ... ${end}
    CMD_RUN="openssl x509 -signkey $DEFAULT_KEYSTORE_DIR/$DEFAULT_CA_PRIVATE_KEY -days $DEFAULT_VALIDITY -req -in $DEFAULT_KEYSTORE_DIR/$DEFAULT_CA_CSR -out $DEFAULT_KEYSTORE_DIR/$DEFAULT_CACERT -sha256"
    echo ${cyn}Generating CA certificate using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo
    echo ${blu}***** Deleting CA Certificate Signing Request ... ${end}
    rm -rf $DEFAULT_KEYSTORE_DIR/$DEFAULT_CA_CSR
    echo
}

createClientTruststore()
{
    echo ${blu}**************************************${end}
    echo ${blu}***** Generate client truststore *****${end}
    echo ${blu}**************************************${end}
    echo 
    echo ${blu}***** Creating a new client truststore and import CA certificate ... ${end}
    if [ -z $TRUSTSTORE ]; then 
		inputTruststore
	fi
    CMD_RUN="keytool -keystore $DEFAULT_KEYSTORE_DIR/$TRUSTSTORE -alias CARoot -import -file $DEFAULT_KEYSTORE_DIR/$DEFAULT_CACERT"
    echo ${cyn}Generating client truststore using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo
}

signCertificate()
{
    echo ${blu}***************************************${end}
    echo ${blu}***** Sign the server certificate *****${end}
    echo ${blu}***************************************${end}
    echo 
    # Sign server certificate with CA
    echo ${blu}***** Signing server certificate using CA certificate ... ${end}
    CMD_RUN="openssl x509 -req -days $DEFAULT_VALIDITY -in $DEFAULT_KEYSTORE_DIR/$DEFAULT_CSR -CA $DEFAULT_KEYSTORE_DIR/$DEFAULT_CACERT -CAkey $DEFAULT_KEYSTORE_DIR/$DEFAULT_CA_PRIVATE_KEY -out $DEFAULT_KEYSTORE_DIR/$DEFAULT_SERVER_CERTIFICATE -set_serial 01 -sha256"
    echo ${cyn}Signing certificate with CA using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo 
    # Import CA certificate into keystore
    echo ${blu}***** Importing CA certificate into keystore ... ${end}
    CMD_RUN="keytool -keystore $DEFAULT_KEYSTORE_DIR/$KEYSTORE -alias CARoot -import -file $DEFAULT_KEYSTORE_DIR/$DEFAULT_CACERT"
    echo ${cyn}Importing CA certificate in keystore using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo 
    # Import signed certificate into keystore
    echo ${blu}***** Importing signed server certificate into keystore ... ${end}
    CMD_RUN="keytool -keystore $DEFAULT_KEYSTORE_DIR/$KEYSTORE -alias localhost -import -file $DEFAULT_KEYSTORE_DIR/$DEFAULT_SERVER_CERTIFICATE"
    echo ${cyn}Importing signed certificate into keystore using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo
    echo ${blu}***** Deleting Server Certificate Signing Request ... ${end}
    rm -rf $DEFAULT_KEYSTORE_DIR/$DEFAULT_CSR
    echo
}

createSSLConfiguration()
{
    createSSLKey
    createCA
    createClientTruststore
    signCertificate
}

inputKeystore()
{
    ###### Set keystore name
    if [ "$KEYSTORE" != "" ]; then
        echo Keystore is set to $KEYSTORE
    else
        echo ${grn}Enter keystore - leaving blank will set keystore to ${end}${mag}$DEFAULT_KEYSTORE : ${end}
        read KEYSTORE
        if [ "$KEYSTORE" == "" ]; then
            KEYSTORE=$DEFAULT_KEYSTORE
        fi
    fi
}

inputValidity()
{
    ###### Set validity days
    if [ "$VALIDITY" != "" ]; then
        echo Validity days are set to $VALIDITY
    else
        echo ${grn}Enter keystore validity days - leaving blank will set validaty days to ${end}${mag}$DEFAULT_VALIDITY : ${end}
        read VALIDITY
        if [ "$VALIDITY" == "" ]; then
            VALIDITY=$DEFAULT_VALIDITY
        fi
    fi
}

inputTruststore()
{
    ###### Set truststore name
    if [ "$TRUSTSTORE" != "" ]; then
        echo Truststore is set to $TRUSTSTORE
    else
        echo ${grn}Enter truststore - leaving blank will set truststore to ${end}${mag}$DEFAULT_TRUSTSTORE : ${end}
        read TRUSTSTORE
        if [ "$TRUSTSTORE" == "" ]; then
            TRUSTSTORE=$DEFAULT_TRUSTSTORE
        fi
    fi
}
# ***** Function section - END

# ##############################################
# #################### MAIN ####################
# ##############################################
printChooseFunction
main