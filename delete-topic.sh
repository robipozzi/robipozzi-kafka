source ./setenv.sh
# ##### Variable section - START
SCRIPT=delete-topic.sh
DESCRIBE_TOPICS_SCRIPT=describe-topics.sh
PLATFORM_OPTION=$1
KAFKA_TOPIC=$2
BOOTSTRAP_SERVER=
TOPIC=
# ##### Variable section - END

# ***** Function section - START
########################
## Delete Kafka Topic ##
########################
main()
{
	if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
	if [ -z $KAFKA_TOPIC ]; then 
		#printHelp
		inputKafkaTopic
	fi
	DELETE_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --delete --topic $KAFKA_TOPIC"	
    if [ $PLATFORM_OPTION == "2" ]; then
		DELETE_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --delete --topic $KAFKA_TOPIC --command-config ./deployments/local/security/config.properties"
    fi
	if [ $PLATFORM_OPTION == "3" ]; then
		DELETE_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --delete --topic $KAFKA_TOPIC --command-config ./deployments/openshift/config.properties"
    fi
	if [ $PLATFORM_OPTION == "4" ]; then
		DELETE_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --delete --topic $KAFKA_TOPIC --command-config deployments/confluent/config.properties"
    fi
	echo ${cyn}Deleting Topic:${end} ${grn}$KAFKA_TOPIC${end}
	$DELETE_TOPIC_CMD_RUN
	source $DESCRIBE_TOPICS_SCRIPT $PLATFORM_OPTION
}

###############
## printHelp ##
###############
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

inputKafkaTopic()
{
	echo ${grn}Input Kafka Topic : ${end}
	read TOPIC
	setKafkaTopic
}

setKafkaTopic()
{  
	if [ -z $TOPIC ]; then
		echo ${red}No Kafka topic${end}
		inputKafkaTopic
	fi
	KAFKA_TOPIC=$TOPIC
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