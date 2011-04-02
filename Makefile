TARGET = pong.sfc
ASM_OBJ = pong.obj
ASM_SRC = pong.asm
ASM_ALL_SRC = $(wildcard *.asm)

WLA_65816 = wla-65816
WLA_LINK = wlalink
WLA_LDFILE = pong.ld

all: $(TARGET)

$(TARGET): $(ASM_OBJ) $(WLA_LDFILE)
	$(WLA_LINK) -vr $(WLA_LDFILE) $@

%.obj: %.asm $(ASM_ALL_SRC)
	$(WLA_65816) -o $< $@

clean:
	rm -f $(TARGET)
	rm -f $(ASM_OBJ)

.PHONY: clean
