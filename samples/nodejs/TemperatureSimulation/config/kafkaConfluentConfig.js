const { Kafka } = require('kafkajs')
const config = {
    clientId: 'nodeJS-kafka-temperature-simulator',
    brokers: ['pkc-38xx2.eu-south-1.aws.confluent.cloud:9092'],
    ssl: true,
    sasl_mechanism: 'plain',
    apiKey: 'T6J6UNEYSG2JC3K3',
    apiSecret: 'Fadnog2bkWOiNg8UF4s1qncOCohFwlYt1MG6DsDs4P5w775ohU+08FbmNNNorX36',
    connectionTimeout: 3000,
    authenticationTimeout: 1000,
    reauthenticationThreshold: 10000
};
console.log("Instantiating Kafka with:");
console.log("   --> Client ID: " + config.clientId);
console.log("   --> Kafka Brokers: " + config.brokers);
console.log("   --> SSL: " + config.ssl);
console.log("   --> SASL Mechanism: " + config.sasl_mechanism);
console.log("   --> API Key: " + config.apiKey);
// This creates a client instance that is configured to connect to the Kafka broker defined
const kafka = new Kafka({
    clientId: config.clientId,
    brokers: config.brokers,
    ssl: config.ssl,
    sasl: {
        mechanism: config.sasl_mechanism, // scram-sha-256 or scram-sha-512
        username: config.apiKey,
        password: config.apiSecret
      },
})
module.exports = kafka