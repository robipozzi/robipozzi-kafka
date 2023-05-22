# Kafka
- [Introduction](#introduction)
- [Setup and run Kafka](#setup-and-run-kafka)
    - [Run Kafka cluster on local environment](#run-Kafka-cluster-on-local-environment)
    - [Run Kafka cluster on Confluent](#run-Kafka-cluster-on-confluent)
    - [Run Kafka cluster on Red Hat OpenShift](#run-Kafka-cluster-on-red-hat-openshift)
    - [Create and delete Kafka topics](#create-and-delete-kafka-topics)
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

Activate a Kafka cluster to interact with; instructions are provided to install Kafka locally or instantiate it on a Red Hat OpenShift cluster.

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
[TODO]

### Run Kafka cluster on Red Hat OpenShift
[TODO]

### Create and delete Kafka topics
[TODO]

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