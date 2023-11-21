const { Kafka } = require('kafkajs');
const fs = require('fs');
const config = {
    clientId: 'nodeJS-kafka-temperature-simulator',
    brokers: ['localhost:9093'],
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
    ssl: {
        rejectUnauthorized: false,
        ca: [fs.readFileSync('<path to CARoot.pem>', 'utf-8')],
        //key: fs.readFileSync('/my/custom/client-key.pem', 'utf-8'),
        //cert: fs.readFileSync('/my/custom/client-cert.pem', 'utf-8')
    }
});

module.exports = kafka;