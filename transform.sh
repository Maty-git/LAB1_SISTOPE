#!/bin/bash
# -----------------------------
# transform.sh
# Entradas:
#   stdin en formato: ts pid uid comm cpu mem
# Flags:
#   --anon-uid : reemplaza el UID real por un hash SHA-256 corto
# Salida:
#   Imprime en stdout las líneas con UID transformado (si corresponde)
# -----------------------------

ANON=false
if [[ "$1" == "--anon-uid" ]]; then
  ANON=true
fi

# Leer línea a línea
while read -r ts pid uid comm cpu mem; do
  if $ANON; then
    # Hash del UID (primeros 8 caracteres de SHA-256)
    uid=$(echo -n "$uid" | sha256sum | awk '{print $1}' | cut -c1-8)
  fi

  echo "$ts $pid $uid $comm $cpu $mem"
done
