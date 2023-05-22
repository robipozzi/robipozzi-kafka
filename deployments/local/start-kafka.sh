source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties"
echo ${cyn}Starting Kafka Server with:${end} ${grn}$CMD_RUN${end}
$CMD_RUN