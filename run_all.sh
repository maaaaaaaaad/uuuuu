#!/bin/bash

FLUTTER_BIN="/Users/vector/dev/flutter/bin/flutter"
PROJECT_DIR="/Users/vector/dev/jellomark"
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
echo "Opening two terminal windows..."
echo "==================================="
echo ""

cat > /tmp/run_ios.sh << 'SCRIPT'
#!/bin/bash
cd /Users/vector/dev/jellomark
echo "=== iOS Simulator ==="
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d 2C1F3472-8ED7-4516-B3DC-14DD1481B8B9
SCRIPT
chmod +x /tmp/run_ios.sh

cat > /tmp/run_android.sh << 'SCRIPT'
#!/bin/bash
cd /Users/vector/dev/jellomark
echo "=== Android Emulator ==="
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d emulator-5554
SCRIPT
chmod +x /tmp/run_android.sh

open -a Terminal /tmp/run_ios.sh
sleep 3
open -a Terminal /tmp/run_android.sh

echo "Two terminal windows opened!"
echo ""
echo "Each window supports:"
echo "  r - Hot Reload"
echo "  R - Hot Restart"
echo "  q - Quit"
echo ""
echo "To stop all: ./stop_all.sh"
