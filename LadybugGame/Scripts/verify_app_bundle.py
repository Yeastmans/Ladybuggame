"""Verify the built product, not just project settings. Accept an .app or IPA."""
import json
import plistlib
import sys
import zipfile
from pathlib import Path

artifact = Path(sys.argv[1])
if artifact.suffix == '.ipa':
    archive = zipfile.ZipFile(artifact)
    prefix = next(n.rsplit('/', 1)[0] + '/' for n in archive.namelist() if n.endswith('.app/Info.plist'))
    names = [n[len(prefix):] for n in archive.namelist() if n.startswith(prefix)]
    read = lambda name: archive.read(prefix + name)
else:
    names = [p.relative_to(artifact).as_posix() for p in artifact.rglob('*')]
    read = lambda name: (artifact / name).read_bytes()

info = plistlib.loads(read('Info.plist'))
for required in ['Assets.car', 'PrivacyInfo.xcprivacy']:
    assert required in names, f'Missing required resource: {required}'
assert any('LaunchScreen.storyboardc/' in name for name in names), 'Missing compiled launch storyboard'
assert info.get('UIDeviceFamily') == [1], 'Expected iPhone-only product'
assert info.get('CFBundleDisplayName') == 'Ladybug Run', 'Unexpected display name'
icons = info.get('CFBundleIcons', {}).get('CFBundlePrimaryIcon', {})
assert icons.get('CFBundleIconName') == 'AppIcon', 'Missing primary app icon metadata'
assert icons.get('CFBundleIconFiles'), 'Missing generated iPhone icon files'
privacy = plistlib.loads(read('PrivacyInfo.xcprivacy'))
assert privacy.get('NSPrivacyTracking') is False, 'Unexpected tracking declaration'
assert int(info['DTPlatformVersion'].split('.')[0]) >= 26, 'Build SDK is older than iOS 26'
print(json.dumps({key: info.get(key) for key in ['CFBundleIdentifier','CFBundleShortVersionString',
    'CFBundleVersion','UIDeviceFamily','MinimumOSVersion','DTSDKName']}, indent=2))
print('PASS: launch screen, compiled assets, icon metadata, privacy manifest and iPhone configuration')
