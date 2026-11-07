# RAM_SIZE - construction des executables .TOS
#
# Necessite GNU binutils pour m68k (Debian/Ubuntu : binutils-m68k-linux-gnu).
# Prefixe surchargeable : make CROSS=m68k-atari-mint-

CROSS   ?= m68k-linux-gnu-
AS      := $(CROSS)as
OBJCOPY := $(CROSS)objcopy
ASFLAGS := -m68000 --register-prefix-optional -I src

SIZES   := 512 1024 2048 2560 4096 14336
TARGETS := $(foreach s,$(SIZES),bin/$(s)_KO.TOS)

all: $(TARGETS)

bin/%_KO.TOS: src/%.s src/ram_size.s
	@mkdir -p bin build
	$(AS) $(ASFLAGS) -o build/$*.o $<
	$(OBJCOPY) -O binary -j .text build/$*.o $@

clean:
	rm -rf build $(TARGETS)

.PHONY: all clean
.SECONDARY:
