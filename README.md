# Ocarina of Time (Switch 2) sur Lichii : 60 images/s, cinématiques synchronisées, sans flashs blancs

Ce dépôt regroupe la configuration qui nous a donné la meilleure expérience avec **The Legend of Zelda: Ocarina of Time** (Switch 2, `0400486024DEC000`) sur PC Windows, à partir de [Frizti v3](https://github.com/Frizti/Lichii/releases/tag/frizti-v3) :

- trois correctifs de code à appliquer sur Frizti v3 ;
- les scripts pour recompiler comme Frizti (clang + profil d'optimisation) ;
- quelques réglages.

Il ne contient **aucun exécutable, aucune clé, aucun firmware et aucun jeu**. Il vous faut vos propres `prod.keys` / `title.keys` et votre propre copie du jeu.

## Résultats

Machine de test : Ryzen 9 7900X3D, RTX 4080 SUPER, 32 Go, Windows 11, écran 1440p 240 Hz, mode Docked.

| Version | Images/s en jeu | Cinématique d'intro | Flashs blancs |
|---|---|---|---|
| Frizti v3 officielle | 50 à 60 | son en avance sur l'image | oui, quand la caméra bouge |
| zortos293 build 95 | 30, chutes à 19 | — | — |
| Frizti v3 + correctifs, compilée avec Visual Studio | 40 à 48 | synchronisée | non |
| **Frizti v3 + correctifs, compilée comme Frizti (ce dépôt)** | **60 stables** | **synchronisée** | **non** |

Ce sont les mesures d'une seule machine, lues dans `eden_log.txt` (lignes `Host pacing on`). Elles peuvent varier chez vous.

## Les correctifs

Ils s'appliquent sur le tag `frizti-v3` (commit `72e5ad6c22`), dans cet ordre.

1. **`0001-son-cinematiques-PR251.patch`** : reprise telle quelle de [zortos293/Lichii#251](https://github.com/zortos293/Lichii/pull/251) par **SinCuri0** (pas encore fusionnée au moment où nous écrivons). Le jeu prend une image de la vidéo par image affichée ; sous 60 images/s, la vidéo ralentit alors que le son avance en temps réel. Le correctif saute les images de la vidéo arrivées en retard. Il ne concerne qu'Ocarina of Time.
2. **`0002-flashs-blancs-PR215-attente-limitee.patch`** : portage à la main de [zortos293/Lichii#215](https://github.com/zortos293/Lichii/pull/215) par **WeslieDE**, lui-même construit sur [#204](https://github.com/zortos293/Lichii/pull/204) par **vouion**. Quand la caméra bouge, le jeu lit les résultats d'occlusion (le nombre de pixels visibles) avant que la carte graphique ait fini de les écrire, et le feuillage ou le terrain apparaissent surexposés. Frizti v3 croit attendre ces résultats, mais en mode GPU « Fast », l'attente rend la main tout de suite. Le correctif attend vraiment. **Notre ajout :** l'attente est limitée à 100 ms. Sans limite, l'émulateur ne pouvait plus se fermer (« Emulation thread failed to stop ») : à l'arrêt, plus rien ne venait débloquer l'attente.
3. **`0003-mingw-dwmapi.patch`** : `vk_host_pacer.cpp` demande la bibliothèque `dwmapi` avec `#pragma comment(lib)`, que seul le compilateur de Microsoft comprend. Sous clang MinGW, la compilation échoue. Le correctif réserve la directive à MSVC et ajoute `dwmapi` dans CMake pour MinGW.

## Compiler

Il faut [MSYS2](https://www.msys2.org/) et environ 8 Go de libre. Ouvrez un terminal **MSYS2 UCRT64**, puis :

```bash
git clone https://github.com/Rikka230/lichii-oot-config.git
cd lichii-oot-config/scripts
bash 1-installer-msys2.sh        # la première mise à jour ferme le terminal : relancez-le une 2e fois
bash 2-compiler.sh /d/lichii     # environ 1 h sur un 7900X3D
bash 3-assembler.sh /d/lichii /d/Jeux/Lichii-opti
```

Ces scripts reprennent les commandes que nous avons utilisées, mais ils n'ont pas été rejoués tels quels de bout en bout sur une machine vierge. Signalez-nous ce qui coince.

Deux pièges que les scripts évitent :

- **Cinématiques noires :** pour MinGW, le projet télécharge un FFmpeg sans décodeur AV1. Le journal affiche alors `FFmpeg has no decoder for "video/av1"`. On utilise donc le FFmpeg de MSYS2 (`-DYUZU_USE_BUNDLED_FFMPEG=OFF`), qui contient libdav1d.
- **Pas de ThinLTO :** activé à la main (`-flto=thin`), il faisait planter le jeu émulé quelques secondes après le lancement (`Emulated program broke execution`, écran bloqué sur « Launching »). La recette officielle de Frizti ne l'utilise pas non plus.

Le profil d'optimisation `eglantine.profdata` a été créé avec LLVM 23 et une version MinGW de l'émulateur. Il est illisible pour le clang de Visual Studio (version 22), et une compilation MSVC n'en profiterait pas non plus. D'où la différence de 40-48 à 60 images/s dans le tableau.

## Installer et régler

1. Copiez vos `prod.keys` et `title.keys` dans `Lichii-opti\user\keys\`. Le dossier `user` à côté de l'exécutable active le mode portable : tout reste dans ce dossier.
2. Lancez `lichii.exe` et ajoutez le dossier qui contient votre `.nup`. Le `.nup` se lit directement, il n'y a rien à installer dans la NAND.
3. Dans **Emulation → Configure…** :
   - **GPU Mode : Fast**. C'est le réglage le plus important : « Accurate » fait tomber les images/s.
   - **Console Mode : Docked**.
   - **Enable asynchronous shader compilation** et **asynchronous presentation** : activés.
   - **Memory Layout : 8GB DRAM**. Pour un jeu Switch 2, l'émulateur passe de lui-même à 12 Go.
4. Au premier lancement, Frizti v3 demande 60 ou 30 images/s : choisissez **60** si votre processeur est récent.
5. Copiez `config/nx2_switches.txt` à côté de `lichii.exe` s'il n'y est pas déjà : il désactive le *preflush*, ce qui a réduit les flashs blancs dans nos essais.
6. **Ryzen X3D à deux blocs (7900X3D, 7950X3D) :** lancez l'émulateur avec `scripts/lancer-cache-3D.bat`, copié à côté de `lichii.exe`. Il le cantonne au bloc qui a le cache 3D, en priorité haute. Windows ne reconnaît pas l'émulateur comme un jeu et le fait sinon tourner sur les deux blocs, ce qui provoque des à-coups.

La première partie compile les shaders, avec des à-coups et parfois des flashs pendant le premier passage dans chaque zone. Ils disparaissent quand le cache est rempli.

## Ce qui n'a pas marché

- `EDEN_NX2_DMA_SNAPSHOT=10` (contrôle des lectures rapides d'occlusion de Frizti) : 0 lecture fausse sur 193 000. Ce n'est pas la cause des flashs.
- `EDEN_NX2_ASYNC_DISCARD=0` (attendre les shaders au lieu de sauter l'objet) : plus de flashs dans la cinématique, mais des figements jusqu'à 1,3 s en jeu.
- Le `nx2_switches.txt` présent dans les sources active `EDEN_NX2_FENCE_BATCH=1`. D'après le code de Frizti, ce regroupement des fences provoque justement des flashs blancs dans Ocarina. Ne le copiez pas.

## Licence et crédits

Les correctifs modifient Lichii / Eden (GPL-3.0-or-later) et suivent la même licence. Merci à Frizti, zortos293, SinCuri0, WeslieDE, vouion, Evil et Dark (Dynamic FPS), ainsi qu'à tous les contributeurs de Lichii et d'Eden.
