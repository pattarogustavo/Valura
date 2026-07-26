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
  # Fix fmt consteval for Xcode 26
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |cfg|
      flags = cfg.build_settings['OTHER_CPLUSPLUSFLAGS'] || '$(inherited)'
      unless flags.include?('FMT_USE_CONSTEVAL')
        cfg.build_settings['OTHER_CPLUSPLUSFLAGS'] = flags.to_s + ' -DFMT_USE_CONSTEVAL=0'
      end
      cfg.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
    end
  end
`;

      // Insere imediatamente após a linha de abertura do post_install
      content = content.replace(
        /(post_install do \|installer\|)/,
        '$1\n' + fmtFix
      );

      fs.writeFileSync(podfilePath, content);
      return config;
    },
  ]);
};
