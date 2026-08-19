const { withDangerousMod, withXcodeProject, IOSConfig } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

// Copies ValuraCrashLogger.mm into ios/<ProjectName>/ during prebuild and
// registers it as a compiled source file in the Xcode project. The file
// installs a std::terminate handler via +load (see ValuraCrashLogger.mm for
// why NSSetUncaughtExceptionHandler alone isn't enough for this crash type).
function withTerminateHandler(config) {
  config = withDangerousMod(config, [
    'ios',
    async (config) => {
      const projectRoot = config.modRequest.projectRoot;
      const sourceRoot = IOSConfig.Paths.getSourceRoot(projectRoot);
      const srcFile = path.join(__dirname, 'ValuraCrashLogger.mm');
      const destFile = path.join(sourceRoot, 'ValuraCrashLogger.mm');
      fs.copyFileSync(srcFile, destFile);
      return config;
    },
  ]);

  config = withXcodeProject(config, (config) => {
    const project = config.modResults;
    const projectName = config.modRequest.projectName;
    const groupKey = project.findPBXGroupKey({ name: projectName });

    // IMPORTANT: the path must include the "<ProjectName>/" prefix (matching
    // how AppDelegate.swift itself is referenced, e.g. path = "Valura/AppDelegate.swift"),
    // because this PBXFileReference resolves relative to the ios/ project root,
    // not relative to the group it's nested under. Passing just the filename
    // here causes Xcode Cloud/EAS Build to look for the file directly in ios/
    // instead of ios/<ProjectName>/, where we actually copied it, producing:
    // "Build input file cannot be found: '.../ios/ValuraCrashLogger.mm'"
    project.addSourceFile(
      `${projectName}/ValuraCrashLogger.mm`,
      {
        target: project.getFirstTarget().uuid,
        lastKnownFileType: 'sourcecode.cpp.objcpp',
      },
      groupKey
    );

    return config;
  });

  return config;
}

module.exports = withTerminateHandler;
