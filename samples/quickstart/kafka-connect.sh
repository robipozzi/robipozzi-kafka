source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/connect-standalone.sh $KAFKA_HOME/config/connect-standalone.properties $KAFKA_HOME/config/connect-file-source.properties $KAFKA_HOME/config/connect-file-sink.properties"
echo ${cyn}Start Kafka connect standalone with :${end} ${grn}$CMD_RUN${end}
$CMD_RUN