.PHONY: all clean flash
CHIP ?= 4

all: foo.elf

foo.elf: foo.S
	avr-gcc -Os -nostdlib -mmcu=attiny$(CHIP) -o $@ $<
	avr-size -C --mcu=attiny$(CHIP) $@

flash: foo.elf
	avrdude -cusbasp -Pusb -pt$(CHIP) -Uflash:w:$<:e

clean:
	rm -f foo.elf
