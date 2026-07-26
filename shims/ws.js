'use strict';
// React Native has native WebSocket support
// This shim replaces the Node.js 'ws' package
const NativeWebSocket = global.WebSocket;

class WebSocketServer {
  constructor() {}
  on() { return this; }
  once() { return this; }
  emit() { return this; }
  close(cb) { if (typeof cb === 'function') cb(); }
  address() { return {}; }
  get clients() { return new Set(); }
}

if (NativeWebSocket) {
  NativeWebSocket.Server = WebSocketServer;
  NativeWebSocket.WebSocket = NativeWebSocket;
  NativeWebSocket.WebSocketServer = WebSocketServer;
  NativeWebSocket.createWebSocketStream = () => null;
  module.exports = NativeWebSocket;
} else {
  module.exports = WebSocketServer;
  module.exports.WebSocket = WebSocketServer;
  module.exports.WebSocketServer = WebSocketServer;
}
