source ../../../setenv.sh
# ##### Variable section - START
SCRIPT=testProducer.sh
PLATFORM_OPTION=$1
KAFKA_TOPIC=$2
KAFKA_PLATFORM=
# ##### Variable section - END

# ***** Function section - START
main()
{
	if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
	if [ -z $KAFKA_TOPIC ]; then 
		inputKafkaTopic
	fi

    KAFKA_ENVIRONMENT=$KAFKA_PLATFORM TOPIC=$KAFKA_TOPIC python3 testProducer.py
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
		1)  KAFKA_PLATFORM="local"
			;;
        2)  KAFKA_PLATFORM="local-ssl"
			;;
        3)  KAFKA_PLATFORM="openshift"
            ;;
        4)  KAFKA_PLATFORM="confluent"
            ;;
		*) 	printf "\n${red}No valid option selected${end}\n"
			printSelectPlatform
			;;
	esac
}

inputKafkaTopic()
{
    ###### Set Kafka Topic
    if [ "$KAFKA_TOPIC" != "" ]; then
        echo Kafka topic is set to $KAFKA_TOPIC
    else
        echo ${grn}Enter Kafka topic - leaving blank will set topic to ${end}${mag}$TEMPERATURES_TOPIC : ${end}
        read KAFKA_TOPIC
        if [ "$KAFKA_TOPIC" == "" ]; then
            KAFKA_TOPIC=$TEMPERATURES_TOPIC
        fi
    fi
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