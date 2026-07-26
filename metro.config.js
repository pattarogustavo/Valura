const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

const WS_SHIM = path.resolve(__dirname, 'shims', 'ws.js');

config.resolver.resolveRequest = (context, moduleName, platform) => {
  if (
    moduleName === 'ws' ||
    moduleName.startsWith('ws/lib/') ||
    moduleName.startsWith('ws/lib')
  ) {
    return { filePath: WS_SHIM, type: 'sourceFile' };
  }
  return context.resolveRequest(context, moduleName, platform);
};

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
};

module.exports = config;
