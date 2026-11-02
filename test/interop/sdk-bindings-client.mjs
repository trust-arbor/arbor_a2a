import assert from 'node:assert/strict';
import { ClientFactory, RestTransportFactory } from '@a2a-js/sdk/client';
import { GrpcTransportFactory } from '@a2a-js/sdk/client/grpc';
import { AgentCard, GetTaskRequest, Message, SendMessageRequest, StreamResponse, TaskState } from '@a2a-js/sdk';
const base=process.argv[2];
const card=AgentCard.fromJSON(await (await fetch(base+'/.well-known/agent-card.json')).json());
let assertions=0;
for(const binding of ['HTTP+JSON','GRPC']) {
  // grpc-js expects an authority, whereas A2A advertises an absolute URL.
  // This explicit host adapter does not modify the SDK or upstream TCK tests.
  const factory=binding==='HTTP+JSON' ? new RestTransportFactory() : new GrpcTransportFactory();
  const wrapper={protocolName:binding, create:(url,card)=>factory.create(binding==='GRPC'?new URL(url).host:url,card)};
  const client=await new ClientFactory({transports:[wrapper],preferredTransports:[binding]}).createFromAgentCard(card);
  const message=Message.fromJSON({messageId:'tck-complete-task-'+binding,role:'ROLE_USER',parts:[{text:'hello'}]});
  const task=await client.sendMessage(SendMessageRequest.fromJSON({message:Message.toJSON(message)}));
  assert.equal(task.status.state,TaskState.TASK_STATE_COMPLETED);assertions++;
  const fetched=await client.getTask(GetTaskRequest.fromJSON({id:task.id,historyLength:0}));
  assert.equal(fetched.id,task.id);assertions++;
  await assert.rejects(()=>client.getTask(GetTaskRequest.fromJSON({id:'missing'})));assertions++;
  const events=[];
  for await(const event of client.sendMessageStream(SendMessageRequest.fromJSON({message:{messageId:'tck-stream-001-'+binding,role:'ROLE_USER',parts:[{text:'stream'}]}})))events.push(StreamResponse.toJSON(event));
  assert.ok(events[0].task);assertions++;
  assert.equal(events.at(-1).statusUpdate.status.state,'TASK_STATE_COMPLETED');assertions++;
}
console.log(JSON.stringify({direction:'sdk-bindings-to-elixir',assertions}));
process.exit(0);
