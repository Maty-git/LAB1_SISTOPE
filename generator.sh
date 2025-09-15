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

# Valores por defecto
INTERVAL=1
TOTAL=10

# Leer parámetros
while getopts "i:t:" opt; do
  case $opt in
    i) INTERVAL=$OPTARG ;;
    t) TOTAL=$OPTARG ;;
    *) echo "Uso: $0 -i <intervalo> -t <tiempo>" >&2; exit 1 ;;
  esac
done

# Calcular cuántas iteraciones hacer
ITERATIONS=$((TOTAL / INTERVAL))

# Bucle de muestreo
for ((n=0; n<ITERATIONS; n++)); do
  # Capturar timestamp en formato UNIX (segundos)
  TIMESTAMP=$(date +%s)

  # Ejecutar ps y añadir timestamp como primera columna
  ps -eo pid=,uid=,comm=,pcpu=,pmem= --sort=-%cpu \
  | awk -v ts="$TIMESTAMP" '{print ts, $0}'

  # Esperar el intervalo
  sleep "$INTERVAL"
done
