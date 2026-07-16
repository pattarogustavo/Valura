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

      if (content.includes('FMT_USE_CONSTEVAL')) return config;

      const fmtPatch = `
    installer.pods_project.targets.each do |target|
      if target.name == 'fmt'
        target.build_configurations.each do |cfg|
          cfg.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
          cfg.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
          cfg.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'FMT_USE_CONSTEVAL=0'
        end
      end
    end`;

      // Insere DENTRO do post_install existente, antes do 'end' final
      content = content.replace(
        /post_install do \|installer\|([\s\S]*?)^end/m,
        `post_install do |installer|$1${fmtPatch}\nend`
      );

      fs.writeFileSync(podfilePath, content);
      return config;
    },
  ]);
};
