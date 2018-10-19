# Strict mode
set -eu

# Tests
apk --version
aws --version
java -version
j2 --version
cat /etc/alpine-release

# Show directory sizes
du -d 2 -h /
