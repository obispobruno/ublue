# BlueBuild Template &nbsp; [![build-ublue](https://github.com/blue-build/template/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/template/actions/workflows/build.yml)

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for quick setup instructions for setting up your own repository based on this template.

After setup, it is recommended you update this README to describe your custom image.

## Installation

> **Warning**  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/obispobruno/ublue-sway-custom:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/obispobruno/ublue-sway-custom:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## Custom commands

The `justfiles` module installs recipes from `files/justfiles/custom.just`.
This Fedora-based image uses `blujust` rather than Universal Blue's `ujust`.
Run `blujust --list` to see the commands after deploying the rebuilt image.

To make plain `just` available from your home directory, set the import in
`~/.justfile` to `/usr/share/bluebuild/justfile` after that file exists.

`blujust configure-coolercontrol` restores
`~/.config/coolercontrol/config.toml` to the daemon configuration directory.
It validates the snapshot, stops the daemon, backs up the current settings,
and restarts the daemon. A failed installation rolls back the original config.
The snapshot must already exist; refreshing it from `/etc/coolercontrol/config.toml`
and tracking it with chezmoi is a separate, manual operation.
Keep these snapshots machine-specific because their device IDs and fan mappings
depend on the hardware. Do not include daemon credentials or TLS private keys.

The legacy `install-opentabletdriver` recipe still depends on
`/usr/lib/ujust/ujust.sh`; the `justfiles` module does not provide that helper.

Validate local changes with the unittest suite under `tests/` and BlueBuild's
recipe validation before building the image.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/blue-build/template
```
