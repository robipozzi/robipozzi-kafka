const kafka = require('./kafka');
const { IncomingWebhook } = require('@slack/webhook');
const slackIncomingWebhookUrl="https://hooks.slack.com/services/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";
const slack = new IncomingWebhook(slackIncomingWebhookUrl);
const consumer = kafka.consumer({
  groupId: process.env.GROUP_ID
});

const main = async () => {
  await consumer.connect();
  await consumer.subscribe({
    topic: process.env.TOPIC,
    fromBeginning: true
  });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      console.log('Received message', {
        topic,
        partition,
        key: message.key.toString(),
        value: message.value.toString()
      })
      // Remember that we need to deserialize the message value back into a Javascript object
      // by using JSON.parse on the stringified value.
      const { package, version } = JSON.parse(message.value.toString());
      const text = `:package: ${package}@${version} released\n<https://www.npmjs.com/package/${package}/v/${version}|Check it out on NPM>`;
      await slack.send({
        text,
        username: 'Package bot',
      });
    }
  });
};

main().catch(async error => {
  console.error(error);
  try {
    await consumer.disconnect();
  } catch (e) {
    console.error('Failed to gracefully disconnect consumer', e);
  }
  process.exit(1);
});