#!/bin/bash

# -----------------------------
# preprocess.sh
# Valida y normaliza la salida de generator.sh
# Opciones:
#   --iso8601 : convierte el timestamp UNIX a formato ISO 8601
# -----------------------------

ISO8601=false
if [[ "$1" == "--iso8601" ]]; then
  ISO8601=true
fi

while read -r line; do

  # Usamos awk para extraer los campos desde atrás (CPU y MEM siempre son los últimos dos números)
  ts=$(awk '{print $1}' <<< "$line")
  pid=$(awk '{print $2}' <<< "$line")
  uid=$(awk '{print $3}' <<< "$line")
  cpu=$(awk '{print $(NF-1)}' <<< "$line")
  mem=$(awk '{print $NF}' <<< "$line")
  # El comando es todo lo que queda en el medio
  comm=$(awk '{for (i=4; i<=NF-2; i++) printf $i (i<NF-2?OFS:"")}' OFS=" " <<< "$line")


  [[ "$ts" =~ ^[0-9]+$ ]] || continue
  [[ "$pid" =~ ^[0-9]+$ ]] || continue
  [[ "$uid" =~ ^[0-9]+$ ]] || continue
  [[ "$cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
  [[ "$mem" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue

  if $ISO8601; then
    ts=$(date -d @"$ts" +"%Y-%m-%dT%H:%M:%S")
  fi

  echo "$ts $pid $uid $comm $cpu $mem"
done
