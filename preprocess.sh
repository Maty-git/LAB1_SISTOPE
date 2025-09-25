#!/bin/bash

# -----------------------------
# preprocess.sh
# Entradas:
#   salida de generator.sh conectada por pipe donde cada 
#   linea tiene un formato: ts pid uid comm cpu mem
# Salidas:
#   Imprime los datos pre-procesados con un formato:
#   ts, pid, uid, comm, %cpu y %mem
# Descripción:
#   valida formatos y tipos de datos para su posterior filtrado.
#   adicionalmente se puede convertir el timestamp a ISO8601 
#   escribiendo "--iso8601" luego de "./preprocess.sh"
# -----------------------------

# -----------------------------
# Función: conFormatoIso
# Entradas:
#   líneas de texto generadas por generator.sh
# Salidas:
#   ts convertido a ISO8601 junto con pid, uid, comm, cpu y mem
# Descripción:
#   valida que cada campo tenga el formato correcto y convierte 
#   el timestamp en formato UNIX a ISO8601
# -----------------------------
conFormatoIso() {
  local salida=""
  # separar los campos  en varriables para verificar
  while read -r line; do
    ts=$(awk '{print $1}' <<< "$line")
    pid=$(awk '{print $2}' <<< "$line")
    uid=$(awk '{print $3}' <<< "$line")
    cpu=$(awk '{print $(NF-1)}' <<< "$line")
    mem=$(awk '{print $NF}' <<< "$line")
    comm=$(awk '{for (i=4; i<=NF-2; i++) printf $i (i<NF-2?OFS:"")}' OFS=" " <<< "$line")
    #verificacion
    [[ "$ts" =~ ^[0-9]+$ ]] || continue
    [[ "$pid" =~ ^[0-9]+$ ]] || continue
    [[ "$uid" =~ ^[0-9]+$ ]] || continue
    [[ "$cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    [[ "$mem" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    #cambio de formato
    ts=$(date -d @"$ts" +"%Y-%m-%dT%H:%M:%S")

    salida+="$ts $pid $uid $comm $cpu $mem"$'\n'
  done
  echo "$salida"
}
# -----------------------------
# Función: sinFormatoIso
# Entradas:
#   líneas de texto generadas por generator.sh
# Salidas:
#   ts en formato UNIX junto con pid, uid, comm, cpu y mem
# Descripción:
#   valida que cada campo tenga el formato correcto pero no 
#   transforma el timestamp
# -----------------------------
sinFormatoIso() {
  local salida=""
  # separar los campos  en varriables para verificar
  while read -r line; do
    ts=$(awk '{print $1}' <<< "$line")
    pid=$(awk '{print $2}' <<< "$line")
    uid=$(awk '{print $3}' <<< "$line")
    cpu=$(awk '{print $(NF-1)}' <<< "$line")
    mem=$(awk '{print $NF}' <<< "$line")
    comm=$(awk '{for (i=4; i<=NF-2; i++) printf $i (i<NF-2?OFS:"")}' OFS=" " <<< "$line")
    #verificacion
    [[ "$ts" =~ ^[0-9]+$ ]] || continue
    [[ "$pid" =~ ^[0-9]+$ ]] || continue
    [[ "$uid" =~ ^[0-9]+$ ]] || continue
    [[ "$cpu" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    [[ "$mem" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    #se mantiene el formato de ts
    salida+="$ts $pid $uid $comm $cpu $mem"$'\n'
  done
  echo "$salida"
}

# -----------------------------
# Función principal main
# -----------------------------
main() {
  if [[ "$1" == "--iso8601" ]]; then
    salida=$(conFormatoIso)
  else
    salida=$(sinFormatoIso)
  fi

  # saca lo que se a filtrado
  printf "%s\n" "$salida"
}

main "$@"