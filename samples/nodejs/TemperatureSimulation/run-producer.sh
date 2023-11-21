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
	
	KAFKA_ENVIRONMENT=$KAFKA_PLATFORM node temperatureSimulationProducer.js
}

printSelectPlatform()
{
	echo ${grn}Select Kafka cluster run platform : ${end}
    echo "${grn}1. Localhost${end}"
	echo "${grn}2. Localhost (SSL enabled)${end}"
    echo "${grn}3. Openshift (RHOKS cluster)${end}"
	echo "${grn}4. Confluent${end}"
	read PLATFORM_OPTION
	setKafkaEnvironment
}

setKafkaEnvironment()
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
# ***** Function section - END

# ##############################################
# #################### MAIN ####################
# ##############################################
RUN_FUNCTION=main
$RUN_FUNCTION