#!/bin/bash
# Entradas: stdin de aggregate.sh
# Flags: -o archivo
# Salida: CSV con metadatos

while getopts "o:" opt; do
  case $opt in
    o) OUT=$OPTARG ;;
  esac
done

{
  echo "#generated_at: $(date -Iseconds)"
  echo "#user: $USER"
  echo "#host: $(hostname)"
  echo "COMANDO NUM_PROCESOS CPU_PROM CPU_MAX MEM_PROM MEM_MAX"
  cat
} > "$OUT"
