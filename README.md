# Kafka
- [Introduction](#introduction)
- [Setup and run Kafka](#setup-and-run-kafka)
    - [Run Kafka cluster on local environment](#run-Kafka-cluster-on-local-environment)
    - [Run Kafka cluster on Confluent](#run-Kafka-cluster-on-confluent)
    - [Run Kafka cluster on Red Hat OpenShift](#run-Kafka-cluster-on-red-hat-openshift)
    - [Create, delete and describe Kafka topics](#create-delete-and-describe-kafka-topics)
- [Nodejs examples](#nodejs-examples)
    - [Temperature simulation](#temperature-simulation)
    - [NPM Slack Notifier](#npm-slack-notifier)
- [Python examples](#python-examples)
    - [Using kafka-python library](#using-kafka-python-library)
    
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

## Nodejs examples
[TODO]

### Temperature simulation
[TODO]

### NPM Slack Notifier
[TODO]

## Python examples
[TODO]

### Using kafka-python library
[TODO]