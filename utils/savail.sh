#!/usr/bin/env bash
# Summarize GPU availability per GPU type across the cluster.
#   Total   = GPUs configured on all nodes of that type
#   Used    = GPUs currently allocated to jobs
#   Offline = GPUs on nodes that are DOWN / DRAIN / NOT_RESPONDING (not schedulable)
#   Avail   = Total - Used - Offline

printf "%-12s %7s %7s %7s %7s\n" "GPU" "Avail" "Used" "Offline" "Total"
echo "============================================"

scontrol show nodes -o | awk '
{
    cfg = alloc = state = ""
    # Pick fields by name instead of regex-searching the whole line:
    # a greedy "Gres=.*gpu:" would otherwise match the gres/gpu entry
    # inside AllocTRES at the end of the line.
    for (i = 1; i <= NF; i++) {
        if      ($i ~ /^CfgTRES=/)   cfg   = substr($i, 9)
        else if ($i ~ /^AllocTRES=/) alloc = substr($i, 11)
        else if ($i ~ /^State=/)     state = substr($i, 7)
    }
    if (cfg !~ /gres\/gpu/) next

    offline = (state ~ /DOWN|DRAIN|NOT_RESPONDING|FAIL|POWER/)

    # Configured GPUs: gres/gpu:<type>=N (typed) or gres/gpu=N (untyped total)
    delete ntype; ntypes = 0; untyped_total = 0
    n = split(cfg, parts, ",")
    for (i = 1; i <= n; i++) {
        if (match(parts[i], /^gres\/gpu:([^=]+)=([0-9]+)$/, m)) {
            total_gpu[m[1]] += m[2]
            if (offline) offline_gpu[m[1]] += m[2]
            ntype[++ntypes] = m[1]
        } else if (match(parts[i], /^gres\/gpu=([0-9]+)$/, m)) {
            untyped_total = m[1]
        }
    }
    if (ntypes == 0 && untyped_total > 0) {
        total_gpu["gpu"] += untyped_total
        if (offline) offline_gpu["gpu"] += untyped_total
        ntype[++ntypes] = "gpu"
    }

    # Allocated GPUs: prefer typed entries; fall back to the untyped count
    # when the node has exactly one GPU type.
    if (offline) next
    typed_alloc = 0; untyped_alloc = 0
    n = split(alloc, parts, ",")
    for (i = 1; i <= n; i++) {
        if (match(parts[i], /^gres\/gpu:([^=]+)=([0-9]+)$/, m)) {
            used_gpu[m[1]] += m[2]
            typed_alloc = 1
        } else if (match(parts[i], /^gres\/gpu=([0-9]+)$/, m)) {
            untyped_alloc = m[1]
        }
    }
    if (!typed_alloc && untyped_alloc > 0 && ntypes == 1)
        used_gpu[ntype[1]] += untyped_alloc
}
END {
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (g in total_gpu) {
        avail = total_gpu[g] - used_gpu[g] - offline_gpu[g]
        printf "%-12s %7d %7d %7d %7d\n", g, avail, used_gpu[g], offline_gpu[g], total_gpu[g]
    }
}'
