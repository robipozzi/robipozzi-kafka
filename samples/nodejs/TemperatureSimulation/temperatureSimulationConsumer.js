// Reading environemnt variables
const KAFKA_ENVIRONMENT = process.env.KAFKA_ENVIRONMENT || 'local';
console.log("KAFKA ENVIRONMENT VARIABLE = " + KAFKA_ENVIRONMENT);
// Module and configuration
var config = require('./config/appConfig');
// Instantiating Kafka connection for different environments
console.log("Instantiating Kafka connection for the specific environment ...");
var kafka = null;
if (KAFKA_ENVIRONMENT == "local") {
  console.log("Use Kafka on local");
  kafka = require('./config/kafkaLocalConfig');
}
if (KAFKA_ENVIRONMENT == "local-ssl") {
  console.log("Use Kafka on local with SSL enabled");
  kafka = require('./config/kafkaLocalSSLConfig');
}
if (KAFKA_ENVIRONMENT == "openshift") {
  console.log("Use Kafka on OpenShift");
  kafka = require('./config/kafkaOpenShiftConfig');
}
if (KAFKA_ENVIRONMENT == "confluent") {
  console.log("Use Kafka on Confluent");
  kafka = require('./config/kafkaConfluentConfig');
}
console.log("Kafka connection instantiated");
// Creating Kafka Consumer
console.log("Instantiating Kafka Consumer ...");
const consumer = kafka.consumer({ groupId: 'temperatures-group' });
console.log("Kafka Consumer instantiated");
const topic = config.kafka_topic_temperatures;
console.log("Consuming messages from Kafka Topic: " + topic);
// Asynchronously running Kafka Consumer
const run = async () => {
  await consumer.connect()
  await consumer.subscribe({ topic, fromBeginning: true })
  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const prefix = `${topic}[${partition} | ${message.offset}] / ${message.timestamp}`
      console.log(`- ${prefix} - ${message.value}`)
    },
  })
};
// Run
run().catch(e => console.error(`[TemperatureSimulation/consumer] ${e.message}`, e));

// Error management
const errorTypes = ['unhandledRejection', 'uncaughtException'];
const signalTraps = ['SIGTERM', 'SIGINT', 'SIGUSR2'];

errorTypes.map(type => {
  process.on(type, async e => {
    try {
      console.log(`process.on ${type}`)
      console.error(e)
      await consumer.disconnect()
      process.exit(0)
    } catch (_) {
      process.exit(1)
    }
  })
});

signalTraps.map(type => {
  process.once(type, async () => {
    try {
      await consumer.disconnect()
    } finally {
      process.kill(process.pid, type)
    }
  })
});