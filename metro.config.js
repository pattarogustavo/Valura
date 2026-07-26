const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

config.resolver.extraNodeModules = {
  stream: require.resolve('stream-browserify'),
  zlib: require.resolve('browserify-zlib'),
  path: require.resolve('path-browserify'),
  crypto: require.resolve('crypto-browserify'),
  http: require.resolve('stream-http'),
  https: require.resolve('https-browserify'),
  os: require.resolve('os-browserify/browser'),
  url: require.resolve('url'),
};

module.exports = config;
