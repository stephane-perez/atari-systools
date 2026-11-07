# RAM_SIZE

Limits the amount of ST-RAM seen by TOS, to run old games and demos (auto-boot
floppies) that do not like having too much memory. Based on the same idea as
MEMLIMIT (1997).

There is one executable per limit, in `bin/`:

| Program        | Limit   | phystop    |
|----------------|---------|------------|
| `512_KB.TOS`   | 512 KB  | `$080000`  |
| `1024_KB.TOS`  | 1 MB    | `$100000`  |
| `2048_KB.TOS`  | 2 MB    | `$200000`  |
| `2560_KB.TOS`  | 2.5 MB  | `$280000`  |
| `4096_KB.TOS`  | 4 MB    | `$400000`  |
| `14336_KB.TOS` | 14 MB   | `$E00000`  |

## How it works

1. If the machine already has at most the requested amount of memory, the
   program quits silently. This is also what happens when it runs again
   after the reset, e.g. from the `AUTO` folder.
2. Otherwise it displays `Your machine will be limited to <size>` /
   `Press any key to reboot`, flushes the keyboard buffer and waits for a key.
3. It writes the limit to `phystop` (`$42E`) and jumps to the TOS reset
   vector. The `memvalid`/`memval2` system variables are still valid, so this
   warm reset does not size the memory again: TOS keeps `phystop` and puts
   the screen just below it.

To get all the memory back, switch the machine off and on again.

## Building

Requires GNU binutils for m68k (Debian/Ubuntu: `binutils-m68k-linux-gnu`).

```bash
make
```

The code is in `src/ram_size.s`. Each `src/<size>.s` file defines `LIMIT` and
the size text, then includes `ram_size.s`. To add a limit, create a new
`src/<size>.s` and add it to `SIZES` in the `Makefile`.

## Tests

`test/hatari_test.py` runs a program headless under
[Hatari](https://hatari.tuxfamily.org/), presses a key and checks `phystop`
after the reset (TOS images are not provided):

```bash
python3 test/hatari_test.py bin/1024_KB.TOS tos104.img megast 4 100000
```

Arguments: program, TOS image, Hatari machine type, memory in MB, then the
expected `phystop` in hex (if omitted, `phystop` must stay unchanged).
`NOKEY=1` checks that no reset happens without a key press.

Tested with Hatari 2.4.1:

| TOS  | Machine  | RAM    | Program        | phystop after    |
|------|----------|--------|----------------|------------------|
| 1.04 | Mega ST  | 4 MB   | `512_KB.TOS`   | 512 KB           |
| 1.04 | Mega ST  | 4 MB   | `1024_KB.TOS`  | 1 MB             |
| 1.04 | ST       | 2 MB   | `1024_KB.TOS`  | 1 MB             |
| 1.04 | Mega ST  | 1 MB   | `4096_KB.TOS`  | 1 MB (unchanged) |
| 1.62 | STE      | 4 MB   | `512_KB.TOS`   | 512 KB           |
| 1.62 | STE      | 4 MB   | `2560_KB.TOS`  | 2.5 MB           |
| 1.62 | STE      | 4 MB   | `4096_KB.TOS`  | 4 MB (unchanged) |
| 2.06 | Mega STE | 4 MB   | `1024_KB.TOS`  | 1 MB             |
| 2.06 | Mega STE | 4 MB   | `2048_KB.TOS`  | 2 MB             |
| 4.04 | Falcon   | 14 MB  | `512_KB.TOS`   | 512 KB           |
| 4.04 | Falcon   | 4 MB   | `2048_KB.TOS`  | 2 MB             |
| 4.04 | Falcon   | 14 MB  | `4096_KB.TOS`  | 4 MB             |
| 4.04 | Falcon   | 14 MB  | `14336_KB.TOS` | 14 MB (unchanged) |

Not tested on real hardware yet.
