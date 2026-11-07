# RAM_SIZE - builds the .TOS executables
#
# Requires GNU binutils for m68k (Debian/Ubuntu: binutils-m68k-linux-gnu).
# The tool prefix can be overridden: make CROSS=m68k-atari-mint-

CROSS   ?= m68k-linux-gnu-
AS      := $(CROSS)as
OBJCOPY := $(CROSS)objcopy
ASFLAGS := -m68000 --register-prefix-optional -I src

SIZES   := 512 1024 2048 2560 4096 14336
TARGETS := $(foreach s,$(SIZES),bin/$(s)_KB.TOS)

all: $(TARGETS)

bin/%_KB.TOS: src/%.s src/ram_size.s
	@mkdir -p bin build
	$(AS) $(ASFLAGS) -o build/$*.o $<
	$(OBJCOPY) -O binary -j .text build/$*.o $@

clean:
	rm -rf build $(TARGETS)

.PHONY: all clean
.SECONDARY:
