#!/bin/bash

# -----------------------------
# filter.sh
# Entradas:
#   salida de preprocess.sh conectada por pipe donde cada 
#   linea tiene un formato: ts pid uid comm cpu mem.
#   adicionalmente los parametros de:
#   -c <cpu_min>, -m <mem_min>, [-r <regex>]
# Salidas:
#   Imprime los datos filtrados con un formato:
#   ts, pid, uid, comm, %cpu y %mem
# Descripción:
#   Filtra procesos según los parámetros. 
#   -c y -m son obligatorios, -r es opcional.
# -----------------------------

# ----------------------------- 
# Función: validarNumero 
# Entradas: 
#   numero entero o flotante 
# Salidas: 
#   error en caso de que no sea valido 
# Descripción: 
#   valida que un numero sea positivo incluyendo el 0 
#   si no cumple muestra mensaje de error 
# -----------------------------
validarNumero() {
  local num="$1"
  if ! [[ "$num" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: '$num' no es un número válido (se requiere entero o decimal positivo)" >&2
    exit 1
  fi
}

# -----------------------------
# Función: parsearEntrada
# Entradas:
#   linea por linea generada por preprocess.sh
# Salidas:
#   ts, pid, uid, comm, %cpu y %mem
#   como variable que luego se filtrara
# Descripción:
#   parsea la entrada (linea) de texto, con el fin de descomponerlo
#   en variables que se puedan filtrar
# -----------------------------
parsearEntrada() {
  local line="$1"
  # separar los campos  en varriables para verificar
  ts=$(awk '{print $1}' <<< "$line")
  pid=$(awk '{print $2}' <<< "$line")
  uid=$(awk '{print $3}' <<< "$line")
  cpu=$(awk '{print $(NF-1)}' <<< "$line")
  mem=$(awk '{print $NF}' <<< "$line")
  comm=$(awk '{for (i=4; i<=NF-2; i++) printf $i (i<NF-2?OFS:"")}' OFS=" " <<< "$line")

  echo "$ts|$pid|$uid|$comm|$cpu|$mem"
}

# -----------------------------
# Función: filtrarDatos
# Entradas:
#   linea por linea de texto generada por preprocess.sh
# Salidas:
#   ts, pid, uid, comm, %cpu y %mem
# Descripción:
#   filtra las variables parseadas con los criterios de 
#   cpu, mem, y regex o nombre
# -----------------------------
filtrarDatos() {
  local ts="$1"
  local pid="$2"
  local uid="$3"
  local comm="$4"
  local cpu="$5"
  local mem="$6"

  if (( $(echo "$cpu >= $CPU_MIN" | bc -l) )) \
     && (( $(echo "$mem >= $MEM_MIN" | bc -l) )) \
     && [[ "$comm" =~ $REGEX ]]; then
    echo "$ts $pid $uid $comm $cpu $mem"
  fi
}

# -----------------------------
# Función principal: main
# -----------------------------
main() {
  CPU_MIN="0"
  MEM_MIN="0"
  REGEX=".*"   # por defecto coincide con todo

  # Parsear parámetros
  while getopts "c:m:r:" opt; do
    case "$opt" in
      c) validarNumero "$OPTARG"; CPU_MIN=$OPTARG ;;
      m) validarNumero "$OPTARG"; MEM_MIN=$OPTARG ;;
      r) REGEX=$OPTARG ;;
      *) echo "Uso: $0 -c cpu_min -m mem_min [-r regex]" >&2; exit 1 ;;
    esac
  done

  # parsear y filtrar linea por linea
  while read -r line; do
    linea=$(parsearEntrada "$line")
    IFS="|" read -r ts pid uid comm cpu mem <<< "$linea"
    filtrarDatos "$ts" "$pid" "$uid" "$comm" "$cpu" "$mem"
  done
}

# Ejecutar programa
main "$@"

