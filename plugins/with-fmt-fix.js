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

      if (content.includes('# withFmtFix')) {
        return config;
      }

      const MARKER = 'post_install do |installer|';
      const idx = content.indexOf(MARKER);
      if (idx === -1) return config;

      const fix = `
  # withFmtFix - Patch fmt headers for Xcode 26
  fmt_pod_dir = installer.sandbox.pod_dir('fmt')
  if fmt_pod_dir.exist?
    Dir.glob(File.join(fmt_pod_dir.to_s, '**', '*.h')).each do |f|
      c = File.read(f)
      if c.include?('FMT_USE_CONSTEVAL')
        c2 = c.gsub(/^(\\s*#\\s*define\\s+FMT_USE_CONSTEVAL)\\s+1/, '\\\\1 0')
        File.write(f, c2) if c2 != c
      end
    end
  end
`;

      content = content.slice(0, idx + MARKER.length) +
                fix +
                content.slice(idx + MARKER.length);

      fs.writeFileSync(podfilePath, content);
      return config;
    },
  ]);
};
