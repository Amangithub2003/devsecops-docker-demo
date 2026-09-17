#!/usr/bin/env bash
# Deploys the app + monitoring/logging stack to the EC2 host via SSH.
# Called from Jenkins as: ./deploy/deploy.sh <host> <ssh_key_path> <image_tag>
set -euo pipefail

HOST="$1"
SSH_KEY="$2"
IMAGE_TAG="$3"
REMOTE_DIR="/home/ubuntu/demo-app"

SSH="ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${HOST}"
SCP="scp -i ${SSH_KEY} -o StrictHostKeyChecking=no"

echo "Copying compose file and configs to ${HOST}..."
${SSH} "mkdir -p ${REMOTE_DIR}/monitoring ${REMOTE_DIR}/logging"
${SCP} docker-compose.yml ubuntu@${HOST}:${REMOTE_DIR}/docker-compose.yml
${SCP} monitoring/*.yml monitoring/*.json ubuntu@${HOST}:${REMOTE_DIR}/monitoring/
${SCP} logging/*.conf logging/*.yml ubuntu@${HOST}:${REMOTE_DIR}/logging/

echo "Setting image tag to ${IMAGE_TAG} and redeploying..."
${SSH} "cd ${REMOTE_DIR} && \
  sed -i 's|image: .*demo-app:.*|image: nexus.example.com:5000/demo-app:${IMAGE_TAG}|' docker-compose.yml && \
  docker compose pull demo-app && \
  docker compose up -d"

echo "Deployed ${IMAGE_TAG} to ${HOST}."
