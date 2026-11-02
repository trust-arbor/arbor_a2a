import express from 'express';
import { AgentCard, Message, TaskState } from '@a2a-js/sdk';
import { DefaultRequestHandler, InMemoryTaskStore } from '@a2a-js/sdk/server';
import { jsonRpcHandler, agentCardHandler, UserBuilder } from '@a2a-js/sdk/server/express';
import { randomUUID } from 'node:crypto';

const port = Number(process.argv[2]);
const card = AgentCard.fromJSON({name: 'Official SDK Echo', description: 'Interop fixture', version: '1.0.0',
  supportedInterfaces: [{url: `http://127.0.0.1:${port}/a2a`, protocolBinding: 'JSONRPC', protocolVersion: '1.0'}],
  capabilities: {}, defaultInputModes: ['text/plain'], defaultOutputModes: ['text/plain'],
  skills: [{id: 'echo', name: 'Echo', description: 'Echo messages', tags: ['echo']}]});
const executor = {
  async execute(ctx, bus) {
    const text = ctx.userMessage.parts[0].content.value;
    const task = {id: ctx.taskId, contextId: ctx.contextId,
      status: {state: TaskState.TASK_STATE_COMPLETED},
      history: [ctx.userMessage, Message.fromJSON({messageId: randomUUID(), contextId: ctx.contextId, taskId: ctx.taskId,
        role: 'ROLE_AGENT', parts: [{text: `SDK: ${text}`} ]})]};
    bus.publish({kind: 'task', data: task});
    bus.finished();
  },
  async cancelTask() { throw new Error('Completed tasks cannot be canceled'); }
};
const handler = new DefaultRequestHandler(card, new InMemoryTaskStore(), executor);
const app = express();
app.use('/.well-known/agent-card.json', agentCardHandler({agentCardProvider: handler}));
app.use('/a2a', jsonRpcHandler({requestHandler: handler, userBuilder: UserBuilder.noAuthentication}));
const server = app.listen(port, '127.0.0.1', () => console.log(`A2A_READY ${port}`));
process.on('SIGTERM', () => server.close(() => process.exit(0)));
