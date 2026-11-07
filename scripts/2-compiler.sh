#!/usr/bin/env bash
# Telecharge Frizti v3, applique les correctifs de ce depot et compile comme la CI de Frizti
# (clang MinGW + profil eglantine.profdata), sans ThinLTO.
# A lancer depuis un terminal "MSYS2 UCRT64" :  bash 2-compiler.sh /d/lichii
set -euo pipefail
work="${1:-$HOME/lichii}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$work/source"
build="$work/build"
mkdir -p "$work"

if [ ! -d "$src" ]; then
    git clone --depth 1 --branch frizti-v3 https://github.com/Frizti/Lichii.git "$src"
    for patch in "$repo_dir"/correctifs/*.patch; do
        echo "Correctif : $(basename "$patch")"
        git -C "$src" apply "$patch"
    done
fi

profile="-fprofile-use=$(cygpath -m "$src/eglantine.profdata") -Wno-backend-plugin \
  -Wno-profile-instr-unprofiled -Wno-profile-instr-out-of-date"

# YUZU_USE_BUNDLED_FFMPEG=OFF : le FFmpeg que le projet telecharge pour MinGW n'a pas de decodeur
# AV1, et les cinematiques d'Ocarina of Time restent noires. Celui de MSYS2 a libdav1d.
# Pas de ThinLTO : ajoute a la main, il faisait planter le jeu emule au demarrage.
cmake -S "$src" -B "$build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF \
  -DYUZU_TESTS=OFF \
  -DYUZU_CMD=ON \
  -DYUZU_ROOM=OFF \
  -DYUZU_ROOM_STANDALONE=OFF \
  -DYUZU_USE_BUNDLED_QT=OFF \
  -DYUZU_USE_BUNDLED_SDL3=ON \
  -DYUZU_USE_BUNDLED_FFMPEG=OFF \
  -DVulkanHeaders_FORCE_BUNDLED=ON \
  -DVulkanUtilityLibraries_FORCE_BUNDLED=ON \
  -DENABLE_UPDATE_CHECKER=OFF \
  -DUSE_DISCORD_PRESENCE=OFF \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld \
  "-DCMAKE_C_FLAGS=$profile" \
  "-DCMAKE_CXX_FLAGS=$profile"
ninja -C "$build" yuzu
echo "Compilation terminee : $build/bin/lichii.exe"
