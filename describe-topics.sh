source ./setenv.sh
# ##### Variable section - START
SCRIPT=describe-topics.sh
PLATFORM_OPTION=$1
BOOTSTRAP_SERVER=
# ##### Variable section - END

# ***** Function section - START
main()
{
    if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
    CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --describe"
    if [ $PLATFORM_OPTION == "2" ]; then
        CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --describe --command-config ./deployments/local/security/config.properties"
    fi
    if [ $PLATFORM_OPTION == "3" ]; then
        CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --describe --command-config ./deployments/openshift/config.properties"
    fi
    if [ $PLATFORM_OPTION == "4" ]; then
        CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --describe --command-config deployments/confluent/config.properties"
    fi
    echo ${cyn}Describing Kafka Topics with:${end} ${grn}$CMD_RUN${end}
    $CMD_RUN
}

printHelp()
{
	printf "\n${yel}Usage:${end}\n"
  	printf "${cyn}$SCRIPT <PLATFORM_OPTION> <KAFKA_TOPIC>${end}\n"
	printf "${cyn}where:${end}\n"
	printf "${cyn}- <PLATFORM_OPTION> can be one of the following${end}\n"
	printf "${cyn}	1. Localhost${end}\n"
	printf "${cyn}	2. Localhost (SSL enabled)${end}\n"
	printf "${cyn}	3. Openshift${end}\n"
	printf "${cyn}	4. Confluent${end}\n"
	printf "${cyn}- <KAFKA_TOPIC> is a string representing the Kafka topic to be deleted${end}\n"
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