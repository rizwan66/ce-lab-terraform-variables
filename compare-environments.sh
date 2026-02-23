#!/bin/bash
echo "=== Development Environment ==="
aws s3api get-bucket-versioning --bucket myapp-677746-dev-bucket
aws s3api get-bucket-tagging --bucket myapp-677746-dev-bucket

echo ""
echo "=== Production Environment ==="
aws s3api get-bucket-versioning --bucket myapp-677746-prod-bucket
aws s3api get-bucket-tagging --bucket myapp-677746-prod-bucket
