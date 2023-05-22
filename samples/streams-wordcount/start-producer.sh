source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic $STREAMS_PLAINTEXT_INPUT_TOPIC"
echo ${cyn}Starting Producer with:${end} ${grn}$CMD_RUN${end}
$CMD_RUN
