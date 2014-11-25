
REQUIRE_CURDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

REQUIRE_INC += $(REQUIRE_CURDIR)/src
REQUIRE_LIB += $(REQUIRE_CURDIR)/bin/librlib.a

# This library is built from source

require_build: $(REQUIRE_CURDIR)/bin/librlib.a
$(REQUIRE_CURDIR)/bin/librlib.a:
	$(MAKE) -C $(REQUIRE_CURDIR)/src

require_clean: $(REQUIRE_CURDIR)/clean
$(REQUIRE_CURDIR)/clean:
	$(MAKE) -C $(REQUIRE_CURDIR)/src clean

