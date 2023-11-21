source ../../setenv.sh
# ##### Variable section - START
SCRIPT=start-producer.sh
PLATFORM_OPTION=$1
BOOTSTRAP_SERVER=
# ##### Variable section - END

# ***** Function section - START
main()
{
    if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
    CMD_RUN="$KAFKA_HOME/bin/kafka-console-producer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $STREAMS_PLAINTEXT_INPUT_TOPIC"
    if [ $PLATFORM_OPTION == "2" ]; then
        CMD_RUN="$KAFKA_HOME/bin/kafka-console-producer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $STREAMS_PLAINTEXT_INPUT_TOPIC --producer.config $KAFKA_HOME/config/producer.properties"
    fi
	if [ $PLATFORM_OPTION == "3" ]; then
        CMD_RUN="$KAFKA_HOME/bin/kafka-console-producer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $STREAMS_PLAINTEXT_INPUT_TOPIC--producer-property security.protocol=SSL --producer-property ssl.truststore.password=password --producer-property ssl.truststore.location=./deployments/openshift/tls/truststore.jks"
    fi
	if [ $PLATFORM_OPTION == "4" ]; then        
		CMD_RUN="$KAFKA_HOME/bin/kafka-console-producer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $STREAMS_PLAINTEXT_INPUT_TOPIC --producer.config deployments/confluent/config.properties"
    fi
    echo ${cyn}Starting Producer with:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
}

printSelectPlatform()
{
	echo ${grn}Select Kafka cluster run platform : ${end}
    echo "${grn}1. Localhost${end}"
	echo "${grn}2. Localhost (SSL enabled)${end}"
    echo "${grn}3. Openshift (RHOKS cluster)${end}"
	echo "${grn}4. Confluent${end}"
	read PLATFORM_OPTION
	setBootstrapServer
}

setBootstrapServer()
{
	case $PLATFORM_OPTION in
		1)  BOOTSTRAP_SERVER=$LOCALHOST_KAFKA_BOOTSTRAP
			;;
		2)  BOOTSTRAP_SERVER=$LOCALHOST_SSL_KAFKA_BOOTSTRAP
			;;
        3)  BOOTSTRAP_SERVER=$OPENSHIFT_KAFKA_BOOTSTRAP
            ;;
		4)  BOOTSTRAP_SERVER=$CONFLUENT_KAFKA_BOOTSTRAP
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
# ************ START evaluate args ************"
if [ "$1" != "" ]; then
    setBootstrapServer
fi
# ************** END evaluate args **************"
RUN_FUNCTION=main
$RUN_FUNCTION