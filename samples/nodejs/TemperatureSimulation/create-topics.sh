source ../../../setenv.sh
CREATE_INPUT_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic $TEMPERATURES_TOPIC"
echo ${cyn}Creating Topic:${end} ${grn}$TEMPERATURES_TOPIC${end}
$CREATE_INPUT_TOPIC_CMD_RUN