import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
JUSTFILE = ROOT / 'files/justfiles/custom.just'
SCRIPT = ROOT / 'files/system/usr/libexec/restore-coolercontrol-config'


class JustfilesTests(unittest.TestCase):
    def test_custom_recipes_parse_and_include_restore(self):
        result = subprocess.run(['just', '--justfile', str(JUSTFILE), '--list'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('configure-coolercontrol', result.stdout)
        self.assertIn('update-all', result.stdout)

    def test_module_format_validation_passes(self):
        result = subprocess.run(['just', '--fmt', '--check', '--unstable', '--justfile', str(JUSTFILE)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)


class RestoreTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='coolercontrol-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.config = self.root / 'live'
        self.config.mkdir()
        self.live = self.config / 'config.toml'
        self.live.write_text('name = "original"\n')
        self.source = self.root / 'snapshot.toml'
        self.source.write_text('name = "new"\n')
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        # Substitute only privileged external boundaries; real script performs file I/O.
        self.command('id', '#!/bin/sh\necho 0\n')
        self.command('systemctl', '''#!/bin/sh
if [ "$1" = start ] && [ -f "$TEST_ROOT/fail-start" ]; then
    rm "$TEST_ROOT/fail-start"
    exit 1
fi
exit 0
''')
        self.command('coolercontrold', '''#!/usr/bin/env python3
import os, pathlib, sys, tomllib
if sys.argv[1] == 'check':
    config = pathlib.Path(os.environ['CC_CONFIG_DIR']) / 'config.toml'
    if os.environ.get('REJECT_LIVE') and config.parent == pathlib.Path(os.environ['TEST_ROOT']) / 'live':
        sys.exit('Simulated live configuration validation failure')
    try:
        tomllib.loads(config.read_text())
    except Exception as error:
        sys.exit(str(error))
elif sys.argv[1] == 'backup':
    if os.environ.get('FAIL_BACKUP'):
        sys.exit('Simulated backup failure')
else:
    sys.exit(1)
''')
        self.env = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}',
                        CC_CONFIG_DIR=str(self.config), TEST_ROOT=str(self.root))

    def command(self, name, contents):
        path = self.bin / name
        path.write_text(contents)
        path.chmod(0o755)

    def run_restore(self):
        self.assertTrue(SCRIPT.is_file(), 'Restore helper has not been implemented')
        return subprocess.run(['bash', str(SCRIPT), str(self.source)], env=self.env, capture_output=True, text=True)

    def test_success_replaces_config_and_preserves_original_backup(self):
        result = self.run_restore()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.live.read_text(), 'name = "new"\n')
        backups = list(self.config.glob('config.before-restore.*.toml'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), 'name = "original"\n')

    def test_invalid_snapshot_does_not_change_live_config(self):
        self.source.write_text('invalid = [\n')
        result = self.run_restore()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.live.read_text(), 'name = "original"\n')
        self.assertEqual(list(self.config.glob('config.before-restore.*.toml')), [])

    def test_missing_snapshot_does_not_change_live_config(self):
        self.source.unlink()
        result = self.run_restore()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.live.read_text(), 'name = "original"\n')

    def test_failed_restart_restores_original_config(self):
        (self.root / 'fail-start').touch()
        result = self.run_restore()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.live.read_text(), 'name = "original"\n')
        self.assertIn('restoring', result.stderr.lower())

    def test_failed_live_validation_restores_original_config(self):
        self.env['REJECT_LIVE'] = '1'
        result = self.run_restore()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.live.read_text(), 'name = "original"\n')
        self.assertIn('restoring', result.stderr.lower())

    def test_failed_backup_does_not_replace_config(self):
        self.env['FAIL_BACKUP'] = '1'
        result = self.run_restore()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.live.read_text(), 'name = "original"\n')
        self.assertEqual(list(self.config.glob('config.before-restore.*.toml')), [])


if __name__ == '__main__':
    unittest.main()
