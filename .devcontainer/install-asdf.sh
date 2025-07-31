#!/usr/bin/env bash
set -e

export ASDF_VERSION=v0.18.0

# Download and install asdf binary
rm /tmp/asdf.tar.gz || true

curl -L https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-amd64.tar.gz -o /tmp/asdf.tar.gz
    
mkdir -p /opt/asdf

tar -xzf /tmp/asdf.tar.gz -C /opt/asdf

ln -s -f /opt/asdf/asdf /usr/local/bin/asdf

rm /tmp/asdf.tar.gz
