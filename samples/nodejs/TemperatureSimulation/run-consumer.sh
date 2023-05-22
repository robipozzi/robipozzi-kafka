source ../../../setenv.sh
CMD_RUN="node temperatureSimulationConsumer.js"
echo ${cyn}Starting Kafka Consumer with:${end} ${grn}$CMD_RUN${end}
$CMD_RUN