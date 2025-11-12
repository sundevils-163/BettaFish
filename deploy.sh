#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_REPO="junzhutx/bettafish"
RELEASE_NAME="bettafish"
NAMESPACE="bettafish"
HELM_CHART="helm/bettafish"

# Check if tag parameter is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Image tag is required${NC}"
    echo "Usage: $0 <image-tag>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

IMAGE_TAG="$1"
FULL_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

echo -e "${GREEN}=== BettaFish Build and Deployment Script ===${NC}"
echo -e "Image: ${FULL_IMAGE}"
echo -e "Release: ${RELEASE_NAME}"
echo -e "Namespace: ${NAMESPACE}"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Helm is available
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: Helm is not installed or not in PATH${NC}"
    exit 1
fi

# Check if user is logged in to Docker Hub
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running or you don't have permission${NC}"
    exit 1
fi

# Step 1: Build Docker image
echo -e "${YELLOW}[1/3] Building Docker image: ${FULL_IMAGE}${NC}"
docker build --platform linux/amd64 -t "${FULL_IMAGE}" .

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Docker build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker image built successfully${NC}"
echo ""

# Step 2: Push Docker image
echo -e "${YELLOW}[2/3] Pushing Docker image to docker.io/${IMAGE_REPO}${NC}"
docker push "${FULL_IMAGE}"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Docker push failed${NC}"
    echo -e "${YELLOW}Make sure you are logged in to Docker Hub: docker login${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker image pushed successfully${NC}"
echo ""

# Step 3: Deploy with Helm
echo -e "${YELLOW}[3/3] Deploying to Kubernetes with Helm (namespace: ${NAMESPACE})${NC}"
helm upgrade --install "${RELEASE_NAME}" "${HELM_CHART}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set bettafish.image.tag="${IMAGE_TAG}" \
    --wait \
    --timeout 10m

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Helm deployment failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo -e "Release: ${RELEASE_NAME}"
echo -e "Namespace: ${NAMESPACE}"
echo -e "Image: ${FULL_IMAGE}"
echo ""
echo "To check deployment status:"
echo "  kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=bettafish"
echo ""
echo "To view logs:"
echo "  kubectl logs -f -n ${NAMESPACE} deployment/${RELEASE_NAME}-web"
echo ""

