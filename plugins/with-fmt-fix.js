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
  end
`;

      // Insere antes do último 'end' do ficheiro
      // que é sempre o fecho do bloco post_install
      const lastEndIndex = content.lastIndexOf('\nend');
      if (lastEndIndex !== -1) {
        content = content.slice(0, lastEndIndex) + '\n' + fmtFix + content.slice(lastEndIndex);
      }

      fs.writeFileSync(podfilePath, content);
      return config;
    },
  ]);
};
