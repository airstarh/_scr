#!/bin/bash

# Clean up
### docker builder prune -a -f
### docker system prune -a -f --volumes

# Build with network debug
docker compose -f docker-compose.yml build --no-cache --progress=plain 2>&1 | tee log.log
