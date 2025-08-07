#!/bin/bash

# TrueNAS Directory Setup Script
# Run this script on your TrueNAS server or via SSH

echo "=== TrueNAS Directory Setup for *arr Stack ==="
echo ""

# Base path on TrueNAS
BASE_PATH="/mnt/Pool1/MediaData"

echo "Creating TRASHguides folder structure at: $BASE_PATH"
echo ""

# Create main directories
echo "Creating main directories..."
mkdir -p "$BASE_PATH/media"
mkdir -p "$BASE_PATH/torrents"
mkdir -p "$BASE_PATH/usenet"

# Create media subdirectories
echo "Creating media subdirectories..."
mkdir -p "$BASE_PATH/media/movies"
mkdir -p "$BASE_PATH/media/tv"
mkdir -p "$BASE_PATH/media/music"
mkdir -p "$BASE_PATH/media/books"
mkdir -p "$BASE_PATH/media/audiobooks"

# Create torrent subdirectories
echo "Creating torrent subdirectories..."
mkdir -p "$BASE_PATH/torrents/movies"
mkdir -p "$BASE_PATH/torrents/tv"
mkdir -p "$BASE_PATH/torrents/music"
mkdir -p "$BASE_PATH/torrents/books"
mkdir -p "$BASE_PATH/torrents/audiobooks"
mkdir -p "$BASE_PATH/torrents/incomplete"
mkdir -p "$BASE_PATH/torrents/watch"

# Create usenet subdirectories
echo "Creating usenet subdirectories..."
mkdir -p "$BASE_PATH/usenet/complete"
mkdir -p "$BASE_PATH/usenet/incomplete"
mkdir -p "$BASE_PATH/usenet/intermediate"
mkdir -p "$BASE_PATH/usenet/complete/movies"
mkdir -p "$BASE_PATH/usenet/complete/tv"
mkdir -p "$BASE_PATH/usenet/complete/music"
mkdir -p "$BASE_PATH/usenet/complete/books"
mkdir -p "$BASE_PATH/usenet/complete/audiobooks"

# Set permissions (adjust user:group as needed for your TrueNAS setup)
echo "Setting permissions..."
chown -R 1000:1000 "$BASE_PATH" 2>/dev/null || echo "Note: Could not set ownership to 1000:1000"
chmod -R 775 "$BASE_PATH"

echo ""
echo "✓ Directory structure created successfully!"
echo ""
echo "Directory structure:"
echo "$BASE_PATH/"
echo "├── media/"
echo "│   ├── movies/"
echo "│   ├── tv/"
echo "│   ├── music/"
echo "│   ├── books/"
echo "│   └── audiobooks/"
echo "├── torrents/"
echo "│   ├── movies/"
echo "│   ├── tv/"
echo "│   ├── music/"
echo "│   ├── books/"
echo "│   ├── audiobooks/"
echo "│   ├── incomplete/"
echo "│   └── watch/"
echo "└── usenet/"
echo "    ├── complete/"
echo "    │   ├── movies/"
echo "    │   ├── tv/"
echo "    │   ├── music/"
echo "    │   ├── books/"
echo "    │   └── audiobooks/"
echo "    ├── incomplete/"
echo "    └── intermediate/"
echo ""
echo "Now you can run the setup script on your client machine."
