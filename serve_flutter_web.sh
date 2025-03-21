#!/bin/bash

# Run Flutter web app in debug mode with explicit web-server device
echo "Starting Flutter web app on port 5000..."
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=5000