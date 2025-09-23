#!/bin/bash
# -----------------------------
# filter.sh
# Filtra procesos según:
#   -c <cpu_min>   : uso mínimo de CPU (%)
#   -m <mem_min>   : uso mínimo de MEM (%)
#   -r <regex>     : regex para el nombre de comando
# -----------------------------


while getopts "c:m:r:" opt; do
  case "$opt" in
    c) CPU_MIN=$OPTARG ;;
    m) MEM_MIN=$OPTARG ;;
    r) REGEX=$OPTARG ;;
  esac
done

while read -r ts pid uid comm cpu mem; do
  if (( $(echo "$cpu >= $CPU_MIN" | bc -l) )) \
     && (( $(echo "$mem >= $MEM_MIN" | bc -l) )) \
     && [[ "$comm" =~ $REGEX ]]; then
    echo "$ts $pid $uid $comm $cpu $mem"
  fi
done
