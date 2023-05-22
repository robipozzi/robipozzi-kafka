const { Kafka } = require('kafkajs');
const config = require('./config/kafkaConfig');
// Instantiating kafka
const topic = config.kafka_topic
console.log("Instantiating Kafka with:");
console.log("   --> Kafka Brokers: " + config.brokers);
console.log("   --> Client ID: " + config.clientId);
console.log("   --> Kafka Topic: " + topic);
const kafka = new Kafka({
  brokers: config.brokers,
  clientId: config.clientId
});
// Creating Kafka Producer
const producer = kafka.producer();
// Simulating measurement using randomly generated numbers
const getRandomNumber = () => Math.round(Math.random(10) * 50);
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