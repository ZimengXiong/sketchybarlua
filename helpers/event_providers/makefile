all:
	(cd cpu_load && $(MAKE))
	(cd memory_pressure && $(MAKE))

clean:
	(cd cpu_load && $(MAKE) clean)
	(cd memory_pressure && $(MAKE) clean)
	rm -rf bin/

.PHONY: all clean
