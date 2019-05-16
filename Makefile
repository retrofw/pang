CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC  := $(CROSS_COMPILE)gcc

SYSROOT := $(shell $(CC) --print-sysroot)
SDL_CFLAGS := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

CFLAGS += -DPC_VERSION -DRES320X240 $(SDL_CFLAGS)

all: pang

pang : src/main.o src/structures.o src/ball.o src/collisions.o src/plateforme.o src/player.o src/ladder.o src/bonus.o src/shoot.o src/objets.o src/levels.o src/PCGfxEngine.o src/PCSoundEngine.o
	$(CC) -lSDL -lSDL_gfx -lSDL_mixer -lSDL_image -o pang/pang.elf src/main.o src/structures.o src/ball.o src/collisions.o src/plateforme.o src/player.o src/ladder.o src/bonus.o src/shoot.o src/objets.o src/levels.o src/PCGfxEngine.o src/PCSoundEngine.o

.c.o: 
	$(CC) $(CFLAGS) -c $*.c -o $*.o 

ipk: pang
	@rm -rf /tmp/.pang-ipk/ && mkdir -p /tmp/.pang-ipk/root/home/retrofw/games/pang /tmp/.pang-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r pang/pang.elf pang/pang.png pang/romdisk /tmp/.pang-ipk/root/home/retrofw/games/pang
	@cp pang/pang.lnk /tmp/.pang-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" pang/control > /tmp/.pang-ipk/control
	@cp pang/conffiles /tmp/.pang-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.pang-ipk/control.tar.gz -C /tmp/.pang-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.pang-ipk/data.tar.gz -C /tmp/.pang-ipk/root/ .
	@echo 2.0 > /tmp/.pang-ipk/debian-binary
	@ar r pang/pang.ipk /tmp/.pang-ipk/control.tar.gz /tmp/.pang-ipk/data.tar.gz /tmp/.pang-ipk/debian-binary

clean:
	rm -rf src/*.o pang/pang.elf *~ pang/pang.ipk

.PHONY: clean pang
