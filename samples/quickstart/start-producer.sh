source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/kafka-console-producer.sh --topic $QUICKSTART_INPUT_TOPIC --bootstrap-server $LOCALHOST_KAFKA_BOOTSTRAP"
echo ${cyn}Starting Producer with:${end} ${grn}$CMD_RUN${end}
$CMD_RUN
