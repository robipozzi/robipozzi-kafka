const { Kafka } = require('kafkajs');
const config = require('./config/kafkaConfig');
// Instantiating kafka
const topic = config.kafka_topic;
console.log("Instantiating Kafka with:");
console.log("   --> Kafka Brokers: " + config.brokers);
console.log("   --> Client ID: " + config.clientId);
console.log("   --> Kafka Topic: " + topic);
const kafka = new Kafka({
  brokers: config.brokers,
  clientId: config.clientId
});
// Creating Kafka Consumer
const consumer = kafka.consumer({ groupId: 'temperatures-group' });
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