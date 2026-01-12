#!/bin/bash

FLUTTER_PATH="/Users/vector/dev/flutter/bin/flutter"
PROJECT_DIR="/Users/vector/dev/jellomark"

ENV_FILE="$PROJECT_DIR/.env.dev"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ $ENV_FILE 파일이 없습니다."
    echo "   .env.example을 .env.dev로 복사하고 값을 채워주세요."
    exit 1
fi

source "$ENV_FILE"

DART_DEFINES="--dart-define=ENV=$ENV --dart-define=API_BASE_URL=$API_BASE_URL --dart-define=KAKAO_NATIVE_APP_KEY=$KAKAO_NATIVE_APP_KEY"

echo "🔍 연결된 실기기 검색 중..."
echo "   환경: $ENV"
echo "   API: $API_BASE_URL"
echo ""

DEVICES_OUTPUT=$($FLUTTER_PATH devices 2>/dev/null)

IOS_LINE=$(echo "$DEVICES_OUTPUT" | grep -E "•.*•.*ios.*• iOS [0-9]" | head -1)
IOS_DEVICE_ID=""
IOS_DEVICE_NAME=""

if [ -n "$IOS_LINE" ]; then
    IOS_DEVICE_ID=$(echo "$IOS_LINE" | awk -F'•' '{print $2}' | xargs)
    IOS_DEVICE_NAME=$(echo "$IOS_LINE" | awk -F'•' '{print $1}' | sed 's/(mobile)//g' | xargs)
    echo "✅ iOS 기기 발견: $IOS_DEVICE_NAME"
    echo "   📱 ID: $IOS_DEVICE_ID"
else
    echo "⚠️  iOS 기기 없음"
fi

ANDROID_LINE=$(echo "$DEVICES_OUTPUT" | grep -E "•.*•.*android.*• Android [0-9]" | head -1)
ANDROID_DEVICE_ID=""
ANDROID_DEVICE_NAME=""

if [ -n "$ANDROID_LINE" ]; then
    ANDROID_DEVICE_ID=$(echo "$ANDROID_LINE" | awk -F'•' '{print $2}' | xargs)
    ANDROID_DEVICE_NAME=$(echo "$ANDROID_LINE" | awk -F'•' '{print $1}' | sed 's/(mobile)//g' | xargs)
    echo "✅ Android 기기 발견: $ANDROID_DEVICE_NAME"
    echo "   📱 ID: $ANDROID_DEVICE_ID"
else
    echo "⚠️  Android 기기 없음"
fi

echo ""

if [ -z "$IOS_DEVICE_ID" ] && [ -z "$ANDROID_DEVICE_ID" ]; then
    echo "❌ 연결된 실기기를 찾을 수 없습니다."
    echo ""
    echo "확인 사항:"
    echo "  iOS:"
    echo "    1. iPhone이 USB로 연결되어 있는지 확인"
    echo "    2. iPhone에서 '이 컴퓨터를 신뢰' 선택"
    echo "    3. 개발자 모드 활성화 (설정 → 개인정보 보호 및 보안 → 개발자 모드)"
    echo ""
    echo "  Android:"
    echo "    1. USB 디버깅 활성화 (설정 → 개발자 옵션 → USB 디버깅)"
    echo "    2. USB 연결 후 '이 컴퓨터 허용' 선택"
    exit 1
fi

echo "🚀 앱 실행 중..."
echo "   종료: Ctrl+C"
echo ""

if [ -n "$IOS_DEVICE_ID" ] && [ -n "$ANDROID_DEVICE_ID" ]; then
    echo "📱 iOS + Android 병렬 실행"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""


    echo "🍎 iOS 빌드 시작..."
    cd "$PROJECT_DIR" && $FLUTTER_PATH run -d "$IOS_DEVICE_ID" $DART_DEFINES &
    IOS_PID=$!


    sleep 3


    echo "🤖 Android 빌드 시작..."
    cd "$PROJECT_DIR" && $FLUTTER_PATH run -d "$ANDROID_DEVICE_ID" $DART_DEFINES &
    ANDROID_PID=$!

    echo ""
    echo "📱 iOS PID: $IOS_PID"
    echo "📱 Android PID: $ANDROID_PID"
    echo ""
    echo "두 프로세스가 실행 중입니다. Ctrl+C로 종료하세요."


    trap "kill $IOS_PID $ANDROID_PID 2>/dev/null; exit" INT TERM


    wait $IOS_PID $ANDROID_PID

elif [ -n "$IOS_DEVICE_ID" ]; then
    echo "📱 iOS 단독 실행"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd "$PROJECT_DIR" && $FLUTTER_PATH run -d "$IOS_DEVICE_ID" $DART_DEFINES

else
    echo "📱 Android 단독 실행"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd "$PROJECT_DIR" && $FLUTTER_PATH run -d "$ANDROID_DEVICE_ID" $DART_DEFINES
fi
