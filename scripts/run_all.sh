#!/bin/bash

FLUTTER_BIN="/Users/vector/dev/flutter/bin/flutter"
PROJECT_DIR="/Users/vector/dev/jellomark/jellomark-mobile"
EMULATOR_BIN=~/Library/Android/sdk/emulator/emulator
ADB_BIN=~/Library/Android/sdk/platform-tools/adb

IOS_LARGE="2C1F3472-8ED7-4516-B3DC-14DD1481B8B9"
ANDROID_SMALL_AVD="Small_Phone"

ENV_FILE="$PROJECT_DIR/.env.dev"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ $ENV_FILE 파일이 없습니다."
    echo "   .env.example을 .env.dev로 복사하고 값을 채워주세요."
    exit 1
fi

source "$ENV_FILE"

DART_DEFINES="--dart-define=ENV=$ENV --dart-define=API_BASE_URL=$API_BASE_URL --dart-define=KAKAO_NATIVE_APP_KEY=$KAKAO_NATIVE_APP_KEY"

echo "==================================="
echo "Starting 2 devices..."
echo "환경: $ENV"
echo "API: $API_BASE_URL"
echo "==================================="
echo ""

echo "[1/2] Booting iPhone 17 Pro..."
xcrun simctl boot $IOS_LARGE 2>/dev/null
open -a Simulator
sleep 3

echo "[2/2] Starting Android Small Phone (port 5556)..."
if ! $ADB_BIN devices | grep -q "emulator-5556"; then
    $EMULATOR_BIN -avd $ANDROID_SMALL_AVD -port 5556 &>/dev/null &
fi

echo ""
echo "Waiting for Android emulator to fully boot..."
while ! $ADB_BIN -s emulator-5556 shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
    sleep 2
done
echo "  - emulator-5556 ready"

sleep 3

echo ""
echo "Connected devices:"
$ADB_BIN devices
echo ""

echo "==================================="
echo "Pre-building Android APK..."
echo "==================================="
cd $PROJECT_DIR
$FLUTTER_BIN build apk --debug $DART_DEFINES
echo "APK build complete!"

echo ""
echo "==================================="
echo "Opening two terminal windows..."
echo "==================================="
echo ""

cat > /tmp/run_ios_large.sh << SCRIPT
#!/bin/bash
cd /Users/vector/dev/jellomark/jellomark-mobile
echo "=== iPhone 17 Pro (Large) ==="
echo "환경: $ENV | API: $API_BASE_URL"
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d 2C1F3472-8ED7-4516-B3DC-14DD1481B8B9 $DART_DEFINES
SCRIPT
chmod +x /tmp/run_ios_large.sh

cat > /tmp/run_android_small.sh << SCRIPT
#!/bin/bash
cd /Users/vector/dev/jellomark/jellomark-mobile
echo "=== Android Small Phone ==="
echo "환경: $ENV | API: $API_BASE_URL"
echo "Hot Reload: r | Hot Restart: R | Quit: q"
echo ""
/Users/vector/dev/flutter/bin/flutter run -d emulator-5556 $DART_DEFINES
SCRIPT
chmod +x /tmp/run_android_small.sh

osascript -e 'tell application "Terminal" to do script "/tmp/run_ios_large.sh"'
sleep 3
osascript -e 'tell application "Terminal" to do script "/tmp/run_android_small.sh"'

echo ""
echo "==================================="
echo "2 terminal windows opened!"
echo "==================================="
echo ""
echo "Devices:"
echo "  - iPhone 17 Pro (Large)"
echo "  - Android Small Phone (emulator-5556)"
echo ""
echo "Each window: r=Hot Reload, R=Restart, q=Quit"
echo "Stop all: ./stop_all.sh"
