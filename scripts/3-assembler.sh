#!/usr/bin/env bash
# Assemble un dossier autonome : lichii.exe, Qt, et toutes les DLL de MSYS2 dont ils dependent
# (une centaine, dont avcodec et libdav1d pour les cinematiques).
# A lancer depuis un terminal "MSYS2 UCRT64" :  bash 3-assembler.sh /d/lichii /d/Jeux/Lichii-opti
set -euo pipefail
work="${1:-$HOME/lichii}"
out="${2:-$work/Lichii-opti}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin="$work/build/bin"
mkdir -p "$out"

# Le nx2_switches.txt des sources active EDEN_NX2_FENCE_BATCH=1, qui provoque des flashs blancs :
# on ne le copie pas et on met celui de ce depot.
find "$bin" -maxdepth 1 -type f ! -name nx2_switches.txt -exec cp {} "$out" \;
cp -r "$bin"/plugins/* "$out"/
cp "$repo_dir/config/nx2_switches.txt" "$out"/

for f in "$bin"/lichii.exe "$bin"/*.dll $(find "$bin/plugins" -name "*.dll"); do
    ldd "$f"
done | awk '{print $3}' | grep -i '/ucrt64/' | sort -u | while read -r dll; do
    cp -n "$dll" "$out"/
done

# Mode portable : reglages, cles et sauvegardes iront dans "user" a cote de l'exe.
mkdir -p "$out/user"
echo "Dossier pret : $out"
