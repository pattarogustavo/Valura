const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

config.resolver.extraNodeModules = {
  ws:      require.resolve('./shims/ws'),
  stream:  require.resolve('stream-browserify'),
  zlib:    require.resolve('browserify-zlib'),
  path:    require.resolve('path-browserify'),
  crypto:  require.resolve('crypto-browserify'),
  http:    require.resolve('stream-http'),
  https:   require.resolve('https-browserify'),
  os:      require.resolve('os-browserify/browser'),
  url:     require.resolve('url'),
  net:     require.resolve('./shims/empty'),
  tls:     require.resolve('./shims/empty'),
  fs:      require.resolve('./shims/empty'),
  dns:     require.resolve('./shims/empty'),
};

module.exports = config;
