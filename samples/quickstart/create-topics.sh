source ../../setenv.sh
CREATE_INPUT_TOPIC_CMD_RUN="$KAFKA_HOME/bin/kafka-topics.sh --create --topic $QUICKSTART_INPUT_TOPIC --bootstrap-server $LOCALHOST_KAFKA_BOOTSTRAP"
echo ${cyn}Creating Input Topic:${end} ${grn}$QUICKSTART_INPUT_TOPIC${end}
$CREATE_INPUT_TOPIC_CMD_RUN