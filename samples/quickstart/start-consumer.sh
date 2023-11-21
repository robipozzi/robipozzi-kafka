source ../../setenv.sh


$CMD_RUN





source ../../setenv.sh
# ##### Variable section - START
SCRIPT=start-consumer.sh
PLATFORM_OPTION=$1
BOOTSTRAP_SERVER=
# ##### Variable section - END

# ***** Function section - START
main()
{
    if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
    CMD_RUN="$KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $QUICKSTART_INPUT_TOPIC --from-beginning"
    if [ $PLATFORM_OPTION == "2" ]; then
        CMD_RUN="$KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $QUICKSTART_INPUT_TOPIC --from-beginning --consumer.config $KAFKA_HOME/config/consumer.properties"
    fi
	if [ $PLATFORM_OPTION == "3" ]; then
        CMD_RUN="$KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $QUICKSTART_INPUT_TOPIC --from-beginning--consumer.config $KAFKA_HOME/config/consumer.properties"
    fi
	if [ $PLATFORM_OPTION == "4" ]; then        
        CMD_RUN="$KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic $QUICKSTART_INPUT_TOPIC --from-beginning--consumer.config $KAFKA_HOME/config/consumer.properties"
    fi
    echo ${cyn}Starting Consumer with :${end} ${grn}$CMD_RUN${end}
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