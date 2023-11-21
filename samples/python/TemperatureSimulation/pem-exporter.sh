source ../../../setenv.sh
# ##### Variable section - START
SCRIPT=testConsumer.sh
PLATFORM_OPTION=$1
TRUSTSTORE_DIR=
TRUSTSTORE_NAME=
TRUSTSTORE_PASSWORD=
DESTINATION_DIR=
# ##### Variable section - END

# ***** Function section - START
main()
{
	if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
    mkdir -p $DESTINATION_DIR
    exportCACertificate
    #exportKeyAndCertificate
}

exportCACertificate()
{
    echo ${blu}*************************************************************${end}
    echo ${blu}***** Exporting CA root certificate from jks truststore *****${end}
    echo ${blu}*************************************************************${end}
    echo
	echo ${cyn}Generating CARoot.pem with:${end}
    GENERATE_CAROOT="keytool -exportcert -alias $DEFAULT_CA_ALIAS -keystore $TRUSTSTORE_DIR/$TRUSTSTORE_NAME -rfc -file $DESTINATION_DIR/CARoot.pem -storepass $TRUSTSTORE_PASSWORD"
    echo ${grn}$GENERATE_CAROOT${end}
    $GENERATE_CAROOT
}

exportKeyAndCertificate()
{
	echo ${cyn}Generating key.pem with keytool ...${end}
    GENERATE_CERTIFICATE_AND_KEY="keytool -v -importkeystore -srckeystore $keyStore -srcalias $alias -destkeystore $outputFolder/cert_and_key.p12 -deststoretype PKCS12 -storepass $password -srcstorepass $password"
    echo ${grn}$GENERATE_CERTIFICATE_AND_KEY${end}
    $GENERATE_CERTIFICATE_AND_KEY
    echo ${cyn}... and openssl${end}
    GENERATE_KEY="openssl pkcs12 -in $outputFolder/cert_and_key.p12 -nodes -nocerts -out $outputFolder/key.pem -passin pass:$password"
    echo ${grn}$GENERATE_KEY${end}
    $GENERATE_KEY
}

printSelectPlatform()
{
	echo ${grn}Select Kafka platform : ${end}
	echo "${grn}1. Localhost (SSL enabled)${end}"
    echo "${grn}2. Openshift (RHOKS cluster)${end}"
	read PLATFORM_OPTION
	selectKafkaPlatform
}

selectKafkaPlatform()
{
	case $PLATFORM_OPTION in
		1)  TRUSTSTORE_DIR=$HOME/dev/robipozzi-kafka/deployments/local/security/ssl
            TRUSTSTORE_NAME=$DEFAULT_TRUSTSTORE
            TRUSTSTORE_PASSWORD=S5cure@1
            DESTINATION_DIR=tls/local
			;;
        2)  TRUSTSTORE_DIR=$HOME/dev/robipozzi-kafka/deployments/openshift/tls
            TRUSTSTORE_NAME=truststore.jks
            TRUSTSTORE_PASSWORD=password
            DESTINATION_DIR=tls/openshift
			;;
		*) 	printf "\n${red}No valid option selected${end}\n"
			printSelectPlatform
			;;
	esac
}
# ***** Function section - END

# ##############################################
# #################### MAIN ####################
# ##############################################
RUN_FUNCTION=main
$RUN_FUNCTION