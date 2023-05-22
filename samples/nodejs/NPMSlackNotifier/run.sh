source ../../../setenv.sh
HOOK_SECRET="super-secret-string" KAFKA_BOOTSTRAP_SERVER="localhost:9092" TOPIC="npm-slack-notifier" node server.js