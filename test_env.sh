#!/bin/sh
echo "=== ENVIRONNEMENT ==="
echo "PATH: $PATH"
echo "HOME: $HOME"
echo "USER: $(whoami)"
echo "PWD: $(pwd)"
echo ""
echo "=== FICHIERS DANS .local/bin ==="
ls -la /home/node/.local/bin/
echo ""
echo "=== TEST DOCKER ==="
/home/node/.local/bin/docker --version
