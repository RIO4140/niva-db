#!/bin/sh
# تشغيل اختبارات NivaDB: كل برنامج اختبار .نيفا يعمل في الوضعين
# (المترجم الافتراضي والمفسر التشخيصي)، والناجح هو الذي يطبع «ناجح».
# لا إطار اختبار في لغة Niva بعد (انظر docs/تقييم-القدرات.md) — فالسكربت يحكم.
# (أسماء متغيرات الشل لاتينية — معرّفات داخلية لا تظهر للمستخدم؛ وكل النصوص عربية.)
set -u

if command -v نيفا >/dev/null 2>&1; then
  NIVA="نيفا"
elif [ -x "$HOME/.local/bin/نيفا" ]; then
  NIVA="$HOME/.local/bin/نيفا"
else
  echo "ثنائي نيفا غير موجود — شغّل أولا: sh tools/تمهيد.sh"
  exit 1
fi

cd "$(dirname "$0")/.."
passed=0
failed=0

for test in tests/unit/اختبار-*.نيفا tests/integration/اختبار-*.نيفا tests/recovery/اختبار-*.نيفا; do
  [ -e "$test" ] || continue
  for mode in "" "--مفسر"; do
    if [ -z "$mode" ]; then
      mode_name="المترجم"
    else
      mode_name="المفسر"
    fi
    if "$NIVA" $mode "$test" 2>/dev/null | grep -qx "ناجح"; then
      echo "ناجح: $test ($mode_name)"
      passed=$((passed + 1))
    else
      echo "فاشل: $test ($mode_name)"
      failed=$((failed + 1))
    fi
  done
done

echo "النتيجة: $passed ناجح، $failed فاشل"
if [ "$failed" -gt 0 ]; then
  exit 1
fi
