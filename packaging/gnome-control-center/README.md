# Openfen GNOME Settings Packaging

Openfen maintains a customised build of GNOME Control Center.

## Current base

- GNOME Control Center: 50.4
- Fedora source package: 50.4-1.fc44
- Openfen package release: 1.fc44.openfen.1
- Target: Fedora 44 x86_64

## Changes

GNOME Settings uses Openfen distributor logos in light and dark modes,
configured through GNOME's supported Meson build options.

The original Fedora RPM specification and changelog are retained.

## Build

Requirements: rpm-build, mock, curl, and Fedora 44 Mock configuration.

From the repository root:

    ./scripts/build-gnome-control-center.sh

The script verifies the upstream source archive checksum, builds the
source RPM, compiles the binary packages in Mock, and copies the resulting
RPMs into image/rpms/.

Compiled RPMs are ignored by Git. Run the packaging script before building
the Openfen bootc container from a fresh checkout.

## Maintenance

Whenever Fedora updates GNOME Control Center, review the new source
RPM and its dependencies, reapply the Openfen branding configuration,
update the source checksum, and rebuild and test both RPM subpackages.

Development RPMs are currently unsigned. Production distribution will
require a defined package-signing and update policy.
