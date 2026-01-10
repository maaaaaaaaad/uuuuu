#!/bin/bash

FLUTTER_BIN="/Users/vector/dev/flutter/bin/flutter"
PROJECT_DIR="/Users/vector/dev/jellomark"
EMULATOR_BIN=~/Library/Android/sdk/emulator/emulator
ADB_BIN=~/Library/Android/sdk/platform-tools/adb

IOS_LARGE="2C1F3472-8ED7-4516-B3DC-14DD1481B8B9"
IOS_SMALL="2D2BFEDB-478A-4A1C-BAF7-53BF1C97E2FB"

ANDROID_MEDIUM_AVD="Medium_Phone_API_36.1"
ANDROID_SMALL_AVD="Small_Phone"

echo "==================================="
echo "Starting 4 devices..."
echo "==================================="
echo ""

echo "[1/4] Booting iPhone 17 Pro..."
xcrun simctl boot $IOS_LARGE 2>/dev/null
echo "[2/4] Booting iPhone 16e..."
xcrun simctl boot $IOS_SMALL 2>/dev/null
open -a Simulator
sleep 3

echo "[3/4] Starting Medium Phone (port 5554)..."
if ! $ADB_BIN devices | grep -q "emulator-5554"; then
    $EMULATOR_BIN -avd $ANDROID_MEDIUM_AVD -port 5554 &>/dev/null &
    sleep 10
fi

echo "[4/4] Starting Small Phone (port 5556)..."
if ! $ADB_BIN devices | grep -q "emulator-5556"; then
    $EMULATOR_BIN -avd $ANDROID_SMALL_AVD -port 5556 &>/dev/null &
    sleep 10
fi

echo ""
echo "Waiting for all devices to be ready..."
sleep 5

echo ""
echo "Connected devices:"
$ADB_BIN devices
echo ""

echo "==================================="
echo "Opening four terminal windows..."
echo "==================================="
echo ""

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
echo "  - Android Medium Phone (emulator-5554)"
echo "  - Android Small Phone (emulator-5556)"
echo ""
echo "Each window: r=Hot Reload, R=Restart, q=Quit"
echo "Stop all: ./stop_all.sh"
