#!/bin/sh
URL="https://raw.githubusercontent.com/necronicle/z2k/refs/heads/z2k-enhanced/files/lists/tcp16_nets.txt"
OUTPUT="ipset_as.list"

echo "Скачивание и обработка списка сетей..."
curl -s "$URL" | awk '!/^#/ && !/:/ && NF>=2 {print $2}' > "$OUTPUT"
echo "Готово! файл: $OUTPUT"
