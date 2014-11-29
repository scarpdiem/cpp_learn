
define pythonCode
print "hello"
endef


all:
	echo $(shell python -c '$(pythonCode)')

