#!/usr/bin/env bash

echo "Post install";

set -ex
yarn global add gulp bower

echo "alias sf='php bin/console'" >> /root/.bashrc && source /root/.bashrc