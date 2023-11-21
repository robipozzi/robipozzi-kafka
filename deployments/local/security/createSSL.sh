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
    mkdir -p $DEFAULT_SSL_DIR
    $FUNCTION
}

printChooseFunction()
{
	echo ${grn}Choose function : ${end}
    echo "${grn}1. Generate server keystore and certificate signing request${end}"
    echo "${grn}2. Create our own Certification Authority${end}"
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
    echo ${blu}*****************************************************************${end}
    echo ${blu}***** Generate SSL keystore and Certificate Signing Request *****${end}
    echo ${blu}*****************************************************************${end}
    echo

    ##############################################################################################################################
    # The first step of deploying one or more brokers with SSL support is to generate a public/private keypair for every server. #
    # Since Kafka expects all keys and certificates to be stored in keystores we will use Java's keytool command for this task.  #
    ##############################################################################################################################
    echo ${blu}***** Creating a new keystore ...${end}
    if [ -z $KEYSTORE ]; then 
		inputKeystore
	fi
    if [ -z $VALIDITY ]; then 
		inputValidity
	fi
    CMD_RUN="keytool -keystore $DEFAULT_SSL_DIR/$KEYSTORE -alias $DEFAULT_KEYSTORE_ALIAS -validity $VALIDITY -genkey -keyalg RSA -storetype pkcs12 -ext SAN=DNS:localhost,IP:127.0.0.1"
    echo ${cyn}Creating keystore using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo

    ##########################################################################################################################################
    # To obtain a certificate that can be used with the private key that was just created a certificate signing request needs to be created. #
    # This signing request, when signed by a trusted CA results in the actual certificate which can then be installed in the keystore and    #
    # used for authentication purposes.                                                                                                      #
    ##########################################################################################################################################
    echo ${blu}***** Generating a Certificate Signing Request from keystore ...${end}
    CMD_RUN="keytool -certreq -alias $DEFAULT_KEYSTORE_ALIAS -file $DEFAULT_SSL_DIR/$DEFAULT_CSR -keystore $DEFAULT_SSL_DIR/$KEYSTORE"
    echo ${cyn}Generating CSR using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo
}

createCA()
{
    echo ${blu}****************************************************${end}
    echo ${blu}***** Generate our own Certification Authority *****${end}
    echo ${blu}****************************************************${end}
    echo 

    ###########################################################################################################################################
    # A certificate authority (CA) is responsible for signing certificates. In this case we will be our own Certificate Authority.            #
    # Due to a bug in OpenSSL, the x509 module will not copy requested extension fields from CSRs into the final certificate.                 #
    # Since we want the SAN extension to be present in our certificate to enable hostname verification, we'll use the ca module instead.      #
    # This requires some additional configuration to be in place before we generate our CA keypair, which are defined in openssl-ca.cnf file. #
    #                                                                                                                                         #
    # With these steps done we can now generate our own CA that will be used to sign certificates later.                                      #
    # The CA is simply a public/private key pair and certificate that is signed by itself, and is only intended to sign other certificates.   #
    ###########################################################################################################################################
    echo ${blu}***** Creating CA private key and CA certificate ... ${end}
    CMD_RUN="openssl req -x509 -config openssl-ca.cnf -newkey rsa:4096 -sha256 -nodes -out $DEFAULT_SSL_DIR/$DEFAULT_CACERT -outform PEM"
    echo ${cyn}Generating CA certificate using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo
}

createClientTruststore()
{
    echo ${blu}**************************************${end}
    echo ${blu}***** Generate client truststore *****${end}
    echo ${blu}**************************************${end}
    echo 

    ###########################################################################################################################
    # The next step is to add the generated CA to the **clients' truststore** so that the clients can trust this CA.          #
    # In contrast to the keystore in step 1 that stores each machine's own identity, the truststore of a client stores        #
    # all the certificates that the client should trust.                                                                      #
    #                                                                                                                         #
    # Importing a certificate into one's truststore also means trusting all certificates that are signed by that certificate. #
    # This attribute is called the chain of trust, and it is particularly useful when deploying SSL on a large Kafka cluster. #
    ###########################################################################################################################
    echo ${blu}***** Creating a new client truststore and import CA certificate ... ${end}
    if [ -z $TRUSTSTORE ]; then 
		inputTruststore
	fi
    CMD_RUN="keytool -keystore $DEFAULT_SSL_DIR/$TRUSTSTORE -alias $DEFAULT_CA_ALIAS -import -file $DEFAULT_SSL_DIR/$DEFAULT_CACERT"
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

    ##############################################################################################################################
    # Create a database and serial number file, these will be used to keep track of which certificates were signed with this CA. #
    # Both of these are simply text files that reside in the same directory as your CA keys.                                     #
    ##############################################################################################################################
    echo 01 > $DEFAULT_SSL_DIR/serial.txt
    touch $DEFAULT_SSL_DIR/index.txt 

    ############################################################################################
    # Create a server certificate signing the Certificate Signing Request using CA certificate #
    ############################################################################################
    echo ${blu}***** Signing server certificate using CA certificate ... ${end}
    CMD_RUN="openssl ca -config openssl-ca.cnf -policy signing_policy -extensions signing_req -out $DEFAULT_SSL_DIR/$DEFAULT_SERVER_CERTIFICATE -infiles $DEFAULT_SSL_DIR/$DEFAULT_CSR"
    echo ${cyn}Signing certificate with CA using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo 

    #######################################
    # Import CA certificate into keystore #
    #######################################
    echo ${blu}***** Importing CA certificate into keystore ... ${end}
    CMD_RUN="keytool -keystore $DEFAULT_SSL_DIR/$DEFAULT_KEYSTORE -alias $DEFAULT_CA_ALIAS -import -file $DEFAULT_SSL_DIR/$DEFAULT_CACERT"
    echo ${cyn}Importing CA certificate in keystore using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo 
    
    ######################################################
    # Import the signed server certificate into keystore #
    ######################################################
    echo ${blu}***** Importing signed server certificate into keystore ... ${end}
    CMD_RUN="keytool -keystore $DEFAULT_SSL_DIR/$DEFAULT_KEYSTORE -alias localhost -import -file $DEFAULT_SSL_DIR/$DEFAULT_SERVER_CERTIFICATE"
    echo ${cyn}Importing signed certificate into keystore using following command:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
    echo

    echo ${blu}***** Deleting Server Certificate Signing Request ... ${end}
    rm -rf $DEFAULT_SSL_DIR/$DEFAULT_CSR
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