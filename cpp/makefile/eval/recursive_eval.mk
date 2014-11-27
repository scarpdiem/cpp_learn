
# make -f recursive_eval.mk

COUNT:=

define func
COUNT := $$(COUNT)a
$$(eval $$(if $$(findstring aaaaa,$$(COUNT)),,$$(call func)))
endef

$(eval $(call func))

all:
	@echo $(COUNT)
	@echo all


