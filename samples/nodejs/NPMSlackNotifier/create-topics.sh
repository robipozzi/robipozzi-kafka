source ../../../setenv.sh
CREATE_INPUT_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic $NPM_SLACK_TOPIC"
echo ${cyn}Creating Topic:${end} ${grn}$NPM_SLACK_TOPIC${end}
$CREATE_INPUT_TOPIC_CMD_RUN