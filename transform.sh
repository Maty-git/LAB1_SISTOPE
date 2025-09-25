#!/bin/bash
# -----------------------------
# transform.sh
# Entradas: del pipeline viene ts, pid, uid, comm, cpu y mem, y se utiliza la flag --anon-uid para poder anonimizar el User ID con un hash SHA-256
# Salidas: Imprime en stdout el ts, pid, uid, comm, cpu y mem con el UID anonimizado si es que corresponde
# Descripción: Recibe la flag de --anon-uid y revisa linea por linea hasta llegar al del uid, luego de eso lo anonimiza
# -----------------------------

ANON=false
if [[ "$1" == "--anon-uid" ]]; then
  ANON=true
fi

# Leer línea a línea
while read -r ts pid uid comm cpu mem; do

  if [[ -z "${mem:-}" ]]; then
    echo "Faltan columnas: $ts $pid $uid $comm $cpu $mem"
    continue
  fi


  if $ANON; then

    if [[ -z "$uid" ]]; then
      echo "No hay UID"
      continue
    fi

    # Hash del UID (primeros 8 caracteres de SHA-256)
    uid=$(echo -n "$uid" | sha256sum | awk '{print $1}' | cut -c1-8)
  fi

  echo "$ts $pid $uid $comm $cpu $mem"
done
