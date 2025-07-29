#!/bin/bash

set -e

echo "[INFO] Starting deployment on EC2..."

AWS_REGION=${AWS_REGION:-'us-east-1'}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-'533267002821'}
ECR_REPOSITORY=${ECR_REPOSITORY:-'python-app-ecr'}
IMAGE_TAG=${IMAGE_TAG:-'latest'}
CONTAINER_NAME=${CONTAINER_NAME:-'python-app-ecr-api'}
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_NAME="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "[INFO] Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "[INFO] Pulling latest image..."
docker pull "$FULL_IMAGE_NAME"

echo "[INFO] Stopping old container if exists..."
docker stop "$CONTAINER_NAME" || true
docker rm "$CONTAINER_NAME" || true

echo "[INFO] Running new container..."
docker run -d --name "$CONTAINER_NAME" -p 80:80 "$FULL_IMAGE_NAME"

echo "[INFO] Deployment finished successfully."
