#!/usr/bin/env python3
"""Headless test of RAM_SIZE under Hatari.

Usage: hatari_test.py <prog.TOS> <tos.img> <machine> <memsize> [limit_hex]

Runs the program from the AUTO folder of the emulated GEMDOS hard disk,
presses a key every 3 s for $DURATION s (default 60), then reads phystop
($42e) after the reset. Exit code 0 if phystop equals the expected limit
(or is unchanged when no limit is given).
"""
import os, re, shutil, socket, subprocess, sys, tempfile, time

prg, tos, machine, memsize = sys.argv[1:5]
expect = int(sys.argv[5], 16) if len(sys.argv) > 5 else None
DURATION = int(os.environ.get("DURATION", 60))  # seconds (real time)

work = tempfile.mkdtemp(prefix="ramsize-")
hd = os.path.join(work, "hd")
os.makedirs(os.path.join(hd, "AUTO"))
shutil.copy(prg, os.path.join(hd, "AUTO", "RAMSIZE.PRG"))
sock_path = os.path.join(work, "ctl.sock")
srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
srv.bind(sock_path)
srv.listen(1)

env = dict(os.environ, SDL_VIDEODRIVER="dummy", SDL_AUDIODRIVER="dummy",
           HOME=work)
cmd = ["hatari", "--configfile", "/dev/null", "--machine", machine,
       "--tos", tos, "--memsize", memsize, "--harddrive", hd,
       "--sound", "off", "--fast-boot", "off", "--confirm-quit", "off",
       "--conout", "2", "--log-level", "error", "--control-socket", sock_path]
if machine in ("tt", "falcon"):
    cmd += ["--cpulevel", "3"]
out = open(os.path.join(work, "out.txt"), "w+")
p = subprocess.Popen(cmd, stdout=out, stderr=subprocess.STDOUT, env=env)
srv.settimeout(20)
conn, _ = srv.accept()

def send(s):
    conn.sendall((s + "\n").encode())
    time.sleep(0.5)

def phystop():
    send("hatari-debug m $42e-$432")
    time.sleep(1)
    out.flush(); out.seek(0)
    vals = re.findall(r"0000042E: ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2})",
                      out.read(), re.I)
    return int("".join(vals[-1]), 16) if vals else None

time.sleep(5)
before = phystop()
# Press space every 3 s: presses before the wait are eaten by the buffer
# flush, presses after the reset have no effect.
t0 = time.time()
while time.time() - t0 < DURATION:
    if not os.environ.get("NOKEY"):        # NOKEY=1: check that it waits
        send("hatari-event keypress 57")
    time.sleep(2.5)
after = phystop()
p.kill(); p.wait()
out.seek(0)
log = out.read()
shutil.rmtree(work, ignore_errors=True)

txt = re.sub(r"\x1b.", "", log)
print("--- console ---")
print("\n".join(l for l in txt.splitlines() if l.strip() and not l.startswith("0000042E")))
print("--- phystop before=%s after=%s" % (before and hex(before), after and hex(after)))
want = expect if expect is not None else before
ok = after == want
print("OK" if ok else "FAIL (expected %s)" % hex(want))
sys.exit(0 if ok else 1)
