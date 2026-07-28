'use strict';

// React Native já tem suporte nativo a WebSocket.
// Este shim substitui o pacote 'ws' do Node.js (usado internamente pelo
// @supabase/realtime-js), mas SEM tentar adicionar propriedades como
// `.Server` ou `.WebSocketServer` na classe WebSocket nativa.
//
// Motivo: em algumas configurações do Hermes / Nova Arquitetura, o objeto
// WebSocket nativo não é extensível — tentar atribuir uma propriedade nova
// nele (`NativeWebSocket.Server = ...`) lança um erro de forma síncrona,
// assim que este módulo é carregado. Como isso acontecia bem cedo (durante
// a criação do cliente Supabase, antes de qualquer tela), o erro escapava
// até virar um crash nativo (C++ Exception / facebook::jsi::JSError).
//
// O cliente Supabase Realtime, rodando dentro do app (não em Node.js),
// só precisa de `new WebSocket(url, protocols)` — nunca usa `.Server`,
// `.WebSocketServer` ou `.createWebSocketStream`. Por isso é seguro só
// exportar a classe nativa sem modificá-la.

module.exports = global.WebSocket;
