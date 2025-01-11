#!/usr/bin/env bash -xe

VERSIONS=(
    "0.30.1"
)

for VERSION in "${VERSIONS[@]}"; do
    echo "Downloading Cargo.lock@$VERSION"
    mkdir -p cargo/v$VERSION
    curl https://raw.githubusercontent.com/coral-xyz/anchor/v$VERSION/Cargo.lock >cargo/v$VERSION/Cargo.lock

    PATCH_FILE=./patches/cargo-$VERSION.patch
    if [ -f $PATCH_FILE ]; then
        echo "We have a patch for $VERSION. Patching"
        patch --reject-file=/dev/null --no-backup-if-mismatch -f ./cargo/v$VERSION/Cargo.lock <$PATCH_FILE || {
            echo "Patched."
        }
    fi
done
