#!/usr/bin/env bash

set -ev

cd /opt
git clone https://github.com/Hevienz/handlebars-renderer.git
cd handlebars-renderer
cargo install --path .
