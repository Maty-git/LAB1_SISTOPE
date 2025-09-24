#!/bin/bash
# -----------------------------
# aggregate.sh
# Entradas:
#   stdin en formato: ts pid uid comm cpu mem
# Salida:
#   stdout agrupado por comm con métricas:
#   comando, num_procesos, cpu_prom, cpu_max, mem_prom, mem_max
# -----------------------------

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
