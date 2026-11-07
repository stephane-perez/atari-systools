# RAM_SIZE

Limite la quantité de ST-RAM vue par le TOS, pour faire tourner les vieux jeux
et démos (disquettes autoexécutables) qui n'aiment pas avoir trop de mémoire.
Reprend le principe de MEMLIMIT (1997).

Il y a un exécutable par limite, dans `bin/` :

| Programme      | Limite  | phystop    |
|----------------|---------|------------|
| `512_KO.TOS`   | 512 Ko  | `$080000`  |
| `1024_KO.TOS`  | 1 Mo    | `$100000`  |
| `2048_KO.TOS`  | 2 Mo    | `$200000`  |
| `2560_KO.TOS`  | 2,5 Mo  | `$280000`  |
| `4096_KO.TOS`  | 4 Mo    | `$400000`  |
| `14336_KO.TOS` | 14 Mo   | `$E00000`  |

## Fonctionnement

1. Le programme affiche le message d'information.
2. Si la machine a déjà au plus la mémoire demandée, il rend la main
   (c'est aussi ce qui se passe quand il est relancé après le reset, par
   exemple depuis le dossier `AUTO`).
3. Sinon il affiche le message de reboot, vide le buffer clavier puis attend
   l'appui d'une touche.
4. Il écrit la limite dans `phystop` (`$42E`) et saute au vecteur de reset
   du TOS. Les variables `memvalid`/`memval2` restent valides, donc ce reset
   « à chaud » ne redimensionne pas la mémoire : le TOS garde `phystop` et
   place l'écran juste en dessous.

Pour retrouver toute la mémoire, il faut éteindre puis rallumer la machine.

## Construction

Il faut les GNU binutils pour m68k (Debian/Ubuntu : `binutils-m68k-linux-gnu`).

```bash
make
```

Le code est dans `src/ram_size.s`. Chaque fichier `src/<taille>.s` définit
`LIMIT` et le texte de la taille, puis inclut `ram_size.s`. Pour ajouter une
limite, il suffit de créer un nouveau `src/<taille>.s` et de l'ajouter à
`SIZES` dans le `Makefile`.

## Tests

`test/hatari_test.py` lance un programme sous [Hatari](https://hatari.tuxfamily.org/)
sans affichage, appuie sur une touche et vérifie `phystop` après le reset
(les images TOS ne sont pas fournies) :

```bash
python3 test/hatari_test.py bin/1024_KO.TOS tos104.img megast 4 100000
```

Arguments : programme, image TOS, machine Hatari, mémoire en Mo, puis
`phystop` attendu en hexadécimal (s'il est omis, `phystop` ne doit pas
changer). `NOKEY=1` vérifie qu'aucun reset n'a lieu sans appui sur une touche.

Testé sous Hatari 2.4.1 :

| TOS  | Machine  | RAM    | Programme      | phystop après    |
|------|----------|--------|----------------|------------------|
| 1.04 | Mega ST  | 4 Mo   | `512_KO.TOS`   | 512 Ko           |
| 1.04 | Mega ST  | 4 Mo   | `1024_KO.TOS`  | 1 Mo             |
| 1.04 | ST       | 2 Mo   | `1024_KO.TOS`  | 1 Mo             |
| 1.04 | Mega ST  | 1 Mo   | `4096_KO.TOS`  | 1 Mo (inchangé)  |
| 1.62 | STE      | 4 Mo   | `512_KO.TOS`   | 512 Ko           |
| 1.62 | STE      | 4 Mo   | `2560_KO.TOS`  | 2,5 Mo           |
| 1.62 | STE      | 4 Mo   | `4096_KO.TOS`  | 4 Mo (inchangé)  |
| 2.06 | Mega STE | 4 Mo   | `1024_KO.TOS`  | 1 Mo             |
| 2.06 | Mega STE | 4 Mo   | `2048_KO.TOS`  | 2 Mo             |
| 4.04 | Falcon   | 14 Mo  | `512_KO.TOS`   | 512 Ko           |
| 4.04 | Falcon   | 4 Mo   | `2048_KO.TOS`  | 2 Mo             |
| 4.04 | Falcon   | 14 Mo  | `4096_KO.TOS`  | 4 Mo             |
| 4.04 | Falcon   | 14 Mo  | `14336_KO.TOS` | 14 Mo (inchangé) |

Pas encore testé sur du vrai matériel.
