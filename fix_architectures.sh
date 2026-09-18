#!/bin/bash
set -e
echo "Removendo plugins de crash-logger customizados (suspeitos do erro 'No architectures in the binary')..."

cat > app.json << 'FILEEOF'
{
  "expo": {
    "name": "Valura",
    "slug": "valura",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "scheme": "valura",
    "userInterfaceStyle": "light",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#1756F5"
    },
    "ios": {
      "supportsTablet": false,
      "bundleIdentifier": "com.valura.app",
      "buildNumber": "8",
      "infoPlist": {
        "NSFaceIDUsageDescription": "Use Face ID to protect your financial data",
        "ITSAppUsesNonExemptEncryption": false,
        "UIFileSharingEnabled": true,
        "LSSupportsOpeningDocumentsInPlace": true
      }
    },
    "android": {
      "package": "com.valura.app",
      "versionCode": 1,
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#1756F5"
      }
    },
    "plugins": [
      "./plugins/with-fmt-fix",
      "expo-router",
      "expo-apple-authentication",
      [
        "expo-image-picker",
        {
          "photosPermission": "Allow Valura to access your photos to update your profile picture."
        }
      ]
    ],
    "extra": {
      "eas": {
        "projectId": "aa162697-4275-422d-87a0-9bd4228a903b"
      }
    }
  }
}
FILEEOF

echo "Testando prebuild local antes de gastar um build de verdade..."
rm -rf ios
npx expo prebuild --platform ios --no-install

if grep -q "ValuraCrashLogger" ios/*.xcodeproj/project.pbxproj 2>/dev/null; then
  echo "AVISO: ValuraCrashLogger ainda aparece no projeto, revisar"
else
  echo "OK: nenhuma cirurgia manual no pbxproj presente"
fi
rm -rf ios

echo "Fazendo commit..."
git add -A
git commit -m "Remove custom crash-logger plugins (raw pbxproj surgery) - likely cause of 'No architectures in binary' error"
git push

echo ""
echo "Pronto! Gera o build de novo:"
echo "  eas build --platform ios --profile production --auto-submit"
