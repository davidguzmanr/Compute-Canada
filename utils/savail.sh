#!/usr/bin/env bash

printf "%-12s %7s / %-7s\n" "GPU" "Avail" "Total"
echo "================================"

scontrol show nodes -o | awk '
{
    total = used = 0
    type = ""

    if (match($0, /Gres=.*gpu:([^:()=,]+)[=:]([0-9]+)/, a)) {
        type = a[1]
        total = a[2]
    } else {
        next
    }

    if (match($0, /AllocTRES=.*gres\/gpu[^=]*=([0-9]+)/, b)) {
        used = b[1]
    } else {
        used = 0
    }

    avail = total - used
    total_gpu[type] += total
    avail_gpu[type] += avail
}
END {
    for (g in total_gpu)
        printf "%-12s %7d / %-7d\n", g, avail_gpu[g], total_gpu[g]
}'