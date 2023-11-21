# Kafka
- [Introduction](#introduction)
- [Setup and run Kafka](#setup-and-run-kafka)
    - [Run Kafka cluster on local environment](#run-Kafka-cluster-on-local-environment)
        - [Enable security on Kafka cluster in local environment](#Enable-security-on-Kafka-cluster-in-local-environment)
    - [Run Kafka cluster on Confluent](#run-Kafka-cluster-on-confluent)
    - [Run Kafka cluster on Red Hat OpenShift](#run-Kafka-cluster-on-red-hat-openshift)
    - [Create, delete and describe Kafka topics](#create-delete-and-describe-kafka-topics)
    - [Producers and consumers using Kafka command line tools](#producers-and-consumers-using-Kafka-command-line-tools)
- [Nodejs examples](#nodejs-examples)
    - [Temperature simulation](#temperature-simulation)
    - [NPM Slack Notifier](#npm-slack-notifier)
- [Python examples](#python-examples)
    - [Temperature simulation with Python](#temperature-simulation-with-python)
    
## Introduction
This repository contains code and scripts to experiment on Kafka technology. See https://kafka.apache.org/intro for a general introduction to what Kafka is, how it works and which use cases is most suited for.

## Setup and run Kafka
This repository provides several scripts to interact with Kafka clusters, create and delete topics, produce and consume messages.

Start by cloning this repository with the following commands:

```
mkdir $HOME/dev
cd $HOME/dev
git clone https://github.com/robipozzi/robipozzi-kafka
```

Activate a Kafka cluster to interact with; instructions are provided to install Kafka locally or instantiate it on Confluent or Red Hat OpenShift.

### Run Kafka cluster on local environment
Installing Kafka locally for development and test is quite straightforward, please refer to https://kafka.apache.org/quickstart for instructions.

A couple of convenient scripts are provided to start the cluster, do the following in order:

* Open a terminal and run **[start-zookeeper.sh](deployments/local/start-zookeeper.sh)** that runs a local Zookeper (https://zookeeper.apache.org/) cluster.
```
cd $HOME/dev/robipozzi-kafka/deployments/local
./start-zookeeper.sh
```
* Open another terminal and run **[start-kafka.sh](deployments/local/start-kafka.sh)** that runs the actual Kafka cluster.
```
cd $HOME/dev/robipozzi-kafka/deployments/local
./start-kafka.sh
```

You are now ready to play with your local Kafka cluster.

#### Enable security on Kafka cluster in local environment
Apache Kafka allows clients to use SSL for encryption of traffic as well as authentication. 

The steps needed to enable security are schematically reported here below

1. **Generate keystore and certificate signing request for each Kafka broker**
2. **Create your own CA**
3. **Add CA to client truststore**
4. **Sign the certificate with the CA**
5. **Update Kafka server SSL configuration**
6. **Update Kafka clients SSL configuration**

Here following there are step by step instructions on how to set up PKI infrastructure, use it to create certificates and configure Kafka to use these.

1. **Generate keystore and certificate signing request for each Kafka broker**

The first step of deploying one or more brokers with SSL support is to generate a public/private keypair for every server. Since Kafka expects all keys and certificates to be stored in keystores we will use Java's keytool command for this task.

The second step is to obtain a certificate that can be used with the private key that was just created: a certificate signing request needs to be created. This signing request, when signed by a trusted CA results in the actual certificate which can then be installed in the keystore and used for authentication purposes. 

With this we have created a private key pair which can already be used to encrypt traffic and a certificate signing request, which is the basis for creating a certificate. To add authentication capabilities this signing request needs to be signed by a trusted authority (a *Certification Authority*, usually indicated as *CA*), which will be created in the next step.

2. **Create your own CA**

A certificate authority (CA) is responsible for signing certificates. When setting up a production cluster in a corporate environment these certificates would usually be signed by an external trusted CA, in our case we will go the fastest way and be our own Certificate Authority.

To create our own Certificate Authority we are going to use openssl with an appropriate configuration file called **[openssl-ca.cnf](deployments/local/security/openssl-ca.cnf)**.

3. **Add CA to client truststore**

Once CA has been generated, the next step is to add it to the **clients' truststore** so that the clients can trust the CA, and all the certificates that have been signed by that CA.

4. **Sign the certificate with the CA**

Finally, we can sign the certificate with the CA and import both the CA certificate and the signed certificate into the keystore.

A convenient script, **[createSSL.sh](deployments/local/security/createSSL.sh)**, with default values, is provided to choose which one of the tasks above to run, or decide to run all of them at once.

5. **Update Kafka server SSL configuration**

Now that a server certificate has been created and it has been imported in a keystore, we need to configure Kafka server to appropriately use it and enable SSL. Kafka server configuration is done in **server.properties**, which is available in **<KAFKA_INSTALL_DIR>/config** folder (where <KAFKA_INSTALL_DIR> is obviously the directory where Kafka server is installed).

```
[From Kafka official documentation - *Listener Configuration* section: https://kafka.apache.org/documentation/#listener_configuration]

In order to secure a Kafka cluster, it is necessary to secure the channels that are used to communicate with the servers. Each server must define the set of listeners that are used to receive requests from clients as well as other servers. Each listener may be configured to authenticate clients using various mechanisms and to ensure traffic between the server and the client is encrypted. This section provides a primer for the configuration of listeners.

Kafka servers support listening for connections on multiple ports. This is configured through the listeners property in the server configuration, which accepts a comma-separated list of the listeners to enable. At least one listener must be defined on each server. The format of each listener defined in listeners is given below:
```

Set the LISTENER_NAME as following (in this case only one listener has been defined, but several listeners can be added to the configuration if needed):

```
listeners=SECURE://localhost:9093
```

Every listener can have a different security protocol setting, defined in a separate property: **listener.security.protocol.map**. 
The value is a comma-separated list of each listener mapped to its security protocol. 

Set the security protcol for listener **SECURE** to SSL, as follows (such configuration only allows SSL encrypted communication):

```
listener.security.protocol.map=SECURE:SSL
```

Then also set **SECURE** as the listener for inter broker communication, setting **inter.broker.listener.name** property as follows:

```
inter.broker.listener.name=SECURE
```

Finally, the following SSL configuration settings need to be addedd in the same **server.properties** file: 

```
ssl.keystore.location=<path to server keystore>
ssl.keystore.password=<password set when keystore was created>
ssl.key.password=<password set when keystore was created>
ssl.truststore.location=<path to client truststore>
ssl.truststore.password=<password set when truststore was created>
```

6. **Update Kafka clients SSL configuration**

SSL is supported for both Kafka Producers and Consumers. The configuration for SSL will be exactly the same for both producers and consumers, though it is set in **producer.properties** configuration file for Kafka Producers and in **consumer.properties** for Kafka Consumers.

If client authentication is not required in the broker, then the following is a minimal configuration example: 

```
security.protocol=SSL
ssl.truststore.location=<path to client truststore>
ssl.truststore.password=<password set when truststore was created>
```

And here are examples using *kafka-console-producer* and *kafka-console-consumer* utilities:

```
kafka-console-producer.sh --bootstrap-server localhost:9093 --topic test --producer.config $KAFKA_HOME/config/producer.properties
kafka-console-consumer.sh --bootstrap-server localhost:9093 --topic test --consumer.config $KAFKA_HOME/config/consumer.properties
```

### Run Kafka cluster on Confluent
Confluent (https://www.confluent.io/) is a technology company that designs and develops data platform which helps organizations harness business value from stream data. 

It provides the Confluent Cloud platform (https://confluent.cloud/), that allows to create Kafka clusters in a Cloud environment. Once you signup to Confluent Cloud, you will receive $400 credit to use the platform.

![](img/welcome-confluent-cloud.png)

Once you are in the platform you can create a Kafka cluster, choosing the Cloud provider where the cluster will be provisioned.

![](img/confluent-cluster.png)

To use the cluster there is just one final thing to do: create the API Key that the clients shall use to connect securely to the cluster.

![](img/confluent-apikeys.png)

Once everything is setup correctly as above, you can create all the topics needed by the application that shall use the cluster.

![](img/confluent-topics.png)


### Run Kafka cluster on Red Hat OpenShift
[TODO]

### Create, delete and describe Kafka topics
Kafka command line tools (available in /bin subdirectory of any local Kafka installation) allow to interact with Kafka clusters and operate many administrative tasks, like creating, deleting and describing topics.

Currently the code made available in this repo has been developed and tested against 3 different type of Kafka clusters, i.e.: local deployment, OpenShift and Confluent. Each deployment has its own connection and configuration parameters, that are available in the **[deployment](deployment)** subdirectory.

Convenient scripts are provided to:

* Create a topic: open a terminal and run **[create-topic.sh](create-topic.sh)**
```
cd $HOME/dev/robipozzi-kafka
./create-topic.sh
```

The script lets you choose the kind of Kafka cluster deployment you want to use (local, OpenShift or Confluent) and then asks to input the name of the Kafka topic you want to create, as seen in the following figure:

![](img/create-topic.png)

The script uses **kafka-topics.sh** Kafka command line tool with the **--create** argument and the appropriate configuration parameters for the specific Kafka cluster.

* Delete a topic: open a terminal and run **[delete-topic.sh](delete-topic.sh)**
```
cd $HOME/dev/robipozzi-kafka
./delete-topic.sh
```

The script uses **kafka-topics.sh** Kafka command line tool with the **--delete** argument and the appropriate configuration parameters for the specific Kafka cluster.

* Describe topics: open a terminal and run **[describe-topics.sh](describe-topics.sh)**
```
cd $HOME/dev/robipozzi-kafka
./describe-topics.sh
```
The script again uses **kafka-topics.sh** Kafka command line tool with the **--describe** argument and the appropriate configuration parameters for the specific Kafka cluster, to describe the configurations of all topics defined in the cluster.

The three scripts described above allows to choose either plain or SSL enabled connections to Kafka brokers; to enable SSL the following configuration file needs to be created **[config.properties](deployments/local/security/config.properties)**

### Producers and consumers using Kafka command line tools
Kafka is a distributed system consisting of servers and clients that communicate via a high-performance TCP network protocol. Clients allow to write distributed applications that read (consume, in Kafka terminology), write (produce, or publish, in Kafka terminology), and process streams of events in parallel.

Kafka provides command line tools to create and use producers and consumers.

Kafka command line tool **kafka-console-producer.sh** allows to connect to a Kafka cluster and publish messages to a specific topic. A convenient script named **test-producer.sh**, which uses *kafka-console-producer.sh*, is provided to test publishing messages to a selected Kafka topic.
```
cd $HOME/dev/robipozzi-kafka
./test-producer.sh
```

Kafka command line tool **kafka-console-consumer.sh** allows to connect to a Kafka cluster and publish messages to a specific topic. A convenient script named **test-consumer.sh**, which uses *kafka-console-consumer.sh*, is provided to test reading messages from a selected Kafka topic.
```
cd $HOME/dev/robipozzi-kafka
./test-consumer.sh
```

## Nodejs examples
Some application samples are provided to experiment with Kafka Nodejs clients.

* **[Temperature simulation](samples/nodejs/TemperatureSimulation/)** application simulates the behavior of a Temperature sensor, publishing temperature data to *temperatures* topic.

* **[NPM Slack Notifier](samples/nodejs/NPMSlackNotifier/)** application is yet to be implemented.

### Temperature simulation
Temperature simulation application is made of 2 Nodejs programs:

* **[temperatureSimulationProducer.js](samples/nodejs/TemperatureSimulation/temperatureSimulationProducer.js)** is Nodejs program that uses *kafkajs* Nodejs module to connect to a Kafka cluster and publish a message to *temperatures* topic. It is conveniently launched with adequate parameters using **[run-producer.sh](samples/nodejs/TemperatureSimulation/run-producer.sh)**.

* **[temperatureSimulationConsumer.js](samples/nodejs/TemperatureSimulation/temperatureSimulationConsumer.js)** is Nodejs program that uses *kafkajs* Nodejs module to connect to a Kafka cluster and consume messages from *temperatures* topic. It is conveniently launched with adequate parameters using **[run-consumer.sh](samples/nodejs/TemperatureSimulation/run-consumer.sh)**.

For both Producer and Consumer connection and other application parameters are configurable in environment related modules:

* **[kafkaLocalConfig.js](samples/nodejs/TemperatureSimulation/config/kafkaLocalConfig.js)** gathers configuration parameters to connect to a local running Kafka cluster.
* **[kafkaOpenShiftConfig.js](samples/nodejs/TemperatureSimulation/config/kafkaOpenShiftConfig.js)** gathers configuration parameters to connect to a Kafka cluster running on OpenShift.
* **[kafkaConfluentConfig.js](samples/nodejs/TemperatureSimulation/config/kafkaConfluentConfig.js)** gathers configuration parameters to connect to a Kafka cluster running on Confluent.
* **[appConfig.js](samples/nodejs/TemperatureSimulation/config/appConfig.js)** gathers common configuration parameters for the application, in particular the topic name *temperatures*.

### NPM Slack Notifier
[YET TO BE IMPLEMENTED]

## Python examples
Some application samples are provided to experiment with Kafka Python clients.

### Temperature simulation with Python
Temperature simulation application is made of 2 Python programs:

* **[testProducer.py](samples/python/TemperatureSimulation/testProducer.py)** is a Python program that uses *confluent-kafka* Python module to connect to a Kafka cluster and publish a message to *temperatures* topic. It is conveniently launched with adequate parameters using **[testProducer.sh](samples/python/TemperatureSimulation/testProducer.sh)**.

* **[testConsumer.py](samples/python/TemperatureSimulation/testConsumer.py)** is a Python program that uses *confluent-kafka* Python module to connect to a Kafka cluster and consume messages from *temperatures* topic. It is conveniently launched with adequate parameters using **[testConsumer.sh](samples/python/TemperatureSimulation/testConsumer.sh)**.

For both Producer and Consumer connection and other application parameters are configurable in environment related modules:

* **[configuration-local.ini](samples/python/TemperatureSimulation/config/configuration-local.ini)** gathers configuration parameters to connect to a local running Kafka cluster.
* **[configuration-openshift.ini](samples/python/TemperatureSimulation/config/configuration-openshift.ini)** gathers configuration parameters to connect to a Kafka cluster running on OpenShift.
* **[configuration-confluent.ini](samples/python/TemperatureSimulation/config/configuration-confluent.ini)** gathers configuration parameters to connect to a Kafka cluster running on Confluent.