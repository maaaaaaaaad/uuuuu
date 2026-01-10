#!/bin/bash

FLUTTER_PATH="/Users/vector/dev/flutter/bin/flutter"

echo "🔍 연결된 iOS 실기기 검색 중..."

DEVICES_OUTPUT=$($FLUTTER_PATH devices 2>/dev/null)

DEVICE_LINE=$(echo "$DEVICES_OUTPUT" | grep -E "•.*•.*ios.*• iOS [0-9]" | head -1)

if [ -z "$DEVICE_LINE" ]; then
    echo "❌ 연결된 iOS 실기기를 찾을 수 없습니다."
    echo ""
    echo "확인 사항:"
    echo "  1. iPhone이 USB로 연결되어 있는지 확인"
    echo "  2. iPhone에서 '이 컴퓨터를 신뢰' 선택"
    echo "  3. 개발자 모드 활성화 (설정 → 개인정보 보호 및 보안 → 개발자 모드)"
    exit 1
fi

DEVICE_ID=$(echo "$DEVICE_LINE" | awk -F'•' '{print $2}' | xargs)
DEVICE_NAME=$(echo "$DEVICE_LINE" | awk -F'•' '{print $1}' | sed 's/(mobile)//g' | xargs)

echo "✅ 기기 발견: $DEVICE_NAME"
echo "📱 기기 ID: $DEVICE_ID"
echo ""
echo "🚀 앱 실행 중..."
echo "   핫 리로드: r"
echo "   핫 리스타트: R"
echo "   종료: q"
echo ""

$FLUTTER_PATH run -d "$DEVICE_ID"
