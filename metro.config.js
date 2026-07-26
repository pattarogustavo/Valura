const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

// Intercepta ws ANTES da resolução normal (extraNodeModules não funciona para pacotes instalados)
const originalResolveRequest = config.resolver.resolveRequest;
config.resolver.resolveRequest = (context, moduleName, platform) => {
  if (moduleName === 'ws' || moduleName.startsWith('ws/')) {
    return {
      filePath: path.resolve(__dirname, './shims/ws.js'),
      type: 'sourceFile',
    };
  }
  if (originalResolveRequest) {
    return originalResolveRequest(context, moduleName, platform);
  }
  return context.resolveRequest(context, moduleName, platform);
};

// Polyfills para módulos built-in do Node.js (estes SIM funcionam com extraNodeModules)
config.resolver.extraNodeModules = {
  stream:  require.resolve('stream-browserify'),
  zlib:    require.resolve('browserify-zlib'),
  path:    require.resolve('path-browserify'),
  crypto:  require.resolve('crypto-browserify'),
  http:    require.resolve('stream-http'),
  https:   require.resolve('https-browserify'),
  os:      require.resolve('os-browserify/browser'),
  url:     require.resolve('url'),
  util:    require.resolve('util'),
  events:  require.resolve('events'),
  net:     require.resolve('./shims/empty'),
  tls:     require.resolve('./shims/empty'),
  fs:      require.resolve('./shims/empty'),
  dns:     require.resolve('./shims/empty'),
  assert:  require.resolve('./shims/empty'),
};

module.exports = config;
