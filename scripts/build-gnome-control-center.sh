#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE="gnome-control-center"
VERSION="50.4"
RELEASE="1.fc44.openfen.1"

SOURCE_SHA256="5856c73999bedf45e74f73bac3d61e2b5ec1689f8bcf1943737baeee8204fb11"

WORK="$(mktemp -d -t openfen-gnome-XXXXXXXX)"
RPMTOP="$WORK/rpmbuild"
RESULTS="$WORK/results"
OUTPUT="$REPO/image/rpms"

mkdir -p \
  "$RPMTOP/SOURCES" \
  "$RPMTOP/SPECS" \
  "$RPMTOP/SRPMS" \
  "$RPMTOP/RPMS" \
  "$RPMTOP/BUILD" \
  "$RPMTOP/BUILDROOT" \
  "$RESULTS" \
  "$OUTPUT"

echo "== Downloading GNOME Control Center ${VERSION} =="

ARCHIVE="${PACKAGE}-${VERSION}.tar.xz"

curl -fL --retry 3 \
  "https://download.gnome.org/sources/${PACKAGE}/50/${ARCHIVE}" \
  -o "$RPMTOP/SOURCES/$ARCHIVE"

echo "${SOURCE_SHA256}  $RPMTOP/SOURCES/$ARCHIVE" | sha256sum -c -

echo "== Preparing Openfen packaging =="

cp "$REPO/packaging/gnome-control-center/gnome-control-center.spec" \
   "$RPMTOP/SPECS/"

cp "$REPO/packaging/gnome-control-center/assets/"*.png \
   "$RPMTOP/SOURCES/"

echo "== Building source RPM =="

rpmbuild -bs --nodeps \
  --define "_topdir $RPMTOP" \
  "$RPMTOP/SPECS/gnome-control-center.spec"

SRPM="$RPMTOP/SRPMS/${PACKAGE}-${VERSION}-${RELEASE}.src.rpm"
test -s "$SRPM"

echo "== Building binary RPMs with Mock =="

sudo mock \
  -r fedora-44-x86_64 \
  --resultdir="$RESULTS" \
  --rebuild "$SRPM"

MAIN="${PACKAGE}-${VERSION}-${RELEASE}.x86_64.rpm"
FILESYSTEM="${PACKAGE}-filesystem-${VERSION}-${RELEASE}.noarch.rpm"

test -s "$RESULTS/$MAIN"
test -s "$RESULTS/$FILESYSTEM"

echo "== Publishing development RPMs =="

# Remove previous GNOME Settings RPMs only after a successful build.
find "$OUTPUT" -maxdepth 1 -type f \
  -name 'gnome-control-center-*.rpm' -delete

install -m 0644 "$RESULTS/$MAIN" "$OUTPUT/"
install -m 0644 "$RESULTS/$FILESYSTEM" "$OUTPUT/"

echo "== Openfen GNOME Settings build complete =="
ls -lh "$OUTPUT"/*.rpm
echo "Build workspace: $WORK"
