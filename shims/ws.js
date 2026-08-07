'use strict';
// React Native has native WebSocket support.
// Mutating properties on the native WebSocket constructor can throw
// synchronously under Hermes, so just re-export it as-is.
module.exports = global.WebSocket;
