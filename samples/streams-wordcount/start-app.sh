source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo"
echo ${cyn}Starting Wordcount application with:${end} ${grn}$CMD_RUN${end}
$CMD_RUN