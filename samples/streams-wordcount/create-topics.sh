source ../../setenv.sh
CREATE_INPUT_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic $STREAMS_PLAINTEXT_INPUT_TOPIC"
echo ${cyn}Creating Input Topic:${end} ${grn}$STREAMS_PLAINTEXT_INPUT_TOPIC${end}
$CREATE_INPUT_TOPIC_CMD_RUN
echo 
CREATE_OUTPUT_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic $STREAMS_WORDCOUNT_OUTPUT_TOPIC --config cleanup.policy=compact"
echo ${cyn}Creating Output Topic:${end} ${grn}$STREAMS_WORDCOUNT_OUTPUT_TOPIC${end}
$CREATE_OUTPUT_TOPIC_CMD_RUN