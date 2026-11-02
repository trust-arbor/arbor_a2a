import assert from 'node:assert/strict';
import { ClientFactory } from '@a2a-js/sdk/client';
import { Message, SendMessageRequest, StreamResponse } from '@a2a-js/sdk';
const client = await new ClientFactory().createFromUrl(process.argv[2]);
const events = [];
for await (const event of client.sendMessageStream(SendMessageRequest.fromJSON({message: Message.toJSON(Message.fromJSON({messageId:'tck-stream-001-sdk', role:'ROLE_USER',parts:[{text:'stream'}]}))}))) {
  events.push(StreamResponse.toJSON(event));
}
assert.equal(events[0].task.status.state, 'TASK_STATE_WORKING');
assert.equal(events.at(-1).statusUpdate.status.state, 'TASK_STATE_COMPLETED');
assert.equal(events.filter(e => e.artifactUpdate).length, 1);
const direct = [];
for await (const event of client.sendMessageStream(SendMessageRequest.fromJSON({message:{messageId:'tck-stream-002-sdk',role:'ROLE_USER',parts:[{text:'direct'}]}}))) direct.push(StreamResponse.toJSON(event));
assert.equal(direct.length,1);
assert.equal(direct[0].message.role,'ROLE_AGENT');
console.log(JSON.stringify({direction:'sdk-stream-client-to-elixir',assertions:5}));
