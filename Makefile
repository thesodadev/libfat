LIBFAT_MAJOR = 1
LIBFAT_MINOR = 1
LIBFAT_PATCH = 5
VERSTRING = $(LIBFAT_MAJOR).$(LIBFAT_MINOR).$(LIBFAT_PATCH)
VERSION_HEADER_PATH = include/libfatversion.h

BUILD ?= release
SOURCE_DIR = source
INCLUDE_DIR = include
BUILD_DIR = build

CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
AR = arm-none-eabi-gcc-ar

CFLAGS = -g -Wall -O2 \
		 -ffunction-sections \
		 -fdata-sections \
		 -march=armv5te \
		 -mtune=arm946e-s \
		 -fomit-frame-pointer\
		 -ffast-math \
		 -mthumb \
 	   	 -mthumb-interwork \
		 -DARM9 -DNDS \
		 -I $(INCLUDE_DIR)

ARFLAGS = -rcs

ifneq ($(BUILD),debug)
	BIN_NAME = libfat.a
else
	BIN_NAME = libfatd.a
	CFLAGS += -DFAT_DEBUG
endif

BIN_PATH = $(BUILD_DIR)/$(BIN_NAME)
SRC_FILES = $(wildcard $(SOURCE_DIR)/*.c)
OBJ_FILES = $(patsubst %,$(BUILD_DIR)/%,$(addsuffix .o,$(basename $(notdir $(SRC_FILES)))))

.PHONY: all rebuild clean install path_builder

all: path_builder $(BIN_PATH)
rebuild: clean all

clean:
	rm -fr $(BUILD_DIR) $(VERSION_HEADER_PATH)

path_builder:
	mkdir -p $(BUILD_DIR)

PREFIX ?= /usr/lib

install:
	install -d $(DESTDIR)$(PREFIX)/arm-none-eabi/include
	cp -f include/fat.h $(DESTDIR)$(PREFIX)/arm-none-eabi/include
	chmod -R 644 $(DESTDIR)$(PREFIX)/arm-none-eabi/include/fat.h
	install -d $(DESTDIR)$(PREFIX)/arm-none-eabi/lib
	install -m 644 $(BIN_PATH) $(DESTDIR)$(PREFIX)/arm-none-eabi/lib

$(BIN_PATH): $(VERSION_HEADER_PATH) $(OBJ_FILES)
	$(AR) $(ARFLAGS) $(BIN_PATH) $(OBJ_FILES)

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(VERSION_HEADER_PATH):
	@echo "#pragma once" > $@
	@echo >> $@
	@echo "#define _LIBFAT_MAJOR_ $(LIBFAT_MAJOR)" >> $@
	@echo "#define _LIBFAT_MINOR_ $(LIBFAT_MINOR)" >> $@
	@echo "#define _LIBFAT_PATCH_ $(LIBFAT_PATCH)" >> $@
	@echo >> $@
	@echo '#define _LIBFAT_STRING "libFAT Release '$(LIBFAT_MAJOR).$(LIBFAT_MINOR).$(LIBFAT_PATCH)'"' >> $@
	@echo >> $@
