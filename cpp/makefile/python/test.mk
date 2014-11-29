
define pythonCode
print "hello"
endef

define PrintMessagePy
print "$(1)"
endef

all:
	@echo $(shell python -c '$(pythonCode)')
	@echo $(shell python -c '$(call PrintMessagePy,hello world)')

