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
  # Separar campos: timestamp pid uid comm cpu mem
  # Usamos awk para no perder espacios en 'comm'
  ts=$(awk '{print $1}' <<< "$line")
  pid=$(awk '{print $2}' <<< "$line")
  uid=$(awk '{print $3}' <<< "$line")
  comm=$(awk '{print $4}' <<< "$line")
  cpu=$(awk '{print $5}' <<< "$line")
  mem=$(awk '{print $6}' <<< "$line")

  # Validaciones básicas
  [[ "$ts" =~ ^[0-9]+$ ]] || continue
  [[ "$pid" =~ ^[0-9]+$ ]] || continue
  [[ "$uid" =~ ^[0-9]+$ ]] || continue
  [[ "$cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
  [[ "$mem" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue

  # Conversión de timestamp si corresponde
  if $ISO8601; then
    ts=$(date -d @"$ts" +"%Y-%m-%dT%H:%M:%S")
  fi

  # Imprimir limpio
  echo "$ts $pid $uid $comm $cpu $mem"
done
