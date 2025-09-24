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

while read -r line; do

  # Usamos awk para extraer los campos desde atrás (CPU y MEM siempre son los últimos dos números)
  ts=$(awk '{print $1}' <<< "$line")
  pid=$(awk '{print $2}' <<< "$line")
  uid=$(awk '{print $3}' <<< "$line")
  cpu=$(awk '{print $(NF-1)}' <<< "$line")
  mem=$(awk '{print $NF}' <<< "$line")
  # El comando es todo lo que queda en el medio
  comm=$(awk '{for (i=4; i<=NF-2; i++) printf $i (i<NF-2?OFS:"")}' OFS=" " <<< "$line")

  if (( $(echo "$cpu >= $CPU_MIN" | bc -l) )) \
     && (( $(echo "$mem >= $MEM_MIN" | bc -l) )) \
     && [[ "$comm" =~ $REGEX ]]; then
    echo "$ts $pid $uid $comm $cpu $mem"
  fi

done