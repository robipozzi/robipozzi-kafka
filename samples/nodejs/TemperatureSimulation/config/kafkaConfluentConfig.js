const { Kafka } = require('kafkajs')
const { KAFKA_USERNAME: username, KAFKA_PASSWORD: password } = process.env
const sasl = username && password ? { username, password, mechanism: 'plain' } : null
const ssl = !!sasl
const config = {
    clientId: 'nodeJS-kafka-temperature-simulator',
    brokers: ['confluent:9094'],
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
    ssl,
    sasl
})
module.exports = kafka