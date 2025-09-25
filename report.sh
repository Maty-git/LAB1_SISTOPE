#!/bin/bash
# -----------------------------
# Entradas: Recibe las metricas del archivo aggregate.sh
# Salida: un archivo con una extensión .csv o .xlsx
# Descripción: Genera un archivo con la extension especificada, añadiendo tambien la fecha en la que fue generada, el usuario y el host
# -----------------------------

while getopts "o:" opt; do
  case $opt in
    o) OUT=$OPTARG ;;
  esac
done

if [[ -z "$OUT" ]]; then
  echo "Debes especificar un archivo de salida despues del -o"
  exit
fi

if [[ "$OUT" != *.csv || "$OUT" != *.xlsx ]]; then
  echo "Solo se admiten archivos de salida con extensión .csv o .xlsx"
  exit
fi

{
  echo "#generated_at: $(date -Iseconds)"
  echo "#user: $USER"
  echo "#host: $(hostname)"
  echo "COMANDO NUM_PROCESOS CPU_PROM CPU_MAX MEM_PROM MEM_MAX"
  cat
} > "$OUT"
