#!/bin/bash
# -----------------------------
# aggregate.sh
# Entradas: Recibe el ts, pid, uid, comm, cpu y mem
# Salida: agrupa los comandos con metricas de la forma:
# comando, num_procesos, cpu_prom, cpu_max, mem_prom y mem_max
# Descripción: Hace el calculo de las metricas para luego agrupar por comandos
# -----------------------------

if [[ $# -ne 0 ]]; then
  echo "Esta funcion no acepta argumentos de entrada"
  exit
fi

awk '
{
  comm=$4
  cpu= $5
  mem= $6

  count[comm]++
  sum_cpu[comm]+=cpu
  sum_mem[comm]+=mem

  if (cpu > max_cpu[comm]) max_cpu[comm]=cpu
  if (mem > max_mem[comm]) max_mem[comm]=mem
}
END {
  for (c in count) {
    avg_cpu = sum_cpu[c]/count[c]
    avg_mem = sum_mem[c]/count[c]
    printf "%s %d %.2f %.2f %.2f %.2f\n", c, count[c], avg_cpu, max_cpu[c], avg_mem, max_mem[c]
  }
}'
