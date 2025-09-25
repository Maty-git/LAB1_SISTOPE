#!/bin/bash

# -----------------------------
# generator.sh
# Entradas:
#   -i <intervalo> : cada cuántos segundos capturar
#   -t <tiempo>    : tiempo total de captura
# Salidas:
#   Imprime en stdout (para usar con pipes)
#   las líneas con ts, pid, uid, comm, %cpu y %mem
# Descripción:
#   Recolecta datos del sistema usando ps en intervalos definidos
#   hasta que se cumple el tiempo total
# -----------------------------

# -----------------------------
# Función: validador
# Entradas:
#   variables $intervalo y $total
# Salidas:
#   número de iteraciones (entero positivo)
# Descripción:
#   valida que los parámetros -i y -t sean enteros positivos,
#   que tengan una division lógica y retorna cuántas veces se debe
#   ejecutar ps
# -----------------------------
validador() {
  local re_num='^[0-9]+$'

  # Validar que sean números enteros
  if ! [[ "$intervalo" =~ $re_num && "$total" =~ $re_num ]]; then
      echo "Los parámetros -i y -t deben ser enteros positivos" >&2
      exit 1
  fi

  # Validar rangos lógicos
  if [[ "$intervalo" -lt 1 || "$total" -lt "$intervalo" ]]; then
      echo "Los parámetros no son válidos: -i >= 1 y -t >= -i" >&2
      exit 1
  fi

  # Calcular iteraciones y retornarlas
  echo $((total / intervalo))
}

# -----------------------------
# Función: ejecutarPs
# Entradas:
#   número de iteraciones
# Salidas:
#   en cada iteración captura procesos con:
#   ts, pid, uid, comm, %cpu y %mem
# Descripción:
#   ejecuta ps en intervalos definidos, anteponiendo el timestamp
#   UNIX actual en cada línea
# -----------------------------
ejecutarPs() {
  local iteraciones=$1

  for ((n=0; n<iteraciones; n++)); do
    TIMESTAMP=$(date +%s)

    ps -eo pid=,uid=,comm=,pcpu=,pmem= --sort=-%cpu \
    | awk -v ts="$TIMESTAMP" '{print ts, $0}'

    sleep "$intervalo"
  done
}

# -----------------------------
# Función principal main
# -----------------------------
main() {
  # Leer parámetros
  while getopts "i:t:" opt; do
    case $opt in
      i) intervalo=$OPTARG ;;
      t) total=$OPTARG ;;
      *) echo "Uso: $0 -i <intervalo> -t <tiempo>" >&2; exit 1 ;;
    esac
  done

  # Validar y calcular iteraciones
  local iteraciones
  iteraciones=$(validador)

  # Ejecutar ps con los parámetros validados
  ejecutarPs "$iteraciones"
}

# Llamar a main con todos los argumentos
main "$@"
