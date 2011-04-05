TARGET = pong.sfc
TARGET_SPC = pong.spc
ASM_OBJ = pong.obj
ASM_SPC_OBJ = pong_spc.obj
ASM_SRC = pong.asm
ASM_SPC_SRC = pong_spc.s
ASM_ALL_SRC = $(wildcard *.asm)
ASM_ALL_INC = $(wildcard *.inc)

WLA_65816 = wla-65816
WLA_SPC700 = wla-spc700
WLA_LINK = wlalink
WLA_LDFILE = pong.ld
WLA_LDFILE_SPC = pong_spc.ld

all: $(TARGET)

$(TARGET): $(ASM_OBJ) $(WLA_LDFILE)
	$(WLA_LINK) -vr $(WLA_LDFILE) $@

$(TARGET_SPC): $(ASM_SPC_OBJ) $(WLA_LDFILE_SPC)
	$(WLA_LINK) -vr $(WLA_LDFILE_SPC) $@

%.obj: %.s
	$(WLA_SPC700) -o $< $@

%.obj: %.asm $(ASM_ALL_SRC) $(ASM_ALL_INC) $(TARGET_SPC)
	$(WLA_65816) -o $< $@


clean:
	rm -f $(TARGET)
	rm -f $(TARGET_SPC)
	rm -f $(ASM_OBJ)
	rm -f $(ASM_SPC_OBJ)

.PHONY: clean
