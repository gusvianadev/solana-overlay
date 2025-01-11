#!/usr/bin/env bash -xe

VERSIONS=(
    "2.0.21"
)

for VERSION in "${VERSIONS[@]}"; do
    echo "Downloading Cargo.lock@$VERSION"
    mkdir -p cargo/v$VERSION
    curl https://raw.githubusercontent.com/anza-xyz/agave/v$VERSION/Cargo.lock >cargo/v$VERSION/Cargo.lock
done
