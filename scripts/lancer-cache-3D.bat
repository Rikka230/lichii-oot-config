@echo off
rem Lance Lichii en priorite haute sur les 12 premiers threads (bloc de coeurs avec le cache 3D
rem sur un Ryzen 9 7900X3D/7950X3D). Windows ne reconnait pas l'emulateur comme un jeu et le
rem promene sinon entre les deux blocs, ce qui provoque des a-coups.
rem 7950X3D : remplacer FFF par FFFF (16 threads). 7800X3D/9800X3D (un seul bloc) : inutile.
start "" /high /affinity FFF "%~dp0lichii.exe" %*
