SUBDIRS := event_providers/cpu_load event_providers/memory_pressure
OPTIONAL := menus

all:
	@for dir in $(SUBDIRS); do \
		if [ -d $$dir ]; then \
			$(MAKE) -C $$dir >/dev/null; \
		fi; \
	done
	@for dir in $(OPTIONAL); do \
		if [ -d $$dir ]; then \
			$(MAKE) -C $$dir >/dev/null; \
		fi; \
	done
