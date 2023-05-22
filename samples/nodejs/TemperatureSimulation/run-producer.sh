source ../../../setenv.sh
CMD_RUN="node temperatureSimulationProducer.js"
echo ${cyn}Starting Kafka Producer with:${end} ${grn}$CMD_RUN${end}
$CMD_RUN