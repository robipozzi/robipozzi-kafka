source ../../../setenv.sh
HOOK_SECRET="super-secret-string" KAFKA_BOOTSTRAP_SERVER="localhost:9092" TOPIC="npm-slack-notifier" GROUP_ID="npm-slack-notifier-id" node consumer.js
#CMD_RUN="HOOK_SECRET="super-secret-string" KAFKA_BOOTSTRAP_SERVER="localhost:9092" TOPIC="npm-slack-notifier" GROUP_ID="npm-slack-notifier-id" node consumer.js"
#echo ${cyn}Starting Kafka Consumer with:${end} ${grn}$CMD_RUN${end}
#$CMD_RUN