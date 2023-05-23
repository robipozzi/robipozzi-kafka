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
if (KAFKA_ENVIRONMENT == "openshift") {
  console.log("Use Kafka on OpenShift");
  kafka = require('./config/kafkaOpenShiftConfig');
}
if (KAFKA_ENVIRONMENT == "confluent") {
  console.log("Use Kafka on Confluent");
  kafka = require('./config/kafkaConfluentConfig');
}
console.log("Kafka connection instantiated");
// Creating Kafka Producer
console.log("Instantiating Kafka Producer ...");
const producer = kafka.producer();
console.log("Kafka Producer instantiated");
// Simulating measurement using randomly generated numbers
const getRandomNumber = () => Math.round(Math.random(10) * 50);
const topic = config.kafka_topic_temperatures;
console.log("Publishing message to Kafka Topic: " + topic);
const sendMessage = () => {
  const message = {
    key: `key-${getRandomNumber()}`,
    temperature: getRandomNumber(),
    timestamp: new Date().toISOString()
  }
  return producer
    .send({
      topic,
      messages: [{ value: JSON.stringify(message) }],
    })
    .then(console.log)
    .catch(e => console.error(`[TemperatureSimulation/producer] ${e.message}`, e))
};
// Asynchronously running Kafka Producer
const run = async () => {
  await producer.connect()
  setInterval(sendMessage, 3000)
};
// Run
run().catch(e => console.error(`[example/producer] ${e.message}`, e));

// Error management
const errorTypes = ['unhandledRejection', 'uncaughtException'];
const signalTraps = ['SIGTERM', 'SIGINT', 'SIGUSR2'];

errorTypes.map(type => {
  process.on(type, async () => {
    try {
      console.log(`process.on ${type}`)
      await producer.disconnect()
      process.exit(0)
    } catch (_) {
      process.exit(1)
    }
  })
});

signalTraps.map(type => {
  process.once(type, async () => {
    try {
      await producer.disconnect()
    } finally {
      process.kill(process.pid, type)
    }
  })
});