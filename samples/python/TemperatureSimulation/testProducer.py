from confluent_kafka import Producer, KafkaError, KafkaException
from colorama import init, Fore, Back, Style
from configparser import ConfigParser
import os
import sys
import json
import time
import random

# ***** Initializes Colorama
init(autoreset=True)

# ***** Declare variables
kafkaEnv = None
configurationFile = None
kafkaBrokers = None
producer = None
topic = None

# ***** Get environment variables
kafkaEnv = os.getenv('KAFKA_ENVIRONMENT')
topic = os.getenv('TOPIC')

# *****************************
# ***** Functions - START *****
# *****************************
def simulate_sensor():
    temperature = random.randint(20, 28)
    humidity = random.randint(0, 100)
    return humidity, temperature

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
    elif (kafkaEnv == "local-ssl") :
        configurationFile = "config/configuration-local-ssl.ini"
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

    # ***** Initialize Kafka producer
    if (kafkaEnv == "local") :
        print(Style.BRIGHT + 'Connecting to Kafka Broker ' + kafkaBrokers + ' without SSL')
        producer = Producer({
            'bootstrap.servers': kafkaBrokers,
            'error_cb': error_cb,
        })
    elif (kafkaEnv == "local-ssl") :
        print(Style.BRIGHT + 'Connecting to Kafka Broker ' + kafkaBrokers + ' with SSL')
        caRootLocation = kafkaConfig["caRootLocation"]
        password = kafkaConfig["password"]
        producer = Producer({
            'bootstrap.servers': kafkaBrokers,
            'security.protocol': 'SSL',
            'ssl.ca.location': caRootLocation,
            #'ssl.certificate.location': certLocation,
            #'ssl.key.location':keyLocation,
            'ssl.key.password' : password,
            'error_cb': error_cb,
        })
    elif (kafkaEnv == "openshift") :
        print(Style.BRIGHT + 'Connecting to Kafka Broker ' + kafkaBrokers + ' with SSL')
        error_cb("NO OPENSHIFT CONNECTION IS CONFIGURED")
        #producer = KafkaProducer(bootstrap_servers=kafkaBrokers, value_serializer=lambda v: json.dumps(v).encode('utf-8'),
        #                        security_protocol='SSL',
        #                        ssl_check_hostname=False,
        #                        ssl_cafile=caRootLocation,
        #                        ssl_password=password)
    elif (kafkaEnv == "confluent") :
        sasl = kafkaConfig["sasl"]
        apiKey = kafkaConfig["apiKey"]
        apiSecret = kafkaConfig["apiSecret"]
        print(Style.BRIGHT + 'Connecting to Kafka Broker ' + kafkaBrokers + ' with SASL = ' + sasl)
        producer = Producer({
            'bootstrap.servers': kafkaBrokers,
            'sasl.mechanism': sasl,
            'security.protocol': 'SASL_SSL',
            'sasl.username': apiKey,
            'sasl.password': apiSecret,
            'error_cb': error_cb,
        })
    
    # ***** Write messages to Kafka topic
    print(Style.BRIGHT + 'Writing message to topic : ' + Fore.GREEN + topic)
    try:
        while True:
            print(Style.BRIGHT + 'Simulate sensor reading')
            humidity, temperature = simulate_sensor();
            print('Temp={0:0.1f}*C  Humidity={1:0.1f}%'.format(temperature, humidity))
            message = {'temperature': temperature,'humidity':humidity}
            # Convert data to JSON string
            jsonMessage = json.dumps(message)
            producer.produce(topic, key="sensor-data", value=jsonMessage)
            producer.flush()
            time.sleep(5)
    except KafkaException as e:
        print(f"Failed to send message to Kafka: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        producer.close()