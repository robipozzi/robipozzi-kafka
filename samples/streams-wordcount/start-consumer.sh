source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic $STREAMS_WORDCOUNT_OUTPUT_TOPIC --from-beginning --formatter kafka.tools.DefaultMessageFormatter --property print.key=true --property print.value=true --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer"
echo ${cyn}Starting Consumer with :${end} ${grn}$CMD_RUN${end}
$CMD_RUN