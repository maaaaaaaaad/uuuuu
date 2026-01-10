#!/bin/bash

FLUTTER_BIN="/Users/vector/dev/flutter/bin/flutter"
IOS_DEVICE="2C1F3472-8ED7-4516-B3DC-14DD1481B8B9"
ANDROID_DEVICE="emulator-5554"
ANDROID_EMULATOR_NAME="Medium_Phone_API_36.1"

echo "Checking devices..."

if ! xcrun simctl list devices | grep -q "$IOS_DEVICE.*Booted"; then
    echo "Starting iOS Simulator..."
    xcrun simctl boot $IOS_DEVICE 2>/dev/null
    open -a Simulator
    sleep 3
fi

if ! ~/Library/Android/sdk/platform-tools/adb devices | grep -q "emulator-5554"; then
    echo "Starting Android Emulator..."
    $FLUTTER_BIN emulators --launch $ANDROID_EMULATOR_NAME &
    sleep 15
fi

echo ""
echo "==================================="
echo "Starting Flutter on both devices..."
echo "==================================="
echo ""

echo "[iOS] Starting..."
$FLUTTER_BIN run -d $IOS_DEVICE &
IOS_PID=$!

echo "[Android] Starting..."
$FLUTTER_BIN run -d $ANDROID_DEVICE &
ANDROID_PID=$!

echo ""
echo "==================================="
echo "Both apps running!"
echo "==================================="
echo ""
echo "Hot Reload: Press 'r' in terminal"
echo "Hot Restart: Press 'R'"
echo "Quit: Press 'q' or Ctrl+C"
echo ""

wait $IOS_PID $ANDROID_PID
