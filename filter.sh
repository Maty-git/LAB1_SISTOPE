#!/bin/bash
# -----------------------------
# filter.sh
# Filtra procesos según:
#   -c <cpu_min>   : uso mínimo de CPU (%)
#   -m <mem_min>   : uso mínimo de MEM (%)
#   -r <regex>     : regex para el nombre de comando
# -----------------------------

CPU_MIN=0
MEM_MIN=0
REGEX=".*"   # por defecto acepta todo

usage() {
  echo "Uso: $0 -c <cpu_min> -m <mem_min> -r <regex>" >&2
  exit 1
}

# Parseo de flags
while getopts "c:m:r:" opt; do
  case "$opt" in
    c) CPU_MIN=$OPTARG ;;
    m) MEM_MIN=$OPTARG ;;
    r) REGEX=$OPTARG ;;
    *) usage ;;
  esac
done

# Leer stdin línea a línea
while read -r ts pid uid comm cpu mem; do
  # Validar que cpu y mem sean números válidos
  if ! [[ "$cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    continue
  fi
  if ! [[ "$mem" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    continue
  fi

  # Comparar con umbrales y regex
  if (( $(echo "$cpu >= $CPU_MIN" | bc -l) )) \
     && (( $(echo "$mem >= $MEM_MIN" | bc -l) )) \
     && [[ "$comm" =~ $REGEX ]]; then
    echo "$ts $pid $uid $comm $cpu $mem"
  fi
done
