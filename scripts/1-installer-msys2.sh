#!/usr/bin/env bash
# Installe dans MSYS2 (environnement UCRT64) tout ce qu'il faut pour compiler Lichii comme Frizti :
# clang/LLVM 23, Qt 6, les bibliotheques du projet et le FFmpeg de MSYS2 (avec le decodeur AV1 libdav1d).
# A lancer depuis un terminal "MSYS2 UCRT64". La premiere mise a jour ferme le terminal :
# relancez simplement le script une seconde fois.
set -euo pipefail
pacman -Syu --noconfirm
pacman -S --needed --noconfirm git make autoconf libtool automake-wrapper patch jq ninja \
  mingw-w64-ucrt-x86_64-toolchain mingw-w64-ucrt-x86_64-clang mingw-w64-ucrt-x86_64-lld \
  mingw-w64-ucrt-x86_64-llvm mingw-w64-ucrt-x86_64-llvm-tools \
  mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-python-pip \
  mingw-w64-ucrt-x86_64-qt6-base mingw-w64-ucrt-x86_64-qt6-charts mingw-w64-ucrt-x86_64-qt6-tools \
  mingw-w64-ucrt-x86_64-qt6-translations mingw-w64-ucrt-x86_64-qt6-svg \
  mingw-w64-ucrt-x86_64-openssl mingw-w64-ucrt-x86_64-boost mingw-w64-ucrt-x86_64-fmt \
  mingw-w64-ucrt-x86_64-lz4 mingw-w64-ucrt-x86_64-nlohmann-json mingw-w64-ucrt-x86_64-zlib \
  mingw-w64-ucrt-x86_64-zstd mingw-w64-ucrt-x86_64-libiconv \
  mingw-w64-ucrt-x86_64-vulkan-memory-allocator mingw-w64-ucrt-x86_64-vulkan-devel \
  mingw-w64-ucrt-x86_64-glslang mingw-w64-ucrt-x86_64-enet mingw-w64-ucrt-x86_64-opus \
  mingw-w64-ucrt-x86_64-libusb mingw-w64-ucrt-x86_64-unordered_dense mingw-w64-ucrt-x86_64-jbigkit \
  mingw-w64-ucrt-x86_64-xz mingw-w64-ucrt-x86_64-libdeflate mingw-w64-ucrt-x86_64-bzip2 \
  mingw-w64-ucrt-x86_64-lerc mingw-w64-ucrt-x86_64-graphite2 mingw-w64-ucrt-x86_64-libwebp \
  mingw-w64-ucrt-x86_64-libtiff mingw-w64-ucrt-x86_64-brotli mingw-w64-ucrt-x86_64-ccache \
  mingw-w64-ucrt-x86_64-ffmpeg
clang --version | head -1
ffmpeg -hide_banner -decoders 2>/dev/null | grep -i libdav1d
