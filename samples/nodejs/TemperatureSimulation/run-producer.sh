source ../../../setenv.sh
# ##### Variable section - START
SCRIPT=run-producer.sh
PLATFORM_OPTION=$1
KAFKA_PLATFORM=
# ##### Variable section - END

# ***** Function section - START
main()
{
	if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
    CMD_RUN="KAFKA_ENVIRONMENT=local node temperatureSimulationProducer.js"
    echo ${cyn}Starting Kafka Producer with:${end} ${grn}$CMD_RUN${end}
    #$CMD_RUN
    KAFKA_ENVIRONMENT=$KAFKA_PLATFORM node temperatureSimulationProducer.js
}

printSelectPlatform()
{
	echo ${grn}Select Kafka cluster run platform : ${end}
    echo "${grn}1. Localhost${end}"
    echo "${grn}2. Openshift (RHOKS cluster)${end}"
	echo "${grn}3. Confluent${end}"
	read PLATFORM_OPTION
	setKafkaEnvironment
}

setKafkaEnvironment()
{
	case $PLATFORM_OPTION in
		1)  KAFKA_PLATFORM="local"
			;;
        2)  KAFKA_PLATFORM="openshift"
            ;;
		3)  KAFKA_PLATFORM="confluent"
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
    setKafkaEnvironment
fi
# ************** END evaluate args **************"
RUN_FUNCTION=main
$RUN_FUNCTION