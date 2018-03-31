import EventEmitter from 'wolfy87-eventemitter';

const emitter = new EventEmitter();

emitter.BATCH_UPDATED = 'batchUpdated';
emitter.triggerNewBatch = function() {
  emitter.emitEvent(emitter.BATCH_UPDATED);
}

export default emitter;