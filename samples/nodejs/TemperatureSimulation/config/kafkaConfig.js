module.exports = {
    clientId: 'nodeJS-medium-kafka-example',
    kafka_topic: 'temperatures',
    brokers: ['localhost:9092'],
    connectionTimeout: 3000,
    authenticationTimeout: 1000,
    reauthenticationThreshold: 10000,
};