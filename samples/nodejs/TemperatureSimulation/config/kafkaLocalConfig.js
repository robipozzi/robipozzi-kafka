const { Kafka } = require('kafkajs');
const config = {
    clientId: 'nodeJS-kafka-temperature-simulator',
    brokers: ['localhost:9092'],
    connectionTimeout: 3000,
    authenticationTimeout: 1000,
    reauthenticationThreshold: 10000
};
console.log("Instantiating Kafka with:");
console.log("   --> Client ID: " + config.clientId);
console.log("   --> Kafka Brokers: " + config.brokers);
// This creates a client instance that is configured to connect to the Kafka broker defined
const kafka = new Kafka({
    clientId: config.clientId,
    brokers: config.brokers,
    connectionTimeout: config.connectionTimeout,
    authenticationTimeout: config.authenticationTimeout,
    reauthenticationThreshold: config.reauthenticationThreshold,
});

module.exports = kafka;