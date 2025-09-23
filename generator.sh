#!/bin/bash

# -----------------------------
# generator.sh
# Entradas:
#   -i <intervalo> : cada cuántos segundos capturar
#   -t <tiempo>    : tiempo total de captura
# Salidas:
#   Imprime en stdout (para que se pueda usar con pipes)
#   las líneas con pid, uid, comm, %cpu y %mem
# Descripción:
#   Recolecta datos del sistema usando ps en intervalos definidos
#   hasta que se cumple el tiempo total.
# -----------------------------


while getopts "i:t:" opt; do
  case $opt in
    i) intervalo=$OPTARG ;;
    t) total=$OPTARG ;;
    *) echo "no se pudo llevar a cabo" >&2; exit 1 ;;
  esac
done

iteraciones=$((total / intervalo))

for ((n=0; n<iteraciones; n++)); do

  TIMESTAMP=$(date +%s)

  ps -eo pid=,uid=,comm=,pcpu=,pmem= --sort=-%cpu \
  | awk -v ts="$TIMESTAMP" '{print ts, $0}'

  sleep "$intervalo"
done
