const { withDangerousMod } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

module.exports = function withFmtFix(config) {
  return withDangerousMod(config, [
    'ios',
    async (config) => {
      const podfilePath = path.join(
        config.modRequest.platformProjectRoot,
        'Podfile'
      );

      let content = fs.readFileSync(podfilePath, 'utf8');

      if (content.includes('FMT_USE_CONSTEVAL')) {
        return config;
      }

      const fmtFix = `
  # Fix fmt for Xcode 26
  installer.pods_project.targets.each do |target|
    if target.name == 'fmt'
      target.build_configurations.each do |cfg|
        cfg.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
        cfg.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        cfg.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'FMT_USE_CONSTEVAL=0'
      end
    end
  end`;

      // Encontra o post_install e insere o código dentro dele
      content = content.replace(
        /(post_install do \|installer\|)([\s\S]*?)(^end)/m,
        (match, open, body, close) => {
          return open + body + '\n' + fmtFix + '\n' + close;
        }
      );

      fs.writeFileSync(podfilePath, content);
      return config;
    },
  ]);
};
