#!/bin/bash

# -----------------------------
# preprocess.sh
# Entradas:
#   salida de generator.sh conectada por pipe donde cada 
#   line tiene un formato: ts pid uid comm cpu mem
# Salidas:
#   Imprime los datos pre-procesados con un formato:
#   ts, pid, uid, comm, %cpu y %mem
# Descripción:
#   valida formatos y tipos de datos para su posterior filtrado
#   adicionalmente se puede convertir el timestamp a ISO8601 
#   escibiendo "--iso8601" luego de "./preprocess.sh"
# -----------------------------

conFormatoIso() {
  local salida=""
  while read -r line; do
    ts=$(awk '{print $1}' <<< "$line")
    pid=$(awk '{print $2}' <<< "$line")
    uid=$(awk '{print $3}' <<< "$line")
    cpu=$(awk '{print $(NF-1)}' <<< "$line")
    mem=$(awk '{print $NF}' <<< "$line")
    comm=$(awk '{for (i=4; i<=NF-2; i++) printf $i (i<NF-2?OFS:"")}' OFS=" " <<< "$line")

    [[ "$ts" =~ ^[0-9]+$ ]] || continue
    [[ "$pid" =~ ^[0-9]+$ ]] || continue
    [[ "$uid" =~ ^[0-9]+$ ]] || continue
    [[ "$cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    [[ "$mem" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue

    ts=$(date -d @"$ts" +"%Y-%m-%dT%H:%M:%S")

    salida+="$ts $pid $uid $comm $cpu $mem"$'\n'
  done
  echo "$salida"
}

sinFormatoIso() {
  local salida=""
  while read -r line; do
    ts=$(awk '{print $1}' <<< "$line")
    pid=$(awk '{print $2}' <<< "$line")
    uid=$(awk '{print $3}' <<< "$line")
    cpu=$(awk '{print $(NF-1)}' <<< "$line")
    mem=$(awk '{print $NF}' <<< "$line")
    comm=$(awk '{for (i=4; i<=NF-2; i++) printf $i (i<NF-2?OFS:"")}' OFS=" " <<< "$line")

    [[ "$ts" =~ ^[0-9]+$ ]] || continue
    [[ "$pid" =~ ^[0-9]+$ ]] || continue
    [[ "$uid" =~ ^[0-9]+$ ]] || continue
    [[ "$cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    [[ "$mem" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue

    salida+="$ts $pid $uid $comm $cpu $mem"$'\n'
  done
  echo "$salida"
}

# Función principal
main() {
  if [[ "$1" == "--iso8601" ]]; then
    salida=$(conFormatoIso)
  else
    salida=$(sinFormatoIso)
  fi

  # Aquí recién imprimes TODO lo que procesó la función
  printf "%s\n" "$salida"
}

main "$@"