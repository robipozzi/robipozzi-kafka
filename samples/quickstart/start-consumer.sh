source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/kafka-console-consumer.sh --topic $QUICKSTART_INPUT_TOPIC --from-beginning --bootstrap-server $LOCALHOST_KAFKA_BOOTSTRAP"
echo ${cyn}Starting Consumer with :${end} ${grn}$CMD_RUN${end}
$CMD_RUN