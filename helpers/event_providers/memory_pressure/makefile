TARGET=../bin/memory_pressure

.PHONY: all clean

all: $(TARGET)

$(TARGET): memory_pressure.c ../sketchybar.h
	clang -std=c99 -O3 memory_pressure.c -o $(TARGET)

clean:
	rm -f $(TARGET)
