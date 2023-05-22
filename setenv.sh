##### Terminal Colors - START
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'
coffee=$'\xE2\x98\x95'
coffee3="${coffee} ${coffee} ${coffee}"
##### Terminal Colors - END

###### Variable section - START
KAFKA_HOME=/Users/robertopozzi/software/kafka_2.13-3.4.0
## Kafka Bootstrap Servers
LOCALHOST_KAFKA_BOOTSTRAP=localhost:9092
OPENSHIFT_KAFKA_BOOTSTRAP=robipozzi-kafka-kafka-tls-bootstrap-openshift-operators.robipozzi-rhocp-420022-3c76f4d12b7fe02f9cab56e64bec3e29-0000.eu-de.containers.appdomain.cloud:443
CONFLUENT_KAFKA_BOOTSTRAP=pkc-38xx2.eu-south-1.aws.confluent.cloud:9092
## Topics for Kafka Quickstart Events
QUICKSTART_INPUT_TOPIC=quickstart-events
QUICKSTART_CONNECT_TOPIC=connect-test
## Topics for Streams Wordcont application
STREAMS_PLAINTEXT_INPUT_TOPIC=streams-plaintext-input
STREAMS_WORDCOUNT_OUTPUT_TOPIC=streams-wordcount-output
## Topics for Node.js based example application
NODEJS_TOPIC=nodejs-example
## Topics for Node.js based simulated temperature application
TEMPERATURES_TOPIC=temperatures
## Topics for Node.js based NPM Slack Notifier application
NPM_SLACK_TOPIC=npm-slack-notifier
###### Variable section - END