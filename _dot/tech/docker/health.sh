#!/bin/bash

echo "========================================="
echo "   DOCKER NETWORK TEST - deb.debian.org"
echo "========================================="
echo ""

echo "1. Test IP connectivity (ping 8.8.8.8):"
docker run --rm alpine ping -c 3 8.8.8.8 2>&1 | tail -3

echo ""
echo "2. Test DNS resolution (getent deb.debian.org):"
docker run --rm alpine getent hosts deb.debian.org

echo ""
echo "3. Test DNS with explicit DNS (--dns 8.8.8.8):"
docker run --rm --dns 8.8.8.8 alpine getent hosts deb.debian.org

echo ""
echo "4. Test DNS with host network (--network host):"
docker run --rm --network host alpine getent hosts deb.debian.org

echo ""
echo "5. Test HTTP (wget deb.debian.org):"
docker run --rm alpine wget -O- --timeout=3 http://deb.debian.org 2>&1 | head -3

echo ""
echo "6. Test HTTP with PHP container (curl):"
docker run --rm php:8.2-fpm curl -sI http://deb.debian.org 2>&1 | head -1

echo ""
echo "7. Container resolv.conf:"
docker run --rm alpine cat /etc/resolv.conf

echo ""
echo "8. Host DNS resolution (reference):"
getent hosts deb.debian.org

echo ""
echo "========================================="
echo "   TEST COMPLETE"
echo "========================================="
