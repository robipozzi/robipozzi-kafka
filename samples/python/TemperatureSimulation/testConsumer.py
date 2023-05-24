from confluent_kafka import Consumer, KafkaError, KafkaException
from colorama import init, Fore, Back, Style
from configparser import ConfigParser
import os
import sys

# ***** Initializes Colorama
init(autoreset=True)

# ***** Declare variables
kafkaEnv = None
configurationFile = None
kafkaBrokers = None
consumer = None
topic = None
caRootLocation='tls/CARoot.pem'
password='password'

# ***** Get environment variables
kafkaEnv = os.getenv('KAFKA_ENVIRONMENT')
topic = os.getenv('TOPIC')

# ***** Declare functions
def error_cb(err):
    """ The error callback is used for generic client errors. These
        errors are generally to be considered informational as the client will
        automatically try to recover from all errors, and no extra action
        is typically required by the application.
        For this example however, we terminate the application if the client
        is unable to connect to any broker (_ALL_BROKERS_DOWN) and on
        authentication errors (_AUTHENTICATION). """

    print("Client error: {}".format(err))
    if err.code() == KafkaError._ALL_BROKERS_DOWN or err.code() == KafkaError._AUTHENTICATION:
        # Any exception raised from this callback will be re-raised from the
        # triggering flush() or poll() call.
        raise KafkaException(err)
    
# ***** Program execution
if __name__ == '__main__':

    print(Style.BRIGHT + 'KAFKA_ENVIRONMENT environment variable = ' + kafkaEnv)
    # Initialize configuration from configuration file
    if (kafkaEnv == None) :
        print(Style.BRIGHT + 'No KAFKA_ENVIRONMENT environment variable set, exiting ... ')
        sys.exit();
    if (kafkaEnv == "local") :
        configurationFile = "config/configuration-local.ini"
    elif (kafkaEnv == "openshift") :
        configurationFile = "config/configuration-openshift.ini"
    elif (kafkaEnv == "confluent") :
        configurationFile = "config/configuration-confluent.ini"
    
    # Read configuration-<environment>.ini file for the specific Kafka environment
    configuration = ConfigParser()
    configuration.read(configurationFile)

    # Read Kafka Broker from configuration file
    kafkaConfig = configuration["KAFKACONFIG"]
    kafkaBrokers = kafkaConfig["brokers"]

    # ***** Initialize Kafka consumer
    if (kafkaEnv == "local") :
        print(Style.BRIGHT + 'Connecting to Kafka Broker ' + kafkaBrokers + ' without SSL')        
        consumer = Consumer({
            'bootstrap.servers': kafkaBrokers,
            'group.id': "temperatures",
            'enable.auto.commit': False,
            'auto.offset.reset': 'earliest',
            'error_cb': error_cb})
    elif (kafkaEnv == "openshift") :
        print(Style.BRIGHT + 'Connecting to Kafka Broker ' + kafkaBrokers + ' with SSL')
        error_cb("NO OPENSHIFT CONNECTION IS CONFIGURED")
        #consumer = KafkaConsumer(topic, bootstrap_servers=kafkaBrokers, value_deserializer=lambda m: json.loads(m.decode('ascii')),
        #                        security_protocol='SSL',
        #                        ssl_check_hostname=False,
        #                        ssl_cafile=caRootLocation,
        #                        ssl_password=password,
        #                        auto_offset_reset='earliest')
    elif (kafkaEnv == "confluent") :
        sasl = kafkaConfig["sasl"]
        apiKey = kafkaConfig["apiKey"]
        apiSecret = kafkaConfig["apiSecret"]
        print(Style.BRIGHT + 'Connecting to Kafka Broker ' + kafkaBrokers + ' with SASL = ' + sasl)
        consumer = Consumer({
            'bootstrap.servers': kafkaBrokers,
            'group.id': "temperatures",
            'sasl.mechanism': sasl,
            'security.protocol': 'SASL_SSL',
            'sasl.username': apiKey,
            'sasl.password': apiSecret,
            'enable.auto.commit': False,
            'auto.offset.reset': 'earliest',
            'error_cb': error_cb
        })
    
    # ***** Read messages from Kafka topic
    print(Style.BRIGHT + 'Reading messages from topic : ' + Fore.GREEN + topic)
    consumer.subscribe([topic])
    try:
        while True:
            msg = consumer.poll(0.1)  # Wait for message or event/error
            if msg is None:
                # No message available within timeout.
                # Initial message consumption may take up to `session.timeout.ms` for
                # the group to rebalance and start consuming.
                continue
            if msg.error():
                # Errors are typically temporary, print error and continue.
                print('Consumer error: {}'.format(msg.error()))
                continue

            print('Consumed: {}'.format(msg.value()))

    except KeyboardInterrupt:
        pass

    finally:
        # Leave group and commit final offsets
        consumer.close()