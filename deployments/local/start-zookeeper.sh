source ../../setenv.sh
CMD_RUN="$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties"
echo ${cyn}Starting Zookeeper with:${end} ${grn}$CMD_RUN${end}
$CMD_RUN