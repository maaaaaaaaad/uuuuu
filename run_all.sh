#!/bin/bash
# Run Flutter app on 4 devices (2 iOS + 2 Android)
# Opens four terminal windows - all support hot reload!

FLUTTER_BIN="/Users/vector/dev/flutter/bin/flutter"
PROJECT_DIR="/Users/vector/dev/jellomark"

# iOS Devices
IOS_LARGE="2C1F3472-8ED7-4516-B3DC-14DD1481B8B9"   # iPhone 17 Pro
IOS_SMALL="2D2BFEDB-478A-4A1C-BAF7-53BF1C97E2FB"   # iPhone 16e

# Android Devices
ANDROID_MEDIUM="emulator-5554"                      # Medium Phone API 36
ANDROID_SMALL="emulator-5556"                       # Small Phone API 36
ANDROID_MEDIUM_NAME="Medium_Phone_API_36.1"
ANDROID_SMALL_NAME="Small_Phone"

echo "==================================="
echo "Starting 4 devices..."
echo "==================================="
echo ""

# Start iOS Simulators
echo "[1/4] Booting iPhone 17 Pro..."
xcrun simctl boot $IOS_LARGE 2>/dev/null
echo "[2/4] Booting iPhone 16e..."
xcrun simctl boot $IOS_SMALL 2>/dev/null
open -a Simulator
sleep 3

# Start Android Emulators
echo "[3/4] Starting Medium Phone..."
if ! ~/Library/Android/sdk/platform-tools/adb devices | grep -q "emulator-5554"; then
    $FLUTTER_BIN emulators --launch $ANDROID_MEDIUM_NAME &
    sleep 10
fi

echo "[4/4] Starting Small Phone..."
if ! ~/Library/Android/sdk/platform-tools/adb devices | grep -q "emulator-5556"; then
    $FLUTTER_BIN emulators --launch $ANDROID_SMALL_NAME &
    sleep 10
fi

echo ""
echo "Waiting for all devices to be ready..."
sleep 5

echo ""
echo "==================================="
echo "Opening four terminal windows..."
echo "==================================="
echo ""

# Create temporary scripts for each device
cat > /tmp/run_ios_large.sh << 'SCRIPT'
#!/bin/bash
cd /Users/vector/dev/jellomark
echo "=== iPhone 17 Pro (Large) ==="
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d 2C1F3472-8ED7-4516-B3DC-14DD1481B8B9
SCRIPT
chmod +x /tmp/run_ios_large.sh

cat > /tmp/run_ios_small.sh << 'SCRIPT'
#!/bin/bash
cd /Users/vector/dev/jellomark
echo "=== iPhone 16e (Small) ==="
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d 2D2BFEDB-478A-4A1C-BAF7-53BF1C97E2FB
SCRIPT
chmod +x /tmp/run_ios_small.sh

cat > /tmp/run_android_medium.sh << 'SCRIPT'
#!/bin/bash
cd /Users/vector/dev/jellomark
echo "=== Android Medium Phone ==="
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d emulator-5554
SCRIPT
chmod +x /tmp/run_android_medium.sh

cat > /tmp/run_android_small.sh << 'SCRIPT'
#!/bin/bash
cd /Users/vector/dev/jellomark
echo "=== Android Small Phone ==="
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d emulator-5556
SCRIPT
chmod +x /tmp/run_android_small.sh

# Open terminal windows
open -a Terminal /tmp/run_ios_large.sh
sleep 2
open -a Terminal /tmp/run_ios_small.sh
sleep 2
open -a Terminal /tmp/run_android_medium.sh
sleep 2
open -a Terminal /tmp/run_android_small.sh

echo ""
echo "==================================="
echo "4 terminal windows opened!"
echo "==================================="
echo ""
echo "Devices:"
echo "  - iPhone 17 Pro (Large)"
echo "  - iPhone 16e (Small)"
echo "  - Android Medium Phone"
echo "  - Android Small Phone"
echo ""
echo "Each window: r=Hot Reload, R=Restart, q=Quit"
echo "Stop all: ./stop_all.sh"
